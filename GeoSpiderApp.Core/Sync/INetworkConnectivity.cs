namespace GeoSpiderApp.Core.Sync;

/// <summary>
/// Interface for checking network connectivity
/// </summary>
public interface INetworkConnectivity
{
    /// <summary>
    /// Checks if the device is online
    /// </summary>
    /// <returns>True if online, false otherwise</returns>
    bool IsOnline();
}