using GeoSpiderApp.Core.Configuration;
using GeoSpiderApp.Core.Background;
using GeoSpiderApp.Core.Sync;

namespace GeoSpiderApp.MAUI;

public partial class MainPage : ContentPage
{
    private readonly GeoSpiderBackgroundService _backgroundService;
    private readonly DataSyncService _syncService;
    private readonly AppConfig _config;
    private readonly IDataStore _dataStore;

    public MainPage(
        GeoSpiderBackgroundService backgroundService,
        DataSyncService syncService,
        AppConfig config,
        IDataStore dataStore)
    {
        InitializeComponent();

        _backgroundService = backgroundService;
        _syncService = syncService;
        _config = config;
        _dataStore = dataStore;

        // Update UI with configuration
        UpdateConfigurationDisplay();

        // Start periodic UI updates
        StartPeriodicUpdates();
    }

    private void UpdateConfigurationDisplay()
    {
        IntervalLabel.Text = $"{_config.CollectionIntervalSeconds} seconds";
        ServerLabel.Text = _config.ServerUrl;
        BatchSizeLabel.Text = _config.SyncBatchSize.ToString();
    }

    private void StartPeriodicUpdates()
    {
        // Update status every 5 seconds
        Device.StartTimer(TimeSpan.FromSeconds(5), () =>
        {
            MainThread.InvokeOnMainThreadAsync(UpdateStatus);
            return true; // Continue timer
        });
    }

    private async Task UpdateStatus()
    {
        try
        {
            var dataCount = await _dataStore.GetStoredDataCountAsync();

            ServiceStatusLabel.Text = _backgroundService.IsRunning ? "Running" : "Stopped";
            ServiceStatusLabel.TextColor = _backgroundService.IsRunning ? Colors.Green : Colors.Red;

            DataCountLabel.Text = dataCount.ToString();

            // Update button states
            StartButton.IsEnabled = !_backgroundService.IsRunning;
            StopButton.IsEnabled = _backgroundService.IsRunning;
        }
        catch (Exception ex)
        {
            await DisplayAlert("Error", $"Failed to update status: {ex.Message}", "OK");
        }
    }

    private async void OnStartClicked(object sender, EventArgs e)
    {
        try
        {
            await _backgroundService.StartAsync();
            await UpdateStatus();
            await DisplayAlert("Success", "Location service started successfully!", "OK");
        }
        catch (Exception ex)
        {
            await DisplayAlert("Error", $"Failed to start service: {ex.Message}", "OK");
        }
    }

    private async void OnStopClicked(object sender, EventArgs e)
    {
        try
        {
            await _backgroundService.StopAsync();
            await UpdateStatus();
            await DisplayAlert("Success", "Location service stopped successfully!", "OK");
        }
        catch (Exception ex)
        {
            await DisplayAlert("Error", $"Failed to stop service: {ex.Message}", "OK");
        }
    }

    private async void OnSyncClicked(object sender, EventArgs e)
    {
        try
        {
            SyncButton.IsEnabled = false;
            SyncButton.Text = "Syncing...";

            var result = await _syncService.SyncDataAsync();

            if (result.Success)
            {
                await DisplayAlert("Success",
                    $"Successfully synced {result.SyncedCount} location points!", "OK");
            }
            else
            {
                await DisplayAlert("Sync Failed",
                    $"Sync failed: {result.ErrorMessage}", "OK");
            }
        }
        catch (Exception ex)
        {
            await DisplayAlert("Error", $"Sync error: {ex.Message}", "OK");
        }
        finally
        {
            SyncButton.IsEnabled = true;
            SyncButton.Text = "Sync Data Now";
            await UpdateStatus();
        }
    }
}