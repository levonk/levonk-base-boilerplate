/// Unit tests for suggestion rules

use crate::internal::suggestions::rules::{
    EmptyListRule, ListViewRule, CreateSuccessRule, UpdateSuccessRule,
    DeleteSuccessRule, ErrorRule, SuggestionContext, SuggestionRule, get_rules_for_command
};
use crate::internal::context::ExecutionContext;
use crate::internal::mode::detection::Mode;

#[test]
fn test_empty_list_rule_matches() {
    let rule = EmptyListRule::new("test");
    let ctx = SuggestionContext::new("list").with_empty(true).with_item_count(0);

    assert!(rule.matches(&ctx));
}

#[test]
fn test_empty_list_rule_no_match_non_empty() {
    let rule = EmptyListRule::new("test");
    let ctx = SuggestionContext::new("list").with_empty(false).with_item_count(5);

    assert!(!rule.matches(&ctx));
}

#[test]
fn test_empty_list_rule_no_match_count_nonzero() {
    let rule = EmptyListRule::new("test");
    let ctx = SuggestionContext::new("list").with_empty(true).with_item_count(1);

    assert!(!rule.matches(&ctx));
}

#[test]
fn test_empty_list_rule_generate() {
    let rule = EmptyListRule::new("myapp");
    let ctx = SuggestionContext::new("list").with_empty(true).with_item_count(0);
    let exec_ctx = ExecutionContext::new(Mode::Agent);

    let suggestions = rule.generate(&ctx, &exec_ctx);

    assert_eq!(suggestions.len(), 1);
    assert_eq!(suggestions[0].command, "myapp create --title \"...\"");
    assert_eq!(suggestions[0].score, 0.9);
}

#[test]
fn test_list_view_rule_matches() {
    let rule = ListViewRule::new("test");
    let ctx = SuggestionContext::new("list").with_empty(false).with_item_count(5);

    assert!(rule.matches(&ctx));
}

#[test]
fn test_list_view_rule_no_match_empty() {
    let rule = ListViewRule::new("test");
    let ctx = SuggestionContext::new("list").with_empty(true).with_item_count(0);

    assert!(!rule.matches(&ctx));
}

#[test]
fn test_list_view_rule_generate_without_open_items() {
    let rule = ListViewRule::new("myapp");
    let ctx = SuggestionContext::new("list")
        .with_empty(false)
        .with_item_count(5)
        .with_open_items(false);
    let exec_ctx = ExecutionContext::new(Mode::Agent);

    let suggestions = rule.generate(&ctx, &exec_ctx);

    assert_eq!(suggestions.len(), 2);
    assert_eq!(suggestions[0].command, "myapp view 1");
    assert_eq!(suggestions[1].command, "myapp create --title \"...\"");
}

#[test]
fn test_list_view_rule_generate_with_open_items() {
    let rule = ListViewRule::new("myapp");
    let ctx = SuggestionContext::new("list")
        .with_empty(false)
        .with_item_count(5)
        .with_open_items(true);
    let exec_ctx = ExecutionContext::new(Mode::Agent);

    let suggestions = rule.generate(&ctx, &exec_ctx);

    assert_eq!(suggestions.len(), 3);
    assert_eq!(suggestions[0].command, "myapp view 1");
    assert_eq!(suggestions[1].command, "myapp create --title \"...\"");
    assert_eq!(suggestions[2].command, "myapp close 1");
}

#[test]
fn test_create_success_rule_matches() {
    let rule = CreateSuccessRule::new("test");
    let ctx = SuggestionContext::new("create")
        .with_success(true)
        .with_last_item_id("42");

    assert!(rule.matches(&ctx));
}

#[test]
fn test_create_success_rule_no_match_failure() {
    let rule = CreateSuccessRule::new("test");
    let ctx = SuggestionContext::new("create")
        .with_success(false)
        .with_last_item_id("42");

    assert!(!rule.matches(&ctx));
}

#[test]
fn test_create_success_rule_no_match_wrong_command() {
    let rule = CreateSuccessRule::new("test");
    let ctx = SuggestionContext::new("update")
        .with_success(true)
        .with_last_item_id("42");

    assert!(!rule.matches(&ctx));
}

#[test]
fn test_create_success_rule_no_match_no_id() {
    let rule = CreateSuccessRule::new("test");
    let ctx = SuggestionContext::new("create")
        .with_success(true);

    assert!(!rule.matches(&ctx));
}

#[test]
fn test_create_success_rule_generate() {
    let rule = CreateSuccessRule::new("myapp");
    let ctx = SuggestionContext::new("create")
        .with_success(true)
        .with_last_item_id("42");
    let exec_ctx = ExecutionContext::new(Mode::Agent);

    let suggestions = rule.generate(&ctx, &exec_ctx);

    assert_eq!(suggestions.len(), 1);
    assert_eq!(suggestions[0].command, "myapp view 42");
    assert_eq!(suggestions[0].score, 0.95);
}

#[test]
fn test_update_success_rule_matches() {
    let rule = UpdateSuccessRule::new("test");
    let ctx = SuggestionContext::new("update")
        .with_success(true)
        .with_last_item_id("42");

    assert!(rule.matches(&ctx));
}

#[test]
fn test_update_success_rule_generate() {
    let rule = UpdateSuccessRule::new("myapp");
    let ctx = SuggestionContext::new("update")
        .with_success(true)
        .with_last_item_id("42");
    let exec_ctx = ExecutionContext::new(Mode::Agent);

    let suggestions = rule.generate(&ctx, &exec_ctx);

    assert_eq!(suggestions.len(), 1);
    assert_eq!(suggestions[0].command, "myapp view 42");
}

#[test]
fn test_delete_success_rule_matches() {
    let rule = DeleteSuccessRule::new("test");
    let ctx = SuggestionContext::new("delete").with_success(true);

    assert!(rule.matches(&ctx));
}

#[test]
fn test_delete_success_rule_generate() {
    let rule = DeleteSuccessRule::new("myapp");
    let ctx = SuggestionContext::new("delete").with_success(true);
    let exec_ctx = ExecutionContext::new(Mode::Agent);

    let suggestions = rule.generate(&ctx, &exec_ctx);

    assert_eq!(suggestions.len(), 1);
    assert_eq!(suggestions[0].command, "myapp list");
    assert_eq!(suggestions[0].score, 0.9);
}

#[test]
fn test_error_rule_matches() {
    let rule = ErrorRule::new("test");
    let ctx = SuggestionContext::new("create").with_success(false);

    assert!(rule.matches(&ctx));
}

#[test]
fn test_error_rule_no_match_success() {
    let rule = ErrorRule::new("test");
    let ctx = SuggestionContext::new("create").with_success(true);

    assert!(!rule.matches(&ctx));
}

#[test]
fn test_error_rule_generate_create() {
    let rule = ErrorRule::new("myapp");
    let ctx = SuggestionContext::new("create")
        .with_success(false)
        .with_carry_flags(vec!["--title".to_string(), "test".to_string()]);
    let exec_ctx = ExecutionContext::new(Mode::Agent);

    let suggestions = rule.generate(&ctx, &exec_ctx);

    assert!(!suggestions.is_empty());
    assert!(suggestions.iter().any(|s| s.command.contains("--force")));
}

#[test]
fn test_error_rule_generate_update() {
    let rule = ErrorRule::new("myapp");
    let ctx = SuggestionContext::new("update")
        .with_success(false)
        .with_last_item_id("42");
    let exec_ctx = ExecutionContext::new(Mode::Agent);

    let suggestions = rule.generate(&ctx, &exec_ctx);

    assert!(!suggestions.is_empty());
    assert!(suggestions.iter().any(|s| s.command.contains("view 42")));
}

#[test]
fn test_error_rule_generate_delete() {
    let rule = ErrorRule::new("myapp");
    let ctx = SuggestionContext::new("delete").with_success(false);
    let exec_ctx = ExecutionContext::new(Mode::Agent);

    let suggestions = rule.generate(&ctx, &exec_ctx);

    // Delete errors don't generate specific suggestions
    assert!(suggestions.is_empty());
}

#[test]
fn test_get_rules_for_command_list() {
    let rules = get_rules_for_command("list");

    // Should have universal rules
    assert!(rules.len() >= 3);
}

#[test]
fn test_get_rules_for_command_create() {
    let rules = get_rules_for_command("create");

    // Should have universal rules + create-specific rule
    assert!(rules.len() >= 4);
}

#[test]
fn test_get_rules_for_command_update() {
    let rules = get_rules_for_command("update");

    // Should have universal rules + update-specific rule
    assert!(rules.len() >= 4);
}

#[test]
fn test_get_rules_for_command_delete() {
    let rules = get_rules_for_command("delete");

    // Should have universal rules + delete-specific rule
    assert!(rules.len() >= 4);
}

#[test]
fn test_get_rules_for_command_unknown() {
    let rules = get_rules_for_command("unknown");

    // Should have universal rules only
    assert!(rules.len() >= 3);
}

#[test]
fn test_suggestion_context_builder_chain() {
    let ctx = SuggestionContext::new("test")
        .with_empty(true)
        .with_item_count(0)
        .with_success(true)
        .with_open_items(false)
        .with_last_item_id("42")
        .with_carry_flags(vec!["--flag".to_string()]);

    assert_eq!(ctx.command, "test");
    assert!(ctx.is_empty);
    assert_eq!(ctx.item_count, 0);
    assert!(ctx.success);
    assert!(!ctx.has_open_items);
    assert_eq!(ctx.last_item_id, Some("42".to_string()));
    assert_eq!(ctx.carry_flags, vec!["--flag".to_string()]);
}
