# {{package_name | title_case}}

{{package_description}}

## Features

- **Logging**: Structured logging with Python's logging module
- **Context Processing**: Handle data with context-aware operations
- **Error Handling**: Comprehensive error handling with proper exception management
- **Type Safety**: Full type hints for better code documentation and IDE support
- **Modular Design**: Clean separation of concerns with service-oriented architecture

## Prerequisites

- Python {{python_version}} or higher

## Installation

### Option 1: Development Installation

```bash
# Clone the repository
git clone <repository-url>
cd {{package_name}}

# Install in development mode
pip install -e .
```

### Option 2: Install from Package

```bash
pip install {{package_name}}
```

## Usage

### Basic Usage

```python
from {{package_name}} import Service, process, multiply_by_two

# Using the service class
service = Service()
result = service.process("hello", "test-context")
print(result)  # Output: HELLO

doubled = service.multiply_by_two(5)
print(doubled)  # Output: 10

# Using convenience functions
result = process("hello", "test-context")
print(result)  # Output: HELLO

doubled = multiply_by_two(5)
print(doubled)  # Output: 10
```

### Logging Configuration

```python
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# The module logger will inherit this configuration
```

## Development

### Project Structure

```text
src/
└── {{package_name}}/
    ├── __init__.py
    ├── service.py
    └── logger.py
tests/
    ├── test_service.py
    └── __init__.py
docs/
    └── README.md
README.md
pyproject.toml
```

### Development Setup

```bash
# Install development dependencies
pip install -e ".[dev]"

# Run tests
pytest

# Run tests with coverage
pytest --cov={{package_name}}

# Run linting
flake8 src/ tests/
black src/ tests/
isort src/ tests/

# Type checking
mypy src/
```

### Building

```bash
# Build the package
python -m build

# Upload to PyPI (requires credentials)
python -m twine upload dist/*
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run all tests and linting
6. Submit a pull request

## License

{{license}}

## Author

{{author_name}} <{{author_email}}>
