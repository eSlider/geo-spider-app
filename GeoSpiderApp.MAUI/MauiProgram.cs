using GeoSpiderApp.Core.Configuration;
using GeoSpiderApp.Core.Background;
using GeoSpiderApp.Core.Sync;
using GeoSpiderApp.Core.Location;
using Microsoft.Extensions.Logging;

namespace GeoSpiderApp.MAUI;

public static class MauiProgram
{
    public static MauiApp? CurrentApp { get; private set; }

    public static MauiApp CreateMauiApp()
    {
        var builder = MauiApp.CreateBuilder();
        builder
            .UseMauiApp<App>()
            .ConfigureFonts(fonts =>
            {
                fonts.AddFont("OpenSans-Regular.ttf", "OpenSansRegular");
                fonts.AddFont("OpenSans-Semibold.ttf", "OpenSansSemibold");
            });

#if DEBUG
        builder.Logging.AddDebug();
#endif

        // Register platform-specific services
        // Note: In a real MAUI environment, these would be implemented
        // For now, we'll use mock implementations for demonstration
        builder.Services.AddSingleton<ILocationProvider, MockLocationProvider>();
        builder.Services.AddSingleton<IDataStore, MockDataStore>();
        builder.Services.AddSingleton<INetworkConnectivity, MockNetworkConnectivity>();
        builder.Services.AddSingleton<IHttpClientWrapper, MockHttpClient>();

        // Register core services (our completed business logic)
        builder.Services.AddSingleton<ILocationService, LocationService>();
        builder.Services.AddSingleton<GeoSpiderBackgroundService>();
        builder.Services.AddSingleton<DataSyncService>();

        // Load configuration
        var config = ConfigurationLoader.LoadFromFile("config.yaml");
        builder.Services.AddSingleton(config);

        // Register MainPage with dependency injection
        builder.Services.AddTransient<MainPage>();

        CurrentApp = builder.Build();
        return CurrentApp;
    }
}

// Mock implementations for demonstration (would be replaced with real Android implementations)
public class MockLocationProvider : ILocationProvider
{
    public Task<LocationData?> GetCurrentLocationAsync() =>
        Task.FromResult<LocationData?>(new LocationData
        {
            Latitude = 40.7128,
            Longitude = -74.0060,
            Accuracy = 10.0,
            Timestamp = DateTimeOffset.UtcNow,
            Provider = "MockGPS"
        });

    public bool IsLocationServiceEnabled() => true;
    public Task<bool> RequestPermissionsAsync() => Task.FromResult(true);
}

public class MockDataStore : IDataStore
{
    private readonly List<LocationData> _data = new();

    public Task StoreLocationDataAsync(LocationData locationData)
    {
        _data.Add(locationData);
        return Task.CompletedTask;
    }

    public Task<IEnumerable<LocationData>> GetStoredLocationDataAsync() =>
        Task.FromResult<IEnumerable<LocationData>>(_data);

    public Task CleanOldDataAsync(DateTimeOffset olderThan)
    {
        _data.RemoveAll(d => d.Timestamp < olderThan);
        return Task.CompletedTask;
    }

    public Task<int> GetStoredDataCountAsync() => Task.FromResult(_data.Count);
}

public class MockNetworkConnectivity : INetworkConnectivity
{
    public bool IsOnline() => true;
}

public class MockHttpClient : IHttpClientWrapper
{
    public Task<bool> PostAsync(string url, object data) => Task.FromResult(true);
}