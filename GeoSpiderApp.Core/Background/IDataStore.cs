using GeoSpiderApp.Core.Location;

namespace GeoSpiderApp.Core.Background;

/// <summary>
/// Interface for storing location data
/// </summary>
public interface IDataStore
{
    /// <summary>
    /// Stores location data asynchronously
    /// </summary>
    /// <param name="locationData">Location data to store</param>
    Task StoreLocationDataAsync(LocationData locationData);

    /// <summary>
    /// Gets all stored location data
    /// </summary>
    /// <returns>Collection of stored location data</returns>
    Task<IEnumerable<LocationData>> GetStoredLocationDataAsync();

    /// <summary>
    /// Removes location data older than the specified date
    /// </summary>
    /// <param name="olderThan">Remove data older than this date</param>
    Task CleanOldDataAsync(DateTimeOffset olderThan);

    /// <summary>
    /// Gets the count of stored location data points
    /// </summary>
    Task<int> GetStoredDataCountAsync();
}