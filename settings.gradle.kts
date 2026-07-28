pluginManagement {
    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
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

rootProject.name = "XiaoyuMusic"

include(":app")

// Core
include(":core:common")
include(":core:ui")
include(":core:database")
include(":core:player")

// Data
include(":data:local")
include(":data:repository")

// Feature
include(":feature:home")
include(":feature:library-local")
include(":feature:player")
include(":feature:settings")
