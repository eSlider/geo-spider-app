using GeoSpiderApp.Core.Configuration;
using GeoSpiderApp.Core.Location;

namespace GeoSpiderApp.Core.Background;

/// <summary>
/// Background service that periodically collects location data
/// </summary>
public class GeoSpiderBackgroundService
{
    private readonly ILocationService _locationService;
    private readonly IDataStore _dataStore;
    private readonly AppConfig _config;
    private readonly CancellationTokenSource _cancellationTokenSource;
    private Task? _backgroundTask;
    private readonly TimeSpan _collectionInterval;

    public bool IsRunning { get; private set; }

    public GeoSpiderBackgroundService(
        ILocationService locationService,
        IDataStore dataStore,
        AppConfig config)
    {
        _locationService = locationService ?? throw new ArgumentNullException(nameof(locationService));
        _dataStore = dataStore ?? throw new ArgumentNullException(nameof(dataStore));
        _config = config ?? throw new ArgumentNullException(nameof(config));

        _cancellationTokenSource = new CancellationTokenSource();
        _collectionInterval = TimeSpan.FromSeconds(_config.CollectionIntervalSeconds);
    }

    /// <summary>
    /// Starts the background location collection
    /// </summary>
    public async Task StartAsync()
    {
        if (IsRunning)
        {
            return;
        }

        if (!_locationService.IsLocationServiceEnabled())
        {
            throw new InvalidOperationException("Location services are not enabled");
        }

        IsRunning = true;
        _backgroundTask = Task.Run(() => RunCollectionLoopAsync(_cancellationTokenSource.Token));
    }

    /// <summary>
    /// Stops the background location collection
    /// </summary>
    public async Task StopAsync()
    {
        if (!IsRunning)
        {
            return;
        }

        _cancellationTokenSource.Cancel();

        if (_backgroundTask != null)
        {
            try
            {
                await _backgroundTask.WaitAsync(TimeSpan.FromSeconds(5));
            }
            catch (TimeoutException)
            {
                // Task didn't complete in time, but we'll continue
            }
        }

        IsRunning = false;
    }

    private async Task RunCollectionLoopAsync(CancellationToken cancellationToken)
    {
        while (!cancellationToken.IsCancellationRequested)
        {
            try
            {
                await CollectAndStoreLocationAsync();
                await CleanOldDataIfNeededAsync();
            }
            catch (Exception ex)
            {
                // Log error but continue running
                // In a real app, this would use proper logging
                Console.WriteLine($"Error during location collection: {ex.Message}");
            }

            try
            {
                await Task.Delay(_collectionInterval, cancellationToken);
            }
            catch (TaskCanceledException)
            {
                // Cancellation requested, exit loop
                break;
            }
        }
    }

    private async Task CollectAndStoreLocationAsync()
    {
        try
        {
            var locationData = await _locationService.GetCurrentLocationAsync();
            await _dataStore.StoreLocationDataAsync(locationData);
        }
        catch (LocationException ex)
        {
            // Location collection failed, but don't crash the service
            Console.WriteLine($"Location collection failed: {ex.Message}");
        }
    }

    private async Task CleanOldDataIfNeededAsync()
    {
        try
        {
            var cutoffDate = DateTimeOffset.UtcNow.AddDays(-_config.MaxOfflineStorageDays);
            await _dataStore.CleanOldDataAsync(cutoffDate);
        }
        catch (Exception ex)
        {
            // Data cleanup failed, log but continue
            Console.WriteLine($"Data cleanup failed: {ex.Message}");
        }
    }

    /// <summary>
    /// Gets the current count of stored data points
    /// </summary>
    public async Task<int> GetStoredDataCountAsync()
    {
        return await _dataStore.GetStoredDataCountAsync();
    }
}