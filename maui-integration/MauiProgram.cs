using GeoSpiderApp.Core.Configuration;
using GeoSpiderApp.Core.Background;
using GeoSpiderApp.Core.Sync;
using GeoSpiderApp.Core.Location;
// Platform-specific implementations would be imported here

public static class MauiProgram
{
    public static MauiApp CreateMauiApp()
    {
        var builder = MauiApp.CreateBuilder();
        builder.UseMauiApp<App>();

        // Register platform-specific services
        // These would be implemented in Platforms/Android/Services/
        builder.Services.AddSingleton<ILocationProvider, AndroidLocationProvider>();
        builder.Services.AddSingleton<IDataStore, AndroidDataStore>();
        builder.Services.AddSingleton<INetworkConnectivity, AndroidNetworkConnectivity>();
        builder.Services.AddSingleton<IHttpClientWrapper, AndroidHttpClient>();

        // Register core services (our completed business logic)
        builder.Services.AddSingleton<ILocationService, LocationService>();
        builder.Services.AddSingleton<GeoSpiderBackgroundService>();
        builder.Services.AddSingleton<DataSyncService>();

        // Load configuration
        var config = ConfigurationLoader.LoadFromFile("config.yaml");
        builder.Services.AddSingleton(config);

        return builder.Build();
    }
}</content>
</xai:function_call">Create sample MauiProgram.cs