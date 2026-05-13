#!/bin/bash

# {{package_description}}
# Author: {{author_name}} <{{author_email}}>
# License: {{license}}

set -euo pipefail

# Script version
VERSION="0.1.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Main function
main() {
    log_info "Starting {{package_name}} v${VERSION}"
    
    # Your main logic goes here
    echo "Hello from {{package_name}}!"
    
    log_success "Script completed successfully"
}

# Help function
show_help() {
    cat << EOF
{{package_name}} v${VERSION}

{{package_description}}

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help      Show this help message
    -v, --version   Show version information

EXAMPLES:
    $0              Run the script with default options

EOF
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -v|--version)
        echo "{{package_name}} v${VERSION}"
        exit 0
        ;;
    "")
        main
        ;;
    *)
        log_error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac

# vim: set ft=sh:
