namespace GeoSpiderApp.MAUI;

public partial class App : Application
{
    public App()
    {
        InitializeComponent();
    }

    protected override Window CreateWindow(IActivationState? activationState)
    {
        // Get MainPage from service provider
        var window = base.CreateWindow(activationState);
        
        if (MauiProgram.CurrentApp?.Services != null)
        {
            MainPage = MauiProgram.CurrentApp.Services.GetRequiredService<MainPage>();
        }
        
        return window;
    }
}