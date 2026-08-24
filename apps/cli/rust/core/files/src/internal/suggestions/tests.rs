/// Integration tests for suggestion engine

use crate::internal::suggestions::{SuggestionEngine, SuggestionContext};
use crate::internal::context::ExecutionContext;
use crate::internal::mode::detection::Mode;

#[test]
fn test_suggestion_engine_empty_list() {
    let engine = SuggestionEngine::new();
    let context = SuggestionContext::new("list")
        .with_empty(true)
        .with_item_count(0);
    let exec_context = ExecutionContext::new(Mode::Agent);

    let suggestions = engine.generate("list", &context, &exec_context);
    
    // Should suggest create when list is empty
    assert!(!suggestions.is_empty());
    assert!(suggestions.iter().any(|s| s.command.contains("create")));
}

#[test]
fn test_suggestion_engine_list_with_items() {
    let engine = SuggestionEngine::new();
    let context = SuggestionContext::new("list")
        .with_empty(false)
        .with_item_count(5)
        .with_open_items(true);
    let exec_context = ExecutionContext::new(Mode::Agent);

    let suggestions = engine.generate("list", &context, &exec_context);
    
    // Should suggest view and create
    assert!(!suggestions.is_empty());
    assert!(suggestions.iter().any(|s| s.command.contains("view")));
    assert!(suggestions.iter().any(|s| s.command.contains("create")));
}

#[test]
fn test_suggestion_engine_create_success() {
    let engine = SuggestionEngine::new();
    let context = SuggestionContext::new("create")
        .with_success(true)
        .with_last_item_id("42");
    let exec_context = ExecutionContext::new(Mode::Agent);

    let suggestions = engine.generate("create", &context, &exec_context);
    
    // Should suggest viewing the created item
    assert!(!suggestions.is_empty());
    assert!(suggestions.iter().any(|s| s.command.contains("view 42")));
}

#[test]
fn test_suggestion_engine_update_success() {
    let engine = SuggestionEngine::new();
    let context = SuggestionContext::new("update")
        .with_success(true)
        .with_last_item_id("42");
    let exec_context = ExecutionContext::new(Mode::Agent);

    let suggestions = engine.generate("update", &context, &exec_context);
    
    // Should suggest viewing the updated item
    assert!(!suggestions.is_empty());
    assert!(suggestions.iter().any(|s| s.command.contains("view 42")));
}

#[test]
fn test_suggestion_engine_delete_success() {
    let engine = SuggestionEngine::new();
    let context = SuggestionContext::new("delete")
        .with_success(true);
    let exec_context = ExecutionContext::new(Mode::Agent);

    let suggestions = engine.generate("delete", &context, &exec_context);
    
    // Should suggest listing remaining items
    assert!(!suggestions.is_empty());
    assert!(suggestions.iter().any(|s| s.command.contains("list")));
}

#[test]
fn test_suggestion_engine_error_context() {
    let engine = SuggestionEngine::new();
    let context = SuggestionContext::new("create")
        .with_success(false)
        .with_carry_flags(vec!["--title".to_string(), "test".to_string()]);
    let exec_context = ExecutionContext::new(Mode::Agent);

    let suggestions = engine.generate("create", &context, &exec_context);
    
    // Should suggest retry with force
    assert!(!suggestions.is_empty());
    assert!(suggestions.iter().any(|s| s.command.contains("--force")));
}

#[test]
fn test_suggestion_engine_limits() {
    let engine = SuggestionEngine::with_max_suggestions(2);
    let context = SuggestionContext::new("list")
        .with_empty(false)
        .with_item_count(10)
        .with_open_items(true);
    let exec_context = ExecutionContext::new(Mode::Agent);

    let suggestions = engine.generate("list", &context, &exec_context);
    
    // Should limit to 2 suggestions
    assert!(suggestions.len() <= 2);
}

#[test]
fn test_suggestion_engine_ranking() {
    let engine = SuggestionEngine::new();
    let context = SuggestionContext::new("create")
        .with_success(true)
        .with_last_item_id("42");
    let exec_context = ExecutionContext::new(Mode::Agent);

    let suggestions = engine.generate("create", &context, &exec_context);
    
    // Suggestions should be sorted by score (descending)
    for i in 1..suggestions.len() {
        assert!(suggestions[i-1].score >= suggestions[i].score);
    }
}

#[test]
fn test_suggestion_engine_context_awareness() {
    let engine = SuggestionEngine::new();
    
    // Empty context
    let empty_ctx = SuggestionContext::new("list")
        .with_empty(true)
        .with_item_count(0);
    let exec_context = ExecutionContext::new(Mode::Agent);
    let empty_suggestions = engine.generate("list", &empty_ctx, &exec_context);
    
    // Non-empty context
    let non_empty_ctx = SuggestionContext::new("list")
        .with_empty(false)
        .with_item_count(5);
    let non_empty_suggestions = engine.generate("list", &non_empty_ctx, &exec_context);
    
    // Suggestions should differ based on context
    let empty_cmds: Vec<_> = empty_suggestions.iter().map(|s| &s.command).collect();
    let non_empty_cmds: Vec<_> = non_empty_suggestions.iter().map(|s| &s.command).collect();
    
    assert_ne!(empty_cmds, non_empty_cmds);
}

#[test]
fn test_suggestion_engine_flag_carry_forward() {
    let engine = SuggestionEngine::new();
    let context = SuggestionContext::new("create")
        .with_success(false)
        .with_carry_flags(vec!["--title".to_string(), "My Task".to_string()]);
    let exec_context = ExecutionContext::new(Mode::Agent);

    let suggestions = engine.generate("create", &context, &exec_context);
    
    // Should carry forward flags in error suggestions
    assert!(!suggestions.is_empty());
    let has_carry = suggestions.iter().any(|s| {
        s.command.contains("--title") && s.command.contains("My Task")
    });
    assert!(has_carry);
}
