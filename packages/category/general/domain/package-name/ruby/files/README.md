# {{package_name | title_case}}

{{package_description}}

## Features

- **Logging**: Structured logging with Ruby's Logger
- **Context Processing**: Handle data with context-aware operations
- **Error Handling**: Comprehensive error handling with proper exception management
- **Module Design**: Clean Ruby module with namespaced functionality
- **Factory Pattern**: Convenient factory methods for object creation

## Prerequisites

- Ruby {{ruby_version}} or higher

## Installation

### Option 1: Development Installation

```bash
# Clone the repository
git clone <repository-url>
cd {{package_name}}

# Install dependencies
bundle install

# Load the library
require_relative 'lib/{{package_name}}'
```

### Option 2: Gem Installation

```bash
# Install from RubyGems
gem install {{package_name}}

# Require in your code
require '{{package_name}}'
```

## Usage

### Basic Usage

```ruby
require '{{package_name}}'

# Using the service class
service = {{package_name | title_case}}.create_service
result = service.process("hello", "test-context")
puts result  # Output: HELLO

doubled = service.multiply_by_two(5)
puts doubled  # Output: 10

# Using module-level convenience methods
result = {{package_name | title_case}}.process("hello", "test-context")
puts result  # Output: HELLO

doubled = {{package_name | title_case}}.multiply_by_two(5)
puts doubled  # Output: 10
```

### Logging Configuration

```ruby
# Configure logger (default: INFO level, stdout output)
{{package_name | title_case}}::LOGGER.level = Logger::DEBUG
{{package_name | title_case}}::LOGGER.formatter = proc do |severity, datetime, progname, msg|
  "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] [#{severity}] #{msg}\n"
end
```

## Development

### Project Structure

```text
lib/
└── {{package_name}}.rb
spec/
├── spec_helper.rb
└── {{package_name}}_spec.rb
README.md
{{package_name}}.gemspec
Gemfile
Rakefile
```

### Development Setup

```bash
# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run tests with coverage
bundle exec rspec --format documentation

# Run linting
bundle exec rubocop

# Build the gem
gem build {{package_name}}.gemspec
```

### Testing

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/{{package_name}}_spec.rb

# Run with verbose output
bundle exec rspec --format documentation
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
