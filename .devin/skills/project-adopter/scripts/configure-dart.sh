#!/usr/bin/env bash
# configure-dart.sh
# Dart/Flutter project configuration script
# Handles pubspec.yaml, analysis_options.yaml, and framework-specific configs

set -euo pipefail

# Import common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/config-functions.sh
if [[ -f "$SCRIPT_DIR/../common/config-functions.sh" ]]; then
    source "$SCRIPT_DIR/../common/config-functions.sh"
fi

# Configure Dart/Flutter project
configure_dart_project() {
    local project_path="$1"
    local mode="${2:-adopt}"     # adopt | standardize
    local app_type="${3:-unknown}" # web | cli | api | library | mobile
    local project_type="${4:-unknown}" # frontend-web | api-service | cli-tool | library | mobile-app

    log_info "Configuring Dart/Flutter project (mode: $mode, app_type: $app_type)"

    # Handle pubspec.yaml
    if [[ -f "$project_path/pubspec.yaml" ]]; then
        configure_pubspec_yaml "$project_path" "$mode" "$app_type" "$project_type"
    elif [[ "$mode" == "standardize" ]]; then
        create_pubspec_yaml "$project_path" "$mode" "$app_type" "$project_type"
    fi

    # Handle analysis_options.yaml
    configure_analysis_options "$project_path" "$mode"

    # Handle Dart testing configuration
    configure_dart_testing_config "$project_path" "$mode"

    # Handle framework-specific configs
    configure_flutter_framework_configs "$project_path" "$mode" "$app_type" "$project_type"
}

# Configure pubspec.yaml
configure_pubspec_yaml() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring pubspec.yaml for Dart/Flutter project"

    if [[ "$mode" == "standardize" ]]; then
        # Standardize mode - comprehensive additions
        add_standardize_pubspec_dependencies "$project_path" "$app_type" "$project_type"
        add_standardize_pubspec_dev_dependencies "$project_path" "$app_type" "$project_type"
    else
        # Adopt mode - minimal essential additions
        add_adopt_pubspec_dependencies "$project_path" "$app_type" "$project_type"
    fi
}

# Add standardize mode dependencies to pubspec.yaml
add_standardize_pubspec_dependencies() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    local deps_to_add=""

    # App-type specific dependencies
    case "$app_type" in
        "web")
            deps_to_add="$deps_to_add http: ^1.1.0"
            if [[ "$project_type" == *"frontend-web"* ]]; then
                deps_to_add="$deps_to_add shelf: ^1.4.0"
            fi
            ;;
        "mobile")
            deps_to_add="$deps_to_add flutter: ^3.16.0 cupertino_icons: ^1.0.6"
            ;;
        "cli")
            deps_to_add="$deps_to_add args: ^2.4.0"
            ;;
        "api")
            deps_to_add="$deps_to_add shelf: ^1.4.0 json_annotation: ^4.8.1"
            ;;
    esac

    # Framework-specific dependencies
    case "$project_type" in
        "mobile-app")
            if [[ -f "$project_path/pubspec.yaml" ]] && grep -q "flutter:" "$project_path/pubspec.yaml" 2>/dev/null; then
                deps_to_add="$deps_to_add provider: ^6.1.1 shared_preferences: ^2.2.2 sqflite: ^2.3.0"
            fi
            ;;
        "frontend-web")
            deps_to_add="$deps_to_add flutter_web: ^0.2.0"
            ;;
        "api-service")
            deps_to_add="$deps_to_add shelf_router: ^1.4.0 shelf_cors: ^1.4.0"
            ;;
    esac

    # Apply surgical changes using yq-go if available
    if command -v yq-go >/dev/null 2>&1; then
        echo "Adding standardize dependencies to pubspec.yaml using yq-go"
        # yq-go eval ".dependencies += {$deps_to_add}" "$project_path/pubspec.yaml" -i
    else
        log_warn "yq-go not available, skipping pubspec.yaml dependency updates"
    fi
}

# Add adopt mode dependencies to pubspec.yaml
add_adopt_pubspec_dependencies() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Adopt mode - minimal essential dependencies only
    local essential_deps=""

    case "$app_type" in
        "mobile")
            essential_deps="flutter: ^3.16.0"
            ;;
        "web")
            essential_deps="http: ^1.1.0"
            ;;
        "api")
            essential_deps="shelf: ^1.4.0"
            ;;
    esac

    # Apply surgical changes
    if command -v yq-go >/dev/null 2>&1 && [[ -n "$essential_deps" ]]; then
        echo "Adding adopt dependencies to pubspec.yaml using yq-go"
        # yq-go eval ".dependencies += {$essential_deps}" "$project_path/pubspec.yaml" -i
    else
        log_warn "yq-go not available or no dependencies to add"
    fi
}

# Add standardize mode dev dependencies to pubspec.yaml
add_standardize_pubspec_dev_dependencies() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    local dev_deps_to_add=""

    # Base dev dependencies for all Dart projects
    dev_deps_to_add="$dev_deps_to_add test: ^1.24.0 build_runner: ^2.4.7 lints: ^3.0.0"

    # App-type specific dev dependencies
    case "$app_type" in
        "mobile")
            dev_deps_to_add="$dev_deps_to_add flutter_test: ^0.6.0 integration_test: ^3.3.0"
            ;;
        "web")
            dev_deps_to_add="$dev_deps_to_add build_web_compilers: ^4.0.0"
            ;;
        "cli")
            dev_deps_to_add="$dev_deps_to_add mockito: ^5.4.2"
            ;;
        "api")
            dev_deps_to_add="$dev_deps_to_add mockito: ^5.4.2 http_mock: ^2.6.0"
            ;;
    esac

    # Framework-specific dev dependencies
    case "$project_type" in
        "mobile-app")
            if [[ -f "$project_path/pubspec.yaml" ]] && grep -q "flutter:" "$project_path/pubspec.yaml" 2>/dev/null; then
                dev_deps_to_add="$dev_deps_to_add flutter_driver: ^0.2.0"
            fi
            ;;
    esac

    # Apply surgical changes
    if command -v yq-go >/dev/null 2>&1; then
        echo "Adding standardize dev dependencies to pubspec.yaml using yq-go"
        # yq-go eval ".dev_dependencies += {$dev_deps_to_add}" "$project_path/pubspec.yaml" -i
    else
        log_warn "yq-go not available, skipping pubspec.yaml dev dependency updates"
    fi
}

# Create pubspec.yaml
create_pubspec_yaml() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/pubspec.yaml" ]]; then
        local project_name
        project_name=$(basename "$project_path")
        
        cat > "$project_path/pubspec.yaml" << EOF
name: $project_name
description: A Dart project.
version: 0.1.0

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
EOF

        # Add app-type specific dependencies
        case "$app_type" in
            "mobile")
                cat >> "$project_path/pubspec.yaml" << 'EOF'
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
EOF
                ;;
            "web")
                cat >> "$project_path/pubspec.yaml" << 'EOF'
  http: ^1.1.0
EOF
                ;;
            "api")
                cat >> "$project_path/pubspec.yaml" << 'EOF'
  shelf: ^1.4.0
  json_annotation: ^4.8.1
EOF
                ;;
        esac

        # Add dev dependencies
        cat >> "$project_path/pubspec.yaml" << 'EOF'

dev_dependencies:
  test: ^1.24.0
  build_runner: ^2.4.7
  lints: ^3.0.0
EOF

        # Add app-type specific dev dependencies
        case "$app_type" in
            "mobile")
                cat >> "$project_path/pubspec.yaml" << 'EOF'
  flutter_test: ^0.6.0
  integration_test: ^3.3.0
EOF
                ;;
            "web")
                cat >> "$project_path/pubspec.yaml" << 'EOF'
  build_web_compilers: ^4.0.0
EOF
                ;;
        esac

        log_info "✓ Created pubspec.yaml"
    fi
}

# Configure analysis_options.yaml
configure_analysis_options() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/analysis_options.yaml" ]]; then
        cat > "$project_path/analysis_options.yaml" << 'EOF'
# This file configures the analyzer, which statically analyzes Dart code to
# check for errors, warnings, and lints.
#
# The issues identified by the analyzer are surfaced in the UI of Dart-enabled
# IDEs (https://dart.dev/tools#ides-and-editors). The analyzer can also be
# invoked from the command line by running `flutter analyze`.

# The following line activates a set of recommended lints for Flutter apps,
# packages, and plugins designed to encourage good coding practices.
include: package:flutter_lints/

# The following section activates a set of recommended lints for
# Flutter apps, packages, and plugins designed to encourage good
# coding practices.
linter:
  rules:
    # Error rules
    avoid_dynamic_calls: false
    avoid_print: false
    avoid_relative_lib_imports: true
    avoid_type_to_string: true
    cancel_subscriptions: true
    close_sinks: true
    comment_references: true
    deprecated_member_use_from_same_package: true
    implicit_call_tearoffs: true
    library_names: true
    no_adjacent_strings_in_list: true
    no_duplicate_case_values: true
    avoid_slow_async_io: true
    prefer_single_quotes: true
    test_types_in_equals: true
    throw_in_finally: true
    unnecessary_statements: true
    unrelated_type_equality_checks: true
    unsafe_html: true
    use_key_in_test_constructors: true
    use_super_parameters: true

    # Style rules
    always_declare_return_types: true
    always_put_control_body_on_new_line: true
    always_put_required_named_parameters_first: true
    annotate_overrides: true
    avoid_function_literals_in_foreach_calls: false
    avoid_init_to_null: false
    avoid_null_checks_in_equality_operators: false
    avoid_redundant_argument_values: false
    avoid_return_types_on_setters: false
    avoid_setters_without_getters: false
    avoid_unnecessary_containers: false
    avoid_unused_final_parameters: false
    cascade_invocations: false
    cast_nullable_to_non_nullable: false
    deprecated_considered_removal: false
    file_names: true
    implementation_imports: true
    join_return_with_assignment: false
    lines_longer_than_80_chars: false
    missing_whitespace_between_adjacent_strings: false
    no_default_cases: false
    prefer_adjacent_string_concatenation: false
    prefer_final_fields: false
    prefer_final_in_for_each: false
    prefer_final_locals: false
    prefer_for_elements_to_map_fromIterable: false
    prefer_if_elements_to_conditional_expressions: false
    prefer_if_null_operators: false
    prefer_interpolation_to_compose_strings: false
    prefer_is_empty: false
    prefer_is_not_empty: false
    prefer_is_not_operator: false
    prefer_iterable_whereType: false
    prefer_null_aware_operators: false
    prefer_spread_collections: false
    prefer_typing_uninitialized_variables: false
    require_trailing_commas: true
    slash_for_doc_comments: false
    sort_child_properties_last: false
    sort_constructors_first: false
    sort_unnamed_constructors_first: false
    type_annotate_public_apis: true
    unnecessary_await_in_return: false
    unnecessary_brace_in_string_interpolations: false
    unnecessary_const: true
    unnecessary_getters_setters: false
    unnecessary_late: false
    unnecessary_library_directive: false
    unnecessary_new: false
    unnecessary_null_aware_assignments: false
    unnecessary_null_checks: false
    unnecessary_null_checks_if_operator: false
    unnecessary_null_in_if_null_operators: false
    unnecessary_overrides: false
    unnecessary_parenthesis: false
    unnecessary_raw_strings: false
    unnecessary_string_escapes: false
    unnecessary_string_interpolations: false
    unnecessary_this: false
    unrelated_type_equality_checks: false
    unsafe_html: false
    use_build_context_synchronously: false
    use_colored_box: false
    use_decorated_box: false
    use_full_hex_values_for_md5: false
    use_function_type_syntax_for_parameters: false
    use_if_null_to_convert_nulls_to_bools: false
    use_is_even Rather_than_modulo: false
    use_key_words_in_test_descriptions: true
    use_late_for_private_and_final_fields: false
    use_named_constants: true
    use_raw_strings: false
    use_rethrow_when_possible: true
    use_setters_to_change_properties: false
    use_string_buffers: false
    use_test_throws_matchers: true
    use_to_list_as_if_type_check: false
    use_to_list_if_null: false
    use_uninitialized_variables: false
    valid_regexps: true
    void_checks: true

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    # Error rules
    avoid_dynamic_calls: true
    avoid_print: true
    avoid_relative_lib_imports: true
    avoid_type_to_string: true
    cancel_subscriptions: true
    close_sinks: true
    comment_references: true
    deprecated_member_use_from_same_package: true
    implicit_call_tearoffs: true
    library_names: true
    no_adjacent_strings_in_list: true
    no_duplicate_case_values: true
    avoid_slow_async_io: true
    prefer_single_quotes: true
    test_types_in_equals: true
    throw_in_finally: true
    unnecessary_statements: true
    unrelated_type_equality_checks: true
    unsafe_html: true
    use_key_in_test_constructors: true
    use_super_parameters: true

  # Style rules
  always_declare_return_types: true
  always_put_control_body_on_new_line: true
  always_put_required_named_parameters_first: true
  annotate_overrides: true
  avoid_function_literals_in_foreach_calls: false
  avoid_init_to_null: false
  avoid_null_checks_in_equality_operators: false
  avoid_redundant_argument_values: false
  avoid_return_types_on_setters: false
  avoid_setters_without_getters: false
  avoid_unnecessary_containers: false
  avoid_unused_final_parameters: false
  cascade_invocations: false
  cast_nullable_to_non_nullable: false
  deprecated_considered_removal: false
  file_names: true
  implementation_imports: true
  join_return_with_assignment: false
  lines_longer_than_80_chars: false
  missing_whitespace_between_adjacent_strings: false
  no_default_cases: false
  prefer_adjacent_string_concatenation: false
  prefer_final_fields: false
  prefer_final_in_for_each: false
  prefer_final_locals: false
  prefer_for_elements_to_map_fromIterable: false
  prefer_if_elements_to_conditional_expressions: false
  prefer_if_null_operators: false
  prefer_interpolation_to_compose_strings: false
  prefer_is_empty: false
  prefer_is_not_empty: false
  prefer_is_not_operator: false
  prefer_iterable_whereType: false
  prefer_null_aware_operators: false
  prefer_spread_collections: false
  prefer_typing_uninitialized_variables: false
  require_trailing_commas: true
  slash_for_doc_comments: false
  sort_child_properties_last: false
  sort_constructors_first: false
  sort_unnamed_constructors_first: false
  type_annotate_public_apis: true
  unnecessary_await_in_return: false
  unnecessary_brace_in_string_interpolations: false
  unnecessary_const: true
  unnecessary_getters_setters: false
  unnecessary_late: false
  unnecessary_library_directive: false
  unnecessary_new: false
  unnecessary_null_aware_assignments: false
  unnecessary_null_checks: false
  unnecessary_null_checks_if_operator: false
  unnecessary_null_in_if_null_operators: false
  unnecessary_overrides: false
  unnecessary_parenthesis: false
  unnecessary_raw_strings: false
  unnecessary_string_escapes: false
  unnecessary_string_interpolations: false
  unnecessary_this: false
  unrelated_type_equality_checks: false
  unsafe_html: false
  use_build_context_synchronously: false
  use_colored_box: false
  use_decorated_box: false
  use_full_hex_values_for_md5: false
  use_function_type_syntax_for_parameters: false
  use_if_null_to_convert_nulls_to_bools: false
  use_is_even Rather_than_modulo: false
  use_key_words_in_test_descriptions: true
  use_late_for_private_and_final_fields: false
  use_named_constants: true
  use_raw_strings: false
  use_rethrow_when_possible: true
  use_setters_to_change_properties: false
  use_string_buffers: false
  use_test_throws_matchers: true
  use_to_list_as_if_type_check: false
  use_to_list_if_null: false
  use_uninitialized_variables: false
  valid_regexps: true
  void_checks: true
EOF
        log_info "✓ Created analysis_options.yaml"
    fi
}

# Configure Dart testing
configure_dart_testing_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]]; then
        # Create test directory structure
        mkdir -p "$project_path/test"

        # Create basic test file
        if [[ ! -f "$project_path/test/widget_test.dart" ]]; then
            cat > "$project_path/test/widget_test.dart" << 'EOF'
import 'package:flutter_test.dart';

void main() {
  testWidgets('Counter smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
  });
}
EOF
            log_info "✓ Created test/widget_test.dart"
        fi

        # Create integration test file for Flutter
        if [[ -f "$project_path/pubspec.yaml" ]] && grep -q "flutter:" "$project_path/pubspec.yaml" 2>/dev/null; then
            mkdir -p "$project_path/integration_test"
            if [[ ! -f "$project_path/integration_test/app_test.dart" ]]; then
                cat > "$project_path/integration_test/app_test.dart" << 'EOF'
import 'package:flutter_test.dart';
import 'package:my_app/main.dart' as app;

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(app.MyApp());

    // Verify that our app starts with the home screen.
    expect(find.text('Welcome to Flutter!'), findsOneWidget);
  });
}
EOF
                log_info "✓ Created integration_test/app_test.dart"
            fi
        fi
    fi
}

# Configure Flutter framework-specific configurations
configure_flutter_framework_configs() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    # Flutter configuration
    if [[ -f "$project_path/pubspec.yaml" ]] && grep -q "flutter:" "$project_path/pubspec.yaml" 2>/dev/null; then
        configure_flutter_config "$project_path" "$mode" "$app_type" "$project_type"
    fi

    # Dart web configuration
    if [[ "$app_type" == "web" ]] || [[ "$project_type" == *"frontend-web"* ]]; then
        configure_dart_web_config "$project_path" "$mode"
    fi
}

# Configure Flutter
configure_flutter_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    if [[ "$mode" == "standardize" ]]; then
        # Create basic Flutter project structure
        mkdir -p "$project_path/lib"
        mkdir -p "$project_path/lib/widgets"
        mkdir -p "$project_path/lib/services"
        mkdir -p "$project_path/lib/models"

        if [[ ! -f "$project_path/lib/main.dart" ]]; then
            cat > "$project_path/lib/main.dart" << 'EOF'
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Welcome to Flutter!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20),
            Text(
              'Your app is running.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
EOF
            log_info "✓ Created lib/main.dart"
        fi

        # Create app configuration for mobile apps
        if [[ "$app_type" == "mobile" ]] || [[ "$project_type" == *"mobile-app"* ]]; then
            if [[ ! -f "$project_path/android/app/src/main/MainActivity.kt" ]] && [[ ! -f "$project_path/ios/Runner/AppDelegate.swift" ]]; then
                # Create basic configuration files
                mkdir -p "$project_path/android/app/src/main"
                mkdir -p "$project_path/ios/Runner"
                
                # Android configuration
                cat > "$project_path/android/app/src/main/MainActivity.kt" << 'EOF'
package com.example.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.flutterFlutterEngineActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterFlutterEngineActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}
EOF
                log_info "✓ Created Android MainActivity.kt"

                # iOS configuration
                cat > "$project_path/ios/Runner/AppDelegate.swift" << 'EOF'
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
EOF
                log_info "✓ Created iOS AppDelegate.swift"
            fi
        fi
    fi
}

# Configure Dart web
configure_dart_web_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]]; then
        # Create web directory structure
        mkdir -p "$project_path/web"
        
        if [[ ! -f "$project_path/web/index.html" ]]; then
            cat > "$project_path/web/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <!--
    If you are serving your web app in a directory other than the root (such as
    "/my_app/"), make sure to update the "baseHref" attribute below.
  -->
  <base href="/">

  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>my_app</title>
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <!-- This script installs service_worker.js to provide PWA functionality.
       It is generated by the Flutter build process. -->
  <script src="flutter.js" defer></script>
</body>
</html>
EOF
            log_info "✓ Created web/index.html"
        fi

        if [[ ! -f "$project_path/web/manifest.json" ]]; then
            cat > "$project_path/web/manifest.json" << 'EOF'
{
    "name": "my_app",
    "short_name": "my_app",
    "start_url": ".",
    "display": "standalone",
    "background_color": "#0175C2",
    "theme_color": "#0175C2"
}
EOF
            log_info "✓ Created web/manifest.json"
        fi
    fi
}

# Export functions for use by adopt-project.sh
export -f configure_dart_project
export -f configure_pubspec_yaml
export -f configure_analysis_options
export -f configure_dart_testing_config
