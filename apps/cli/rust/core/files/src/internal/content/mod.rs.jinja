//! Content selection and state summary for no-args behavior
//!
//! This module implements content-first behavior where running the CLI with no arguments
//! shows the most relevant live content instead of a usage manual. This enables agents
//! to see actual state immediately and act without a second call.

pub mod selector;
pub mod summary;
#[cfg(test)]
mod tests;

pub use selector::{ContentSelector, ContentContext, select_content, ContentType};
pub use summary::{StateSummary, generate_summary};

use serde::{Deserialize, Serialize};

/// Content-first output that combines state summary with contextual suggestions
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ContentFirstOutput {
    /// State summary with relevant information
    pub summary: StateSummary,
    /// Contextual help suggestions
    pub suggestions: Vec<String>,
    /// Mode-aware formatting flag
    pub agent_mode: bool,
}

impl ContentFirstOutput {
    /// Create content-first output
    pub fn new(summary: StateSummary, suggestions: Vec<String>, agent_mode: bool) -> Self {
        Self {
            summary,
            suggestions,
            agent_mode,
        }
    }

    /// Format output for display
    pub fn format(&self) -> String {
        if self.agent_mode {
            self.format_toon()
        } else {
            self.format_human()
        }
    }

    /// Format in TOON format for agent mode
    fn format_toon(&self) -> String {
        let mut output = String::new();
        
        // Add summary in TOON format
        output.push_str(&self.summary.format_toon());
        
        // Add suggestions if any
        if !self.suggestions.is_empty() {
            output.push('\n');
            output.push_str("help[");
            output.push_str(&self.suggestions.len().to_string());
            output.push_str("]: ");
            for (i, suggestion) in self.suggestions.iter().enumerate() {
                if i > 0 {
                    output.push_str(", ");
                }
                output.push_str(suggestion);
            }
        }
        
        output
    }

    /// Format in human-readable format
    fn format_human(&self) -> String {
        let mut output = String::new();
        
        // Add summary in human format
        output.push_str(&self.summary.format_human());
        
        // Add suggestions if any
        if !self.suggestions.is_empty() {
            output.push_str("\n\n");
            output.push_str("Suggested commands:\n");
            for suggestion in &self.suggestions {
                output.push_str("  ");
                output.push_str(suggestion);
                output.push_str("\n");
            }
        }
        
        output
    }
}
