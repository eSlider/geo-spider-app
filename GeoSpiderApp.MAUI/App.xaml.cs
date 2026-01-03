namespace GeoSpiderApp.MAUI;

public partial class App : Application
{
    public App()
    {
        InitializeComponent();
        
        // Get MainPage from service provider
        if (MauiProgram.CurrentApp != null)
        {
            MainPage = MauiProgram.CurrentApp.Services.GetRequiredService<MainPage>();
        }
    }
}