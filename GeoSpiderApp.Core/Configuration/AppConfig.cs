namespace GeoSpiderApp.Core.Configuration;

/// <summary>
/// Application configuration loaded from config.yaml
/// </summary>
public class AppConfig
{
    /// <summary>
    /// Server URL for syncing location data
    /// </summary>
    public string ServerUrl { get; set; } = string.Empty;

    /// <summary>
    /// Interval in seconds between location collections
    /// </summary>
    public int CollectionIntervalSeconds { get; set; } = 60;

    /// <summary>
    /// Number of location points to batch before syncing
    /// </summary>
    public int SyncBatchSize { get; set; } = 50;

    /// <summary>
    /// Maximum days to keep offline location data
    /// </summary>
    public int MaxOfflineStorageDays { get; set; } = 7;

    /// <summary>
    /// Validates the configuration
    /// </summary>
    public void Validate()
    {
        if (string.IsNullOrWhiteSpace(ServerUrl))
        {
            throw new ArgumentException("ServerUrl is required");
        }

        if (CollectionIntervalSeconds <= 0)
        {
            throw new ArgumentException("CollectionIntervalSeconds must be positive");
        }

        if (SyncBatchSize <= 0)
        {
            throw new ArgumentException("SyncBatchSize must be positive");
        }

        if (MaxOfflineStorageDays <= 0)
        {
            throw new ArgumentException("MaxOfflineStorageDays must be positive");
        }

        if (!Uri.IsWellFormedUriString(ServerUrl, UriKind.Absolute))
        {
            throw new ArgumentException("ServerUrl must be a valid absolute URL");
        }
    }
}