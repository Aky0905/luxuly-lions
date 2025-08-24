import org.gradle.api.file.Directory

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Firebase Gradle 플러그인
        classpath("com.google.gms:google-services:4.3.15")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 빌드 디렉토리 위치 변경
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // app 모듈 평가 우선
    project.evaluationDependsOn(":app")
}

// clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
