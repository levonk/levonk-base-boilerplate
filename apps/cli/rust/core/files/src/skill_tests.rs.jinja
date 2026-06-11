//! Tests for skill command

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_skill_generation() {
        // Test skill generation logic
        // This would typically be an integration test
    }

    #[test]
    fn test_skill_validation() {
        // Test skill validation logic
        // This would typically be an integration test
    }
}

#[cfg(test)]
mod integration_tests {
    use std::fs;
    use tempfile::NamedTempFile;

    #[test]
    fn test_skill_validation_integration() {
        use crate::internal::skill::{SkillValidator, ValidationResult};

        let temp_file = NamedTempFile::new().unwrap();
        let skill_path = temp_file.path().to_str().unwrap();

        // Test with fresh skill
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
    fn test_skill_validation_stale() {
        use crate::internal::skill::{SkillValidator, ValidationResult};

        let temp_file = NamedTempFile::new().unwrap();
        let skill_path = temp_file.path().to_str().unwrap();

        // Test with stale skill (missing section)
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
}
