using GeoSpiderApp.Core.Configuration;

namespace GeoSpiderApp.Core.Tests;

public class ConfigurationTests
{
    [Fact]
    public void LoadConfiguration_ValidYaml_ReturnsConfiguration()
    {
        // Arrange
        var yamlContent = @"
serverUrl: https://api.example.com/locations
collectionIntervalSeconds: 30
syncBatchSize: 100
maxOfflineStorageDays: 7
";

        // Act
        var config = ConfigurationLoader.LoadFromYaml(yamlContent);

        // Assert
        Assert.NotNull(config);
        Assert.Equal("https://api.example.com/locations", config.ServerUrl);
        Assert.Equal(30, config.CollectionIntervalSeconds);
        Assert.Equal(100, config.SyncBatchSize);
        Assert.Equal(7, config.MaxOfflineStorageDays);
    }

    [Fact]
    public void LoadConfiguration_InvalidYaml_ThrowsArgumentException()
    {
        // Arrange
        var invalidYaml = "invalid: yaml: content: ["; // Invalid YAML

        // Act & Assert
        Assert.Throws<ArgumentException>(() => ConfigurationLoader.LoadFromYaml(invalidYaml));
    }

    [Fact]
    public void LoadConfiguration_MissingRequiredField_ThrowsArgumentException()
    {
        // Arrange
        var incompleteYaml = @"
collectionIntervalSeconds: 30
syncBatchSize: 100
";

        // Act & Assert
        Assert.Throws<ArgumentException>(() => ConfigurationLoader.LoadFromYaml(incompleteYaml));
    }
}
