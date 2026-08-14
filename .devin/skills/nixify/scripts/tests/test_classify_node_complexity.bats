#!/usr/bin/env bats
# test_classify_node_complexity.bats — unit tests for classify-node-complexity.sh
#
# Tests the deterministic detection of Node.js build complexity factors:
#   1. monorepo_separate_lockfiles — subdirectories with own package.json
#   2. custom_build_scripts — build script does more than a standard command
#   3. postinstall_complications — native addons or postinstall scripts
#   4. build_time_network_fetches — next/font/google, telemetry, curl in build
#
# Run via:
#   bats scripts/tests/test_classify_node_complexity.bats
#
# Creates temp scenarios under /tmp/skill-test/nixify/{scenario}/

SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME:-${BASH_SOURCE[0]}}")" && pwd)"
CLASSIFY_SCRIPT="$SCRIPT_DIR/../classify-node-complexity.sh"
TEST_BASE="/tmp/skill-test/nixify"

assert_contains() {
    local needle="$1" haystack="$2"
    [[ "$haystack" == *"$needle"* ]] || {
        echo "expected '$needle' in: '$haystack'" >&3
        return 1
    }
}

assert_not_contains() {
    local needle="$1" haystack="$2"
    [[ "$haystack" != *"$needle"* ]] || {
        echo "did not expect '$needle' in: '$haystack'" >&3
        return 1
    }
}

# Create a scenario dir. Echoes the dir path.
setup_scenario() {
    local scenario="$1"
    local dir="$TEST_BASE/$scenario"
    rm -rf "$dir"
    mkdir -p "$dir"
    echo "$dir"
}

# Write a package.json with given content to a dir
write_pkgjson() {
    local dir="$1" content="$2"
    echo "$content" > "$dir/package.json"
}

# Run the classifier on a dir. Echoes JSON output.
run_classify() {
    local dir="$1"
    bash "$CLASSIFY_SCRIPT" "$dir" 2>/dev/null || true
}

# --- simple project (no complexity factors) ---

@test "simple: single package.json with standard build -> is_complex=false" {
    local dir
    dir=$(setup_scenario simple-standard)
    write_pkgjson "$dir" '{"name":"simple","version":"1.0.0","scripts":{"build":"tsc"},"dependencies":{"express":"^4.0.0"}}'
    local out; out=$(run_classify "$dir")
    assert_contains '"is_complex": false' "$out"
    assert_contains '"recommended_template": "source-build/node.md"' "$out"
    assert_contains '"complexity_factors": []' "$out"
}

@test "simple: vite build -> is_complex=false" {
    local dir
    dir=$(setup_scenario simple-vite)
    write_pkgjson "$dir" '{"name":"app","version":"1.0.0","scripts":{"build":"vite build"},"dependencies":{"vue":"^3.0.0"}}'
    local out; out=$(run_classify "$dir")
    assert_contains '"is_complex": false' "$out"
}

@test "simple: next build without font/google -> is_complex=false" {
    local dir
    dir=$(setup_scenario simple-next)
    write_pkgjson "$dir" '{"name":"nextapp","version":"1.0.0","scripts":{"build":"next build"},"dependencies":{"next":"^14.0.0"}}'
    local out; out=$(run_classify "$dir")
    assert_contains '"is_complex": false' "$out"
}

# --- monorepo_separate_lockfiles ---

@test "monorepo: subdirectory with package.json -> is_complex=true" {
    local dir
    dir=$(setup_scenario monorepo-subdir)
    write_pkgjson "$dir" '{"name":"root","version":"1.0.0","scripts":{"build":"next build"},"dependencies":{"next":"^14.0.0"}}'
    mkdir -p "$dir/cli"
    write_pkgjson "$dir/cli" '{"name":"cli","version":"1.0.0","bin":{"mycli":"./cli.js"}}'
    local out; out=$(run_classify "$dir")
    assert_contains '"is_complex": true' "$out"
    assert_contains '"monorepo_separate_lockfiles"' "$out"
    assert_contains '"recommended_template": "source-build/node-complex.md"' "$out"
}

@test "monorepo: npm workspaces with subdirectory package.json -> is_complex=true" {
    local dir
    dir=$(setup_scenario monorepo-workspaces)
    write_pkgjson "$dir" '{"name":"root","version":"1.0.0","workspaces":["packages/*"],"scripts":{"build":"next build"},"dependencies":{"next":"^14.0.0"}}'
    mkdir -p "$dir/packages/mylib"
    write_pkgjson "$dir/packages/mylib" '{"name":"mylib","version":"1.0.0"}'
    local out; out=$(run_classify "$dir")
    assert_contains '"is_complex": true' "$out"
    assert_contains '"monorepo_separate_lockfiles"' "$out"
}

@test "monorepo: node_modules package.json is ignored" {
    local dir
    dir=$(setup_scenario monorepo-node-modules)
    write_pkgjson "$dir" '{"name":"root","version":"1.0.0","scripts":{"build":"tsc"},"dependencies":{"express":"^4.0.0"}}'
    mkdir -p "$dir/node_modules/express"
    write_pkgjson "$dir/node_modules/express" '{"name":"express","version":"4.0.0"}'
    local out; out=$(run_classify "$dir")
    assert_contains '"is_complex": false' "$out"
    assert_not_contains '"monorepo_separate_lockfiles"' "$out"
}

# --- custom_build_scripts ---

@test "custom_build: build script references scripts/ file -> is_complex=true" {
    local dir
    dir=$(setup_scenario custom-build-script)
    write_pkgjson "$dir" '{"name":"app","version":"1.0.0","scripts":{"build":"node scripts/build-cli.js"},"dependencies":{"next":"^14.0.0"}}'
    local out; out=$(run_classify "$dir")
    assert_contains '"is_complex": true' "$out"
    assert_contains '"custom_build_scripts"' "$out"
}

@test "custom_build: build with esbuild -> is_complex=true" {
    local dir
    dir=$(setup_scenario custom-esbuild)
    write_pkgjson "$dir" '{"name":"app","version":"1.0.0","scripts":{"build":"esbuild src/index.ts --bundle --outfile=dist/bundle.js"},"dependencies":{"esbuild":"^0.20.0"}}'
    local out; out=$(run_classify "$dir")
    assert_contains '"is_complex": true' "$out"
    assert_contains '"custom_build_scripts"' "$out"
}

@test "custom_build: cli:pack wrapper script -> is_complex=true" {
    local dir
    dir=$(setup_scenario custom-cli-pack)
    write_pkgjson "$dir" '{"name":"app","version":"1.0.0","scripts":{"build":"next build","cli:pack":"npm run build && cd cli && npm pack"},"dependencies":{"next":"^14.0.0"}}'
    local out; out=$(run_classify "$dir")
    assert_contains '"is_complex": true' "$out"
    assert_contains '"custom_build_scripts"' "$out"
}

# --- postinstall_complications ---

@test "postinstall: better-sqlite3 dependency -> is_complex=true" {
    local dir
    dir=$(setup_scenario postinstall-sqlite3)
    write_pkgjson "$dir" '{"name":"app","version":"1.0.0","scripts":{"build":"tsc"},"dependencies":{"better-sqlite3":"^11.0.0"}}'
    local out; out=$(run_classify "$dir")
    assert_contains '"is_complex": true' "$out"
    assert_contains '"postinstall_complications"' "$out"
}

@test "postinstall: sharp dependency -> is_complex=true" {
    local dir
    dir=$(setup_scenario postinstall-sharp)
    write_pkgjson "$dir" '{"name":"app","version":"1.0.0","scripts":{"build":"tsc"},"dependencies":{"sharp":"^0.33.0"}}'
    local out; out=$(run_classify "$dir")
    assert_contains '"is_complex": true' "$out"
    assert_contains '"postinstall_complications"' "$out"
}

@test "postinstall: explicit postinstall script -> is_complex=true" {
    local dir
    dir=$(setup_scenario postinstall-script)
    write_pkgjson "$dir" '{"name":"app","version":"1.0.0","scripts":{"build":"tsc","postinstall":"node install.js"},"dependencies":{"some-pkg":"^1.0.0"}}'
    local out; out=$(run_classify "$dir")
    assert_contains '"is_complex": true' "$out"
    assert_contains '"postinstall_complications"' "$out"
}

@test "postinstall: better-sqlite3 in optionalDependencies -> is_complex=true" {
    local dir
    dir=$(setup_scenario postinstall-optional)
    write_pkgjson "$dir" '{"name":"app","version":"1.0.0","scripts":{"build":"tsc"},"optionalDependencies":{"better-sqlite3":"^11.0.0"}}'
    local out; out=$(run_classify "$dir")
    assert_contains '"is_complex": true' "$out"
    assert_contains '"postinstall_complications"' "$out"
}

# --- build_time_network_fetches ---

@test "network_fetch: next/font/google import -> is_complex=true" {
    local dir
    dir=$(setup_scenario network-next-font)
    write_pkgjson "$dir" '{"name":"app","version":"1.0.0","scripts":{"build":"next build"},"dependencies":{"next":"^14.0.0"}}'
    mkdir -p "$dir/src/app"
    echo 'import { Inter } from "next/font/google";' > "$dir/src/app/layout.js"
    local out; out=$(run_classify "$dir")
    assert_contains '"is_complex": true' "$out"
    assert_contains '"build_time_network_fetches"' "$out"
}

@test "network_fetch: next.config.mjs present -> is_complex=true (telemetry)" {
    local dir
    dir=$(setup_scenario network-next-config)
    write_pkgjson "$dir" '{"name":"app","version":"1.0.0","scripts":{"build":"next build"},"dependencies":{"next":"^14.0.0"}}'
    echo 'export default {};' > "$dir/next.config.mjs"
    local out; out=$(run_classify "$dir")
    assert_contains '"is_complex": true' "$out"
    assert_contains '"build_time_network_fetches"' "$out"
}

@test "network_fetch: curl in build script -> is_complex=true" {
    local dir
    dir=$(setup_scenario network-curl)
    write_pkgjson "$dir" '{"name":"app","version":"1.0.0","scripts":{"build":"curl -o data.json https://example.com/data.json && tsc"},"dependencies":{"typescript":"^5.0.0"}}'
    local out; out=$(run_classify "$dir")
    assert_contains '"is_complex": true' "$out"
    assert_contains '"build_time_network_fetches"' "$out"
}

# --- combined factors (9router-like) ---

@test "combined: monorepo + custom_build + postinstall + network_fetch -> is_complex=true, 4 factors" {
    local dir
    dir=$(setup_scenario combined-9router-like)
    write_pkgjson "$dir" '{"name":"app","version":"1.0.0","scripts":{"build":"next build","cli:pack":"npm run build && cd cli && npm pack"},"dependencies":{"next":"^14.0.0","better-sqlite3":"^11.0.0"}}'
    echo 'export default {};' > "$dir/next.config.mjs"
    mkdir -p "$dir/src/app"
    echo 'import { Inter } from "next/font/google";' > "$dir/src/app/layout.js"
    mkdir -p "$dir/cli"
    write_pkgjson "$dir/cli" '{"name":"cli","version":"1.0.0","bin":{"mycli":"./cli.js"}}'
    local out; out=$(run_classify "$dir")
    assert_contains '"is_complex": true' "$out"
    assert_contains '"monorepo_separate_lockfiles"' "$out"
    assert_contains '"custom_build_scripts"' "$out"
    assert_contains '"postinstall_complications"' "$out"
    assert_contains '"build_time_network_fetches"' "$out"
    assert_contains '"recommended_template": "source-build/node-complex.md"' "$out"
    assert_contains '"needs_subagent_validation": true' "$out"
}

# --- subagent validation ---

@test "subagent: is_complex=true -> needs_subagent_validation=true" {
    local dir
    dir=$(setup_scenario subagent-needed)
    write_pkgjson "$dir" '{"name":"app","version":"1.0.0","scripts":{"build":"tsc"},"dependencies":{"better-sqlite3":"^11.0.0"}}'
    local out; out=$(run_classify "$dir")
    assert_contains '"needs_subagent_validation": true' "$out"
    assert_contains '"subagent_checks"' "$out"
}

@test "subagent: is_complex=false -> needs_subagent_validation=false" {
    local dir
    dir=$(setup_scenario subagent-not-needed)
    write_pkgjson "$dir" '{"name":"simple","version":"1.0.0","scripts":{"build":"tsc"},"dependencies":{"express":"^4.0.0"}}'
    local out; out=$(run_classify "$dir")
    assert_contains '"needs_subagent_validation": false' "$out"
}

# --- edge cases ---

@test "edge: no package.json -> is_complex=false (not a node project)" {
    local dir
    dir=$(setup_scenario no-pkgjson)
    echo "hello" > "$dir/readme.txt"
    local out; out=$(run_classify "$dir")
    assert_contains '"is_complex": false' "$out"
}

@test "edge: empty package.json -> is_complex=false" {
    local dir
    dir=$(setup_scenario empty-pkgjson)
    write_pkgjson "$dir" '{}'
    local out; out=$(run_classify "$dir")
    assert_contains '"is_complex": false' "$out"
}
