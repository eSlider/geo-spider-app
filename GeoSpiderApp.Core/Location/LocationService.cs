namespace GeoSpiderApp.Core.Location;

/// <summary>
/// Service for managing location data collection
/// </summary>
public class LocationService
{
    private readonly ILocationProvider _locationProvider;

    public LocationService(ILocationProvider locationProvider)
    {
        _locationProvider = locationProvider ?? throw new ArgumentNullException(nameof(locationProvider));
    }

    /// <summary>
    /// Gets the current location
    /// </summary>
    /// <returns>Location data</returns>
    /// <exception cref="LocationException">Thrown when location cannot be retrieved</exception>
    public async Task<LocationData> GetCurrentLocationAsync()
    {
        try
        {
            var location = await _locationProvider.GetCurrentLocationAsync();
            if (location == null)
            {
                throw new LocationException("Unable to retrieve current location");
            }

            location.Validate();
            return location;
        }
        catch (LocationException)
        {
            throw;
        }
        catch (Exception ex)
        {
            throw new LocationException("Failed to get current location", ex);
        }
    }

    /// <summary>
    /// Checks if location services are enabled
    /// </summary>
    /// <returns>True if location services are enabled</returns>
    public bool IsLocationServiceEnabled()
    {
        return _locationProvider.IsLocationServiceEnabled();
    }

    /// <summary>
    /// Requests location permissions
    /// </summary>
    /// <returns>True if permissions are granted</returns>
    public async Task<bool> RequestPermissionsAsync()
    {
        return await _locationProvider.RequestPermissionsAsync();
    }
}