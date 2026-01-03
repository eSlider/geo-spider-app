pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "GeoSpiderApp"

include(":shared")
project(":shared").projectDir = file("geo-spider-app/shared")

include(":androidApp")
project(":androidApp").projectDir = file("geo-spider-app/androidApp")
