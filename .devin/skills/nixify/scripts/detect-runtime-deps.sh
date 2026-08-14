#!/usr/bin/env bash
# Detect runtime service dependencies from project manifests.
# Usage: detect-runtime-deps.sh [project-dir]
#
# Scans Cargo.toml, package.json, pyproject.toml, requirements.txt, or go.mod
# for crate/package imports that imply a runtime service (database, message
# broker, cache, etc.) and outputs the nix packages that should be added to
# devbox.json and devShells.
#
# Output: JSON with:
#   - runtime_deps: array of { crate, nix_package, service, reason }
#   - devbox_packages: array of nix package names to add to devbox.json
#   - devshell_packages: array of nix package names to add to devShells
#   - manifests_scanned: space-separated list of manifests checked
#
# Use --verbose for full scan details.

set -euo pipefail

DIR="${1:-.}"
VERBOSE=""
if [ "${2:-}" = "--verbose" ]; then
  VERBOSE="--verbose"
fi

# ── Build a combined pattern file for efficient single-pass grep ───────────
# Format: dep_name|nix_package|service_name|reason
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

cat >> "$TMPFILE" <<'MAPPING'
surrealdb|surrealdb|SurrealDB|surrealdb crate requires the SurrealDB server
surrealdb-sdk|surrealdb|SurrealDB|surrealdb-sdk requires the SurrealDB server
sqlx|postgresql|PostgreSQL|sqlx with postgres feature needs PostgreSQL
diesel|postgresql|PostgreSQL|diesel with postgres feature needs PostgreSQL
tokio-postgres|postgresql|PostgreSQL|tokio-postgres needs PostgreSQL
postgres|postgresql|PostgreSQL|postgres crate needs PostgreSQL
redis|redis|Redis|redis crate needs Redis server
deadpool-redis|redis|Redis|deadpool-redis needs Redis server
lapin|rabbitmq|RabbitMQ|lapin (AMQP client) needs RabbitMQ
amqp|rabbitmq|RabbitMQ|AMQP client needs RabbitMQ
mongodb|mongodb|MongoDB|mongodb crate needs MongoDB server
elasticsearch|elasticsearch|Elasticsearch|elasticsearch crate needs ES server
scylla|scylladb|ScyllaDB|scylla crate needs ScyllaDB server
clickhouse|clickhouse|ClickHouse|clickhouse crate needs ClickHouse server
rusqlite|sqlite|SQLite|rusqlite may need SQLite CLI for dev
refinery|sqlite|SQLite|refinery migrations may need SQLite CLI
meilisearch-sdk|meilisearch|Meilisearch|meilisearch-sdk needs Meilisearch
pg|postgresql|PostgreSQL|pg (node-postgres) needs PostgreSQL
ioredis|redis|Redis|ioredis needs Redis server
amqplib|rabbitmq|RabbitMQ|amqplib needs RabbitMQ
mongoose|mongodb|MongoDB|mongoose needs MongoDB server
better-sqlite3|sqlite|SQLite|better-sqlite3 may need SQLite CLI for dev
prisma|postgresql|PostgreSQL|prisma commonly used with PostgreSQL
psycopg2|postgresql|PostgreSQL|psycopg2 needs PostgreSQL
psycopg|postgresql|PostgreSQL|psycopg3 needs PostgreSQL
asyncpg|postgresql|PostgreSQL|asyncpg needs PostgreSQL
sqlalchemy|postgresql|PostgreSQL|sqlalchemy commonly used with PostgreSQL
pika|rabbitmq|RabbitMQ|pika (AMQP client) needs RabbitMQ
aio_pika|rabbitmq|RabbitMQ|aio-pika needs RabbitMQ
pymongo|mongodb|MongoDB|pymongo needs MongoDB server
motor|mongodb|MongoDB|motor (async MongoDB) needs MongoDB server
aiosqlite|sqlite|SQLite|aiosqlite may need SQLite CLI for dev
github.com/lib/pq|postgresql|PostgreSQL|lib/pq needs PostgreSQL
github.com/jackc/pgx|postgresql|PostgreSQL|pgx needs PostgreSQL
github.com/redis/go-redis|redis|Redis|go-redis needs Redis server
github.com/go-redis/redis|redis|Redis|go-redis (old) needs Redis server
github.com/streadway/amqp|rabbitmq|RabbitMQ|streadway/amqp needs RabbitMQ
github.com/rabbitmq/amqp091-go|rabbitmq|RabbitMQ|amqp091-go needs RabbitMQ
go.mongodb.org/mongo-driver|mongodb|MongoDB|mongo-driver needs MongoDB
# Java (Maven/Gradle)
org.postgresql|postgresql|PostgreSQL|postgresql JDBC driver needs PostgreSQL
postgresql|postgresql|PostgreSQL|postgresql JDBC driver needs PostgreSQL
mysql-connector|mysql|MySQL|mysql-connector-j needs MySQL
mysql-connector-j|mysql|MySQL|mysql-connector-j needs MySQL
mongodb-driver|mongodb|MongoDB|mongodb-driver needs MongoDB
mongodb-driver-sync|mongodb|MongoDB|mongodb-driver-sync needs MongoDB
mongodb-driver-reactivestreams|mongodb|MongoDB|mongodb-driver-reactivestreams needs MongoDB
jedis|redis|Redis|jedis needs Redis server
lettuce-core|redis|Redis|lettuce needs Redis server
lettuce|redis|Redis|lettuce needs Redis server
amqp-client|rabbitmq|RabbitMQ|amqp-client needs RabbitMQ
spring-boot-starter-data-redis|redis|Redis|spring-data-redis needs Redis
spring-boot-starter-data-mongodb|mongodb|MongoDB|spring-data-mongodb needs MongoDB
spring-boot-starter-data-jpa|postgresql|PostgreSQL|spring-data-jpa commonly uses PostgreSQL
elasticsearch-java|elasticsearch|Elasticsearch|elasticsearch-java needs ES
# .NET (NuGet packages)
Npgsql|postgresql|PostgreSQL|Npgsql needs PostgreSQL
StackExchange.Redis|redis|Redis|StackExchange.Redis needs Redis
MongoDB.Driver|mongodb|MongoDB|MongoDB.Driver needs MongoDB
RabbitMQ.Client|rabbitmq|RabbitMQ|RabbitMQ.Client needs RabbitMQ
Elastic.Clients.Elasticsearch|elasticsearch|Elasticsearch|Elastic.Clients.Elasticsearch needs ES
Microsoft.Data.Sqlite|sqlite|SQLite|Microsoft.Data.Sqlite may need SQLite CLI for dev
# PHP (Composer packages)
predis|redis|Redis|predis needs Redis server
phpredis|redis|Redis|phpredis extension needs Redis server
ext-redis|redis|Redis|redis extension needs Redis server
mongodb/mongodb|mongodb|MongoDB|mongodb/mongodb needs MongoDB
php-amqplib|rabbitmq|RabbitMQ|php-amqplib needs RabbitMQ
ext-pdo_pgsql|postgresql|PostgreSQL|pdo_pgsql extension needs PostgreSQL
ext-pdo_mysql|mysql|MySQL|pdo_mysql extension needs MySQL
elasticsearch/elasticsearch|elasticsearch|Elasticsearch|elasticsearch-php needs ES
# Ruby (Gems)
pg|postgresql|PostgreSQL|pg gem needs PostgreSQL
mysql2|mysql|MySQL|mysql2 gem needs MySQL
redis|redis|Redis|redis-rb needs Redis server
mongo|mongodb|MongoDB|mongo-ruby-driver needs MongoDB
bunny|rabbitmq|RabbitMQ|bunny needs RabbitMQ
sqlite3|sqlite|SQLite|sqlite3 gem may need SQLite CLI for dev
elasticsearch|elasticsearch|Elasticsearch|elasticsearch-ruby needs ES
MAPPING

# ── Collect all manifest files to scan ─────────────────────────────────────
manifests=()

# Rust: Cargo.toml (root + workspace members)
if [ -f "$DIR/Cargo.toml" ]; then
  manifests+=("$DIR/Cargo.toml")
  for f in "$DIR"/crates/*/Cargo.toml "$DIR"/packages/*/Cargo.toml; do
    [ -f "$f" ] && manifests+=("$f")
  done
fi

# Node.js: package.json
[ -f "$DIR/package.json" ] && manifests+=("$DIR/package.json")

# Python: pyproject.toml or requirements.txt
[ -f "$DIR/pyproject.toml" ] && manifests+=("$DIR/pyproject.toml")
[ -f "$DIR/requirements.txt" ] && manifests+=("$DIR/requirements.txt")

# Go: go.mod
[ -f "$DIR/go.mod" ] && manifests+=("$DIR/go.mod")

# Java: pom.xml (Maven) or build.gradle (Gradle)
[ -f "$DIR/pom.xml" ] && manifests+=("$DIR/pom.xml")
[ -f "$DIR/build.gradle" ] && manifests+=("$DIR/build.gradle")
[ -f "$DIR/build.gradle.kts" ] && manifests+=("$DIR/build.gradle.kts")

# .NET: .csproj, .fsproj, .vbproj, packages.config
for f in "$DIR"/*.csproj "$DIR"/*.fsproj "$DIR"/*.vbproj "$DIR"/packages.config; do
  [ -f "$f" ] && manifests+=("$f")
done

# PHP: composer.json
[ -f "$DIR/composer.json" ] && manifests+=("$DIR/composer.json")

# Ruby: Gemfile
[ -f "$DIR/Gemfile" ] && manifests+=("$DIR/Gemfile")

if [ ${#manifests[@]} -eq 0 ]; then
  echo '{"runtime_deps":[],"devbox_packages":[],"devshell_packages":[],"manifests_scanned":""}'
  exit 0
fi

# ── Single-pass: grep all manifests at once against all patterns ───────────
# Build a list of dep names (first field) for word-matching
dep_names=$(cut -d'|' -f1 "$TMPFILE" | sort -u)

# Grep all manifests in one pass, output matching dep names
# -w: word boundary, -F: fixed strings, -o: only matching, -h: no filename
matched=$(grep -whoFf <(echo "$dep_names") "${manifests[@]}" 2>/dev/null | sort -u || true)

if [ -z "$matched" ]; then
  manifests_str=$(echo "${manifests[@]}" | xargs -n1 | xargs)
  echo "{\"runtime_deps\":[],\"devbox_packages\":[],\"devshell_packages\":[],\"manifests_scanned\":\"$manifests_str\"}"
  exit 0
fi

# ── Build JSON from matched deps ───────────────────────────────────────────
runtime_deps_json="[]"
devbox_pkgs_json="[]"

while IFS= read -r dep; do
  [ -z "$dep" ] && continue
  # Look up the mapping for this dep
  line=$(grep "^${dep}|" "$TMPFILE" | head -1)
  [ -z "$line" ] && continue
  IFS='|' read -r _ nix_pkg service reason <<< "$line"
  runtime_deps_json=$(echo "$runtime_deps_json" | jq \
    --arg dep "$dep" --arg nix "$nix_pkg" --arg svc "$service" --arg rsn "$reason" \
    '. + [{"crate": $dep, "nix_package": $nix, "service": $svc, "reason": $rsn}]')
done <<< "$matched"

# Deduplicate and extract nix package names
devbox_pkgs_json=$(echo "$runtime_deps_json" | jq '[.[].nix_package] | unique')

manifests_str=$(echo "${manifests[@]}" | xargs -n1 | xargs)

result=$(jq -n \
  --argjson runtime_deps "$runtime_deps_json" \
  --argjson devbox_packages "$devbox_pkgs_json" \
  --argjson devshell_packages "$devbox_pkgs_json" \
  --arg manifests "$manifests_str" \
  '{runtime_deps: $runtime_deps, devbox_packages: $devbox_packages, devshell_packages: $devshell_packages, manifests_scanned: $manifests}')

if [ -n "$VERBOSE" ]; then
  echo "$result" | jq .
  dep_count=$(echo "$result" | jq '.runtime_deps | length')
  if [ "$dep_count" -gt 0 ]; then
    echo "[detect-runtime-deps] Found $dep_count runtime service dependency(ies)."
    echo "[detect-runtime-deps] Add these nix packages to devbox.json and devShells:"
    echo "$result" | jq -r '.devbox_packages[]?'
  else
    echo "[detect-runtime-deps] No runtime service dependencies detected."
  fi
else
  echo "$result" | jq -c .
fi
