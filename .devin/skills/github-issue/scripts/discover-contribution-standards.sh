#!/usr/bin/env bash
# Discover and cache a repository's contribution standards (issue/PR templates,
# CONTRIBUTING.md, CODEOWNERS, changelog format, lint configs, AI agent rules).
#
# Caches to ${XDG_CACHE_HOME:-~/.cache}/skills/<namespace>/skills/<skill-name>/<host>/<owner>/<repo>/standards.md
# with a 7-day TTL recorded in frontmatter (date.knowledge-basis).
# If the cache is fresh (<7 days), outputs the cached file path and exits 0
# without re-crawling. If stale or missing, re-crawls and updates the cache.
#
# Usage: discover-contribution-standards.sh <owner> <repo> [--skill <name>] [--force] [--json]
#   --skill <name>   Skill namespace for cache path (default: github-issue)
#   --force          Re-crawl even if cache is fresh
#   --json           Output JSON with cache_path, crawled, age_days fields
# Output: path to the cache file (or JSON if --json)
# Exit: 0 = success, 1 = usage error, 2 = API error

set -euo pipefail

OWNER="${1:?Usage: discover-contribution-standards.sh <owner> <repo> [--skill <name>] [--force] [--json]}"
REPO="${2:?Usage: discover-contribution-standards.sh <owner> <repo> [--skill <name>] [--force] [--json]}"
shift 2

SKILL_NAME="github-issue"
FORCE=""
JSON_OUT=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --skill) SKILL_NAME="$2"; shift 2 ;;
    --force) FORCE="1"; shift ;;
    --json) JSON_OUT="1"; shift ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

# Detect forge from the repo owner/repo (GitHub assumed for owner/repo format;
# for self-hosted, pass full URL as OWNER)
HOST="github"
case "$OWNER" in
  *gitlab.com*|*gitlab.*) HOST="gitlab" ;;
  *codeberg.org*|*forgejo*) HOST="forgejo" ;;
  *gitea*) HOST="gitea" ;;
  *bitbucket.org*) HOST="bitbucket" ;;
  *) HOST="github" ;;
esac

# Cache path
CACHE_BASE="${XDG_CACHE_HOME:-$HOME/.cache}"
CACHE_DIR="$CACHE_BASE/skills/levonk/skills-src/skills/$SKILL_NAME/$HOST/$OWNER/$REPO"
CACHE_FILE="$CACHE_DIR/standards.md"
TTL_DAYS=7

mkdir -p "$CACHE_DIR"

# Check cache freshness
CRAWLED="1"
AGE_DAYS=""
if [ -f "$CACHE_FILE" ] && [ -z "$FORCE" ]; then
  # Extract date.knowledge-basis from frontmatter
  KB_DATE=$(awk '/^date:/{f=1} f && /knowledge-basis:/{gsub(/["[:space:]]/,"",$2); print $2; exit}' "$CACHE_FILE" 2>/dev/null || echo "")
  if [ -n "$KB_DATE" ]; then
    # Calculate age in days (requires date command with -d support or BSD date)
    if date -d "$KB_DATE" +%s >/dev/null 2>&1; then
      # GNU date
      KB_EPOCH=$(date -d "$KB_DATE" +%s)
    else
      # BSD date (macOS)
      KB_EPOCH=$(date -j -f "%Y-%m-%d" "$KB_DATE" +%s 2>/dev/null || echo "0")
    fi
    NOW_EPOCH=$(date +%s)
    AGE_DAYS=$(( (NOW_EPOCH - KB_EPOCH) / 86400 ))
    if [ "$AGE_DAYS" -lt "$TTL_DAYS" ]; then
      CRAWLED="0"
      # Update last-used date in cache
      TODAY=$(date +%Y-%m-%d)
      if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "s/last-used: \".*\"/last-used: \"$TODAY\"/" "$CACHE_FILE" 2>/dev/null || true
      else
        sed -i "s/last-used: \".*\"/last-used: \"$TODAY\"/" "$CACHE_FILE" 2>/dev/null || true
      fi
    fi
  fi
fi

if [ "$CRAWLED" = "0" ]; then
  # Cache hit
  if [ "$JSON_OUT" = "1" ]; then
    echo "{\"cache_path\": \"$CACHE_FILE\", \"crawled\": false, \"age_days\": ${AGE_DAYS:-0}}"
  else
    echo "$CACHE_FILE"
  fi
  exit 0
fi

# --- Crawl (cache miss or forced) ---

TODAY=$(date +%Y-%m-%d)
API_BASE="https://api.github.com/repos/$OWNER/$REPO/contents"

# Helper: fetch file content from GitHub API
fetch_file() {
  local path="$1"
  curl -sL "$API_BASE/$path" 2>/dev/null | jq -r '.content' 2>/dev/null | base64 -d 2>/dev/null || echo ""
}

# Helper: list directory contents from GitHub API
list_dir() {
  local path="$1"
  curl -sL "$API_BASE/$path" 2>/dev/null | jq -r '.[].name' 2>/dev/null || echo ""
}

# Start building the cache file
{
  echo "---"
  echo "date:"
  echo "  knowledge-basis: \"$TODAY\""
  echo "  last-used: \"$TODAY\""
  echo "cache-ttl-days: $TTL_DAYS"
  echo "forge: \"$HOST\""
  echo "owner: \"$OWNER\""
  echo "repo: \"$REPO\""
  echo "---"
  echo ""
  echo "# Contribution Standards: $OWNER/$REPO"
  echo ""
  echo "Crawled on $TODAY from $HOST."
  echo ""

  # CONTRIBUTING.md
  echo "## Contribution Guidelines"
  echo ""
  CONTRIBUTING_PATH=""
  for path in "CONTRIBUTING.md" ".github/CONTRIBUTING.md" "docs/CONTRIBUTING.md" ".gitlab/CONTRIBUTING.md" ".forgejo/CONTRIBUTING.md" ".gitea/CONTRIBUTING.md"; do
    CONTENT=$(fetch_file "$path")
    if [ -n "$CONTENT" ] && [ "$CONTENT" != "" ]; then
      CONTRIBUTING_PATH="$path"
      echo "**Found at**: \`$path\`"
      echo ""
      echo '```markdown'
      echo "$CONTENT" | head -200
      echo '```'
      echo ""
      break
    fi
  done
  if [ -z "$CONTRIBUTING_PATH" ]; then
    echo "No CONTRIBUTING.md found."
    echo ""
  fi

  # Issue templates
  echo "## Issue Templates"
  echo ""
  ISSUE_TEMPLATE_DIR=""
  for path in ".github/ISSUE_TEMPLATE" "ISSUE_TEMPLATE" "docs/ISSUE_TEMPLATE" ".gitlab/ISSUE_TEMPLATE" ".forgejo/ISSUE_TEMPLATE" ".gitea/ISSUE_TEMPLATE"; do
    FILES=$(list_dir "$path")
    if [ -n "$FILES" ] && [ "$FILES" != "" ]; then
      ISSUE_TEMPLATE_DIR="$path"
      echo "**Found at**: \`$path\`"
      echo ""
      echo "$FILES" | while read -r fname; do
        [ -z "$fname" ] && continue
        echo "### $fname"
        echo ""
        CONTENT=$(fetch_file "$path/$fname")
        if [ -n "$CONTENT" ]; then
          echo '```markdown'
          echo "$CONTENT"
          echo '```'
        fi
        echo ""
      done
      break
    fi
  done
  if [ -z "$ISSUE_TEMPLATE_DIR" ]; then
    echo "No issue templates found."
    echo ""
  fi

  # PR templates
  echo "## PR Templates"
  echo ""
  PR_TEMPLATE_PATH=""
  for path in ".github/PULL_REQUEST_TEMPLATE.md" ".github/pull_request_template.md" "PULL_REQUEST_TEMPLATE.md" "docs/PULL_REQUEST_TEMPLATE.md" ".forgejo/pull_request_template.md" ".gitea/pull_request_template.md"; do
    CONTENT=$(fetch_file "$path")
    if [ -n "$CONTENT" ] && [ "$CONTENT" != "" ]; then
      PR_TEMPLATE_PATH="$path"
      echo "**Found at**: \`$path\`"
      echo ""
      echo '```markdown'
      echo "$CONTENT"
      echo '```'
      echo ""
      break
    fi
  done
  if [ -z "$PR_TEMPLATE_PATH" ]; then
    echo "No PR template found."
    echo ""
  fi

  # Issue template config (chooser)
  echo "## Issue Template Config"
  echo ""
  CONFIG_CONTENT=$(fetch_file ".github/ISSUE_TEMPLATE/config.yml")
  if [ -n "$CONFIG_CONTENT" ] && [ "$CONFIG_CONTENT" != "" ]; then
    echo "**Found at**: \`.github/ISSUE_TEMPLATE/config.yml\`"
    echo ""
    echo '```yaml'
    echo "$CONFIG_CONTENT"
    echo '```'
    echo ""
    if echo "$CONFIG_CONTENT" | grep -q 'blank_issues_enabled: false'; then
      echo "> **WARNING**: \`blank_issues_enabled: false\` — this project does NOT accept free-form issues."
      echo "> You MUST use one of the configured templates or contact links."
      echo ""
    fi
  else
    echo "No issue template config found."
    echo ""
  fi

  # AI agent rules
  echo "## AI Agent Rules"
  echo ""
  for path in "AGENTS.md" "CLAUDE.md" ".github/AGENTS.md"; do
    CONTENT=$(fetch_file "$path")
    if [ -n "$CONTENT" ] && [ "$CONTENT" != "" ]; then
      echo "### $path"
      echo ""
      echo '```markdown'
      echo "$CONTENT" | head -100
      echo '```'
      echo ""
    fi
  done

  # CLA / DCO Requirements
  # Detects CLA enforcement via four signals:
  #   1. CLA config files in the repo (.github/cla.yml, cla-assistant.json, etc.)
  #   2. CLA bot references in .github/workflows/*
  #   3. CONTRIBUTORS/AUTHORS files (Google's standard pattern — the CONTRIBUTORS
  #      file often contains CLA URLs directly, e.g. code.google.com/legal/*)
  #   4. Org-level inference (Google, Microsoft, Meta, Apache, etc. enforce CLAs
  #      via org-installed GitHub Apps — invisible to file crawling)
  echo "## CLA / DCO Requirements"
  echo ""
  CLA_SIGNALS=""
  CLA_CONFIG_PATH=""
  CLA_BOT_NAME=""
  CLA_ORG_INFERRED=""
  CLA_CONTRIBUTORS_PATH=""
  CLA_URLS=""
  ORG_LOGIN=""

  # Signal 1: CLA config files
  for path in ".github/cla.yml" ".github/cla.yaml" ".github/cla-assistant.yml" ".github/cla-assistant.yaml" ".github/cla-bot.yml" ".github/cla-bot.yaml" "cla-assistant.json" ".cla-assistant.yml" ".github/CLA.yml"; do
    CONTENT=$(fetch_file "$path")
    if [ -n "$CONTENT" ] && [ "$CONTENT" != "" ]; then
      CLA_CONFIG_PATH="$path"
      CLA_SIGNALS="${CLA_SIGNALS}config-file:$path
"
      echo "**CLA config found at**: \`$path\`"
      echo ""
      echo '```yaml'
      echo "$CONTENT" | head -40
      echo '```'
      echo ""
      break
    fi
  done

  # Signal 3: CONTRIBUTORS / AUTHORS files (Google's standard pattern)
  # Google projects use AUTHORS (copyright holders) + CONTRIBUTORS (people who
  # signed the CLA). The CONTRIBUTORS file often contains CLA URLs directly.
  # This catches VirusTotal/yara-x and other Google subsidiaries that have no
  # CONTRIBUTING.md but do have these files.
  for path in "CONTRIBUTORS" "CONTRIBUTORS.md" "AUTHORS" "AUTHORS.md"; do
    CONTENT=$(fetch_file "$path")
    if [ -n "$CONTENT" ] && [ "$CONTENT" != "" ]; then
      CLA_CONTRIBUTORS_PATH="$path"
      CLA_SIGNALS="${CLA_SIGNALS}contributors-file:$path
"
      echo "**Contributor/authors file found**: \`$path\`"
      echo ""
      echo '```'
      echo "$CONTENT" | head -40
      echo '```'
      echo ""
      # Extract CLA URLs from the file content (Google's pattern)
      local file_urls
      file_urls=$(echo "$CONTENT" | grep -oE 'https?://[^ )"]+(cla|license|legal)[^ )"]*' 2>/dev/null || true)
      if [ -n "$file_urls" ]; then
        CLA_URLS="${CLA_URLS}${file_urls}
"
        echo "**CLA URLs extracted from $path**:"
        echo "$file_urls" | while IFS= read -r url; do
          [ -n "$url" ] && echo "- $url"
        done
        echo ""
      fi
      # If the file mentions CLA explicitly, flag it as a strong signal
      if echo "$CONTENT" | grep -qi 'contributor.license.agreement\|CLA\b\|legal/.*cla'; then
        CLA_SIGNALS="${CLA_SIGNALS}contributors-file-mentions-cla:$path
"
      fi
      break
    fi
  done

  # Signal 2: CLA bot references in .github/workflows/*
  # Avoid pipe-to-while (subshell loses variable updates). Use a for loop
  # with IFS set to newlines.
  WORKFLOW_FILES=$(list_dir ".github/workflows")
  if [ -n "$WORKFLOW_FILES" ] && [ "$WORKFLOW_FILES" != "" ]; then
    _saved_ifs="$IFS"
    IFS='
'
    for wfname in $WORKFLOW_FILES; do
      [ -z "$wfname" ] && continue
      WF_CONTENT=$(fetch_file ".github/workflows/$wfname")
      if [ -n "$WF_CONTENT" ]; then
        for bot in "google-cla" "cla-assistant" "CLAassistant" "cla-bot" "facebook-clang-cla" "apache-cla" "cla-checker" "contributor-assistant"; do
          if echo "$WF_CONTENT" | grep -qi "$bot"; then
            CLA_BOT_NAME="$bot"
            CLA_SIGNALS="${CLA_SIGNALS}workflow-bot:$bot (in .github/workflows/$wfname)
"
            echo "**CLA bot reference found**: \`$bot\` in \`.github/workflows/$wfname\`"
            echo ""
            break
          fi
        done
      fi
    done
    IFS="$_saved_ifs"
  fi

  # Signal 3: Org-level inference via GitHub API
  # Fetch repo metadata to resolve the owner org. Some orgs enforce CLAs
  # via org-installed GitHub Apps (no in-repo signal at all).
  REPO_META=$(curl -sL "https://api.github.com/repos/$OWNER/$REPO" 2>/dev/null || echo "")
  if [ -n "$REPO_META" ] && [ "$REPO_META" != "" ]; then
    ORG_LOGIN=$(echo "$REPO_META" | jq -r '.owner.login // ""' 2>/dev/null || echo "")
    ORG_TYPE=$(echo "$REPO_META" | jq -r '.owner.type // ""' 2>/dev/null || echo "")
    if [ -n "$ORG_LOGIN" ] && [ "$ORG_TYPE" = "Organization" ]; then
      # Known CLA-enforcing orgs and their subsidiaries
      # Google covers: VirusTotal, google/*, GoogleChrome, googleapis, etc.
      KNOWN_CLA_ORGS="google microsoft meta facebook apache cloudflare amazon aws canonical redhat ibm sap"
      # Subsidiary -> parent org mapping (lowercased)
      case "$ORG_LOGIN" in
        virustotal|google|googlechrome|googleapis|googlecloudplatform|googlecontainertools|googlefonts|googleprojectzero|googleai|deepmind|youtube|fitbit|nestlabs|waymo|verilylifesciences|looker|firebase|adswerve|chronosphere)
          CLA_ORG_INFERRED="google"
          ;;
        microsoft|azure|github|visualstudio|dotnet|nuget|aspnet|msftplaywright|msresearch|microsoftdocs|microsoftedge|microsoftgraph|microsoftopensource)
          CLA_ORG_INFERRED="microsoft"
          ;;
        facebook|meta|instagram|whatsapp|oculus|researchgate|fbsource)
          CLA_ORG_INFERRED="meta"
          ;;
        apache|apachecon|apacheinfrastructure)
          CLA_ORG_INFERRED="apache"
          ;;
        cloudflare)
          CLA_ORG_INFERRED="cloudflare"
          ;;
        aws|amazon|amzn|alexa|twitchtv|imdb)
          CLA_ORG_INFERRED="amazon"
          ;;
        canonical|ubuntudesktop|ubuntu)
          CLA_ORG_INFERRED="canonical"
          ;;
        redhat|redhatofficial|openshift|fedora)
          CLA_ORG_INFERRED="redhat"
          ;;
        ibm|ibm-cloud|ibm-watson|ibmresearch|ibmdesign)
          CLA_ORG_INFERRED="ibm"
          ;;
        sap|sap-cloud|sap-developer)
          CLA_ORG_INFERRED="sap"
          ;;
        *)
          # Check against the flat list as a fallback
          for known in $KNOWN_CLA_ORGS; do
            if [ "$ORG_LOGIN" = "$known" ]; then
              CLA_ORG_INFERRED="$known"
              break
            fi
          done
          ;;
      esac

      if [ -n "$CLA_ORG_INFERRED" ]; then
        CLA_SIGNALS="${CLA_SIGNALS}org-inferred:$CLA_ORG_INFERRED (owner: $ORG_LOGIN)
"
        echo "**Org-level CLA inferred**: owner \`$ORG_LOGIN\` is a known \`$CLA_ORG_INFERRED\` property."
        echo "CLA is likely enforced via an org-installed GitHub App (no in-repo config file)."
        echo ""
      fi
    fi
  fi

  # Summary
  if [ -n "$CLA_SIGNALS" ]; then
    echo "> **WARNING**: CLA likely required. Signals detected:"
    echo "> "
    printf '%s' "$CLA_SIGNALS" | while IFS= read -r line; do
      [ -n "$line" ] && echo "> - $line"
    done
    echo ""
    if [ -n "$CLA_URLS" ]; then
      echo "**CLA sign-off URLs** (extracted from repo files):"
      printf '%s' "$CLA_URLS" | while IFS= read -r url; do
        [ -n "$url" ] && echo "- $url"
      done
      echo ""
    fi
    echo "Before pushing a PR, consult the CLA ledger via"
    echo "\`scripts/skill-config.sh get cla.${ORG_LOGIN:-<org>}.signed_at\`."
    echo "If absent or expired, surface the CLA terms to the user and"
    echo "require acknowledgment before pushing."
    echo ""
  else
    echo "No CLA/DCO signals detected (no config files, no workflow bots,"
    echo "no CONTRIBUTORS/AUTHORS files with CLA references, no known"
    echo "CLA-enforcing org). CLA may still be required — check the PR"
    echo "checks after opening and watch for CLA bot comments."
    echo ""
  fi

  # Published Coding Standards (org-inferred)
  # Large companies publish coding standards in separate repos that subsidiary
  # projects reference but may not link in-repo. When org inference fires,
  # emit the known standards URLs so the AI can follow them even if the repo
  # doesn't link them.
  if [ -n "$CLA_ORG_INFERRED" ]; then
    echo "## Published Coding Standards (org-inferred)"
    echo ""
    echo "Owner \`$ORG_LOGIN\` is a known \`$CLA_ORG_INFERRED\` property."
    echo "These coding standards are published by $CLA_ORG_INFERRED and apply"
    echo "to $CLA_ORG_INFERRED-originated projects even when not linked in-repo."
    echo ""
    case "$CLA_ORG_INFERRED" in
      google)
        echo "- **Style guides**: https://google.github.io/styleguide/"
        echo "- **Source repo**: https://github.com/google/styleguide"
        echo "- **Languages covered**: C++, Python, Java, Go, TypeScript,"
        echo "  JavaScript, C#, Swift, R, Shell, Vim, HTML/CSS, JSON, Markdown,"
        echo "  Objective-C, Common Lisp, AngularJS, Kotlin, Dart"
        echo "- **Note**: Google's style guides are copies of internal guides."
        echo "  External contributions to the style guides themselves are NOT"
        echo "  accepted, but the guides apply to all Google-originated projects."
        echo ""
        echo "When contributing to a Google project, follow the language-specific"
        echo "guide above. The project's own formatter/linter usually enforces"
        echo "these — run them (Phase 3 step 7) before pushing."
        ;;
      microsoft)
        echo "- **C# / .NET**: https://github.com/dotnet/runtime/blob/main/docs/coding-guidelines/coding-style.md"
        echo "- **.NET docs conventions**: https://github.com/dotnet/docs/blob/main/docs/csharp/fundamentals/coding-style/coding-conventions.md"
        echo "- **TypeScript**: https://github.com/microsoft/TypeScript-wiki/blob/main/Coding-guidelines.md"
        echo "- **Note**: Microsoft repos often have \`.editorconfig\` at the root"
        echo "  that enforces C# formatting via \`dotnet format\`. Some repos have"
        echo "  \`.github/instructions/coding-standards/\` directories."
        echo ""
        echo "When contributing to a Microsoft project, follow the"
        echo "language-specific guide above and run \`dotnet format\` (C#) or"
        echo "the project's linter before pushing."
        ;;
      meta|facebook)
        echo "- **Facebook coding standards**: https://github.com/facebook/fbjs/blob/main/packages/eslint-shared/README.md"
        echo "- **Note**: Meta projects typically use internal lint configs"
        echo "  that are published per-project. Follow the project's own"
        echo "  \`.eslintrc\` / lint config rather than a central standard."
        echo ""
        echo "When contributing to a Meta project, follow the project's own"
        echo "  lint config (Phase 3 step 7) — Meta does not publish a single"
        echo "  central style guide the way Google does."
        ;;
      apache)
        echo "- **Apache coding standards**: https://www.apache.org/foundation/guidelines.html"
        echo "- **Note**: Apache projects each have their own conventions, but"
        echo "  the foundation guidelines apply broadly. Check the project's"
        echo "  own CONTRIBUTING.md (if present) for project-specific rules."
        ;;
      cloudflare)
        echo "- **Note**: Cloudflare does not publish a single central style"
        echo "  guide. Follow the project's own formatter/linter config."
        ;;
      amazon|aws)
        echo "- **Note**: Amazon/AWS does not publish a single central style"
        echo "  guide. Follow the project's own formatter/linter config."
        ;;
      canonical)
        echo "- **Ubuntu coding standards**: https://github.com/canonical/Contribute"
        echo "- **Note**: Canonical/Ubuntu projects follow the Ubuntu contributor"
        echo "  guidelines. Check the project's CONTRIBUTING.md for specifics."
        ;;
      redhat)
        echo "- **Note**: Red Hat projects follow their own conventions per"
        echo "  project. Follow the project's CONTRIBUTING.md and lint config."
        ;;
      ibm)
        echo "- **Note**: IBM projects follow their own conventions per"
        echo "  project. Follow the project's CONTRIBUTING.md and lint config."
        ;;
      sap)
        echo "- **Note**: SAP projects follow their own conventions per"
        echo "  project. Follow the project's CONTRIBUTING.md and lint config."
        ;;
    esac
    echo ""
  fi

  # CODEOWNERS
  echo "## CODEOWNERS"
  echo ""
  for path in "CODEOWNERS" ".github/CODEOWNERS" "docs/CODEOWNERS" ".gitea/CODEOWNERS"; do
    CONTENT=$(fetch_file "$path")
    if [ -n "$CONTENT" ] && [ "$CONTENT" != "" ]; then
      echo "**Found at**: \`$path\`"
      echo ""
      echo '```'
      echo "$CONTENT" | head -50
      echo '```'
      echo ""
      break
    fi
  done

  # Changelog format
  echo "## Changelog Format"
  echo ""
  CHANGELOG_CONTENT=$(fetch_file "CHANGELOG.md")
  if [ -n "$CHANGELOG_CONTENT" ] && [ "$CHANGELOG_CONTENT" != "" ]; then
    echo "**Found**: CHANGELOG.md"
    echo ""
    echo "First 30 lines (format reference):"
    echo ""
    echo '```markdown'
    echo "$CHANGELOG_CONTENT" | head -30
    echo '```'
    echo ""
  else
    echo "No CHANGELOG.md found."
    echo ""
  fi

  # Lint/style configs
  echo "## Lint and Style Configs"
  echo ""
  for path in ".editorconfig" ".markdownlint.json" ".markdownlint-cli2.jsonc" ".yamllint.yaml" ".yamllint.yml" "statix.toml"; do
    CONTENT=$(fetch_file "$path")
    if [ -n "$CONTENT" ] && [ "$CONTENT" != "" ]; then
      echo "### $path"
      echo ""
      echo '```'
      echo "$CONTENT" | head -30
      echo '```'
      echo ""
    fi
  done

} > "$CACHE_FILE"

if [ "$JSON_OUT" = "1" ]; then
  echo "{\"cache_path\": \"$CACHE_FILE\", \"crawled\": true, \"age_days\": 0}"
else
  echo "$CACHE_FILE"
fi

