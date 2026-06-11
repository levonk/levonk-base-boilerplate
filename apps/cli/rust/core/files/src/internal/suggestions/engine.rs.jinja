//! Suggestion engine for generating context-aware CLI suggestions
//! 
//! The suggestion engine analyzes command output and context to generate
//! relevant, actionable next steps for users.

use crate::internal::aggregates::AggregateInfo;
use crate::internal::emptystate::EmptyStateContext;
use super::rules::RuleRegistry;

/// Context information for suggestion generation
#[derive(Debug, Clone)]
pub struct SuggestionContext {
    /// The command that was executed
    pub command: String,
    /// The subcommand or action that was performed
    pub action: Option<String>,
    /// Whether the output is empty (no results)
    pub is_empty: bool,
    /// Aggregate information about the output (counts, derived fields)
    pub aggregates: Option<AggregateInfo>,
    /// Empty state context if applicable
    pub empty_state: Option<EmptyStateContext>,
    /// Current execution mode (agent vs human)
    pub mode: String,
    /// Any flags that were used in the command
    pub flags: Vec<String>,
}

impl Default for SuggestionContext {
    fn default() -> Self {
        Self {
            command: String::new(),
            action: None,
            is_empty: false,
            aggregates: None,
            empty_state: None,
            mode: "agent".to_string(),
            flags: Vec::new(),
        }
    }
}

/// A single suggestion with metadata
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Suggestion {
    /// The suggested command to run
    pub command: String,
    /// Human-readable description of what the command does
    pub description: String,
    /// Relevance score (higher is more relevant)
    pub rank: SuggestionRank,
}

/// Relevance ranking for suggestions
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum SuggestionRank {
    /// High relevance - directly related to current context
    High = 3,
    /// Medium relevance - related but not directly
    Medium = 2,
    /// Low relevance - generic fallback suggestions
    Low = 1,
}

/// Suggestion engine that generates context-aware suggestions
pub struct SuggestionEngine {
    rules: RuleRegistry,
}

impl SuggestionEngine {
    /// Create a new suggestion engine with default rules
    pub fn new() -> Self {
        Self {
            rules: RuleRegistry::new(),
        }
    }

    /// Create a new suggestion engine with custom rules
    pub fn with_rules(rules: RuleRegistry) -> Self {
        Self { rules }
    }

    /// Generate suggestions based on the current context
    pub fn generate(&self, context: &SuggestionContext) -> Vec<Suggestion> {
        let mut suggestions = Vec::new();

        // Apply all rules to generate suggestions
        for rule in self.rules.get_rules_for_command(&context.command) {
            if let Some(rule_suggestions) = rule.apply(context) {
                suggestions.extend(rule_suggestions);
            }
        }

        // Rank and limit suggestions
        self.rank_and_limit(suggestions)
    }

    /// Rank suggestions by relevance and limit to 2-4 suggestions
    fn rank_and_limit(&self, mut suggestions: Vec<Suggestion>) -> Vec<Suggestion> {
        // Sort by rank (descending)
        suggestions.sort_by(|a, b| b.rank.cmp(&a.rank));

        // Limit to 2-4 suggestions
        suggestions.truncate(4);

        // Ensure at least 2 suggestions if we have any
        if suggestions.len() == 1 {
            // Try to add a generic fallback suggestion
            if let Some(fallback) = self.get_fallback_suggestion() {
                suggestions.push(fallback);
            }
        }

        suggestions
    }

    /// Get a generic fallback suggestion when no specific suggestions are available
    fn get_fallback_suggestion(&self) -> Option<Suggestion> {
        Some(Suggestion {
            command: "--help".to_string(),
            description: "Show help information".to_string(),
            rank: SuggestionRank::Low,
        })
    }
}

impl Default for SuggestionEngine {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_suggestion_context_default() {
        let context = SuggestionContext::default();
        assert_eq!(context.command, "");
        assert!(context.action.is_none());
        assert!(!context.is_empty);
        assert!(context.aggregates.is_none());
        assert!(context.empty_state.is_none());
        assert_eq!(context.mode, "agent");
        assert!(context.flags.is_empty());
    }

    #[test]
    fn test_suggestion_rank_ordering() {
        assert!(SuggestionRank::High > SuggestionRank::Medium);
        assert!(SuggestionRank::Medium > SuggestionRank::Low);
        assert!(SuggestionRank::High > SuggestionRank::Low);
    }

    #[test]
    fn test_suggestion_engine_creation() {
        let engine = SuggestionEngine::new();
        let context = SuggestionContext::default();
        let suggestions = engine.generate(&context);
        // Should return at least the fallback suggestion
        assert!(!suggestions.is_empty());
    }

    #[test]
    fn test_suggestion_limit() {
        let engine = SuggestionEngine::new();
        let mut context = SuggestionContext::default();
        context.command = "test".to_string();

        let suggestions = engine.generate(&context);
        // Should return at most 4 suggestions
        assert!(suggestions.len() <= 4);
    }

    #[test]
    fn test_suggestion_ranking() {
        let engine = SuggestionEngine::new();
        let mut context = SuggestionContext::default();
        context.command = "test".to_string();

        let suggestions = engine.generate(&context);
        // Suggestions should be sorted by rank (descending)
        for window in suggestions.windows(2) {
            assert!(window[0].rank >= window[1].rank);
        }
    }
}
