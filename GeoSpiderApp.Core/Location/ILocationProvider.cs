namespace GeoSpiderApp.Core.Location;

/// <summary>
/// Interface for location providers (GPS, GLONASS, etc.)
/// </summary>
public interface ILocationProvider
{
    /// <summary>
    /// Gets the current location asynchronously
    /// </summary>
    /// <returns>Location data or null if location cannot be determined</returns>
    Task<LocationData?> GetCurrentLocationAsync();

    /// <summary>
    /// Checks if location services are enabled
    /// </summary>
    /// <returns>True if location services are enabled, false otherwise</returns>
    bool IsLocationServiceEnabled();

    /// <summary>
    /// Requests location permissions if needed
    /// </summary>
    /// <returns>True if permissions are granted, false otherwise</returns>
    Task<bool> RequestPermissionsAsync();
}