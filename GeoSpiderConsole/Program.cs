using GeoSpiderApp.Core.Configuration;
using GeoSpiderApp.Core.Background;
using GeoSpiderApp.Core.Sync;
using GeoSpiderApp.Core.Location;

// Mock implementations for demonstration
public class MockLocationProvider : ILocationProvider
{
    private int _locationCount = 0;

    public async Task<LocationData?> GetCurrentLocationAsync()
    {
        // Simulate getting location
        await Task.Delay(100); // Simulate GPS delay

        _locationCount++;
        var location = new LocationData
        {
            Latitude = 40.7128 + (_locationCount * 0.001), // Slightly different location each time
            Longitude = -74.0060 + (_locationCount * 0.001),
            Accuracy = 5.0 + (_locationCount % 3), // Varying accuracy
            Altitude = 10.0 + _locationCount,
            Speed = 1.5 + (_locationCount % 2),
            Bearing = _locationCount * 15.0 % 360,
            Timestamp = DateTimeOffset.UtcNow,
            Provider = "MockGPS"
        };

        location.Validate();
        return location;
    }

    public bool IsLocationServiceEnabled() => true;
    public Task<bool> RequestPermissionsAsync() => Task.FromResult(true);
}

public class MockDataStore : IDataStore
{
    private readonly List<LocationData> _data = new();
    private readonly List<LocationData> _syncedData = new();

    public async Task StoreLocationDataAsync(LocationData locationData)
    {
        _data.Add(locationData);
        Console.WriteLine($"📍 Stored location: {locationData.Latitude:F6}, {locationData.Longitude:F6} (Total: {_data.Count})");
    }

    public Task<IEnumerable<LocationData>> GetStoredLocationDataAsync() =>
        Task.FromResult<IEnumerable<LocationData>>(_data);

    public async Task CleanOldDataAsync(DateTimeOffset olderThan)
    {
        var beforeCount = _data.Count;
        _data.RemoveAll(d => d.Timestamp < olderThan);
        var removed = beforeCount - _data.Count;
        if (removed > 0)
            Console.WriteLine($"🗑️ Cleaned up {removed} old location records");
    }

    public Task<int> GetStoredDataCountAsync() => Task.FromResult(_data.Count);

    // Additional methods for demonstration
    public void SimulateSync(int count)
    {
        var toSync = _data.Take(count).ToList();
        _syncedData.AddRange(toSync);
        _data.RemoveRange(0, Math.Min(count, _data.Count));
        Console.WriteLine($"📤 Synced {toSync.Count} locations to server");
    }

    public int GetSyncedCount() => _syncedData.Count;
}

public class MockNetworkConnectivity : INetworkConnectivity
{
    private bool _isOnline = true;
    private int _offlineCount = 0;

    public bool IsOnline()
    {
        // Simulate occasional network issues
        if (_offlineCount > 0)
        {
            _offlineCount--;
            return false;
        }

        // Go offline every 15 checks for 3 checks
        if (new Random().Next(15) == 0)
        {
            _offlineCount = 3;
            Console.WriteLine("📶 Network connection lost!");
            return false;
        }

        return _isOnline;
    }

    public void SetOnline(bool online) => _isOnline = online;
}

public class MockHttpClient : IHttpClientWrapper
{
    private int _failureCount = 0;

    public async Task<bool> PostAsync(string url, object data)
    {
        await Task.Delay(200); // Simulate network delay

        // Simulate occasional server errors
        if (_failureCount < 2 && new Random().Next(10) == 0)
        {
            _failureCount++;
            Console.WriteLine("🚫 Server error - sync failed");
            return false;
        }

        Console.WriteLine($"✅ Successfully sent data to {url}");
        return true;
    }
}

class Program
{
    static async Task Main(string[] args)
    {
        Console.WriteLine("🕷️ Geo Spider Console Demo");
        Console.WriteLine("==========================");
        Console.WriteLine();

        try
        {
            // Load configuration
            Console.WriteLine("⚙️ Loading configuration...");
            var config = ConfigurationLoader.LoadFromFile("config.yaml");
            Console.WriteLine($"✅ Configuration loaded:");
            Console.WriteLine($"   Server: {config.ServerUrl}");
            Console.WriteLine($"   Collection Interval: {config.CollectionIntervalSeconds}s");
            Console.WriteLine($"   Batch Size: {config.SyncBatchSize}");
            Console.WriteLine($"   Offline Retention: {config.MaxOfflineStorageDays} days");
            Console.WriteLine();

            // Initialize services
            Console.WriteLine("🔧 Initializing services...");
            var locationProvider = new MockLocationProvider();
            var dataStore = new MockDataStore();
            var networkConnectivity = new MockNetworkConnectivity();
            var httpClient = new MockHttpClient();

            var locationService = new LocationService(locationProvider);
            var backgroundService = new GeoSpiderBackgroundService(
                locationService, dataStore, config);
            var syncService = new DataSyncService(
                networkConnectivity, dataStore, httpClient, config);

            Console.WriteLine("✅ Services initialized");
            Console.WriteLine();

            // Demonstrate location collection
            Console.WriteLine("📍 Testing location collection...");
            for (int i = 0; i < 5; i++)
            {
                var location = await locationService.GetCurrentLocationAsync();
                await dataStore.StoreLocationDataAsync(location);
                await Task.Delay(500);
            }
            Console.WriteLine();

            // Start background service
            Console.WriteLine("🚀 Starting background location service...");
            await backgroundService.StartAsync();
            Console.WriteLine("✅ Background service started");
            Console.WriteLine();

            // Simulate running for a period
            Console.WriteLine("⏱️ Simulating app running for 30 seconds...");
            Console.WriteLine("   (Location collection every 5 seconds for demo)");

            var startTime = DateTime.Now;
            var lastCollection = DateTime.MinValue;

            while ((DateTime.Now - startTime).TotalSeconds < 30)
            {
                // Simulate periodic sync attempts
                if ((DateTime.Now - startTime).TotalSeconds % 10 < 1)
                {
                    Console.WriteLine();
                    Console.WriteLine("🔄 Attempting data sync...");
                    var result = await syncService.SyncDataAsync();
                    if (result.Success && result.SyncedCount > 0)
                    {
                        Console.WriteLine($"📤 Synced {result.SyncedCount} locations");
                    }
                    else if (!result.Success)
                    {
                        Console.WriteLine($"❌ Sync failed: {result.ErrorMessage}");
                    }
                }

                // Show status every 5 seconds
                if ((DateTime.Now - lastCollection).TotalSeconds >= 5)
                {
                    var count = await dataStore.GetStoredDataCountAsync();
                    Console.Write($"\r📊 Status: {count} locations stored | Running for {(int)(DateTime.Now - startTime).TotalSeconds}s");
                    lastCollection = DateTime.Now;
                }

                await Task.Delay(1000);
            }

            Console.WriteLine();
            Console.WriteLine();

            // Stop background service
            Console.WriteLine("🛑 Stopping background service...");
            await backgroundService.StopAsync();
            Console.WriteLine("✅ Background service stopped");
            Console.WriteLine();

            // Final sync
            Console.WriteLine("🔄 Final data sync...");
            var finalResult = await syncService.SyncDataAsync();
            Console.WriteLine($"📤 Final sync: {finalResult.SyncedCount} locations synced");
            Console.WriteLine();

            // Show final statistics
            var finalCount = await dataStore.GetStoredDataCountAsync();
            Console.WriteLine("📈 Final Statistics:");
            Console.WriteLine($"   Total locations collected: {((MockDataStore)dataStore).GetSyncedCount() + finalCount}");
            Console.WriteLine($"   Locations synced: {((MockDataStore)dataStore).GetSyncedCount()}");
            Console.WriteLine($"   Locations remaining: {finalCount}");
            Console.WriteLine();

            Console.WriteLine("🎉 Geo Spider Demo Complete!");
            Console.WriteLine("   The core business logic is fully functional and ready for MAUI integration!");

        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Error: {ex.Message}");
            Console.WriteLine($"   Stack trace: {ex.StackTrace}");
        }
    }
}
