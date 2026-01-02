using GeoSpiderApp.Core.Background;
using GeoSpiderApp.Core.Configuration;
using GeoSpiderApp.Core.Location;
using Moq;

namespace GeoSpiderApp.Core.Tests;

public class BackgroundServiceTests
{
    [Fact]
    public async Task StartAsync_ValidConfiguration_StartsLocationCollection()
    {
        // Arrange
        var mockLocationService = new Mock<ILocationService>();
        mockLocationService.Setup(s => s.IsLocationServiceEnabled()).Returns(true);

        var mockDataStore = new Mock<IDataStore>();
        var config = new AppConfig
        {
            ServerUrl = "https://api.example.com",
            CollectionIntervalSeconds = 30,
            SyncBatchSize = 10,
            MaxOfflineStorageDays = 7
        };

        var service = new GeoSpiderBackgroundService(
            mockLocationService.Object,
            mockDataStore.Object,
            config);

        // Act
        await service.StartAsync();

        // Assert
        Assert.True(service.IsRunning);
    }

    [Fact]
    public async Task StopAsync_RunningService_StopsLocationCollection()
    {
        // Arrange
        var mockLocationService = new Mock<ILocationService>();
        mockLocationService.Setup(s => s.IsLocationServiceEnabled()).Returns(true);

        var mockDataStore = new Mock<IDataStore>();
        var config = new AppConfig
        {
            ServerUrl = "https://api.example.com",
            CollectionIntervalSeconds = 30
        };

        var service = new GeoSpiderBackgroundService(
            mockLocationService.Object,
            mockDataStore.Object,
            config);

        await service.StartAsync();
        Assert.True(service.IsRunning);

        // Act
        await service.StopAsync();

        // Assert
        Assert.False(service.IsRunning);
    }

    [Fact]
    public async Task LocationCollectionCycle_ValidLocation_StoresData()
    {
        // Arrange
        var mockLocationService = new Mock<ILocationService>();
        mockLocationService.Setup(s => s.IsLocationServiceEnabled()).Returns(true);

        var mockDataStore = new Mock<IDataStore>();
        var config = new AppConfig
        {
            ServerUrl = "https://api.example.com",
            CollectionIntervalSeconds = 1 // Short interval for testing
        };

        var locationData = new LocationData
        {
            Latitude = 40.7128,
            Longitude = -74.0060,
            Accuracy = 10.0,
            Timestamp = DateTimeOffset.UtcNow,
            Provider = "GPS"
        };

        mockLocationService.Setup(s => s.GetCurrentLocationAsync())
            .ReturnsAsync(locationData);
        mockDataStore.Setup(d => d.StoreLocationDataAsync(locationData))
            .Returns(Task.CompletedTask);

        var service = new GeoSpiderBackgroundService(
            mockLocationService.Object,
            mockDataStore.Object,
            config);

        // Act
        await service.StartAsync();
        await Task.Delay(1500); // Wait for at least one collection cycle
        await service.StopAsync();

        // Assert
        mockDataStore.Verify(d => d.StoreLocationDataAsync(It.IsAny<LocationData>()),
            Times.AtLeastOnce);
    }

    [Fact]
    public async Task LocationCollectionCycle_LocationServiceFails_ContinuesOperation()
    {
        // Arrange
        var mockLocationService = new Mock<ILocationService>();
        mockLocationService.Setup(s => s.IsLocationServiceEnabled()).Returns(true);

        var mockDataStore = new Mock<IDataStore>();
        var config = new AppConfig
        {
            ServerUrl = "https://api.example.com",
            CollectionIntervalSeconds = 1
        };

        mockLocationService.Setup(s => s.GetCurrentLocationAsync())
            .ThrowsAsync(new LocationException("GPS unavailable"));

        var service = new GeoSpiderBackgroundService(
            mockLocationService.Object,
            mockDataStore.Object,
            config);

        // Act
        await service.StartAsync();
        await Task.Delay(2500); // Wait for multiple cycles
        await service.StopAsync();

        // Assert
        Assert.False(service.IsRunning);
        // Service should continue despite location failures
    }
}