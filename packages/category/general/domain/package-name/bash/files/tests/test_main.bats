#!/usr/bin/env bats

load test_helper

setup() {
    # Setup before each test
    export TEST_TEMP_DIR=$(mktemp -d)
    cp src/main.sh "$TEST_TEMP_DIR/"
    cd "$TEST_TEMP_DIR"
}

teardown() {
    # Cleanup after each test
    rm -rf "$TEST_TEMP_DIR"
}

@test "script runs without arguments" {
    run ./main.sh
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "[INFO] Starting {{package_name}} v0.1.0" ]
    [ "${lines[1]}" = "Hello from {{package_name}}!" ]
    [ "${lines[2]}" = "[SUCCESS] Script completed successfully" ]
}

@test "script shows help with -h flag" {
    run ./main.sh -h
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "{{package_name}} v0.1.0" ]
    [ "${lines[2]}" = "{{package_description}}" ]
}

@test "script shows help with --help flag" {
    run ./main.sh --help
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "{{package_name}} v0.1.0" ]
    [ "${lines[2]}" = "{{package_description}}" ]
}

@test "script shows version with -v flag" {
    run ./main.sh -v
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "{{package_name}} v0.1.0" ]
}

@test "script shows version with --version flag" {
    run ./main.sh --version
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "{{package_name}} v0.1.0" ]
}

@test "script fails with unknown option" {
    run ./main.sh --unknown
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "[ERROR] Unknown option: --unknown" ]
}

@test "script is executable" {
    [ -x "main.sh" ]
}

@test "script has proper shebang" {
    run head -n1 main.sh
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "#!/bin/bash" ]
}
