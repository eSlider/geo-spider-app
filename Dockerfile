# Geo Spider App - MAUI Docker Build
# Note: This requires a Windows-based Docker environment for MAUI workloads

FROM mcr.microsoft.com/dotnet/sdk:9.0-windowsservercore-ltsc2022

# Install MAUI workloads (Windows containers only)
RUN dotnet workload install maui android --skip-manifest-update

# Set working directory
WORKDIR /src

# Copy solution and restore dependencies
COPY GeoSpiderApp.sln ./
COPY GeoSpiderApp.Core/ ./GeoSpiderApp.Core/
COPY GeoSpiderApp.Core.Tests/ ./GeoSpiderApp.Core.Tests/
COPY GeoSpiderApp.MAUI/ ./GeoSpiderApp.MAUI/
COPY GeoSpiderConsole/ ./GeoSpiderConsole/

# Restore NuGet packages
RUN dotnet restore

# Build and test
RUN dotnet build --configuration Release
RUN dotnet test --configuration Release

# Publish APK
RUN dotnet publish GeoSpiderApp.MAUI/GeoSpiderApp.MAUI.csproj \
    -c Release \
    -f net9.0-android \
    --self-contained \
    -p:AndroidPackageFormat=apk \
    -o ./publish

# Final stage - extract APK
FROM scratch AS export
COPY --from=0 /src/publish/GeoSpiderApp.MAUI-Signed.apk ./