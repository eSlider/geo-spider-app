# Geo Spider App - MAUI Integration Guide

Since MAUI is not available in the current environment, this guide shows how to integrate the completed Geo Spider core logic into a MAUI Android application.

## Prerequisites for MAUI Development

To build the actual APK, you need:

1. **Development Environment**:
   - Windows 10/11, macOS, or Linux with GUI support
   - Visual Studio 2022 (Windows) or Visual Studio Code
   - Android SDK and JDK

2. **MAUI Setup**:
   ```bash
   dotnet workload install maui
   dotnet workload install android
   ```

3. **Android Development Tools**:
   - Android SDK (API 21+)
   - Android Emulator or physical device
   - JDK 11+

## Project Structure for MAUI Integration

```
GeoSpiderApp.MAUI/
├── GeoSpiderApp.MAUI.csproj          # MAUI project file
├── Platforms/
│   └── Android/
│       ├── MainActivity.cs          # Android platform code
│       ├── MainApplication.cs       # Android app class
│       └── Services/
│           ├── AndroidLocationProvider.cs    # Android GPS implementation
│           ├── AndroidDataStore.cs          # Android storage implementation
│           ├── AndroidNetworkConnectivity.cs # Android connectivity
│           └── AndroidHttpClient.cs         # Android HTTP client
├── MauiProgram.cs                   # MAUI app configuration
├── App.xaml                         # Main app XAML
├── App.xaml.cs                      # Main app code-behind
└── MainPage.xaml                    # Main UI page

GeoSpiderApp.Core/                   # Our completed core logic
└── [All our existing files]
```

## Integration Steps

### 1. Create MAUI Project
```bash
dotnet new maui -n GeoSpiderApp.MAUI
cd GeoSpiderApp.MAUI
dotnet add reference ../GeoSpiderApp.Core/GeoSpiderApp.Core.csproj
```

### 2. Implement Platform Services

#### Android Location Provider
```csharp
// Platforms/Android/Services/AndroidLocationProvider.cs
using GeoSpiderApp.Core.Location;
using Android.Locations;
using Android.Content;

public class AndroidLocationProvider : ILocationProvider
{
    private readonly LocationManager _locationManager;
    private readonly Context _context;

    public AndroidLocationProvider(Context context)
    {
        _context = context;
        _locationManager = (LocationManager)context.GetSystemService(Context.LocationService);
    }

    public async Task<LocationData?> GetCurrentLocationAsync()
    {
        // Implement Android location acquisition
        // Use GPS and GLONASS providers
    }

    public bool IsLocationServiceEnabled()
    {
        return _locationManager.IsProviderEnabled(LocationManager.GpsProvider) ||
               _locationManager.IsProviderEnabled(LocationManager.NetworkProvider);
    }

    public async Task<bool> RequestPermissionsAsync()
    {
        // Request location permissions using MAUI Essentials
        var status = await Permissions.RequestAsync<Permissions.LocationWhenInUse>();
        return status == PermissionStatus.Granted;
    }
}
```

#### Android Data Store
```csharp
// Platforms/Android/Services/AndroidDataStore.cs
using GeoSpiderApp.Core.Background;
using System.Text.Json;

public class AndroidDataStore : IDataStore
{
    private readonly string _dataFile;

    public AndroidDataStore(string dataDirectory)
    {
        _dataFile = Path.Combine(dataDirectory, "location_data.json");
    }

    public async Task StoreLocationDataAsync(LocationData locationData)
    {
        var data = await GetStoredLocationDataAsync();
        data.Add(locationData);
        var json = JsonSerializer.Serialize(data);
        await File.WriteAllTextAsync(_dataFile, json);
    }

    public async Task<IEnumerable<LocationData>> GetStoredLocationDataAsync()
    {
        if (!File.Exists(_dataFile)) return new List<LocationData>();
        var json = await File.ReadAllTextAsync(_dataFile);
        return JsonSerializer.Deserialize<List<LocationData>>(json) ?? new List<LocationData>();
    }

    public async Task CleanOldDataAsync(DateTimeOffset olderThan)
    {
        var data = await GetStoredLocationDataAsync();
        var filtered = data.Where(d => d.Timestamp >= olderThan).ToList();
        var json = JsonSerializer.Serialize(filtered);
        await File.WriteAllTextAsync(_dataFile, json);
    }

    public async Task<int> GetStoredDataCountAsync()
    {
        var data = await GetStoredLocationDataAsync();
        return data.Count();
    }
}
```

### 3. Configure Services in MauiProgram.cs
```csharp
// MauiProgram.cs
using GeoSpiderApp.Core.Configuration;
using GeoSpiderApp.Core.Background;
using GeoSpiderApp.Core.Sync;
using GeoSpiderApp.Core.Location;

public static class MauiProgram
{
    public static MauiApp CreateMauiApp()
    {
        var builder = MauiApp.CreateBuilder();
        builder.UseMauiApp<App>();

        // Register platform-specific services
        builder.Services.AddSingleton<ILocationProvider, AndroidLocationProvider>();
        builder.Services.AddSingleton<IDataStore, AndroidDataStore>();
        builder.Services.AddSingleton<INetworkConnectivity, AndroidNetworkConnectivity>();
        builder.Services.AddSingleton<IHttpClientWrapper, AndroidHttpClient>();

        // Register core services
        builder.Services.AddSingleton<ILocationService, LocationService>();
        builder.Services.AddSingleton<GeoSpiderBackgroundService>();
        builder.Services.AddSingleton<DataSyncService>();

        // Load configuration
        var config = ConfigurationLoader.LoadFromFile("config.yaml");
        builder.Services.AddSingleton(config);

        return builder.Build();
    }
}
```

### 4. Implement Background Service
```csharp
// In MainActivity.cs or App.xaml.cs
protected override void OnCreate(Bundle? savedInstanceState)
{
    base.OnCreate(savedInstanceState);

    // Start background service
    var backgroundService = MauiApplication.Current.Services.GetService<GeoSpiderBackgroundService>();
    Task.Run(() => backgroundService.StartAsync());
}
```

### 5. Update Android Manifest
```xml
<!-- AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application android:allowBackup="true">
        <service android:name=".GeoSpiderBackgroundService"
                 android:enabled="true"
                 android:exported="false" />
    </application>
</manifest>
```

## Build Commands

Once in a proper MAUI environment:

```bash
# Clean and build
dotnet clean
dotnet restore

# Build for Android
dotnet build --configuration Release --framework net9.0-android

# Build APK
dotnet publish --configuration Release --framework net9.0-android --output ./publish /p:AndroidPackageFormat=apk

# Build and install on connected device
dotnet build --configuration Release --framework net9.0-android
dotnet run --framework net9.0-android
```

## Testing on Device

1. Connect Android device or start emulator
2. Enable developer options and USB debugging
3. Run: `dotnet run --framework net9.0-android`

## Configuration

The app uses `config.yaml` for configuration:

```yaml
serverUrl: https://your-api-endpoint.com/locations
collectionIntervalSeconds: 30
syncBatchSize: 100
maxOfflineStorageDays: 7
```

## Summary

The core business logic is complete and tested. MAUI integration requires:
1. Proper MAUI development environment
2. Platform-specific service implementations
3. Android manifest permissions
4. Background service registration

All the heavy lifting (TDD, architecture, testing) is done - MAUI integration is the final step!</content>
</xai:function_call">Create MAUI integration guide