namespace GeoSpiderApp.Core.Sync;

/// <summary>
/// Interface for HTTP client operations
/// </summary>
public interface IHttpClientWrapper
{
    /// <summary>
    /// Posts data to the specified URL
    /// </summary>
    /// <param name="url">The URL to post to</param>
    /// <param name="data">The data to post</param>
    /// <returns>True if successful, false otherwise</returns>
    Task<bool> PostAsync(string url, object data);
}