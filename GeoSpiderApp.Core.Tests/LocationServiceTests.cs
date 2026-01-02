using GeoSpiderApp.Core.Location;
using Moq;

namespace GeoSpiderApp.Core.Tests;

public class LocationServiceTests
{
    [Fact]
    public async Task GetCurrentLocation_ValidLocation_ReturnsLocationData()
    {
        // Arrange
        var mockProvider = new Mock<ILocationProvider>();
        var expectedLocation = new LocationData
        {
            Latitude = 40.7128,
            Longitude = -74.0060,
            Accuracy = 10.0,
            Timestamp = DateTimeOffset.UtcNow,
            Provider = "GPS"
        };
        mockProvider.Setup(p => p.GetCurrentLocationAsync())
            .ReturnsAsync(expectedLocation);

        var service = new LocationService(mockProvider.Object);

        // Act
        var result = await service.GetCurrentLocationAsync();

        // Assert
        Assert.NotNull(result);
        Assert.Equal(expectedLocation.Latitude, result.Latitude);
        Assert.Equal(expectedLocation.Longitude, result.Longitude);
        Assert.Equal(expectedLocation.Accuracy, result.Accuracy);
        Assert.Equal(expectedLocation.Provider, result.Provider);
    }

    [Fact]
    public async Task GetCurrentLocation_ProviderFails_ThrowsException()
    {
        // Arrange
        var mockProvider = new Mock<ILocationProvider>();
        mockProvider.Setup(p => p.GetCurrentLocationAsync())
            .ThrowsAsync(new LocationException("GPS not available"));

        var service = new LocationService(mockProvider.Object);

        // Act & Assert
        await Assert.ThrowsAsync<LocationException>(() => service.GetCurrentLocationAsync());
    }

    [Fact]
    public void IsLocationServiceEnabled_ProviderEnabled_ReturnsTrue()
    {
        // Arrange
        var mockProvider = new Mock<ILocationProvider>();
        mockProvider.Setup(p => p.IsLocationServiceEnabled()).Returns(true);

        var service = new LocationService(mockProvider.Object);

        // Act
        var result = service.IsLocationServiceEnabled();

        // Assert
        Assert.True(result);
    }

    [Fact]
    public void IsLocationServiceEnabled_ProviderDisabled_ReturnsFalse()
    {
        // Arrange
        var mockProvider = new Mock<ILocationProvider>();
        mockProvider.Setup(p => p.IsLocationServiceEnabled()).Returns(false);

        var service = new LocationService(mockProvider.Object);

        // Act
        var result = service.IsLocationServiceEnabled();

        // Assert
        Assert.False(result);
    }
}