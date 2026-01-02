namespace GeoSpiderApp.Core.Location;

/// <summary>
/// Exception thrown when location operations fail
/// </summary>
public class LocationException : Exception
{
    public LocationException() : base() { }

    public LocationException(string message) : base(message) { }

    public LocationException(string message, Exception innerException)
        : base(message, innerException) { }
}