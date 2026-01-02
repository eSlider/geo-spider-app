namespace GeoSpiderApp.Core.Location;

/// <summary>
/// Represents a geographical location data point
/// </summary>
public class LocationData
{
    /// <summary>
    /// Latitude in decimal degrees (-90 to 90)
    /// </summary>
    public double Latitude { get; set; }

    /// <summary>
    /// Longitude in decimal degrees (-180 to 180)
    /// </summary>
    public double Longitude { get; set; }

    /// <summary>
    /// Accuracy of the location in meters
    /// </summary>
    public double? Accuracy { get; set; }

    /// <summary>
    /// Altitude in meters above sea level
    /// </summary>
    public double? Altitude { get; set; }

    /// <summary>
    /// Speed in meters per second
    /// </summary>
    public double? Speed { get; set; }

    /// <summary>
    /// Bearing (direction of travel) in degrees (0-360)
    /// </summary>
    public double? Bearing { get; set; }

    /// <summary>
    /// Timestamp when this location was recorded
    /// </summary>
    public DateTimeOffset Timestamp { get; set; }

    /// <summary>
    /// Location provider (GPS, GLONASS, Network, etc.)
    /// </summary>
    public string Provider { get; set; } = string.Empty;

    /// <summary>
    /// Validates the location data
    /// </summary>
    public void Validate()
    {
        if (Latitude < -90 || Latitude > 90)
        {
            throw new ArgumentOutOfRangeException(nameof(Latitude), "Latitude must be between -90 and 90 degrees");
        }

        if (Longitude < -180 || Longitude > 180)
        {
            throw new ArgumentOutOfRangeException(nameof(Longitude), "Longitude must be between -180 and 180 degrees");
        }

        if (Accuracy.HasValue && Accuracy.Value < 0)
        {
            throw new ArgumentOutOfRangeException(nameof(Accuracy), "Accuracy must be non-negative");
        }

        if (Altitude.HasValue && Altitude.Value < -10000) // Allow reasonable negative altitudes
        {
            throw new ArgumentOutOfRangeException(nameof(Altitude), "Altitude seems unreasonable");
        }

        if (Speed.HasValue && Speed.Value < 0)
        {
            throw new ArgumentOutOfRangeException(nameof(Speed), "Speed must be non-negative");
        }

        if (Bearing.HasValue && (Bearing.Value < 0 || Bearing.Value > 360))
        {
            throw new ArgumentOutOfRangeException(nameof(Bearing), "Bearing must be between 0 and 360 degrees");
        }

        if (string.IsNullOrWhiteSpace(Provider))
        {
            throw new ArgumentException("Provider cannot be null or empty", nameof(Provider));
        }
    }
}