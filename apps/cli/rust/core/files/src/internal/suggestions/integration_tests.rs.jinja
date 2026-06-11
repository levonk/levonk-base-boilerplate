//! Integration tests for the suggestion engine

use super::engine::{SuggestionEngine, SuggestionContext, SuggestionRank};
use super::rules::RuleRegistry;
use crate::internal::aggregates::AggregateInfo;
use crate::internal::emptystate::EmptyStateContext;

#[test]
fn test_suggestion_engine_empty_list() {
    let engine = SuggestionEngine::new();
    let mut context = SuggestionContext::default();
    context.command = "list".to_string();
    context.is_empty = true;

    let suggestions = engine.generate(&context);
    assert!(!suggestions.is_empty());
    assert!(suggestions.len() <= 4);
    assert!(suggestions.iter().any(|s| s.command == "create"));
}

#[test]
fn test_suggestion_engine_non_empty_list() {
    let engine = SuggestionEngine::new();
    let mut context = SuggestionContext::default();
    context.command = "list".to_string();
    context.is_empty = false;

    let suggestions = engine.generate(&context);
    assert!(!suggestions.is_empty());
    assert!(suggestions.len() <= 4);
    assert!(suggestions.iter().any(|s| s.command.contains("show")));
}

#[test]
fn test_suggestion_engine_large_list() {
    let engine = SuggestionEngine::new();
    let mut context = SuggestionContext::default();
    context.command = "list".to_string();
    context.is_empty = false;
    context.aggregates = Some(AggregateInfo {
        total_count: Some(20),
        error_count: Some(0),
        warning_count: Some(0),
    });

    let suggestions = engine.generate(&context);
    assert!(!suggestions.is_empty());
    assert!(suggestions.iter().any(|s| s.command.contains("filter")));
}

#[test]
fn test_suggestion_engine_show_command() {
    let engine = SuggestionEngine::new();
    let mut context = SuggestionContext::default();
    context.command = "show".to_string();
    context.action = Some("item".to_string());

    let suggestions = engine.generate(&context);
    assert!(!suggestions.is_empty());
    assert!(suggestions.iter().any(|s| s.command.contains("edit")));
    assert!(suggestions.iter().any(|s| s.command.contains("delete")));
}

#[test]
fn test_suggestion_engine_create_command() {
    let engine = SuggestionEngine::new();
    let mut context = SuggestionContext::default();
    context.command = "create".to_string();

    let suggestions = engine.generate(&context);
    assert!(!suggestions.is_empty());
    assert!(suggestions.iter().any(|s| s.command.contains("show")));
    assert!(suggestions.iter().any(|s| s.command == "list"));
}

#[test]
fn test_suggestion_engine_delete_command_empty() {
    let engine = SuggestionEngine::new();
    let mut context = SuggestionContext::default();
    context.command = "delete".to_string();
    context.is_empty = true;

    let suggestions = engine.generate(&context);
    assert!(!suggestions.is_empty());
    assert!(suggestions.iter().any(|s| s.command == "create"));
}

#[test]
fn test_suggestion_engine_update_command() {
    let engine = SuggestionEngine::new();
    let mut context = SuggestionContext::default();
    context.command = "update".to_string();

    let suggestions = engine.generate(&context);
    assert!(!suggestions.is_empty());
    assert!(suggestions.iter().any(|s| s.command.contains("show")));
    assert!(suggestions.iter().any(|s| s.command.contains("test")));
}

#[test]
fn test_suggestion_engine_status_with_errors() {
    let engine = SuggestionEngine::new();
    let mut context = SuggestionContext::default();
    context.command = "status".to_string();
    context.aggregates = Some(AggregateInfo {
        total_count: Some(10),
        error_count: Some(3),
        warning_count: Some(1),
    });

    let suggestions = engine.generate(&context);
    assert!(!suggestions.is_empty());
    assert!(suggestions.iter().any(|s| s.command.contains("fix")));
}

#[test]
fn test_suggestion_engine_unknown_command() {
    let engine = SuggestionEngine::new();
    let mut context = SuggestionContext::default();
    context.command = "unknown".to_string();

    let suggestions = engine.generate(&context);
    assert!(!suggestions.is_empty());
    // Should fall back to generic suggestions
    assert!(suggestions.iter().any(|s| s.command == "--help"));
}

#[test]
fn test_suggestion_engine_with_flags() {
    let engine = SuggestionEngine::new();
    let mut context = SuggestionContext::default();
    context.command = "list".to_string();
    context.flags = vec!["--all".to_string(), "--verbose".to_string()];

    let suggestions = engine.generate(&context);
    assert!(!suggestions.is_empty());
}

#[test]
fn test_suggestion_engine_agent_mode() {
    let engine = SuggestionEngine::new();
    let mut context = SuggestionContext::default();
    context.command = "list".to_string();
    context.mode = "agent".to_string();

    let suggestions = engine.generate(&context);
    assert!(!suggestions.is_empty());
}

#[test]
fn test_suggestion_engine_human_mode() {
    let engine = SuggestionEngine::new();
    let mut context = SuggestionContext::default();
    context.command = "list".to_string();
    context.mode = "human".to_string();

    let suggestions = engine.generate(&context);
    assert!(!suggestions.is_empty());
}

#[test]
fn test_suggestion_ranking() {
    let engine = SuggestionEngine::new();
    let mut context = SuggestionContext::default();
    context.command = "list".to_string();
    context.is_empty = true;

    let suggestions = engine.generate(&context);
    // Suggestions should be sorted by rank
    for window in suggestions.windows(2) {
        assert!(window[0].rank >= window[1].rank);
    }
}

#[test]
fn test_suggestion_limit_max_4() {
    let engine = SuggestionEngine::new();
    let context = SuggestionContext::default();

    let suggestions = engine.generate(&context);
    assert!(suggestions.len() <= 4);
}

#[test]
fn test_suggestion_limit_min_2_when_available() {
    let engine = SuggestionEngine::new();
    let mut context = SuggestionContext::default();
    context.command = "list".to_string();

    let suggestions = engine.generate(&context);
    // Should have at least 2 suggestions when rules generate them
    assert!(suggestions.len() >= 2);
}

#[test]
fn test_custom_rule_registry() {
    let custom_rules = RuleRegistry::new();
    let engine = SuggestionEngine::with_rules(custom_rules);

    let context = SuggestionContext::default();
    let suggestions = engine.generate(&context);
    assert!(!suggestions.is_empty());
}

#[test]
fn test_suggestion_context_awareness() {
    let engine = SuggestionEngine::new();
    
    // Empty context
    let mut empty_context = SuggestionContext::default();
    empty_context.command = "list".to_string();
    empty_context.is_empty = true;
    let empty_suggestions = engine.generate(&empty_context);
    
    // Non-empty context
    let mut non_empty_context = SuggestionContext::default();
    non_empty_context.command = "list".to_string();
    non_empty_context.is_empty = false;
    let non_empty_suggestions = engine.generate(&non_empty_context);
    
    // Suggestions should differ based on context
    let empty_commands: Vec<_> = empty_suggestions.iter().map(|s| &s.command).collect();
    let non_empty_commands: Vec<_> = non_empty_suggestions.iter().map(|s| &s.command).collect();
    
    assert_ne!(empty_commands, non_empty_commands);
}

#[test]
fn test_suggestion_description_present() {
    let engine = SuggestionEngine::new();
    let context = SuggestionContext::default();

    let suggestions = engine.generate(&context);
    for suggestion in suggestions {
        assert!(!suggestion.description.is_empty());
    }
}

#[test]
fn test_suggestion_command_present() {
    let engine = SuggestionEngine::new();
    let context = SuggestionContext::default();

    let suggestions = engine.generate(&context);
    for suggestion in suggestions {
        assert!(!suggestion.command.is_empty());
    }
}
