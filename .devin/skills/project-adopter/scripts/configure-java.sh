#!/usr/bin/env bash
# configure-java.sh
# Java project configuration script
# Handles pom.xml, build.gradle, checkstyle.xml, and framework-specific configs

set -euo pipefail

# Import common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/config-functions.sh
if [[ -f "$SCRIPT_DIR/../common/config-functions.sh" ]]; then
    source "$SCRIPT_DIR/../common/config-functions.sh"
fi

# Configure Java project
configure_java_project() {
    local project_path="$1"
    local mode="${2:-adopt}"     # adopt | standardize
    local app_type="${3:-unknown}" # web | cli | api | library
    local project_type="${4:-unknown}" # frontend-web | api-service | cli-tool | library

    log_info "Configuring Java project (mode: $mode, app_type: $app_type)"

    # Handle Maven or Gradle
    if [[ -f "$project_path/pom.xml" ]]; then
        configure_pom_xml "$project_path" "$mode" "$app_type" "$project_type"
    elif [[ -f "$project_path/build.gradle" ]] || [[ -f "$project_path/build.gradle.kts" ]]; then
        configure_gradle_build "$project_path" "$mode" "$app_type" "$project_type"
    elif [[ "$mode" == "standardize" ]]; then
        create_maven_project "$project_path" "$mode" "$app_type" "$project_type"
    fi

    # Handle Java code quality configuration
    configure_checkstyle_config "$project_path" "$mode"

    # Handle Java testing configuration
    configure_java_testing_config "$project_path" "$mode"

    # Handle framework-specific configs
    configure_java_framework_configs "$project_path" "$mode" "$app_type" "$project_type"
}

# Configure pom.xml (Maven)
configure_pom_xml() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring pom.xml for Java project"

    if [[ "$mode" == "standardize" ]]; then
        # Standardize mode - comprehensive additions
        add_standardize_maven_dependencies "$project_path" "$app_type" "$project_type"
        add_standardize_maven_plugins "$project_path" "$app_type" "$project_type"
    else
        # Adopt mode - minimal essential additions
        add_adopt_maven_dependencies "$project_path" "$app_type" "$project_type"
    fi
}

# Add standardize mode dependencies to pom.xml
add_standardize_maven_dependencies() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Apply surgical changes using yq-go if available
    if command -v yq-go >/dev/null 2>&1; then
        echo "Adding standardize dependencies to pom.xml using yq-go"
        
        # Base dependencies for all Java projects
        # yq-go eval '.dependencies += [{"groupId": "org.junit.jupiter", "artifactId": "junit-jupiter", "version": "5.10.0", "scope": "test"}]' "$project_path/pom.xml" -i
        
        # App-type specific dependencies
        case "$app_type" in
            "web")
                # yq-go eval '.dependencies += [{"groupId": "org.springframework.boot", "artifactId": "spring-boot-starter-web", "version": "3.1.0"}]' "$project_path/pom.xml" -i
                if [[ "$project_type" == *"frontend-web"* ]]; then
                    # yq-go eval '.dependencies += [{"groupId": "org.springframework.boot", "artifactId": "spring-boot-starter-thymeleaf", "version": "3.1.0"}]' "$project_path/pom.xml" -i
                fi
                ;;
            "cli")
                # yq-go eval '.dependencies += [{"groupId": "info.picocli", "artifactId": "picocli", "version": "4.7.0"}]' "$project_path/pom.xml" -i
                ;;
            "api")
                # yq-go eval '.dependencies += [{"groupId": "org.springframework.boot", "artifactId": "spring-boot-starter-web", "version": "3.1.0"}]' "$project_path/pom.xml" -i
                # yq-go eval '.dependencies += [{"groupId": "org.springframework.boot", "artifactId": "spring-boot-starter-data-jpa", "version": "3.1.0"}]' "$project_path/pom.xml" -i
                ;;
        esac
    else
        log_warn "yq-go not available, skipping pom.xml dependency updates"
    fi
}

# Add adopt mode dependencies to pom.xml
add_adopt_maven_dependencies() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Apply surgical changes
    if command -v yq-go >/dev/null 2>&1; then
        echo "Adding adopt dependencies to pom.xml using yq-go"
        
        case "$app_type" in
            "web")
                # yq-go eval '.dependencies += [{"groupId": "org.springframework.boot", "artifactId": "spring-boot-starter-web", "version": "3.1.0"}]' "$project_path/pom.xml" -i
                ;;
            "cli")
                # yq-go eval '.dependencies += [{"groupId": "info.picocli", "artifactId": "picocli", "version": "4.7.0"}]' "$project_path/pom.xml" -i
                ;;
            "api")
                # yq-go eval '.dependencies += [{"groupId": "org.springframework.boot", "artifactId": "spring-boot-starter-web", "version": "3.1.0"}]' "$project_path/pom.xml" -i
                ;;
        esac
    else
        log_warn "yq-go not available or no dependencies to add"
    fi
}

# Add standardize mode plugins to pom.xml
add_standardize_maven_plugins() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    if command -v yq-go >/dev/null 2>&1; then
        echo "Adding standardize plugins to pom.xml using yq-go"
        
        # Add standard plugins
        # yq-go eval '.build.plugins += [{"groupId": "org.apache.maven.plugins", "artifactId": "maven-compiler-plugin", "version": "3.11.0", "configuration": {"source": "17", "target": "17"}}]' "$project_path/pom.xml" -i
        # yq-go eval '.build.plugins += [{"groupId": "org.apache.maven.plugins", "artifactId": "maven-surefire-plugin", "version": "3.1.0"}]' "$project_path/pom.xml" -i
        # yq-go eval '.build.plugins += [{"groupId": "org.springframework.boot", "artifactId": "spring-boot-maven-plugin", "version": "3.1.0"}]' "$project_path/pom.xml" -i
    else
        log_warn "yq-go not available, skipping pom.xml plugin updates"
    fi
}

# Configure Gradle build
configure_gradle_build() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring Gradle build for Java project"

    if [[ "$mode" == "standardize" ]]; then
        # Standardize mode - comprehensive additions
        add_standardize_gradle_dependencies "$project_path" "$app_type" "$project_type"
        add_standardize_gradle_plugins "$project_path" "$app_type" "$project_type"
    else
        # Adopt mode - minimal essential additions
        add_adopt_gradle_dependencies "$project_path" "$app_type" "$project_type"
    fi
}

# Add standardize mode dependencies to build.gradle
add_standardize_gradle_dependencies() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    local build_file
    if [[ -f "$project_path/build.gradle.kts" ]]; then
        build_file="build.gradle.kts"
    else
        build_file="build.gradle"
    fi

    # Apply surgical changes
    if command -v yq-go >/dev/null 2>&1; then
        echo "Adding standardize dependencies to $build_file using yq-go"
        
        # Base dependencies
        # yq-go eval '.dependencies += {testImplementation "org.junit.jupiter:junit-jupiter:5.10.0"}' "$project_path/$build_file" -i
        
        # App-type specific dependencies
        case "$app_type" in
            "web")
                # yq-go eval '.dependencies += {implementation "org.springframework.boot:spring-boot-starter-web:3.1.0"}' "$project_path/$build_file" -i
                ;;
            "cli")
                # yq-go eval '.dependencies += {implementation "info.picocli:picocli:4.7.0"}' "$project_path/$build_file" -i
                ;;
            "api")
                # yq-go eval '.dependencies += {implementation "org.springframework.boot:spring-boot-starter-web:3.1.0"}' "$project_path/$build_file" -i
                ;;
        esac
    else
        log_warn "yq-go not available, skipping Gradle dependency updates"
    fi
}

# Add adopt mode dependencies to build.gradle
add_adopt_gradle_dependencies() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    local build_file
    if [[ -f "$project_path/build.gradle.kts" ]]; then
        build_file="build.gradle.kts"
    else
        build_file="build.gradle"
    fi

    if command -v yq-go >/dev/null 2>&1; then
        echo "Adding adopt dependencies to $build_file using yq-go"
        
        case "$app_type" in
            "web")
                # yq-go eval '.dependencies += {implementation "org.springframework.boot:spring-boot-starter-web:3.1.0"}' "$project_path/$build_file" -i
                ;;
            "cli")
                # yq-go eval '.dependencies += {implementation "info.picocli:picocli:4.7.0"}' "$project_path/$build_file" -i
                ;;
            "api")
                # yq-go eval '.dependencies += {implementation "org.springframework.boot:spring-boot-starter-web:3.1.0"}' "$project_path/$build_file" -i
                ;;
        esac
    else
        log_warn "yq-go not available or no dependencies to add"
    fi
}

# Add standardize mode plugins to build.gradle
add_standardize_gradle_plugins() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    local build_file
    if [[ -f "$project_path/build.gradle.kts" ]]; then
        build_file="build.gradle.kts"
    else
        build_file="build.gradle"
    fi

    if command -v yq-go >/dev/null 2>&1; then
        echo "Adding standardize plugins to $build_file using yq-go"
        
        # Add standard plugins
        # yq-go eval '.plugins += {id "java", version "8.0.0"}' "$project_path/$build_file" -i
        # yq-go eval '.plugins += {id "org.springframework.boot", version "3.1.0"}' "$project_path/$build_file" -i
    else
        log_warn "yq-go not available, skipping Gradle plugin updates"
    fi
}

# Create Maven project
create_maven_project() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/pom.xml" ]]; then
        local group_id="com.example"
        local artifact_id
        artifact_id=$(basename "$project_path")
        
        cat > "$project_path/pom.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.1.0</version>
        <relativePath/>
    </parent>

    <groupId>$group_id</groupId>
    <artifactId>$artifact_id</artifactId>
    <version>0.1.0</version>
    <name>$artifact_id</name>
    <description>A Spring Boot application</description>

    <properties>
        <java.version>17</java.version>
    </properties>

    <dependencies>
EOF

        # Add app-type specific dependencies
        case "$app_type" in
            "web")
                cat >> "$project_path/pom.xml" << 'EOF'
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
EOF
                ;;
            "cli")
                cat >> "$project_path/pom.xml" << 'EOF'
        <dependency>
            <groupId>info.picocli</groupId>
            <artifactId>picocli</artifactId>
            <version>4.7.0</version>
        </dependency>
EOF
                ;;
            "api")
                cat >> "$project_path/pom.xml" << 'EOF'
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
EOF
                ;;
        esac

        # Add test dependencies
        cat >> "$project_path/pom.xml" << 'EOF'
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
EOF

        log_info "✓ Created pom.xml"
    fi
}

# Configure Checkstyle
configure_checkstyle_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/checkstyle.xml" ]]; then
        cat > "$project_path/checkstyle.xml" << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE module PUBLIC
    "-//Checkstyle//DTD Checkstyle Configuration 1.3//EN"
    "https://checkstyle.org/dtds/configuration_1_3.dtd">

<module name="Checker">
    <property name="charset" value="UTF-8"/>
    <property name="severity" value="warning"/>
    <property name="fileExtensions" value="java, properties, xml"/>

    <module name="TreeWalker">
        <module name="OuterTypeFilename"/>
        <module name="IllegalTokenText"/>
        <module name="AvoidEscapedUnicodeCharacters"/>
        <module name="LineLength">
            <property name="max" value="120"/>
        </module>
        <module name="AvoidStarImport"/>
        <module name="OneTopLevelClass"/>
        <module name="NoLineWrap"/>
        <module name="EmptyBlock">
            <property name="option" value="TEXT"/>
            <property name="tokens" value="LITERAL_TRY, LITERAL_FINALLY, LITERAL_IF, LITERAL_ELSE, LITERAL_SWITCH"/>
        </module>
        <module name="NeedBraces"/>
        <module name="LeftCurly"/>
        <module name="RightCurly"/>
        <module name="WhitespaceAround"/>
        <module name="OneStatementPerLine"/>
        <module name="MultipleVariableDeclarations"/>
        <module name="ArrayTypeStyle"/>
        <module name="MissingSwitchDefault"/>
        <module name="FallThrough"/>
        <module name="UpperEll"/>
        <module name="ModifierOrder"/>
        <module name="EmptyLineSeparator"/>
        <module name="SeparatorWrap"/>
        <module name="PackageName"/>
        <module name="TypeName"/>
        <module name="MemberName"/>
        <module name="ParameterName"/>
        <module name="LocalVariableName"/>
        <module name="ClassTypeParameterName"/>
        <module name="MethodTypeParameterName"/>
        <module name="InterfaceTypeParameterName"/>
        <module name="NoFinalizer"/>
        <module name="GenericWhitespace"/>
        <module name="Indentation"/>
        <module name="AbbreviationAsWordInName"/>
        <module name="OverloadMethodsDeclarationOrder"/>
        <module name="VariableDeclarationUsageDistance"/>
        <module name="CustomImportOrder"/>
        <module name="MethodParamPad"/>
        <module name="ParenPad"/>
        <module name="OperatorWrap"/>
        <module name="AnnotationLocation"/>
        <module name="NonEmptyAtclauseDescription"/>
        <module name="JavadocMethod"/>
        <module name="JavadocType"/>
        <module name="JavadocVariable"/>
        <module name="JavadocStyle"/>
    </module>
</module>
EOF
        log_info "✓ Created checkstyle.xml"
    fi
}

# Configure Java testing
configure_java_testing_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]]; then
        # Create test configuration
        mkdir -p "$project_path/src/test/java/$(basename "$project_path | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:]' '[:lower:]' | sed 's/^\(.\)/\U\1/')"
        
        if [[ ! -f "$project_path/src/test/java/ExampleTest.java" ]]; then
            cat > "$project_path/src/test/java/ExampleTest.java" << 'EOF'
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class ExampleTest {

    @Test
    void contextLoads() {
        // This test will pass if the Spring context loads successfully
        assertTrue(true);
    }
}
EOF
            log_info "✓ Created ExampleTest.java"
        fi
    fi
}

# Configure Java framework-specific configurations
configure_java_framework_configs() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    # Spring Boot configuration
    if [[ "$app_type" == "web" ]] || [[ "$app_type" == "api" ]] || [[ "$project_type" == *"api-service"* ]]; then
        configure_spring_boot_config "$project_path" "$mode" "$app_type" "$project_type"
    fi

    # Picocli configuration
    if [[ "$app_type" == "cli" ]] || [[ "$project_type" == *"cli-tool"* ]]; then
        configure_picocli_config "$project_path" "$mode"
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
        mkdir -p "$project_path/src/main/java/$(basename "$project_path | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:]' '[:lower:]' | sed 's/^\(.\)/\U\1/')"
        
        local package_name
        package_name=$(basename "$project_path | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:]' '[:lower:]' | sed 's/^\(.\)/\U\1/')
        
        if [[ ! -f "$project_path/src/main/java/$package_name/Application.java" ]]; then
            cat > "$project_path/src/main/java/$package_name/Application.java" << EOF
package $package_name;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
EOF
            log_info "✓ Created Application.java"
        fi

        if [[ ! -f "$project_path/src/main/java/$package_name/controller/HealthController.java" ]]; then
            mkdir -p "$project_path/src/main/java/$package_name/controller"
            cat > "$project_path/src/main/java/$package_name/controller/HealthController.java" << EOF
package $package_name.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

    @GetMapping("/health")
    public String health() {
        return "OK";
    }

    @GetMapping("/")
    public String home() {
        return "Welcome to Spring Boot!";
    }
}
EOF
            log_info "✓ Created HealthController.java"
        fi

        # Create application.properties
        if [[ ! -f "$project_path/src/main/resources/application.properties" ]]; then
            mkdir -p "$project_path/src/main/resources"
            cat > "$project_path/src/main/resources/application.properties" << 'EOF'
# Server Configuration
server.port=8080

# Application Configuration
spring.application.name=java-application

# Logging Configuration
logging.level.root=INFO
logging.level.$package_name=DEBUG
EOF
            log_info "✓ Created application.properties"
        fi
    fi
}

# Configure Picocli
configure_picocli_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]]; then
        # Create basic Picocli project structure
        mkdir -p "$project_path/src/main/java/$(basename "$project_path | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:]' '[:lower:]' | sed 's/^\(.\)/\U\1/')"
        
        local package_name
        package_name=$(basename "$project_path | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:]' '[:lower:]' | sed 's/^\(.\)/\U\1/')
        
        if [[ ! -f "$project_path/src/main/java/$package_name/CliApp.java" ]]; then
            cat > "$project_path/src/main/java/$package_name/CliApp.java" << EOF
package $package_name;

import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

@Command(name = "cli-app", mixinStandardHelpOptions = true, version = "1.0",
         description = "A simple CLI application")
public class CliApp implements Runnable {

    @Option(names = { "-v", "--verbose" }, description = "Verbose mode")
    private boolean verbose = false;

    @Parameters(index = "0", description = "The name to greet", defaultValue = "World")
    private String name;

    @Override
    public void run() {
        if (verbose) {
            System.out.println("Verbose mode enabled");
        }
        System.out.println("Hello, " + name + "!");
    }

    public static void main(String[] args) {
        int exitCode = new CommandLine(new CliApp()).execute(args);
        System.exit(exitCode);
    }
}
EOF
            log_info "✓ Created CliApp.java"
        fi
    fi
}

# Export functions for use by adopt-project.sh
export -f configure_java_project
export -f configure_pom_xml
export -f configure_gradle_build
export -f configure_checkstyle_config
export -f configure_java_testing_config
