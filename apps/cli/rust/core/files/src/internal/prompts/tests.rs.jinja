//! Integration tests for prompt suppression behavior

#[test]
fn test_integration_prompt_suppression_agent_mode() {
    let suppressor = PromptSuppressor::new(Mode::Agent, false, false);
    
    // All prompts should be suppressed in agent mode
    assert_eq!(
        suppressor.should_prompt(PromptType::DestructiveConfirmation),
        PromptDecision::Suppress
    );
    assert_eq!(
        suppressor.should_prompt(PromptType::RequiredValue),
        PromptDecision::Suppress
    );
    assert_eq!(
        suppressor.should_prompt(PromptType::TuiInteraction),
        PromptDecision::Suppress
    );
}

#[test]
fn test_integration_prompt_suppression_human_mode() {
    let suppressor = PromptSuppressor::new(Mode::Human, false, false);
    
    // All prompts should be shown in human mode
    assert_eq!(
        suppressor.should_prompt(PromptType::DestructiveConfirmation),
        PromptDecision::Show
    );
    assert_eq!(
        suppressor.should_prompt(PromptType::RequiredValue),
        PromptDecision::Show
    );
    assert_eq!(
        suppressor.should_prompt(PromptType::TuiInteraction),
        PromptDecision::Show
    );
}

#[test]
fn test_integration_force_flag_bypasses_prompts() {
    let suppressor = PromptSuppressor::new(Mode::Human, true, false);
    
    // Force flag should suppress all prompts
    assert_eq!(
        suppressor.should_prompt(PromptType::DestructiveConfirmation),
        PromptDecision::Suppress
    );
    assert_eq!(
        suppressor.should_prompt(PromptType::RequiredValue),
        PromptDecision::Suppress
    );
}

#[test]
fn test_integration_dry_run_suppresses_destructive_only() {
    let suppressor = PromptSuppressor::new(Mode::Human, false, true);
    
    // Dry run should suppress destructive confirmation
    assert_eq!(
        suppressor.should_prompt(PromptType::DestructiveConfirmation),
        PromptDecision::Suppress
    );
    
    // But not other prompts
    assert_eq!(
        suppressor.should_prompt(PromptType::RequiredValue),
        PromptDecision::Show
    );
}

#[test]
fn test_integration_agent_mode_with_force() {
    let suppressor = PromptSuppressor::new(Mode::Agent, true, false);
    
    // Both agent mode and force should suppress
    assert_eq!(
        suppressor.should_prompt(PromptType::DestructiveConfirmation),
        PromptDecision::Suppress
    );
}

#[test]
fn test_integration_suppression_reason_messages() {
    let agent_suppressor = PromptSuppressor::new(Mode::Agent, false, false);
    let reason = agent_suppressor.suppression_reason(PromptType::DestructiveConfirmation);
    assert!(reason.is_some());
    assert!(reason.unwrap().contains("agent mode"));
    
    let force_suppressor = PromptSuppressor::new(Mode::Human, true, false);
    let reason = force_suppressor.suppression_reason(PromptType::DestructiveConfirmation);
    assert!(reason.is_some());
    assert!(reason.unwrap().contains("--force"));
    
    let human_suppressor = PromptSuppressor::new(Mode::Human, false, false);
    let reason = human_suppressor.suppression_reason(PromptType::DestructiveConfirmation);
    assert!(reason.is_none());
}
