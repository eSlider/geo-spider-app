using GeoSpiderApp.Core.Location;

namespace GeoSpiderApp.Core.Tests;

public class LocationDataTests
{
    [Fact]
    public void Validate_ValidLocationData_NoExceptionThrown()
    {
        // Arrange
        var location = new LocationData
        {
            Latitude = 40.7128,
            Longitude = -74.0060,
            Accuracy = 10.0,
            Altitude = 100.0,
            Speed = 5.0,
            Bearing = 90.0,
            Timestamp = DateTimeOffset.UtcNow,
            Provider = "GPS"
        };

        // Act & Assert
        location.Validate(); // Should not throw
    }

    [Fact]
    public void Validate_InvalidLatitude_ThrowsArgumentOutOfRangeException()
    {
        // Arrange
        var location = new LocationData
        {
            Latitude = 91.0, // Invalid latitude
            Longitude = -74.0060,
            Timestamp = DateTimeOffset.UtcNow,
            Provider = "GPS"
        };

        // Act & Assert
        Assert.Throws<ArgumentOutOfRangeException>(() => location.Validate());
    }

    [Fact]
    public void Validate_InvalidLongitude_ThrowsArgumentOutOfRangeException()
    {
        // Arrange
        var location = new LocationData
        {
            Latitude = 40.7128,
            Longitude = 181.0, // Invalid longitude
            Timestamp = DateTimeOffset.UtcNow,
            Provider = "GPS"
        };

        // Act & Assert
        Assert.Throws<ArgumentOutOfRangeException>(() => location.Validate());
    }

    [Fact]
    public void Validate_NegativeAccuracy_ThrowsArgumentOutOfRangeException()
    {
        // Arrange
        var location = new LocationData
        {
            Latitude = 40.7128,
            Longitude = -74.0060,
            Accuracy = -1.0, // Invalid accuracy
            Timestamp = DateTimeOffset.UtcNow,
            Provider = "GPS"
        };

        // Act & Assert
        Assert.Throws<ArgumentOutOfRangeException>(() => location.Validate());
    }

    [Fact]
    public void Validate_NullProvider_ThrowsArgumentException()
    {
        // Arrange
        var location = new LocationData
        {
            Latitude = 40.7128,
            Longitude = -74.0060,
            Timestamp = DateTimeOffset.UtcNow,
            Provider = null! // Invalid provider
        };

        // Act & Assert
        Assert.Throws<ArgumentException>(() => location.Validate());
    }

    [Fact]
    public void Validate_EmptyProvider_ThrowsArgumentException()
    {
        // Arrange
        var location = new LocationData
        {
            Latitude = 40.7128,
            Longitude = -74.0060,
            Timestamp = DateTimeOffset.UtcNow,
            Provider = "" // Invalid provider
        };

        // Act & Assert
        Assert.Throws<ArgumentException>(() => location.Validate());
    }
}