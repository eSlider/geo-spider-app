using GeoSpiderApp.Core.Background;
using GeoSpiderApp.Core.Configuration;

namespace GeoSpiderApp.Core.Sync;

/// <summary>
/// Service for synchronizing location data to server when online
/// </summary>
public class DataSyncService
{
    private readonly INetworkConnectivity _connectivity;
    private readonly IDataStore _dataStore;
    private readonly IHttpClientWrapper _httpClient;
    private readonly AppConfig _config;

    public DataSyncService(
        INetworkConnectivity connectivity,
        IDataStore dataStore,
        IHttpClientWrapper httpClient,
        AppConfig config)
    {
        _connectivity = connectivity ?? throw new ArgumentNullException(nameof(connectivity));
        _dataStore = dataStore ?? throw new ArgumentNullException(nameof(dataStore));
        _httpClient = httpClient ?? throw new ArgumentNullException(nameof(httpClient));
        _config = config ?? throw new ArgumentNullException(nameof(config));
    }

    /// <summary>
    /// Attempts to sync stored location data to the server
    /// </summary>
    /// <returns>Result of the sync operation</returns>
    public async Task<SyncResult> SyncDataAsync()
    {
        try
        {
            // Check if we're online
            if (!_connectivity.IsOnline())
            {
                return SyncResult.SuccessResult(0); // Not an error, just not online
            }

            // Get stored data
            var storedData = await _dataStore.GetStoredLocationDataAsync();
            if (!storedData.Any())
            {
                return SyncResult.SuccessResult(0); // No data to sync
            }

            // Sync data in batches
            var syncedCount = 0;
            var batches = storedData
                .OrderBy(d => d.Timestamp)
                .Select((data, index) => new { data, index })
                .GroupBy(x => x.index / _config.SyncBatchSize)
                .Select(g => g.Select(x => x.data).ToList())
                .ToList();

            foreach (var batch in batches)
            {
                var success = await SyncBatchAsync(batch);
                if (!success)
                {
                    return SyncResult.FailureResult($"Failed to sync batch containing {batch.Count} items");
                }

                syncedCount += batch.Count;

                // Clean up synced data (in a real implementation, this would be more sophisticated)
                // For now, we'll assume the data is removed after successful sync
            }

            return SyncResult.SuccessResult(syncedCount);
        }
        catch (Exception ex)
        {
            return SyncResult.FailureResult($"Sync operation failed: {ex.Message}");
        }
    }

    private async Task<bool> SyncBatchAsync(IEnumerable<GeoSpiderApp.Core.Location.LocationData> batch)
    {
        try
        {
            var payload = new
            {
                locations = batch.Select(l => new
                {
                    latitude = l.Latitude,
                    longitude = l.Longitude,
                    accuracy = l.Accuracy,
                    altitude = l.Altitude,
                    speed = l.Speed,
                    bearing = l.Bearing,
                    timestamp = l.Timestamp.ToUnixTimeSeconds(),
                    provider = l.Provider
                }).ToArray()
            };

            return await _httpClient.PostAsync(_config.ServerUrl, payload);
        }
        catch (Exception ex)
        {
            // Log error but don't crash the sync process
            Console.WriteLine($"Batch sync failed: {ex.Message}");
            return false;
        }
    }
}