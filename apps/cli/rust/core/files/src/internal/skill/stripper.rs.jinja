//! Live state stripping module
//!
//! Strips live state from generated skill content to ensure skills are static
//! and don't include dynamic data like open sessions, current directory paths,
//! or other runtime-specific information.

use anyhow::Result;
use regex::Regex;

/// Configuration for state stripping
#[derive(Debug, Clone)]
pub struct StripConfig {
    /// Patterns to strip (regex)
    pub patterns: Vec<String>,
    /// Whether to strip file paths
    pub strip_paths: bool,
    /// Whether to strip session IDs
    pub strip_session_ids: bool,
    /// Whether to strip timestamps
    pub strip_timestamps: bool,
}

impl Default for StripConfig {
    fn default() -> Self {
        Self {
            patterns: vec![
                r"/tmp/.*".to_string(),
                r"/var/folders/.*".to_string(),
                r"/Users/[^/]+/".to_string(),
                r"/home/[^/]+/".to_string(),
                r"session-[a-f0-9]+".to_string(),
                r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}".to_string(),
            ],
            strip_paths: true,
            strip_session_ids: true,
            strip_timestamps: true,
        }
    }
}

/// State stripper
pub struct StateStripper {
    config: StripConfig,
    compiled_patterns: Vec<Regex>,
}

impl StateStripper {
    /// Create a new state stripper
    pub fn new(config: StripConfig) -> Self {
        let compiled_patterns = config
            .patterns
            .iter()
            .filter_map(|pattern| Regex::new(pattern).ok())
            .collect();

        Self {
            config,
            compiled_patterns,
        }
    }

    /// Strip live state from content
    pub fn strip(&self, content: &str) -> Result<String> {
        let mut result = content.to_string();

        // Apply all regex patterns
        for pattern in &self.compiled_patterns {
            result = pattern.replace_all(&result, "[REDACTED]").to_string();
        }

        // Strip file paths if enabled
        if self.config.strip_paths {
            result = self.strip_paths(&result);
        }

        // Strip session IDs if enabled
        if self.config.strip_session_ids {
            result = self.strip_session_ids(&result);
        }

        // Strip timestamps if enabled
        if self.config.strip_timestamps {
            result = self.strip_timestamps(&result);
        }

        Ok(result)
    }

    /// Strip file paths
    fn strip_paths(&self, content: &str) -> String {
        // Replace absolute paths with placeholder
        let re = Regex::new(r"/[a-zA-Z0-9_\-/]+").unwrap();
        re.replace_all(content, "[PATH]").to_string()
    }

    /// Strip session IDs
    fn strip_session_ids(&self, content: &str) -> String {
        let re = Regex::new(r"session-[a-f0-9]+").unwrap();
        re.replace_all(content, "session-[ID]").to_string()
    }

    /// Strip timestamps
    fn strip_timestamps(&self, content: &str) -> String {
        let re = Regex::new(r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}").unwrap();
        re.replace_all(content, "[TIMESTAMP]").to_string()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_path_stripping() {
        let config = StripConfig {
            patterns: vec![],
            strip_paths: true,
            strip_session_ids: false,
            strip_timestamps: false,
        };
        let stripper = StateStripper::new(config);
        let content = "File at /Users/test/file.txt";
        let result = stripper.strip(content).unwrap();
        assert!(result.contains("[PATH]"));
        assert!(!result.contains("/Users/test"));
    }

    #[test]
    fn test_session_id_stripping() {
        let config = StripConfig {
            patterns: vec![],
            strip_paths: false,
            strip_session_ids: true,
            strip_timestamps: false,
        };
        let stripper = StateStripper::new(config);
        let content = "Session session-abc123def456";
        let result = stripper.strip(content).unwrap();
        assert!(result.contains("session-[ID]"));
        assert!(!result.contains("abc123"));
    }

    #[test]
    fn test_timestamp_stripping() {
        let config = StripConfig {
            patterns: vec![],
            strip_paths: false,
            strip_session_ids: false,
            strip_timestamps: true,
        };
        let stripper = StateStripper::new(config);
        let content = "At 2025-06-10T12:30:45";
        let result = stripper.strip(content).unwrap();
        assert!(result.contains("[TIMESTAMP]"));
        assert!(!result.contains("2025-06-10"));
    }
}
