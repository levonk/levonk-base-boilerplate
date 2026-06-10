//! Error validation before calling dependencies

use crate::internal::errors::{StructuredError, ErrorCode};

/// Error validator for pre-call validation
pub struct ErrorValidator {
    tool_name: String,
}

impl ErrorValidator {
    /// Create a new error validator
    pub fn new(tool_name: impl Into<String>) -> Self {
        Self {
            tool_name: tool_name.into(),
        }
    }

    /// Validate file path before calling file operations
    pub fn validate_file_path(&self, path: &str) -> Result<(), StructuredError> {
        if path.is_empty() {
            let mut error = StructuredError::new(
                ErrorCode::Validation,
                "File path cannot be empty",
                2,
            );
            error.with_suggestion("Provide a valid file path");
            return Err(error);
        }

        // Check for potentially dangerous paths
        if path.contains("..") {
            let mut error = StructuredError::new(
                ErrorCode::Validation,
                "File path contains parent directory references (..)",
                2,
            );
            error.with_context("path", path);
            error.with_suggestion("Use absolute paths or paths relative to the current directory");
            return Err(error);
        }

        // Check for path length limits
        if path.len() > 4096 {
            let mut error = StructuredError::new(
                ErrorCode::Validation,
                "File path exceeds maximum length",
                2,
            );
            error.with_context("path_length", path.len().to_string());
            error.with_context("max_length", "4096");
            error.with_suggestion("Use a shorter file path");
            return Err(error);
        }

        Ok(())
    }

    /// Validate URL before making network requests
    pub fn validate_url(&self, url: &str) -> Result<(), StructuredError> {
        if url.is_empty() {
            let mut error = StructuredError::new(
                ErrorCode::Validation,
                "URL cannot be empty",
                2,
            );
            error.with_suggestion("Provide a valid URL");
            return Err(error);
        }

        // Basic URL validation
        if !url.starts_with("http://") && !url.starts_with("https://") {
            let mut error = StructuredError::new(
                ErrorCode::Validation,
                "URL must start with http:// or https://",
                2,
            );
            error.with_context("url", url);
            error.with_suggestion("Include the protocol (http:// or https://) in the URL");
            return Err(error);
        }

        Ok(())
    }

    /// Validate configuration before loading
    pub fn validate_config(&self, config_path: &str) -> Result<(), StructuredError> {
        self.validate_file_path(config_path)?;

        // Check if file exists
        if !std::path::Path::new(config_path).exists() {
            let mut error = StructuredError::new(
                ErrorCode::NotFound,
                "Configuration file not found",
                1,
            );
            error.with_context("path", config_path);
            error.with_suggestion_command(
                "Initialize configuration with default settings",
                format!("{} --install", self.tool_name),
            );
            return Err(error);
        }

        Ok(())
    }

    /// Validate command arguments
    pub fn validate_arguments(&self, args: &[String]) -> Result<(), StructuredError> {
        // Check for suspicious argument patterns
        for arg in args {
            if arg.contains(";") || arg.contains("|") || arg.contains("&") {
                let mut error = StructuredError::new(
                    ErrorCode::Validation,
                    "Argument contains shell metacharacters",
                    2,
                );
                error.with_context("argument", arg);
                error.with_suggestion("Remove shell metacharacters from arguments");
                return Err(error);
            }
        }

        Ok(())
    }

    /// Validate resource limits
    pub fn validate_resource_limits(&self, memory_mb: Option<u64>, cpu_cores: Option<u64>) -> Result<(), StructuredError> {
        if let Some(memory) = memory_mb {
            if memory == 0 {
                let mut error = StructuredError::new(
                    ErrorCode::Validation,
                    "Memory limit cannot be zero",
                    2,
                );
                error.with_suggestion("Set a positive memory limit");
                return Err(error);
            }
            if memory > 1_000_000 {
                let mut error = StructuredError::new(
                    ErrorCode::Validation,
                    "Memory limit exceeds maximum allowed value",
                    2,
                );
                error.with_context("requested_memory_mb", memory.to_string());
                error.with_context("max_memory_mb", "1000000");
                error.with_suggestion("Reduce the memory limit to a reasonable value");
                return Err(error);
            }
        }

        if let Some(cpu) = cpu_cores {
            if cpu == 0 {
                let mut error = StructuredError::new(
                    ErrorCode::Validation,
                    "CPU limit cannot be zero",
                    2,
                );
                error.with_suggestion("Set a positive CPU limit");
                return Err(error);
            }
            if cpu > 128 {
                let mut error = StructuredError::new(
                    ErrorCode::Validation,
                    "CPU limit exceeds maximum allowed value",
                    2,
                );
                error.with_context("requested_cpu_cores", cpu.to_string());
                error.with_context("max_cpu_cores", "128");
                error.with_suggestion("Reduce the CPU limit to a reasonable value");
                return Err(error);
            }
        }

        Ok(())
    }
}

/// Validate before calling dependencies
pub fn validate_before_call(tool_name: &str) -> ErrorValidator {
    ErrorValidator::new(tool_name)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_validate_file_path_empty() {
        let validator = ErrorValidator::new("mytool");
        let result = validator.validate_file_path("");
        
        assert!(result.is_err());
        assert_eq!(result.unwrap_err().code, ErrorCode::Validation);
    }

    #[test]
    fn test_validate_file_path_parent_ref() {
        let validator = ErrorValidator::new("mytool");
        let result = validator.validate_file_path("../../../etc/passwd");
        
        assert!(result.is_err());
        assert_eq!(result.unwrap_err().code, ErrorCode::Validation);
    }

    #[test]
    fn test_validate_file_path_too_long() {
        let validator = ErrorValidator::new("mytool");
        let long_path = "a".repeat(5000);
        let result = validator.validate_file_path(&long_path);
        
        assert!(result.is_err());
        assert_eq!(result.unwrap_err().code, ErrorCode::Validation);
    }

    #[test]
    fn test_validate_file_path_valid() {
        let validator = ErrorValidator::new("mytool");
        let result = validator.validate_file_path("/path/to/file.txt");
        
        assert!(result.is_ok());
    }

    #[test]
    fn test_validate_url_empty() {
        let validator = ErrorValidator::new("mytool");
        let result = validator.validate_url("");
        
        assert!(result.is_err());
        assert_eq!(result.unwrap_err().code, ErrorCode::Validation);
    }

    #[test]
    fn test_validate_url_no_protocol() {
        let validator = ErrorValidator::new("mytool");
        let result = validator.validate_url("example.com");
        
        assert!(result.is_err());
        assert_eq!(result.unwrap_err().code, ErrorCode::Validation);
    }

    #[test]
    fn test_validate_url_valid() {
        let validator = ErrorValidator::new("mytool");
        let result = validator.validate_url("https://example.com");
        
        assert!(result.is_ok());
    }

    #[test]
    fn test_validate_arguments_shell_metacharacters() {
        let validator = ErrorValidator::new("mytool");
        let result = validator.validate_arguments(&["arg;rm -rf /".to_string()]);
        
        assert!(result.is_err());
        assert_eq!(result.unwrap_err().code, ErrorCode::Validation);
    }

    #[test]
    fn test_validate_arguments_valid() {
        let validator = ErrorValidator::new("mytool");
        let result = validator.validate_arguments(&["valid".to_string(), "args".to_string()]);
        
        assert!(result.is_ok());
    }

    #[test]
    fn test_validate_resource_limits_zero_memory() {
        let validator = ErrorValidator::new("mytool");
        let result = validator.validate_resource_limits(Some(0), None);
        
        assert!(result.is_err());
        assert_eq!(result.unwrap_err().code, ErrorCode::Validation);
    }

    #[test]
    fn test_validate_resource_limits_excessive_memory() {
        let validator = ErrorValidator::new("mytool");
        let result = validator.validate_resource_limits(Some(2_000_000), None);
        
        assert!(result.is_err());
        assert_eq!(result.unwrap_err().code, ErrorCode::Validation);
    }

    #[test]
    fn test_validate_resource_limits_zero_cpu() {
        let validator = ErrorValidator::new("mytool");
        let result = validator.validate_resource_limits(None, Some(0));
        
        assert!(result.is_err());
        assert_eq!(result.unwrap_err().code, ErrorCode::Validation);
    }

    #[test]
    fn test_validate_resource_limits_excessive_cpu() {
        let validator = ErrorValidator::new("mytool");
        let result = validator.validate_resource_limits(None, Some(256));
        
        assert!(result.is_err());
        assert_eq!(result.unwrap_err().code, ErrorCode::Validation);
    }

    #[test]
    fn test_validate_resource_limits_valid() {
        let validator = ErrorValidator::new("mytool");
        let result = validator.validate_resource_limits(Some(1024), Some(4));
        
        assert!(result.is_ok());
    }

    #[test]
    fn test_validate_before_call_function() {
        let validator = validate_before_call("mytool");
        let result = validator.validate_file_path("/valid/path");
        
        assert!(result.is_ok());
    }
}
