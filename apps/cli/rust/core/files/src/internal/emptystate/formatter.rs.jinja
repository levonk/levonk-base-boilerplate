//! Empty state formatting logic
//! 
//! This module provides formatting for empty state messages with context
//! to clearly communicate when queries return no results.

use crate::internal::emptystate::detector::EmptyStateContext;

/// Empty state message
#[derive(Debug, Clone)]
pub struct EmptyStateMessage {
    /// The main message
    pub message: String,
    /// Context about the query
    pub context: String,
    /// Suggestion for next steps (optional)
    pub suggestion: Option<String>,
}

/// Empty state formatter
#[derive(Debug, Clone)]
pub struct EmptyStateFormatter {
    /// Include suggestions in empty state messages
    include_suggestions: bool,
}

impl EmptyStateFormatter {
    /// Create a new empty state formatter
    pub fn new() -> Self {
        Self {
            include_suggestions: true,
        }
    }

    /// Create a formatter without suggestions
    pub fn without_suggestions() -> Self {
        Self {
            include_suggestions: false,
        }
    }

    /// Format an empty state message
    pub fn format(&self, context: &EmptyStateContext) -> EmptyStateMessage {
        let message = self.build_message(context);
        let context_str = self.build_context(context);
        let suggestion = if self.include_suggestions {
            self.build_suggestion(context)
        } else {
            None
        };

        EmptyStateMessage {
            message,
            context: context_str,
            suggestion,
        }
    }

    /// Build the main message
    fn build_message(&self, context: &EmptyStateContext) -> String {
        format!("No results found for '{}'", context.command)
    }

    /// Build the context string
    fn build_context(&self, context: &EmptyStateContext) -> String {
        let mut parts = Vec::new();

        if let Some(scope) = &context.scope {
            parts.push(format!("scope: {}", scope));
        }

        if !context.filters.is_empty() {
            let filter_str = context
                .filters
                .iter()
                .map(|(k, v)| format!("{}={}", k, v))
                .collect::<Vec<_>>()
                .join(", ");
            parts.push(format!("filters: {}", filter_str));
        }

        if !context.extra.is_empty() {
            let extra_str = context
                .extra
                .iter()
                .map(|(k, v)| format!("{}={}", k, v))
                .collect::<Vec<_>>()
                .join(", ");
            parts.push(format!("context: {}", extra_str));
        }

        if parts.is_empty() {
            "Query executed successfully".to_string()
        } else {
            format!("Query executed successfully ({})", parts.join(", "))
        }
    }

    /// Build a suggestion for next steps
    fn build_suggestion(&self, context: &EmptyStateContext) -> Option<String> {
        if !context.filters.is_empty() {
            Some("Try adjusting your filter criteria or removing filters to see more results".to_string())
        } else if context.scope.as_ref().map(|s| s != "all").unwrap_or(false) {
            Some("Try expanding the scope of your query".to_string())
        } else {
            None
        }
    }

    /// Format the empty state message as a single string
    pub fn format_as_string(&self, context: &EmptyStateContext) -> String {
        let msg = self.format(context);
        let mut output = vec![msg.message, msg.context];

        if let Some(suggestion) = msg.suggestion {
            output.push(suggestion);
        }

        output.join("\n")
    }
}

impl Default for EmptyStateFormatter {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_formatter_basic() {
        let formatter = EmptyStateFormatter::new();
        let context = EmptyStateContext::new("list");

        let message = formatter.format(&context);
        assert_eq!(message.message, "No results found for 'list'");
        assert!(message.context.contains("Query executed successfully"));
    }

    #[test]
    fn test_formatter_with_filters() {
        let formatter = EmptyStateFormatter::new();
        let context = EmptyStateContext::new("list")
            .with_filter("status", "active")
            .with_filter("type", "user");

        let message = formatter.format(&context);
        assert_eq!(message.message, "No results found for 'list'");
        assert!(message.context.contains("filters: status=active, type=user"));
        assert!(message.suggestion.is_some());
    }

    #[test]
    fn test_formatter_with_scope() {
        let formatter = EmptyStateFormatter::new();
        let context = EmptyStateContext::new("list").with_scope("active");

        let message = formatter.format(&context);
        assert_eq!(message.message, "No results found for 'list'");
        assert!(message.context.contains("scope: active"));
    }

    #[test]
    fn test_formatter_with_extra() {
        let formatter = EmptyStateFormatter::new();
        let context = EmptyStateContext::new("list")
            .with_extra("user", "test")
            .with_extra("project", "demo");

        let message = formatter.format(&context);
        assert_eq!(message.message, "No results found for 'list'");
        assert!(message.context.contains("context: user=test, project=demo"));
    }

    #[test]
    fn test_formatter_without_suggestions() {
        let formatter = EmptyStateFormatter::without_suggestions();
        let context = EmptyStateContext::new("list").with_filter("status", "active");

        let message = formatter.format(&context);
        assert!(message.suggestion.is_none());
    }

    #[test]
    fn test_formatter_as_string() {
        let formatter = EmptyStateFormatter::new();
        let context = EmptyStateContext::new("list").with_filter("status", "active");

        let output = formatter.format_as_string(&context);
        assert!(output.contains("No results found for 'list'"));
        assert!(output.contains("Query executed successfully"));
        assert!(output.contains("Try adjusting your filter criteria"));
    }

    #[test]
    fn test_formatter_complex_context() {
        let formatter = EmptyStateFormatter::new();
        let context = EmptyStateContext::new("search")
            .with_filter("status", "pending")
            .with_scope("user")
            .with_extra("user_id", "12345");

        let message = formatter.format(&context);
        assert_eq!(message.message, "No results found for 'search'");
        assert!(message.context.contains("scope: user"));
        assert!(message.context.contains("filters: status=pending"));
        assert!(message.context.contains("context: user_id=12345"));
    }
}
