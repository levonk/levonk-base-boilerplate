//! Output channel separation for errors and diagnostics

use std::io::{self, Write, Stdout, Stderr};
use crate::internal::errors::StructuredError;
use crate::internal::toon::OutputFormat;

/// Output channel for structured errors (stdout)
pub struct ErrorChannel {
    stdout: Stdout,
    format: OutputFormat,
}

impl ErrorChannel {
    /// Create a new error channel
    pub fn new(format: OutputFormat) -> Self {
        Self {
            stdout: io::stdout(),
            format,
        }
    }

    /// Write a structured error to stdout
    pub fn write_error(&mut self, error: &StructuredError) -> io::Result<()> {
        let formatted = crate::internal::errors::format_error_with_format(error, self.format)
            .unwrap_or_else(|e| format!("Error formatting failed: {}", e));
        
        writeln!(self.stdout, "{}", formatted)?;
        self.stdout.flush()
    }

    /// Write a raw message to stdout (for normal output)
    pub fn write_message(&mut self, message: &str) -> io::Result<()> {
        writeln!(self.stdout, "{}", message)?;
        self.stdout.flush()
    }
}

/// Diagnostic channel for logging and debug information (stderr)
pub struct DiagnosticChannel {
    stderr: Stderr,
}

impl DiagnosticChannel {
    /// Create a new diagnostic channel
    pub fn new() -> Self {
        Self {
            stderr: io::stderr(),
        }
    }
    
    /// Write a diagnostic message to stderr
    pub fn write_diagnostic(&mut self, message: &str) -> io::Result<()> {
        writeln!(self.stderr, "[DIAG] {}", message)?;
        self.stderr.flush()
    }

    /// Write a debug message to stderr
    pub fn write_debug(&mut self, message: &str) -> io::Result<()> {
        writeln!(self.stderr, "[DEBUG] {}", message)?;
        self.stderr.flush()
    }

    /// Write a warning to stderr
    pub fn write_warning(&mut self, message: &str) -> io::Result<()> {
        writeln!(self.stderr, "[WARN] {}", message)?;
        self.stderr.flush()
    }
}

impl Default for DiagnosticChannel {
    fn default() -> Self {
        Self::new()
    }
}

/// Combined output channels
pub struct OutputChannels {
    error_channel: ErrorChannel,
    diagnostic_channel: DiagnosticChannel,
}

impl OutputChannels {
    /// Create new output channels
    pub fn new(format: OutputFormat) -> Self {
        Self {
            error_channel: ErrorChannel::new(format),
            diagnostic_channel: DiagnosticChannel::new(),
        }
    }

    /// Write a structured error to stdout
    pub fn write_error(&mut self, error: &StructuredError) -> io::Result<()> {
        self.error_channel.write_error(error)
    }

    /// Write a normal message to stdout
    pub fn write_message(&mut self, message: &str) -> io::Result<()> {
        self.error_channel.write_message(message)
    }

    /// Write a diagnostic to stderr
    pub fn write_diagnostic(&mut self, message: &str) -> io::Result<()> {
        self.diagnostic_channel.write_diagnostic(message)
    }

    /// Write a debug message to stderr
    pub fn write_debug(&mut self, message: &str) -> io::Result<()> {
        self.diagnostic_channel.write_debug(message)
    }

    /// Write a warning to stderr
    pub fn write_warning(&mut self, message: &str) -> io::Result<()> {
        self.diagnostic_channel.write_warning(message)
    }

    /// Get the error channel
    pub fn error_channel(&mut self) -> &mut ErrorChannel {
        &mut self.error_channel
    }

    /// Get the diagnostic channel
    pub fn diagnostic_channel(&mut self) -> &mut DiagnosticChannel {
        &mut self.diagnostic_channel
    }
}

impl Default for OutputChannels {
    fn default() -> Self {
        Self::new(OutputFormat::Human)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::internal::errors::ErrorCode;

    #[test]
    fn test_error_channel_write_error() {
        let mut channel = ErrorChannel::new(OutputFormat::Toon);
        let error = StructuredError::new(
            ErrorCode::Config,
            "Test error",
            3,
        );
        
        // This test just verifies the method exists and doesn't panic
        // Actual output testing would require capturing stdout
        let result = channel.write_error(&error);
        assert!(result.is_ok());
    }

    #[test]
    fn test_error_channel_write_message() {
        let mut channel = ErrorChannel::new(OutputFormat::Toon);
        let result = channel.write_message("Test message");
        assert!(result.is_ok());
    }

    #[test]
    fn test_diagnostic_channel_write_diagnostic() {
        let mut channel = DiagnosticChannel::new();
        let result = channel.write_diagnostic("Test diagnostic");
        assert!(result.is_ok());
    }

    #[test]
    fn test_diagnostic_channel_write_debug() {
        let mut channel = DiagnosticChannel::new();
        let result = channel.write_debug("Test debug");
        assert!(result.is_ok());
    }

    #[test]
    fn test_diagnostic_channel_write_warning() {
        let mut channel = DiagnosticChannel::new();
        let result = channel.write_warning("Test warning");
        assert!(result.is_ok());
    }

    #[test]
    fn test_output_channels_write_error() {
        let mut channels = OutputChannels::new(OutputFormat::Toon);
        let error = StructuredError::new(
            ErrorCode::Config,
            "Test error",
            3,
        );
        
        let result = channels.write_error(&error);
        assert!(result.is_ok());
    }

    #[test]
    fn test_output_channels_write_message() {
        let mut channels = OutputChannels::new(OutputFormat::Toon);
        let result = channels.write_message("Test message");
        assert!(result.is_ok());
    }

    #[test]
    fn test_output_channels_write_diagnostic() {
        let mut channels = OutputChannels::new(OutputFormat::Toon);
        let result = channels.write_diagnostic("Test diagnostic");
        assert!(result.is_ok());
    }

    #[test]
    fn test_output_channels_default() {
        let channels = OutputChannels::default();
        // Verify default format is Human
        // This is an implicit test - the struct should be created successfully
        let _ = channels;
    }
}
