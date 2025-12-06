// Top-level build file where you can add configuration options common to all sub-projects/modules.

plugins {
    id("com.google.gms.google-services") version "4.4.4" apply false
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // ✅ Format Kotlin DSL pakai tanda kutip ganda
        classpath("com.android.tools.build:gradle:8.5.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.23")
        classpath("com.google.gms:google-services:4.4.2") // ✅ Tambahkan ini untuk Firebase
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
