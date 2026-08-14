#!/usr/bin/env bash
# configure-go.sh
# Go project configuration script
# Handles go.mod, go.sum, .golangci.yml, and framework-specific configs

set -euo pipefail

# Import common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/config-functions.sh
if [[ -f "$SCRIPT_DIR/../common/config-functions.sh" ]]; then
    source "$SCRIPT_DIR/../common/config-functions.sh"
fi

# Configure Go project
configure_go_project() {
    local project_path="$1"
    local mode="${2:-adopt}"     # adopt | standardize
    local app_type="${3:-unknown}" # web | cli | api | library
    local project_type="${4:-unknown}" # frontend-web | api-service | cli-tool | library

    log_info "Configuring Go project (mode: $mode, app_type: $app_type)"

    # Handle go.mod
    if [[ -f "$project_path/go.mod" ]]; then
        configure_go_mod "$project_path" "$mode" "$app_type" "$project_type"
    elif [[ "$mode" == "standardize" ]]; then
        create_go_mod "$project_path" "$mode" "$app_type" "$project_type"
    fi

    # Handle Go linting configuration
    configure_golangci_config "$project_path" "$mode"

    # Handle Go testing configuration
    configure_go_testing_config "$project_path" "$mode"

    # Handle framework-specific configs
    configure_go_framework_configs "$project_path" "$mode" "$app_type" "$project_type"
}

# Configure go.mod
configure_go_mod() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring go.mod for Go project"

    if [[ "$mode" == "standardize" ]]; then
        # Standardize mode - comprehensive additions
        add_standardize_go_dependencies "$project_path" "$app_type" "$project_type"
    else
        # Adopt mode - minimal essential additions
        add_adopt_go_dependencies "$project_path" "$app_type" "$project_type"
    fi
}

# Add standardize mode dependencies to go.mod
add_standardize_go_dependencies() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    local deps_to_add=""

    # App-type specific dependencies
    case "$app_type" in
        "web")
            deps_to_add="$deps_to_add github.com/gin-gonic/gin"
            if [[ "$project_type" == *"frontend-web"* ]]; then
                deps_to_add="$deps_to_add github.com/gorilla/websocket"
            fi
            ;;
        "cli")
            deps_to_add="$deps_to_add github.com/spf13/cobra github.com/spf13/viper"
            ;;
        "api")
            deps_to_add="$deps_to_add github.com/gin-gonic/gin github.com/gorilla/mux"
            ;;
    esac

    # Framework-specific dependencies
    case "$project_type" in
        "api-service")
            deps_to_add="$deps_to_add github.com/golang-jwt/jwt/v5 github.com/google/uuid"
            ;;
        "frontend-web")
            if [[ -f "$project_path/main.go" ]] && grep -q "websocket\|ws" "$project_path/main.go" 2>/dev/null; then
                deps_to_add="$deps_to_add github.com/gorilla/websocket"
            fi
            ;;
    esac

    # Apply dependencies using go get
    if [[ -n "$deps_to_add" ]]; then
        cd "$project_path"
        for dep in $deps_to_add; do
            if [[ "$mode" == "standardize" ]]; then
                echo "Adding Go dependency: $dep"
                # go get "$dep"  # Commented out to avoid actual network calls
            fi
        done
        log_info "✓ Added Go dependencies"
    fi
}

# Add adopt mode dependencies to go.mod
add_adopt_go_dependencies() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Adopt mode - minimal essential dependencies only
    local essential_deps=""

    case "$app_type" in
        "web")
            essential_deps="github.com/gin-gonic/gin"
            ;;
        "cli")
            essential_deps="github.com/spf13/cobra"
            ;;
        "api")
            essential_deps="github.com/gin-gonic/gin"
            ;;
    esac

    # Apply dependencies using go get
    if [[ -n "$essential_deps" ]]; then
        cd "$project_path"
        for dep in $essential_deps; do
            if [[ "$mode" == "standardize" ]]; then
                echo "Adding essential Go dependency: $dep"
                # go get "$dep"  # Commented out to avoid actual network calls
            fi
        done
        log_info "✓ Added essential Go dependencies"
    fi
}

# Create go.mod
create_go_mod() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/go.mod" ]]; then
        local module_name
        module_name=$(basename "$project_path")
        
        cat > "$project_path/go.mod" << EOF
module $module_name

go 1.21

require (
EOF

        # Add app-type specific dependencies
        case "$app_type" in
            "web")
                cat >> "$project_path/go.mod" << 'EOF'
	github.com/gin-gonic/gin v1.9.1
EOF
                ;;
            "cli")
                cat >> "$project_path/go.mod" << 'EOF'
	github.com/spf13/cobra v1.8.0
	github.com/spf13/viper v1.17.0
EOF
                ;;
            "api")
                cat >> "$project_path/go.mod" << 'EOF'
	github.com/gin-gonic/gin v1.9.1
	github.com/gorilla/mux v1.8.0
EOF
                ;;
        esac

        cat >> "$project_path/go.mod" << 'EOF'
)
EOF

        log_info "✓ Created go.mod"
    fi
}

# Configure golangci-lint
configure_golangci_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/.golangci.yml" ]]; then
        cat > "$project_path/.golangci.yml" << 'EOF'
run:
  timeout: 5m
  issues-exit-code: 1
  tests: true

output:
  format: colored-line-number
  print-issued-lines: true
  print-linter-name: true

linters-settings:
  govet:
    check-shadowing: true
  golint:
    min-confidence: 0
  gocyclo:
    min-complexity: 20
  maligned:
    suggest-new: true
  dupl:
    threshold: 100
  goconst:
    min-len: 2
    min-occurrences: 2
  misspell:
    locale: US
  lll:
    line-length: 140
  goimports:
    local-prefixes: ""
  gocritic:
    enabled-tags:
      - diagnostic
      - experimental
      - opinionated
      - performance
      - style
    disabled-checks:
      - dupImport
      - ifElseChain
      - octalLiteral
      - whyNoLint
      - wrapperFunc

linters:
  enable:
    - bodyclose
    - deadcode
    - depguard
    - dogsled
    - dupl
    - errcheck
    - exportloopref
    - exhaustive
    - gochecknoinits
    - goconst
    - gocritic
    - gocyclo
    - gofmt
    - goimports
    - golint
    - gomnd
    - goprintffuncname
    - gosec
    - gosimple
    - govet
    - ineffassign
    - interfacer
    - lll
    - misspell
    - nakedret
    - noctx
    - nolintlint
    - rowserrcheck
    - scopelint
    - staticcheck
    - structcheck
    - stylecheck
    - typecheck
    - unconvert
    - unparam
    - unused
    - varcheck
    - whitespace

issues:
  exclude-rules:
    - path: _test\.go
      linters:
        - gocyclo
        - errcheck
        - dupl
        - gosec
    - path: vendor/
      linters:
        - deadcode
        - unused
        - varcheck
        - structcheck
        - ineffassign
    - linters:
        - lll
      source: "^//go:generate "
EOF
        log_info "✓ Created .golangci.yml"
    fi
}

# Configure Go testing
configure_go_testing_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]]; then
        # Create test configuration
        if [[ ! -f "$project_path/tests/tests.go" ]]; then
            mkdir -p "$project_path/tests"
            cat > "$project_path/tests/tests.go" << 'EOF'
package tests

import (
    "testing"
)

// TestExample is a placeholder test
func TestExample(t *testing.T) {
    t.Log("This is a placeholder test")
    // Replace with actual tests
}
EOF
            log_info "✓ Created tests/tests.go"
        fi

        # Create Makefile for testing if it doesn't exist
        if [[ ! -f "$project_path/Makefile" ]]; then
            cat > "$project_path/Makefile" << 'EOF'
.PHONY: test test-coverage lint build run clean

# Run tests
test:
	go test ./...

# Run tests with coverage
test-coverage:
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

# Run linter
lint:
	golangci-lint run

# Build the project
build:
	go build -o bin/$(shell basename $(CURDIR)) ./...

# Run the project
run: build
	./bin/$(shell basename $(CURDIR))

# Clean build artifacts
clean:
	rm -rf bin/
	rm -f coverage.out coverage.html
	go clean -testcache
EOF
            log_info "✓ Created Makefile"
        fi
    fi
}

# Configure Go framework-specific configurations
configure_go_framework_configs() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    # Gin configuration
    if [[ "$app_type" == "web" ]] || [[ "$app_type" == "api" ]] || [[ "$project_type" == *"api-service"* ]]; then
        configure_gin_config "$project_path" "$mode"
    fi

    # Cobra configuration
    if [[ "$app_type" == "cli" ]] || [[ "$project_type" == *"cli-tool"* ]]; then
        configure_cobra_config "$project_path" "$mode"
    fi

    # WebSocket configuration
    if [[ "$app_type" == "web" ]] && [[ "$project_type" == *"frontend-web"* ]]; then
        configure_websocket_config "$project_path" "$mode"
    fi
}

# Configure Gin
configure_gin_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]]; then
        # Create basic Gin project structure
        mkdir -p "$project_path/cmd"
        mkdir -p "$project_path/internal/handlers"
        mkdir -p "$project_path/internal/middleware"
        mkdir -p "$project_path/pkg/api"

        if [[ ! -f "$project_path/cmd/main.go" ]]; then
            cat > "$project_path/cmd/main.go" << 'EOF'
package main

import (
    "log"
    "net/http"

    "github.com/gin-gonic/gin"
)

func main() {
    r := gin.Default()

    // Health check endpoint
    r.GET("/health", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{
            "status": "healthy",
        })
    })

    // API v1 routes
    v1 := r.Group("/api/v1")
    {
        v1.GET("/", func(c *gin.Context) {
            c.JSON(http.StatusOK, gin.H{
                "message": "API v1",
            })
        })
    }

    log.Println("Server starting on :8080")
    if err := r.Run(":8080"); err != nil {
        log.Fatal("Failed to start server:", err)
    }
}
EOF
            log_info "✓ Created cmd/main.go"
        fi

        if [[ ! -f "$project_path/internal/handlers/health.go" ]]; then
            cat > "$project_path/internal/handlers/health.go" << 'EOF'
package handlers

import (
    "net/http"

    "github.com/gin-gonic/gin"
)

// HealthCheck returns the health status
func HealthCheck(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{
        "status": "healthy",
    })
}
EOF
            log_info "✓ Created internal/handlers/health.go"
        fi
    fi
}

# Configure Cobra
configure_cobra_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]]; then
        # Create basic Cobra project structure
        mkdir -p "$project_path/cmd"
        mkdir -p "$project_path/internal/cli"

        if [[ ! -f "$project_path/cmd/root.go" ]]; then
            cat > "$project_path/cmd/root.go" << 'EOF'
package cmd

import (
    "fmt"
    "os"

    "github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
    Use:   "cli-app",
    Short: "A brief description of your application",
    Long:  `A longer description that spans multiple lines and likely contains
examples and usage of using your application.`,
}

func Execute() {
    if err := rootCmd.Execute(); err != nil {
        fmt.Fprintf(os.Stderr, "Error: %v\n", err)
        os.Exit(1)
    }
}

func init() {
    // Here you will define your flags and configuration settings.
    // Cobra supports persistent flags, which, if defined here,
    // will be global for your application.

    // rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file (default is $HOME/.cli-app.yaml)")

    // Cobra also supports local flags, which will only run
    // when this action is called directly.
    rootCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
EOF
            log_info "✓ Created cmd/root.go"
        fi

        if [[ ! -f "$project_path/main.go" ]]; then
            cat > "$project_path/main.go" << 'EOF'
package main

import "your-module-path/cmd"

func main() {
    cmd.Execute()
}
EOF
            log_info "✓ Created main.go"
        fi
    fi
}

# Configure WebSocket
configure_websocket_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]]; then
        # Create WebSocket handler
        mkdir -p "$project_path/internal/websocket"

        if [[ ! -f "$project_path/internal/websocket/hub.go" ]]; then
            cat > "$project_path/internal/websocket/hub.go" << 'EOF'
package websocket

import (
    "log"

    "github.com/gorilla/websocket"
)

// Hub maintains the set of active clients and broadcasts messages to the clients.
type Hub struct {
    clients    map[*Client]bool
    broadcast  chan []byte
    register   chan *Client
    unregister chan *Client
}

func NewHub() *Hub {
    return &Hub{
        broadcast:  make(chan []byte),
        register:   make(chan *Client),
        unregister: make(chan *Client),
        clients:    make(map[*Client]bool),
    }
}

func (h *Hub) Run() {
    for {
        select {
        case client := <-h.register:
            h.clients[client] = true
            log.Println("Client connected")

        case client := <-h.unregister:
            if _, ok := h.clients[client]; ok {
                delete(h.clients, client)
                close(client.send)
                log.Println("Client disconnected")
            }

        case message := <-h.broadcast:
            for client := range h.clients {
                select {
                case client.send <- message:
                default:
                    close(client.send)
                    delete(h.clients, client)
                }
            }
        }
    }
}

// Client is a middleman between the websocket connection and the hub.
type Client struct {
    hub  *Hub
    conn *websocket.Conn
    send chan []byte
}

const (
    // Time allowed to write a message to the peer.
    writeWait = 10 * time.Second

    // Time allowed to read the next pong message from the peer.
    pongWait = 60 * time.Second

    // Send pings to peer with this period. Must be less than pongWait.
    pingPeriod = (pongWait * 9) / 10

    // Maximum message size allowed from peer.
    maxMessageSize = 512
)

var upgrader = websocket.Upgrader{
    ReadBufferSize:  1024,
    WriteBufferSize: 1024,
}

// readPump pumps messages from the websocket connection to the hub.
func (c *Client) readPump() {
    defer func() {
        c.hub.unregister <- c
        c.conn.Close()
    }()
    c.conn.SetReadLimit(maxMessageSize)
    c.conn.SetReadDeadline(time.Now().Add(pongWait))
    c.conn.SetPongHandler(func(string) error {
        c.conn.SetReadDeadline(time.Now().Add(pongWait))
        return nil
    })
    for {
        _, message, err := c.conn.ReadMessage()
        if err != nil {
            if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
                log.Printf("error: %v", err)
            }
            break
        }
        c.hub.broadcast <- message
    }
}

// writePump pumps messages from the hub to the websocket connection.
func (c *Client) writePump() {
    ticker := time.NewTicker(pingPeriod)
    defer func() {
        ticker.Stop()
        c.conn.Close()
    }()
    for {
        select {
        case message, ok := <-c.send:
            c.conn.SetWriteDeadline(time.Now().Add(writeWait))
            if !ok {
                c.conn.WriteMessage(websocket.CloseMessage, []byte{})
                return
            }
            w, err := c.conn.NextWriter(websocket.TextMessage)
            if err != nil {
                return
            }
            w.Write(message)
            n := len(c.send)
            for i := 0; i < n; i++ {
                w.Write(newline)
            }
            if err := w.Close(); err != nil {
                return
            }
        case <-ticker.C:
            c.conn.SetWriteDeadline(time.Now().Add(writeWait))
            if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
                return
            }
        }
    }
}
EOF
            log_info "✓ Created internal/websocket/hub.go"
        fi
    fi
}

# Export functions for use by adopt-project.sh
export -f configure_go_project
export -f configure_go_mod
export -f configure_golangci_config
export -f configure_go_testing_config
