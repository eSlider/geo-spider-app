namespace GeoSpiderApp.Core.Location;

/// <summary>
/// Interface for location services
/// </summary>
public interface ILocationService
{
    /// <summary>
    /// Gets the current location
    /// </summary>
    /// <returns>Location data</returns>
    Task<LocationData> GetCurrentLocationAsync();

    /// <summary>
    /// Checks if location services are enabled
    /// </summary>
    /// <returns>True if location services are enabled</returns>
    bool IsLocationServiceEnabled();

    /// <summary>
    /// Requests location permissions
    /// </summary>
    /// <returns>True if permissions are granted</returns>
    Task<bool> RequestPermissionsAsync();
}