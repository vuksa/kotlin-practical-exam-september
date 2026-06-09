import org.gradle.jvm.toolchain.JavaLanguageVersion

plugins {
    kotlin("jvm") version "2.4.0"
}

group = "com.jetbrains"
version = "1.0-SNAPSHOT"

val examJavaVersion = 21

kotlin {
    jvmToolchain(examJavaVersion)
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(examJavaVersion)
    }
}

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(kotlin("test"))
}

tasks.test {
    useJUnitPlatform()
}
