#!/usr/bin/env bash
# configure-python.sh
# Python project configuration script
# Handles pyproject.toml, requirements.txt, pytest.ini, ruff.toml, mypy.ini, and framework-specific configs

set -euo pipefail

# Import common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../common/config-functions.sh
if [[ -f "$SCRIPT_DIR/../common/config-functions.sh" ]]; then
    source "$SCRIPT_DIR/../common/config-functions.sh"
fi

# Configure Python project
configure_python_project() {
    local project_path="$1"
    local mode="${2:-adopt}"     # adopt | standardize
    local app_type="${3:-unknown}" # web | cli | api | library
    local project_type="${4:-unknown}" # frontend-web | api-service | cli-tool | library

    log_info "Configuring Python project (mode: $mode, app_type: $app_type)"

    # Handle pyproject.toml (preferred) or requirements.txt
    if [[ -f "$project_path/pyproject.toml" ]]; then
        configure_pyproject_toml "$project_path" "$mode" "$app_type" "$project_type"
    elif [[ -f "$project_path/requirements.txt" ]]; then
        configure_requirements_txt "$project_path" "$mode" "$app_type" "$project_type"
    elif [[ "$mode" == "standardize" ]]; then
        create_pyproject_toml "$project_path" "$mode" "$app_type" "$project_type"
    fi

    # Handle Python formatting and linting configuration
    configure_ruff_config "$project_path" "$mode"

    # Handle type checking configuration
    configure_mypy_config "$project_path" "$mode"

    # Handle testing configuration
    configure_pytest_config "$project_path" "$mode" "$app_type"

    # Handle framework-specific configs
    configure_python_framework_configs "$project_path" "$mode" "$app_type" "$project_type"
}

# Configure pyproject.toml
configure_pyproject_toml() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring pyproject.toml for Python project"

    if [[ "$mode" == "standardize" ]]; then
        # Standardize mode - comprehensive additions
        add_standardize_pyproject_dependencies "$project_path" "$app_type" "$project_type"
        add_standardize_pyproject_scripts "$project_path" "$app_type" "$project_type"
    else
        # Adopt mode - minimal essential additions
        add_adopt_pyproject_dependencies "$project_path" "$app_type" "$project_type"
    fi
}

# Add standardize mode dependencies to pyproject.toml
add_standardize_pyproject_dependencies() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    local dev_deps_to_add=""
    local deps_to_add=""

    # Base dev dependencies for all Python projects
    dev_deps_to_add='"black", "ruff", "mypy", "pytest", "pytest-cov", "pre-commit"'

    # App-type specific dependencies
    case "$app_type" in
        "web")
            deps_to_add="$deps_to_add, \"fastapi\", \"uvicorn\", \"jinja2\""
            if [[ "$project_type" == *"frontend-web"* ]]; then
                deps_to_add="$deps_to_add, \"streamlit\""
            fi
            ;;
        "cli")
            deps_to_add="$deps_to_add, \"click\", "typer", "rich""
            ;;
        "api")
            deps_to_add="$deps_to_add, \"fastapi\", \"uvicorn\", "pydantic", "sqlalchemy""
            ;;
        "ml")
            deps_to_add="$deps_to_add, \"numpy\", "pandas", "scikit-learn", "matplotlib""
            dev_deps_to_add="$dev_deps_to_add, "jupyter", "notebook""
            ;;
    esac

    # Framework-specific dependencies
    case "$project_type" in
        "api-service")
            deps_to_add="$deps_to_add, "alembic", "redis", "celery""
            ;;
        "frontend-web")
            if [[ -f "$project_path/app.py" ]] || [[ -f "$project_path/streamlit_app.py" ]]; then
                deps_to_add="$deps_to_add, "streamlit", "plotly""
            fi
            ;;
    esac

    # Apply surgical changes
    if command -v yq-go >/dev/null 2>&1; then
        echo "Adding standardize dependencies to pyproject.toml using yq-go"
        # Add devDependencies
        # yq-go eval ".[\"tool.poetry.group.dev.dependencies\"] += {$dev_deps_to_add}" "$project_path/pyproject.toml" -i
        # Add dependencies if any
        if [[ -n "$deps_to_add" ]]; then
            # yq-go eval ".[\"tool.poetry.dependencies\"] += {$deps_to_add}" "$project_path/pyproject.toml" -i
        fi
    else
        log_warn "yq-go not available, skipping pyproject.toml dependency updates"
    fi
}

# Add adopt mode dependencies to pyproject.toml
add_adopt_pyproject_dependencies() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    # Adopt mode - minimal essential dependencies only
    local essential_deps=""

    case "$app_type" in
        "web")
            essential_deps='"fastapi"'
            ;;
        "cli")
            essential_deps='"click"'
            ;;
        "api")
            essential_deps='"fastapi", "pydantic"'
            ;;
        "ml")
            essential_deps='"numpy"'
            ;;
    esac

    # Apply surgical changes
    if command -v yq-go >/dev/null 2>&1 && [[ -n "$essential_deps" ]]; then
        echo "Adding adopt dependencies to pyproject.toml using yq-go"
        # yq-go eval ".[\"tool.poetry.dependencies\"] += {$essential_deps}" "$project_path/pyproject.toml" -i
    else
        log_warn "yq-go not available or no dependencies to add"
    fi
}

# Add standardize mode scripts to pyproject.toml
add_standardize_pyproject_scripts() {
    local project_path="$1"
    local app_type="$2"
    local project_type="$3"

    local scripts_to_add=""

    # Base scripts for all Python projects
    scripts_to_add='"dev": "devbox dev", "test": "devbox test", "lint": "devbox lint", "format": "devbox format", "typecheck": "devbox typecheck"'

    # App-type specific scripts
    case "$app_type" in
        "web")
            scripts_to_add="$scripts_to_add, \"start\": \"devbox dev\", \"serve\": \"uvicorn main:app --reload\""
            ;;
        "cli")
            scripts_to_add="$scripts_to_add, \"start\": \"python -m src.main\""
            ;;
        "api")
            scripts_to_add="$scripts_to_add, \"start\": \"uvicorn main:app --reload\", "db:migrate": "alembic upgrade head""
            ;;
        "ml")
            scripts_to_add="$scripts_to_add, \"notebook\": "jupyter notebook", "train": "python train.py""
            ;;
    esac

    # Apply surgical changes
    if command -v yq-go >/dev/null 2>&1; then
        echo "Adding scripts to pyproject.toml using yq-go"
        # yq-go eval ".[\"tool.poetry.scripts\"] += {$scripts_to_add}" "$project_path/pyproject.toml" -i
    else
        log_warn "yq-go not available, skipping pyproject.toml script updates"
    fi
}

# Configure requirements.txt
configure_requirements_txt() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    log_info "Configuring requirements.txt for Python project"

    if [[ "$mode" == "standardize" ]]; then
        # Add standardize dependencies to requirements.txt
        local deps_to_add=""

        case "$app_type" in
            "web")
                deps_to_add="fastapi\nuvicorn\njinja2"
                ;;
            "cli")
                deps_to_add="click\ntyper\nrich"
                ;;
            "api")
                deps_to_add="fastapi\nuvicorn\npydantic\nsqlalchemy"
                ;;
            "ml")
                deps_to_add="numpy\npandas\nscikit-learn\nmatplotlib"
                ;;
        esac

        if [[ -n "$deps_to_add" ]]; then
            echo -e "$deps_to_add" >> "$project_path/requirements.txt"
            log_info "✓ Added dependencies to requirements.txt"
        fi
    fi
}

# Create pyproject.toml
create_pyproject_toml() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/pyproject.toml" ]]; then
        cat > "$project_path/pyproject.toml" << 'EOF'
[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"

[tool.poetry]
name = "python-project"
version = "0.1.0"
description = ""
authors = ["Your Name <you@example.com>"]
readme = "README.md"

[tool.poetry.dependencies]
python = "^3.11"

[tool.poetry.group.dev.dependencies]
EOF

        # Add app-type specific dependencies
        case "$app_type" in
            "web")
                cat >> "$project_path/pyproject.toml" << 'EOF'
fastapi = "^0.104.0"
uvicorn = "^0.24.0"
jinja2 = "^3.1.0"
EOF
                ;;
            "cli")
                cat >> "$project_path/pyproject.toml" << 'EOF'
click = "^8.1.0"
typer = "^0.9.0"
rich = "^13.6.0"
EOF
                ;;
            "api")
                cat >> "$project_path/pyproject.toml" << 'EOF'
fastapi = "^0.104.0"
uvicorn = "^0.24.0"
pydantic = "^2.4.0"
sqlalchemy = "^2.0.0"
EOF
                ;;
        esac

        # Add dev dependencies
        cat >> "$project_path/pyproject.toml" << 'EOF'
black = "^23.9.0"
ruff = "^0.1.0"
mypy = "^1.6.0"
pytest = "^7.4.0"
pytest-cov = "^4.1.0"
pre-commit = "^3.5.0"

[tool.poetry.scripts]
dev = "devbox dev"
test = "devbox test"
lint = "devbox lint"
format = "devbox format"
typecheck = "devbox typecheck"
EOF

        log_info "✓ Created pyproject.toml"
    fi
}

# Configure Ruff
configure_ruff_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/ruff.toml" ]] && [[ ! -f "$project_path/pyproject.toml" ]] || ! grep -q "\[tool.ruff\]" "$project_path/pyproject.toml" 2>/dev/null; then
        if [[ -f "$project_path/pyproject.toml" ]]; then
            # Add to existing pyproject.toml
            cat >> "$project_path/pyproject.toml" << 'EOF'

[tool.ruff]
line-length = 88
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "W", "I", "N", "UP", "B", "A", "C4", "T20", "SIM"]
ignore = ["E501", "B008"]

[tool.ruff.lint.per-file-ignores]
"__init__.py" = ["F401"]
"tests/*" = ["S101"]
EOF
        else
            # Create standalone ruff.toml
            cat > "$project_path/ruff.toml" << 'EOF'
line-length = 88
target-version = "py311"

[lint]
select = ["E", "F", "W", "I", "N", "UP", "B", "A", "C4", "T20", "SIM"]
ignore = ["E501", "B008"]

[lint.per-file-ignores]
"__init__.py" = ["F401"]
"tests/*" = ["S101"]
EOF
        fi
        log_info "✓ Created ruff configuration"
    fi
}

# Configure MyPy
configure_mypy_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/mypy.ini" ]] && [[ ! -f "$project_path/pyproject.toml" ]] || ! grep -q "\[tool.mypy\]" "$project_path/pyproject.toml" 2>/dev/null; then
        if [[ -f "$project_path/pyproject.toml" ]]; then
            # Add to existing pyproject.toml
            cat >> "$project_path/pyproject.toml" << 'EOF'

[tool.mypy]
python_version = "3.11"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
disallow_untyped_decorators = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
warn_unreachable = true
strict_equality = true

[[tool.mypy.overrides]]
module = "tests.*"
disallow_untyped_defs = false
EOF
        else
            # Create standalone mypy.ini
            cat > "$project_path/mypy.ini" << 'EOF'
[mypy]
python_version = 3.11
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
disallow_untyped_decorators = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
warn_unreachable = true
strict_equality = true

[mypy-tests.*]
disallow_untyped_defs = false
EOF
        fi
        log_info "✓ Created mypy configuration"
    fi
}

# Configure pytest
configure_pytest_config() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/pytest.ini" ]] && [[ ! -f "$project_path/pyproject.toml" ]] || ! grep -q "\[tool.pytest\]" "$project_path/pyproject.toml" 2>/dev/null; then
        if [[ -f "$project_path/pyproject.toml" ]]; then
            # Add to existing pyproject.toml
            cat >> "$project_path/pyproject.toml" << 'EOF'

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = [
    "--cov=src",
    "--cov-report=term-missing",
    "--cov-report=html",
    "--cov-fail-under=80",
]
EOF
        else
            # Create standalone pytest.ini
            cat > "$project_path/pytest.ini" << 'EOF'
[tool:pytest]
testpaths = tests
python_files = test_*.py *_test.py
python_classes = Test*
python_functions = test_*
addopts = --cov=src --cov-report=term-missing --cov-report=html --cov-fail-under=80
EOF
        fi
        log_info "✓ Created pytest configuration"
    fi
}

# Configure Python framework-specific configurations
configure_python_framework_configs() {
    local project_path="$1"
    local mode="$2"
    local app_type="$3"
    local project_type="$4"

    # FastAPI configuration
    if [[ "$app_type" == "api" ]] || [[ "$project_type" == *"api-service"* ]]; then
        configure_fastapi_config "$project_path" "$mode"
    fi

    # Streamlit configuration
    if [[ "$app_type" == "web" ]] && [[ "$project_type" == *"frontend-web"* ]]; then
        configure_streamlit_config "$project_path" "$mode"
    fi

    # Jupyter configuration for ML projects
    if [[ "$app_type" == "ml" ]]; then
        configure_jupyter_config "$project_path" "$mode"
    fi
}

# Configure FastAPI
configure_fastapi_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]]; then
        # Create basic FastAPI project structure
        mkdir -p "$project_path/src/api"
        mkdir -p "$project_path/src/models"
        mkdir -p "$project_path/tests/api"

        if [[ ! -f "$project_path/src/main.py" ]]; then
            cat > "$project_path/src/main.py" << 'EOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Python API",
    description="A FastAPI application",
    version="0.1.0",
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
EOF
            log_info "✓ Created FastAPI main.py"
        fi
    fi
}

# Configure Streamlit
configure_streamlit_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/.streamlit/config.toml" ]]; then
        mkdir -p "$project_path/.streamlit"
        cat > "$project_path/.streamlit/config.toml" << 'EOF'
[theme]
primaryColor = "#FF6B6B"
backgroundColor = "#FFFFFF"
secondaryBackgroundColor = "#F0F2F6"
textColor = "#262730"

[server]
port = 8501
headless = false
enableCORS = false
enableXsrfProtection = false

[browser]
gatherUsageStats = false
EOF
        log_info "✓ Created Streamlit configuration"
    fi
}

# Configure Jupyter
configure_jupyter_config() {
    local project_path="$1"
    local mode="$2"

    if [[ "$mode" == "standardize" ]] && [[ ! -f "$project_path/.jupyter/jupyter_notebook_config.py" ]]; then
        mkdir -p "$project_path/.jupyter"
        cat > "$project_path/.jupyter/jupyter_notebook_config.py" << 'EOF'
c.NotebookApp.ip = 'localhost'
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False
c.NotebookApp.notebook_dir = '.'
c.InteractiveShellApp.matplotlib = 'inline'

# Auto-save configuration
c.NotebookApp.autosave_interval = 30
c.NotebookApp.autosave_on_terminate = True

# Security
c.NotebookApp.token = ''
c.NotebookApp.password = ''
EOF
        log_info "✓ Created Jupyter configuration"
    fi
}

# Export functions for use by adopt-project.sh
export -f configure_python_project
export -f configure_pyproject_toml
export -f configure_ruff_config
export -f configure_mypy_config
export -f configure_pytest_config
