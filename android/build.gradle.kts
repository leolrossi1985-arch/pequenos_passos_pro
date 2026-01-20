// 1. Configuração Global
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// --- CORREÇÃO CRÍTICA (FORCE COMPILE SDK) ---
// Este bloco força TODAS as bibliotecas (incluindo printing) a usarem o SDK 36.
// Ele está posicionado ANTES do 'evaluationDependsOn' para evitar o erro "already evaluated".
subprojects {
    afterEvaluate {
        // Verifica se o subprojeto é Android (biblioteca ou app)
        if (project.extensions.findByName("android") != null) {
            try {
                configure<com.android.build.gradle.BaseExtension> {
                    compileSdkVersion(36) // Resolve o erro lStar
                    defaultConfig {
                        targetSdkVersion(36)
                    }
                }
            } catch (e: Exception) {
                // Ignora erros se o plugin não for exatamente o BaseExtension (segurança)
            }
        }
    }
}
// --------------------------------------------

// 3. Vincula a avaliação ao App (Isso deve ficar por último)
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}