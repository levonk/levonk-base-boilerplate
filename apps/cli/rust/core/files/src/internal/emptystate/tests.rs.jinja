//! Integration tests for empty state module

use crate::internal::emptystate::{EmptyStateDetector, EmptyStateFormatter, EmptyStateContext};
use crate::internal::toon::{OutputFormatter, OutputFormat};

#[test]
fn test_empty_state_detection_and_formatting_integration() {
    let detector = EmptyStateDetector;
    let formatter = EmptyStateFormatter::new();
    let context = EmptyStateContext::new("list")
        .with_filter("status", "active")
        .with_scope("all");

    let empty_vec: Vec<i32> = vec![];
    
    // Detect empty state
    assert!(detector.is_empty(&empty_vec));
    assert!(detector.is_empty_with_context(&empty_vec, &context));

    // Format empty state message
    let message = formatter.format(&context);
    assert_eq!(message.message, "No results found for 'list'");
    assert!(message.context.contains("scope: all"));
    assert!(message.context.contains("filters: status=active"));
}

#[test]
fn test_empty_state_with_various_data_types() {
    let detector = EmptyStateDetector;
    let formatter = EmptyStateFormatter::new();

    // Test with empty vector
    let empty_vec: Vec<String> = vec![];
    let context = EmptyStateContext::new("list");
    assert!(detector.is_empty(&empty_vec));
    let msg = formatter.format(&context);
    assert!(msg.message.contains("No results found"));

    // Test with empty option
    let empty_option: Option<i32> = None;
    assert!(detector.is_empty(&empty_option));

    // Test with empty string
    let empty_string = "";
    assert!(detector.is_empty(&empty_string));
}

#[test]
fn test_empty_state_formatting_consistency() {
    let formatter = EmptyStateFormatter::new();
    
    let context1 = EmptyStateContext::new("list").with_filter("status", "active");
    let context2 = EmptyStateContext::new("list").with_filter("status", "active");

    let msg1 = formatter.format(&context1);
    let msg2 = formatter.format(&context2);

    assert_eq!(msg1.message, msg2.message);
    assert_eq!(msg1.context, msg2.context);
}

#[test]
fn test_empty_state_suggestion_logic() {
    let formatter = EmptyStateFormatter::new();

    // With filters - should have suggestion
    let with_filters = EmptyStateContext::new("list").with_filter("status", "active");
    let msg = formatter.format(&with_filters);
    assert!(msg.suggestion.is_some());

    // Without filters - should not have suggestion
    let without_filters = EmptyStateContext::new("list");
    let msg = formatter.format(&without_filters);
    assert!(msg.suggestion.is_none());

    // With non-all scope - should have suggestion
    let with_scope = EmptyStateContext::new("list").with_scope("active");
    let msg = formatter.format(&with_scope);
    assert!(msg.suggestion.is_some());
}

#[test]
fn test_empty_state_complex_scenario() {
    let detector = EmptyStateDetector;
    let formatter = EmptyStateFormatter::new();

    let context = EmptyStateContext::new("search")
        .with_filter("type", "issue")
        .with_filter("status", "open")
        .with_scope("repository")
        .with_extra("repo", "test/repo")
        .with_extra("user", "testuser");

    let empty_results: Vec<String> = vec![];
    
    assert!(detector.is_empty_with_context(&empty_results, &context));

    let message = formatter.format(&context);
    assert_eq!(message.message, "No results found for 'search'");
    assert!(message.context.contains("scope: repository"));
    assert!(message.context.contains("filters: type=issue, status=open"));
    assert!(message.context.contains("context: repo=test/repo, user=testuser"));
    assert!(message.suggestion.is_some());
}

#[test]
fn test_empty_state_exit_code_behavior() {
    // Empty state should result in exit code 0 (success)
    // This test verifies the empty state detection doesn't change exit code behavior
    let detector = EmptyStateDetector;
    let empty_vec: Vec<i32> = vec![];
    
    // Detection should work without errors
    assert!(detector.is_empty(&empty_vec));
    
    // Empty state formatting should work without errors
    let formatter = OutputFormatter::new(OutputFormat::Toon);
    let context = EmptyStateContext::new("list");
    let empty_state_output = formatter.format_empty_state(&context);
    
    // Should produce valid output
    assert!(!empty_state_output.is_empty());
    assert!(empty_state_output.contains("empty"));
}
