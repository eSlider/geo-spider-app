namespace GeoSpiderApp.Core.Sync;

/// <summary>
/// Result of a data synchronization operation
/// </summary>
public class SyncResult
{
    /// <summary>
    /// Whether the sync operation was successful
    /// </summary>
    public bool Success { get; set; }

    /// <summary>
    /// Number of data points that were successfully synced
    /// </summary>
    public int SyncedCount { get; set; }

    /// <summary>
    /// Error message if the operation failed
    /// </summary>
    public string? ErrorMessage { get; set; }

    /// <summary>
    /// Creates a successful sync result
    /// </summary>
    /// <param name="syncedCount">Number of synced items</param>
    /// <returns>Successful sync result</returns>
    public static SyncResult SuccessResult(int syncedCount = 0)
    {
        return new SyncResult
        {
            Success = true,
            SyncedCount = syncedCount
        };
    }

    /// <summary>
    /// Creates a failed sync result
    /// </summary>
    /// <param name="errorMessage">Error message</param>
    /// <returns>Failed sync result</returns>
    public static SyncResult FailureResult(string errorMessage)
    {
        return new SyncResult
        {
            Success = false,
            ErrorMessage = errorMessage
        };
    }
}