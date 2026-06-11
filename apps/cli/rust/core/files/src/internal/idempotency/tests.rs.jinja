//! Integration tests for idempotent operations

#[test]
fn test_idempotent_create_with_output_formatter() {
    let mode = Mode::Agent;
    let format = OutputFormatter::auto_detect(mode, false, false, None).unwrap();
    
    let result = check_idempotency(
        OperationType::Create,
        "test-resource",
        Some("active"),
        "active",
    );
    
    if let IdempotentResult::NoOp(msg) = result {
        let formatted = format.format_value(&serde_json::json!({
            "idempotent": true,
            "operation": "create",
            "target": "test-resource",
            "message": msg
        })).unwrap();
        assert!(formatted.contains("No-op"));
    } else {
        panic!("Expected NoOp result");
    }
}

#[test]
fn test_idempotent_delete_with_output_formatter() {
    let mode = Mode::Agent;
    let format = OutputFormatter::auto_detect(mode, false, false, None).unwrap();
    
    let result = check_idempotency(
        OperationType::Delete,
        "test-resource",
        None::<String>,
        "deleted",
    );
    
    if let IdempotentResult::NoOp(msg) = result {
        let formatted = format.format_value(&serde_json::json!({
            "idempotent": true,
            "operation": "delete",
            "target": "test-resource",
            "message": msg
        })).unwrap();
        assert!(formatted.contains("already deleted"));
    } else {
        panic!("Expected NoOp result");
    }
}

#[test]
fn test_idempotent_close_with_output_formatter() {
    let mode = Mode::Human;
    let format = OutputFormatter::auto_detect(mode, false, false, None).unwrap();
    
    let result = check_idempotency(
        OperationType::Close,
        "test-resource",
        Some("closed"),
        "closed",
    );
    
    if let IdempotentResult::NoOp(msg) = result {
        let formatted = format.format_value(&serde_json::json!({
            "idempotent": true,
            "operation": "close",
            "target": "test-resource",
            "message": msg
        })).unwrap();
        assert!(formatted.contains("already closed"));
    } else {
        panic!("Expected NoOp result");
    }
}

#[test]
fn test_idempotent_conflict_with_output_formatter() {
    let mode = Mode::Agent;
    let format = OutputFormatter::auto_detect(mode, false, false, None).unwrap();
    
    let result = check_idempotency(
        OperationType::Create,
        "test-resource",
        Some("inactive"),
        "active",
    );
    
    if let IdempotentResult::Conflict(msg) = result {
        let formatted = format.format_value(&serde_json::json!({
            "idempotent": false,
            "operation": "create",
            "target": "test-resource",
            "conflict": msg
        })).unwrap();
        assert!(formatted.contains("Conflict"));
    } else {
        panic!("Expected Conflict result");
    }
}

#[test]
fn test_acknowledge_noop_exit_code() {
    let result = acknowledge_noop("Resource already exists in desired state");
    assert!(result.is_ok());
    // This would exit with code 0 in actual usage
}

#[test]
fn test_all_operation_types() {
    let operations = vec![
        (OperationType::Create, "create"),
        (OperationType::Update, "update"),
        (OperationType::Delete, "delete"),
        (OperationType::Close, "close"),
        (OperationType::Start, "start"),
        (OperationType::Stop, "stop"),
        (OperationType::Install, "install"),
        (OperationType::Uninstall, "uninstall"),
    ];
    
    for (op_type, name) in operations {
        assert_eq!(format!("{}", op_type), name);
    }
}

#[test]
fn test_idempotent_operation_builder() {
    let op = IdempotentOperation::new(
        OperationType::Create,
        "test-resource",
        Some("current-state"),
        "desired-state",
    );
    
    assert_eq!(op.operation_type, OperationType::Create);
    assert_eq!(op.target, "test-resource");
    assert_eq!(op.current_state, Some("current-state".to_string()));
    assert_eq!(op.desired_state, "desired-state");
}

#[test]
fn test_idempotent_operation_with_none_current_state() {
    let op = IdempotentOperation::new(
        OperationType::Create,
        "test-resource",
        None::<String>,
        "desired-state",
    );
    
    assert_eq!(op.current_state, None);
}

#[test]
fn test_idempotent_result_variants() {
    let proceed = IdempotentResult::Proceed;
    let noop = IdempotentResult::NoOp("test".to_string());
    let conflict = IdempotentResult::Conflict("test".to_string());
    
    assert_eq!(proceed, IdempotentResult::Proceed);
    assert_ne!(proceed, noop);
    assert_ne!(noop, conflict);
}
