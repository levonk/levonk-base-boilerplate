//! Skill generation module
//!
//! Generates SKILL.md content from CLI help and examples for agent discoverability.

use anyhow::Result;

/// Configuration for skill generation
#[derive(Debug, Clone)]
pub struct SkillConfig {
    /// Project name
    pub project_name: String,
    /// Project slug (kebab-case)
    pub project_slug: String,
    /// Project description
    pub description: String,
    /// CLI command examples
    pub examples: Vec<String>,
}

impl SkillConfig {
    /// Create a new skill configuration
    pub fn new(
        project_name: String,
        project_slug: String,
        description: String,
        examples: Vec<String>,
    ) -> Self {
        Self {
            project_name,
            project_slug,
            description,
            examples,
        }
    }
}

/// Skill generator
pub struct SkillGenerator {
    config: SkillConfig,
}

impl SkillGenerator {
    /// Create a new skill generator
    pub fn new(config: SkillConfig) -> Self {
        Self { config }
    }

    /// Generate SKILL.md content
    pub fn generate(&self) -> Result<String> {
        let mut content = String::new();

        // YAML frontmatter
        content.push_str("---\n");
        content.push_str(&format!("name: {}\n", self.config.project_slug));
        content.push_str("description: >\n");
        content.push_str(&format!("  {}\n", self.config.description));
        content.push_str("---\n\n");

        // Main content from CLI help
        content.push_str(&format!("# {}\n\n", self.config.project_name));
        content.push_str(&self.config.description);
        content.push_str("\n\n");

        // Examples section
        if !self.config.examples.is_empty() {
            content.push_str("## Examples\n\n");
            for example in &self.config.examples {
                content.push_str("```bash\n");
                content.push_str(example);
                content.push_str("\n```\n\n");
            }
        }

        // AXI compliance sections
        content.push_str("## Agent Mode Features\n\n");
        content.push_str("This CLI follows the Agent eXperience Interface (AXI) standards for agent consumption:\n\n");
        content.push_str("### Token-Efficient Output\n");
        content.push_str("Uses TOON format by default in agent mode for ~40% token savings over JSON.\n\n");
        content.push_str("### Minimal Default Schemas\n");
        content.push_str("Default list schemas include 3-4 essential fields (identifier, title, status).\n\n");
        content.push_str("### Content Truncation\n");
        content.push_str("Large text fields are truncated with escape hatch via --full flag.\n\n");
        content.push_str("### Pre-computed Aggregates\n");
        content.push_str("List output includes total counts and derived status fields.\n\n");
        content.push_str("### Definitive Empty States\n");
        content.push_str("Empty results are explicitly stated with context.\n\n");
        content.push_str("### Structured Errors\n");
        content.push_str("Errors go to stdout in structured format with actionable suggestions.\n\n");
        content.push_str("### Idempotent Operations\n");
        content.push_str("State-changing operations are idempotent with exit code 0 for no-ops.\n\n");
        content.push_str("### No Interactive Prompts\n");
        content.push_str("All operations are completable with flags alone in agent mode.\n\n");
        content.push_str("### Session Context\n");
        content.push_str("Provides compact session context via --session-context flag.\n\n");
        content.push_str("### Content-First No-Args\n");
        content.push_str("Running with no arguments shows relevant live state, not help.\n\n");
        content.push_str("### Contextual Disclosure\n");
        content.push_str("Output includes relevant next-step suggestions.\n\n");

        Ok(content)
    }

    /// Generate skill with live state stripping
    pub fn generate_with_stripping(&self, strip_config: &super::stripper::StripConfig) -> Result<String> {
        let content = self.generate()?;
        let stripper = super::stripper::StateStripper::new(strip_config.clone());
        stripper.strip(&content)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_skill_generation() {
        let config = SkillConfig::new(
            "My Tool".to_string(),
            "my-tool".to_string(),
            "A tool for processing files".to_string(),
            vec![
                "my-tool file1.txt".to_string(),
                "my-tool --format toon file1.txt".to_string(),
            ],
        );

        let generator = SkillGenerator::new(config);
        let result = generator.generate().unwrap();

        assert!(result.contains("name: my-tool"));
        assert!(result.contains("A tool for processing files"));
        assert!(result.contains("my-tool file1.txt"));
        assert!(result.contains("Token-Efficient Output"));
    }
}
