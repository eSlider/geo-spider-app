using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;

namespace GeoSpiderApp.Core.Configuration;

/// <summary>
/// Loads application configuration from YAML string
/// </summary>
public static class ConfigurationLoader
{
    private static readonly IDeserializer Deserializer = new DeserializerBuilder()
        .WithNamingConvention(CamelCaseNamingConvention.Instance)
        .Build();

    /// <summary>
    /// Loads configuration from YAML string
    /// </summary>
    /// <param name="yamlContent">YAML configuration content</param>
    /// <returns>Parsed and validated AppConfig</returns>
    /// <exception cref="ArgumentException">Thrown when YAML is invalid or required fields are missing</exception>
    public static AppConfig LoadFromYaml(string yamlContent)
    {
        if (string.IsNullOrWhiteSpace(yamlContent))
        {
            throw new ArgumentException("YAML content cannot be null or empty", nameof(yamlContent));
        }

        try
        {
            var config = Deserializer.Deserialize<AppConfig>(yamlContent);
            config.Validate();
            return config;
        }
        catch (YamlDotNet.Core.YamlException ex)
        {
            throw new ArgumentException("Invalid YAML format", nameof(yamlContent), ex);
        }
        catch (Exception ex) when (ex is not ArgumentException)
        {
            throw new ArgumentException("Failed to parse configuration", nameof(yamlContent), ex);
        }
    }

    /// <summary>
    /// Loads configuration from file
    /// </summary>
    /// <param name="filePath">Path to YAML configuration file</param>
    /// <returns>Parsed and validated AppConfig</returns>
    public static AppConfig LoadFromFile(string filePath)
    {
        if (!File.Exists(filePath))
        {
            throw new FileNotFoundException("Configuration file not found", filePath);
        }

        var yamlContent = File.ReadAllText(filePath);
        return LoadFromYaml(yamlContent);
    }
}