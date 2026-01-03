pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
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
