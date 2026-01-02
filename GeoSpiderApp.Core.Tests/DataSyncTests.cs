using GeoSpiderApp.Core.Sync;
using GeoSpiderApp.Core.Background;
using GeoSpiderApp.Core.Configuration;
using GeoSpiderApp.Core.Location;
using Moq;

namespace GeoSpiderApp.Core.Tests;

public class DataSyncTests
{
    [Fact]
    public async Task SyncData_OnlineWithData_SyncsAndRemovesData()
    {
        // Arrange
        var mockConnectivity = new Mock<INetworkConnectivity>();
        var mockDataStore = new Mock<IDataStore>();
        var mockHttpClient = new Mock<IHttpClientWrapper>();
        var config = new AppConfig
        {
            ServerUrl = "https://api.example.com",
            SyncBatchSize = 2
        };

        var locationData = new List<LocationData>
        {
            new LocationData
            {
                Latitude = 40.7128,
                Longitude = -74.0060,
                Accuracy = 10.0,
                Timestamp = DateTimeOffset.UtcNow,
                Provider = "GPS"
            },
            new LocationData
            {
                Latitude = 40.7129,
                Longitude = -74.0061,
                Accuracy = 10.0,
                Timestamp = DateTimeOffset.UtcNow.AddSeconds(30),
                Provider = "GPS"
            }
        };

        mockConnectivity.Setup(c => c.IsOnline()).Returns(true);
        mockDataStore.Setup(d => d.GetStoredLocationDataAsync())
            .ReturnsAsync(locationData);
        mockHttpClient.Setup(h => h.PostAsync(It.IsAny<string>(), It.IsAny<object>()))
            .ReturnsAsync(true);
        mockDataStore.Setup(d => d.GetStoredDataCountAsync()).ReturnsAsync(2);

        var syncService = new DataSyncService(
            mockConnectivity.Object,
            mockDataStore.Object,
            mockHttpClient.Object,
            config);

        // Act
        var result = await syncService.SyncDataAsync();

        // Assert
        Assert.True(result.Success);
        Assert.Equal(2, result.SyncedCount);
        mockHttpClient.Verify(h => h.PostAsync(It.IsAny<string>(), It.IsAny<object>()),
            Times.AtLeastOnce);
    }

    [Fact]
    public async Task SyncData_Offline_SkipsSync()
    {
        // Arrange
        var mockConnectivity = new Mock<INetworkConnectivity>();
        var mockDataStore = new Mock<IDataStore>();
        var mockHttpClient = new Mock<IHttpClientWrapper>();
        var config = new AppConfig
        {
            ServerUrl = "https://api.example.com",
            SyncBatchSize = 10
        };

        mockConnectivity.Setup(c => c.IsOnline()).Returns(false);

        var syncService = new DataSyncService(
            mockConnectivity.Object,
            mockDataStore.Object,
            mockHttpClient.Object,
            config);

        // Act
        var result = await syncService.SyncDataAsync();

        // Assert
        Assert.True(result.Success);
        Assert.Equal(0, result.SyncedCount);
        mockHttpClient.Verify(h => h.PostAsync(It.IsAny<string>(), It.IsAny<object>()),
            Times.Never);
    }

    [Fact]
    public async Task SyncData_NoStoredData_SkipsSync()
    {
        // Arrange
        var mockConnectivity = new Mock<INetworkConnectivity>();
        var mockDataStore = new Mock<IDataStore>();
        var mockHttpClient = new Mock<IHttpClientWrapper>();
        var config = new AppConfig
        {
            ServerUrl = "https://api.example.com",
            SyncBatchSize = 10
        };

        mockConnectivity.Setup(c => c.IsOnline()).Returns(true);
        mockDataStore.Setup(d => d.GetStoredLocationDataAsync())
            .ReturnsAsync(new List<LocationData>());

        var syncService = new DataSyncService(
            mockConnectivity.Object,
            mockDataStore.Object,
            mockHttpClient.Object,
            config);

        // Act
        var result = await syncService.SyncDataAsync();

        // Assert
        Assert.True(result.Success);
        Assert.Equal(0, result.SyncedCount);
        mockHttpClient.Verify(h => h.PostAsync(It.IsAny<string>(), It.IsAny<object>()),
            Times.Never);
    }

    [Fact]
    public async Task SyncData_ServerError_ReturnsFailure()
    {
        // Arrange
        var mockConnectivity = new Mock<INetworkConnectivity>();
        var mockDataStore = new Mock<IDataStore>();
        var mockHttpClient = new Mock<IHttpClientWrapper>();
        var config = new AppConfig
        {
            ServerUrl = "https://api.example.com",
            SyncBatchSize = 10
        };

        var locationData = new List<LocationData>
        {
            new LocationData
            {
                Latitude = 40.7128,
                Longitude = -74.0060,
                Timestamp = DateTimeOffset.UtcNow,
                Provider = "GPS"
            }
        };

        mockConnectivity.Setup(c => c.IsOnline()).Returns(true);
        mockDataStore.Setup(d => d.GetStoredLocationDataAsync())
            .ReturnsAsync(locationData);
        mockHttpClient.Setup(h => h.PostAsync(It.IsAny<string>(), It.IsAny<object>()))
            .ReturnsAsync(false); // Server error

        var syncService = new DataSyncService(
            mockConnectivity.Object,
            mockDataStore.Object,
            mockHttpClient.Object,
            config);

        // Act
        var result = await syncService.SyncDataAsync();

        // Assert
        Assert.False(result.Success);
        Assert.Equal(0, result.SyncedCount);
        Assert.Contains("Failed to sync", result.ErrorMessage);
    }
}