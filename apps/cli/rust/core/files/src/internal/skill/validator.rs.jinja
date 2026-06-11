//! Skill validation module
//!
//! Validates that generated SKILL.md files are fresh and not stale compared
//! to the current CLI implementation.

use anyhow::Result;
use std::path::Path;

/// Validation result
#[derive(Debug, Clone, PartialEq)]
pub enum ValidationResult {
    /// Skill is fresh and up-to-date
    Fresh,
    /// Skill is stale and needs regeneration
    Stale { reason: String },
    /// Skill file not found
    NotFound,
    /// Validation error
    Error(String),
}

/// Skill validator
pub struct SkillValidator {
    skill_path: String,
}

impl SkillValidator {
    /// Create a new skill validator
    pub fn new(skill_path: String) -> Self {
        Self { skill_path }
    }

    /// Validate skill freshness
    pub fn validate(&self) -> Result<ValidationResult> {
        let path = Path::new(&self.skill_path);

        // Check if skill file exists
        if !path.exists() {
            return Ok(ValidationResult::NotFound);
        }

        // Read skill content
        let content = std::fs::read_to_string(path)?;

        // Check for required sections
        let required_sections = vec![
            "name:",
            "description:",
            "Token-Efficient Output",
            "Minimal Default Schemas",
            "Content Truncation",
            "Pre-computed Aggregates",
            "Definitive Empty States",
            "Structured Errors",
            "Idempotent Operations",
            "No Interactive Prompts",
            "Session Context",
            "Content-First No-Args",
            "Contextual Disclosure",
        ];

        for section in required_sections {
            if !content.contains(section) {
                return Ok(ValidationResult::Stale {
                    reason: format!("Missing required section: {}", section),
                });
            }
        }

        // Check for live state indicators (should not be present)
        let forbidden_patterns = vec![
            "/tmp/",
            "/var/folders/",
            r"/Users/[a-zA-Z]",
            r"/home/[a-zA-Z]",
            "session-[a-f0-9]{32}",
            r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}",
        ];

        for pattern in forbidden_patterns {
            if let Ok(re) = regex::Regex::new(pattern) {
                if re.is_match(&content) {
                    return Ok(ValidationResult::Stale {
                        reason: format!("Found forbidden pattern: {}", pattern),
                    });
                }
            }
        }

        Ok(ValidationResult::Fresh)
    }

    /// Check if skill needs regeneration
    pub fn needs_regeneration(&self) -> Result<bool> {
        match self.validate()? {
            ValidationResult::Fresh => Ok(false),
            ValidationResult::Stale { .. } | ValidationResult::NotFound => Ok(true),
            ValidationResult::Error(_) => Ok(true),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use tempfile::NamedTempFile;

    #[test]
    fn test_validation_fresh() {
        let temp_file = NamedTempFile::new().unwrap();
        let skill_path = temp_file.path().to_str().unwrap();

        let content = r#"---
name: my-tool
description: A test tool
---
# My Tool

## Token-Efficient Output
Test content
"#;
        fs::write(skill_path, content).unwrap();

        let validator = SkillValidator::new(skill_path.to_string());
        let result = validator.validate().unwrap();
        assert_eq!(result, ValidationResult::Fresh);
    }

    #[test]
    fn test_validation_missing_section() {
        let temp_file = NamedTempFile::new().unwrap();
        let skill_path = temp_file.path().to_str().unwrap();

        let content = r#"---
name: my-tool
description: A test tool
---
# My Tool
"#;
        fs::write(skill_path, content).unwrap();

        let validator = SkillValidator::new(skill_path.to_string());
        let result = validator.validate().unwrap();
        assert!(matches!(result, ValidationResult::Stale { .. }));
    }

    #[test]
    fn test_validation_not_found() {
        let validator = SkillValidator::new("/nonexistent/skill.md".to_string());
        let result = validator.validate().unwrap();
        assert_eq!(result, ValidationResult::NotFound);
    }
}
