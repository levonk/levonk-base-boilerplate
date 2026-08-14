#!/usr/bin/env bash
# configure-kotlin.sh
# Kotlin project configuration script
# Handles build.gradle.kts, settings.gradle.kts, and framework-specific configs

set -euo pipefail

# Import common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/config-functions.sh
if [[ -f "$SCRIPT_DIR/../common/config-functions.sh" ]]; then
    source "$SCRIPT_DIR/../common/configurations.sh"
fi

# Configure Kotlin project
configure_kotlin_project() {
    local project_path="$1"
    local mode="${2:-adopt}"     # adopt | standardize
    local app_type="${3:-unknown}" # web | cli | api | library | mobile
    local project_type="${4:-unknown}" # frontend-web | api-service | cli-tool | library | mobile-app

    log_info "Configuring Kotlin project (mode: $mode, app_type: $app_type)"

    # Handle build.gradle.kts (preferred) or build.gradle
    if [[ -f "$project_path/build.gradle.kts" ]]; then
        configure_gradle_kts "$project_path" "$mode" "$app_type" "$project_type"
    elif [[ -f "$project_path/build.gradle" ]]; then
        configure_gradle_groovy "$project_path" "$mode" "$app_type" "$project_type"
    elif [[ "$mode" == "standardize" ]]; then
        create_gradle_kts_project "$project_path" "$mode" "$app_type" "$project_type"
    fi

    # Handle settings.gradle.kts
    configure_settings_gradle "$project_path" "$mode"

    # Handle Kotlin testing configuration
    configure_kotlin_testing_config "$project_path" "$mode"

    # Handle framework-specific configs
    configure_kotlin_framework_configs "$project_path" "$mode" "$app_type" "$project_type"
}

# Configure build.gradle.kts
configure_gradle_kts() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring build.gradle.kts for Kotlin project"

    if [[ "$mode" == "standardize" ]]; then
        # Standardize mode - comprehensive additions
        add_standardize_gradle_kts_dependencies "$project_path" "$app_type" "$project_type"
        add_standardize_gradle_kts_plugins "$project_path" "$app_type" "$project_type"
    else
        # Adopt mode - minimal essential additions
        add_adopt_gradle_kts_dependencies "$project_path" "$app_type" "$project_type"
    fi
}

# Configure build.gradle (Groovy)
configure_gradle_groovy() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring build.gradle for Kotlin project"

    if [[ "$mode" == "standardize" ]]; then
        # Standardize mode - comprehensive additions
        add_standardize_gradle_groovy_dependencies "$project_path" "$app_type" "$project_type"
        add_standardize_gradle_groovy_plugins "$project_path" "$app_type" "$project_type"
    else
        # Adopt mode - minimal essential additions
        add_adopt_gradle_groovy_dependencies "$project_path" "$app_type" "$project_type"
    fi
}

# Add standardize mode dependencies to build.gradle.kts
add_standardize_gradle_kts_dependencies() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Apply surgical changes using yq-go if available
    if command -v yq-go >/dev/null 2>&1; then
        echo "Adding standardize dependencies to build.gradle.kts using yq-go"
        
        # Base dependencies for all Kotlin projects
        # yq-go eval '.dependencies += {implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk8"}' "$project_path/build.gradle.kts" -i
        # yq-go eval '.dependencies += {testImplementation "org.jetbrains.kotlin:kotlin-test-junit5"}' "$project_path/build.gradle.kts" -i
        
        # App-type specific dependencies
        case "$app_type" in
            "web")
                # yq-go eval '.dependencies += {implementation "org.springframework.boot:spring-boot-starter-web" }' "$project_path/build.gradle.kts" -i
                if [[ "$project_type" == *"frontend-web"* ]]; then
                    # yq-go eval '.dependencies += {implementation "org.springframework.boot:spring-boot-starter-thymeleaf" }' "$project_path/build.gradle.kts" -i
                fi
                ;;
            "mobile")
                # yq-go eval '.dependencies += {implementation "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3" }' "$project_path/build.gradle.kts" -i
                # yq-go eval '.dependencies += {implementation "androidx.appcompat:appcompat:1.6.1" }' "$project_path/build.gradle.kts" -i
                ;;
            "cli")
                # yq-go eval '.dependencies += {implementation "com.github.ajalt.clikt:clikt:4.2.0" }' "$project_path/build.gradle.kts" -i
                ;;
            "api")
                # yq-go eval '.dependencies += {implementation "org.springframework.boot:spring-boot-starter-web" }' "$project_path/build.gradle.kts" -i"
                # yq-go eval '.dependencies += {implementation "org.springframework.boot:spring-boot-starter-data-jpa" }' "$project_path/build.gradle.kts" -i"
                ;;
        esac

        # Framework-specific dependencies
        case "$project_type" in
            "mobile-app")
                if [[ -f "$project_path/build.gradle.kts" ]] && grep -q "com.android.application" "$project_path/build.gradle.kts" 2>/dev/null; then
                    # yq-go eval '.dependencies += {implementation "androidx.lifecycle:lifecycle-viewmodel-ktx:2.6.1" }' "$project_path/build.gradle.kts" -i
                    # yq-go eval '.dependencies += {implementation "androidx.navigation:navigation-fragment-ktx:2.7.5" }' "$project_path/build.gradle.kts" -i"
                fi
                ;;
            "frontend-web")
                # yq-go eval '.dependencies += {implementation "org.springframework.boot:spring-boot-starter-webflux" }' "$project_path/build.gradle.kts" -i
                ;;
            "api-service")
                # yq-go eval '.dependencies += {implementation "org.springframework.boot:spring-boot-starter-security" }' "$project_path/build.gradle.kts" -i'
                # yq-go eval '.dependencies += {implementation "io.jsonwebtoken:jjwt-api:0.11.5" }' "$project_path/build.gradle.kts" -i"
                ;;
        esac
    else
        log_warn "yq-go not available, skipping build.gradle.kts dependency updates"
    fi
}

# Add adopt mode dependencies to build.gradle.kts
add_adopt_gradle_kts_dependencies() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Apply surgical changes
    if command -v yq-go >/dev/null 2>&1; then
        echo "Adding adopt dependencies to build.gradle.kts using yq-go"
        
        case "$app_type" in
            "web")
                # yq-go eval '.dependencies += {implementation "org.springframework.boot:spring-boot-starter-web" }' "$project_path/build.gradle.kts" -i
                ;;
            "mobile")
                # yq-go eval '.dependencies += {implementation "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3" }' "$project_path/build.gradle.kts" -i
                ;;
            "api")
                # yq-go eval '.dependencies += {implementation "org.springframework.boot:spring-boot-starter-web" }' "$project_path/build.gradle.kts" -i
                ;;
        esac
    else
        log_warn "yq-go not available or no dependencies to add"
    fi
}

# Add standardize mode dependencies to build.gradle (Groovy)
add_standardize_gradle_groovy_dependencies() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Apply surgical changes
    if command -v yq-go >/dev/null 2>&1; then
        echo "Adding standardize dependencies to build.gradle using yq-go"
        
        # Base dependencies
        # yq-go eval '.dependencies { implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk8" }' "$project_path/build.gradle" -i
        # yq-go eval '.dependencies { testImplementation "org.jetbrains.kotlin:kotlin-test-junit5" }' "$project_path/build.gradle" -i
        
        # App-type specific dependencies
        case "$app_type" in
            "web")
                # yq-go eval '.dependencies { implementation "org.springframework.boot:spring-boot-starter-web" }' "$project_path/build.gradle" -i
                ;;
            "mobile")
                # yq-go eval '.dependencies { implementation "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3" }' "$project_path/build.gradle" -i
                ;;
            "api")
                # yq-go eval '.dependencies { implementation "org.springframework.boot:spring-boot-starter-web" }' "$project_path/build.gradle" -i
                ;;
        esac
    else
        log_warn "yq-go not available, skipping build.gradle dependency updates"
    fi
}

# Add adopt mode dependencies to build.gradle (Groovy)
add_adopt_gradle_groovy_dependencies() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    if command -v yq-go >/dev/null 2>&1; then
        echo "Adding adopt dependencies to build.gradle using yq-go"
        
        case "$app_type" in
            "web")
                # yq-go eval '.dependencies { implementation "org.springframework.boot:spring-boot-starter-web" }' "$project_path/build.gradle" -i
                ;;
            "mobile")
                # yq-go eval '.dependencies { implementation "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3" }' "$project_path/build.gradle" -i"
                ;;
            "api")
                # yq-go eval '.dependencies { implementation "org.springframework.boot:spring-boot-starter-web" }' "$project_path/build.gradle" -i
                ;;
        esac
    else
        log_warn "yq-go not available or no dependencies to add"
    fi
}

# Add standardize mode plugins to build.gradle.kts
add_standardize_gradle_kts_plugins() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    if command -v yq-go >/dev/null 2>&1; then
        echo "Adding standardize plugins to build.gradle.kts using yq-go"
        
        # Add standard plugins
        # yq-go eval '.plugins += {id "org.jetbrains.kotlin.jvm", version "1.9.10"}' "$project_path/build.gradle.kts" -i
        # yq-go eval '.plugins += {id "org.springframework.boot", version "3.1.0" }' "$project_path/build.gradle.kts" -i
        # yq-go eval '.plugins += {id "io.spring.dependency-management" version "1.1.0" }' "$project_path/build.gradle.kts" -i
    else
        log_warn "yq-go not available, skipping build.gradle.kts plugin updates"
    fi
}

# Add standardize mode plugins to build.gradle (Groovy)
add_standardize_gradle_groovy_plugins() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    if command -v yq-go >/dev/null 2>&1; then
        echo "Adding standardize plugins to build.gradle using yq-go"
        
        # Add standard plugins
        # yq-go eval 'plugins { id "org.jetbrains.kotlin.jvm" version "1.9.10" }' "$project_path/build.gradle" -i
        # yq-go eval 'plugins { id "org.springframework.boot" version "3.1.0" }' "$project_path/build.gradle" -i
        # yq-go eval 'plugins { id "io.spring.dependency-management" version "1.1.0" }' "$project_path/build.gradle" -i
    else
        log_warn "yq-go not available, skipping build.gradle plugin updates"
    fi
}

# Create Gradle Kotlin project
create_gradle_kts_project() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_path="$4"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/build.gradle.kts" ]]; then
        local group_id="com.example"
        local artifact_id
        artifact_id=$(basename "$project_path")
        
        cat > "$project_path/build.gradle.kts" << EOF
plugins {
    id("org.springframework.boot") version "3.1.0"
    id("io.spring.dependency-management") version "1.1.0"
    id("org.jetbrains.kotlin.jvm") version "1.9.10"
}

group = "$group_id"
version = "0.1.0"
name = "$artifact_id"
description = "A Kotlin Spring Boot application"

repositories {
    mavenCentral()
}

dependencies {
EOF

        # Add app-type specific dependencies
        case "$app_type" in
            "web")
                cat >> "$project_path/build.gradle.kts" << 'EOF'
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("com.fasterxml.jackson.module:jackson-kotlin-module")
EOF
                ;;
            "mobile")
                cat >> "$project_path/build.gradle.kts" << 'EOF'
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.6.1")
EOF
                ;;
            "api")
                cat >> "$project_path/build.gradle.kts" << 'EOF'
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("com.fasterxml.jackson.module:jackson-kotlin-module")
EOF
                ;;
            "cli")
                cat >> "$project_path/build.gradle.kts" << 'EOF'
    implementation("com.github.ajalt.clikt:clikt:4.2.0")
    implementation("com.fasterxml.jackson.module:jackson-kotlin-module")
EOF
                ;;
        esac

        # Add test dependencies
        cat >> "$project_path/build.gradle.kts" << 'EOF'
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
    testImplementation("org.mockito:mockito-core:5.4.0")
EOF

        log_info "✓ Created build.gradle.kts"
    fi
}

# Configure settings.gradle.kts
configure_settings_gradle() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/settings.gradle.kts" ]]; then
        cat > "$project_path/settings.gradle.kts" << 'EOF'
pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}

rootProject.name = "$(basename "$project_path")"

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    versionCatalogs {
        createMavenPom()
    }
}
EOF
        log_info "✓ Created settings.gradle.kts"
    fi
}

# Configure Kotlin testing
configure_kotlin_testing_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]]; then
        # Create test directory structure
        mkdir -p "$project_path/src/test/kotlin/$(basename "$project_path | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:]' '[:lower:]' | sed 's/^\(.\)/\U\1')"
        
        # Create basic test file
        if [[ ! -f "$project_path/src/test/kotlin/ExampleTest.kt" ]]; then
            cat > "$project_path/src/test/kotlin/ExampleTest.kt << 'EOF'
import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.web.client.TestRestTemplate
import org.springframework.boot.test.web.client.get.ServerRequest
import org.springframework.boot.test.web.client.get.ServerResponse
import org.assertj.core.api.Assertions.assertThat

@SpringBootTest
class ExampleTest {

    @Test
    fun contextLoads() {
        // This test will pass if the Spring context loads successfully
        assertThat(true).isTrue()
    }

    @Test
    fun `example test`() {
        val restTemplate = TestRestTemplate()
        val result = restTemplate.getForObject<String, String>("/health", String::class.java)
        assertThat(result).isEqualTo("OK")
    }
}
EOF
            log_info "✓ Created src/test/kotlin/ExampleTest.kt"
        fi

        # Create test resources
        mkdir -p "$project_path/src/test/resources"
        if [[ ! -f "$project_path/src/test/resources/application-test.properties" ]]; then
            cat > "$project_path/src/test/resources/application-test.properties" << 'EOF'
spring.profiles.active=test
logging.level.org.springframework=DEBUG
EOF
            log_info "✓ Created src/test/resources/application-test.properties"
        fi
    fi
fi
}

# Configure Kotlin framework-specific configurations
configure_kotlin_framework_configs() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    # Spring Boot configuration
    if [[ "$app_type" == "web" ]] || [[ "$app_type" == "api" ]] || [[ "$project_type" == *"api-service"* ]]; then
        configure_spring_boot_config "$project_path" "$mode" "$app_type" "$project_type"
    fi

    # Android configuration
    if [[ "$app_type" == "mobile" ]] || [[ "$project_type" == *"mobile-app"* ]]; then
        configure_android_config "$project_path" "$mode" "$app_type" "$project_type"
    fi

    # CLI configuration
    if [[ "$app_type" == "cli" ]] || [[ "$project_type" == *"cli-tool"* ]]; then
        configure_cli_config "$project_path" "$mode" "$app_type" "$project_type"
    fi
}

# Configure Spring Boot
configure_spring_boot_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    if [[ "$mode" == "standardize" ]]; then
        # Create basic Spring Boot project structure
        local package_name
        package_name=$(basename "$project_path" | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:]' '[:lower:]' | sed 's/^\(.\)/\U\1')
        
        mkdir -p "$project_path/src/main/kotlin/$package_name"
        
        if [[ ! -f "$project_path/src/main/kotlin/$package_name/Application.kt" ]]; then
            cat > "$project_path/src/main/kotlin/$package_name/Application.kt" << EOF
package $package_name

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class Application {
    fun main(args: Array<String>) {
        runApplication<Application>(*args)
    }
}
EOF
            log_info "✓ Created Application.kt"
        fi

        if [[ ! -f "$project_path/src/main/kotlin/$package_name/controller/HealthController.kt" ]]; then
            mkdir -p "$project_path/src/main/kotlin/$package_name/controller"
            cat > "$project_path/src/main/kotlin/$package_name/controller/HealthController.kt" << EOF
package $package_name.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.http.ResponseEntity

@RestController
class HealthController {

    @GetMapping("/health")
    fun health(): ResponseEntity<String> {
        return ResponseEntity.ok("OK")
    }

    @GetMapping("/")
    fun home(): ResponseEntity<String> {
        return ResponseEntity.ok("Welcome to Kotlin Spring Boot!")
    }
}
EOF
            log_info "✓ Created HealthController.kt"
        fi

        # Create application properties
        if [[ ! -f "$project_path/src/main/resources/application.yml" ]]; then
            mkdir -p "$project_path/src/main/resources"
            cat > "$project_path/src/main/resources/application.yml" << 'EOF'
server:
  port: 8080

spring:
  application:
    name: kotlin-application
  profiles:
    active: dev
  logging:
    level:
      $package_name: DEBUG
      org.springframework: DEBUG
EOF
            log_info "✓ Created application.yml"
        fi
    fi
}

# Configure Android
configure_android_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    if [[ "$mode" == "standardize" ]]; then
        # Create Android project structure
        mkdir -p "$project_path/src/main/java/$(basename "$project_path" | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:]' '[:lower:]' | sed 's/^\(.\)/\U\1')"
        mkdir -p "$project_path/src/main/res/layout"
        mkdir -p "$project_path/src/main/res/values"
        
        if [[ ! -f "$project_path/src/main/AndroidManifest.xml" ]]; then
            cat > "$project_path/src/main/AndroidManifest.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:theme="@style/Theme.App">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:screenOrientation="portrait">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF
            log_info "✓ Created AndroidManifest.xml"
        fi

        # Create basic MainActivity
        if [[ ! -f "$project_path/src/main/java/$(basename "$project_path" | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:]' '[:lower:]' | sed 's/^\(.\)/\U\1')/MainActivity" ]]; then
            cat > "$project_path/src/main/java/$(basename "$project_path | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:]' '[:lower:] | sed 's/^\(.\)/\U\1')/MainActivity" << 'EOF'
package $(basename "$project_path" | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:] '[:lower:] | sed 's/^\(.\)/\U\1')/MainActivity

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.TextView

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        val textView: TextView = findViewById(R.id.text_view)
        textView.text = "Hello, Kotlin!"
    }
}
EOF
            log_info "✓ Created MainActivity.kt"
        fi

        # Create basic layout
        if [[ ! -f "$project_path/src/main/res/layout/activity_main.xml" ]]; then
            cat > "$project_path/src/main/res/layout/activity_main.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools">

    <TextView
        android:id="@+id/text_view"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Hello, World!"
        app:layout_constraintBottom_toTopOf="parent"
        app:layout_constraintLeft_toLeftOf="parent"
        app:layout_constraintRight_toRightOf="parent"
        app:layout_constraintTop_toTopOf="parent"
        tools:context=".MainActivity" />
</androidx.constraintlayout.widget.ConstraintLayout>
EOF
            log_info "✓ Created activity_main.xml"
        fi

        # Create strings resource
        if [[ ! -f "$project_path/src/main/res/values/strings.xml" ]]; then
            cat > "$project_path/src/main/res/values/strings.xml" << 'EOF
<resources>
    <string name="app_name">Kotlin App</string>
</resources>
EOF
            log_info "✓ Created strings.xml"
        fi
    fi
fi
}

# Configure CLI
configure_cli_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    if [[ "$mode" == "standardize" ]]; then
        # Create basic CLI project structure
        mkdir -p "$project_path/src/main/kotlin/$(basename "$project_path" | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:] '[:lower:]' | sed 's/^\(.\)/\U\1')"
        
        if [[ ! -f "$project_path/src/main/kotlin/$(basename "$project_path | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:] '[:lower:] | sed 's/^\(.\)/\U\1')/Main.kt" ]]; then
            cat > "$project_path/src/main/kotlin/$(basename "$project_path | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:] '[:lower:] | sed 's/^\(.\)/\U\1')/Main.kt" << 'EOF'
package $(basename "$project_path | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:] '[:lower:] | sed 's/^\(.\)/\U\1')/Main.kt'

import com.github.ajalt.clikt.core.Clikt
import com.github.ajalt.clikt.core.main.run
import kotlinx.cli.MissingParameterException

fun main(args: Array<String>) = main {
    val cli = Clikt()
        if (args.isEmpty()) {
            throw MissingParameterException("No arguments provided")
        }
        cli.main(args)
}
EOF
            log_info "✓ Created Main.kt"
        fi
    fi
}

# Export functions for use by adopt-project.sh
export -f configure_kotlin_project
export -f configure_gradle_kts
export -f configure_gradle_groovy
export -f configure_settings_gradle
export -f configure_kotlin_testing_config
export -f configure_kotlin_framework_configs
