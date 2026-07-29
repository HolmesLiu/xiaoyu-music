allprojects {
    repositories {
        // CN mirrors
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/central") }
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// AGP 8+ requires every module to declare a `namespace` in its build script.
// Older Flutter plugins (e.g. on_audio_query_android 1.1.0) didn't set it and
// relied on `package=...` in AndroidManifest.xml, which AGP 8 no longer
// accepts. We patch every Android subproject before the configuration phase
// runs (using beforeEvaluate so namespace is set before AGP reads it).
subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
            if (namespace == null) {
                namespace = "com.xiaoyu.music.plugin.${project.name.replace('-', '_')}"
            }
            compileSdk = 34
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
    plugins.withId("com.android.application") {
        extensions.configure<com.android.build.gradle.AppExtension>("android") {
            if (namespace == null) {
                namespace = "com.xiaoyu.music.plugin.${project.name.replace('-', '_')}"
            }
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
    plugins.withId("org.jetbrains.kotlin.android") {
        extensions.configure(org.jetbrains.kotlin.gradle.dsl.KotlinAndroidProjectExtension::class.java) {
            jvmToolchain(17)
        }
    }
    afterEvaluate {
        // Strip `package="..."` from source AndroidManifest.xml (AGP 8 forbids it)
        listOf("src/main/AndroidManifest.xml", "src/debug/AndroidManifest.xml")
            .mapNotNull { p -> project.file(p).takeIf { it.exists() } }
            .forEach { manifestFile ->
                val text = manifestFile.readText()
                if (text.contains("package=")) {
                    val patched = text.replace(Regex("""\s*package="[^"]+""""), "")
                    manifestFile.writeText(patched)
                    println("[namespace-patch] Stripped package= from ${manifestFile.absolutePath}")
                }
            }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
