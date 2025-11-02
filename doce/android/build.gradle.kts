// Añade el plugin de Google Services en el nivel de proyecto (apply false)
plugins {
    id("com.google.gms.google-services") version "4.4.4" apply false
}

// Tus repos siguen aquí
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// (Opcional) Tu personalización de directorios de build; la mantengo tal cual
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
