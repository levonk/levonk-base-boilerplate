//! Idempotent operation handler
//!
//! Provides state checking and idempotent behavior for state-changing operations.

use std::fmt;
use anyhow::Result;

/// Result of an idempotent operation check
#[derive(Debug, Clone, PartialEq)]
pub enum IdempotentResult {
    /// Operation should proceed (state change needed)
    Proceed,
    /// Operation is a no-op (desired state already exists)
    NoOp(String),
    /// Operation cannot proceed (state conflict)
    Conflict(String),
}

impl fmt::Display for IdempotentResult {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            IdempotentResult::Proceed => write!(f, "Proceed with operation"),
            IdempotentResult::NoOp(msg) => write!(f, "No-op: {}", msg),
            IdempotentResult::Conflict(msg) => write!(f, "Conflict: {}", msg),
        }
    }
}

/// Types of operations that can be made idempotent
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum OperationType {
    Create,
    Update,
    Delete,
    Close,
    Start,
    Stop,
    Install,
    Uninstall,
}

impl fmt::Display for OperationType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            OperationType::Create => write!(f, "create"),
            OperationType::Update => write!(f, "update"),
            OperationType::Delete => write!(f, "delete"),
            OperationType::Close => write!(f, "close"),
            OperationType::Start => write!(f, "start"),
            OperationType::Stop => write!(f, "stop"),
            OperationType::Install => write!(f, "install"),
            OperationType::Uninstall => write!(f, "uninstall"),
        }
    }
}

/// Context for idempotent operation checking
pub struct IdempotentOperation {
    pub operation_type: OperationType,
    pub target: String,
    pub current_state: Option<String>,
    pub desired_state: String,
}

impl IdempotentOperation {
    /// Create a new idempotent operation context
    pub fn new(
        operation_type: OperationType,
        target: impl Into<String>,
        current_state: Option<impl Into<String>>,
        desired_state: impl Into<String>,
    ) -> Self {
        Self {
            operation_type,
            target: target.into(),
            current_state: current_state.map(|s| s.into()),
            desired_state: desired_state.into(),
        }
    }

    /// Check if the operation should proceed, is a no-op, or has a conflict
    pub fn check(&self) -> IdempotentResult {
        match self.operation_type {
            OperationType::Create => self.check_create(),
            OperationType::Update => self.check_update(),
            OperationType::Delete => self.check_delete(),
            OperationType::Close => self.check_close(),
            OperationType::Start => self.check_start(),
            OperationType::Stop => self.check_stop(),
            OperationType::Install => self.check_install(),
            OperationType::Uninstall => self.check_uninstall(),
        }
    }

    /// Check create operation idempotency
    fn check_create(&self) -> IdempotentResult {
        if let Some(current) = &self.current_state {
            if current == &self.desired_state {
                IdempotentResult::NoOp(format!(
                    "{} already exists with desired state: {}",
                    self.target, current
                ))
            } else {
                IdempotentResult::Conflict(format!(
                    "{} already exists with different state: {} (desired: {})",
                    self.target, current, self.desired_state
                ))
            }
        } else {
            IdempotentResult::Proceed
        }
    }

    /// Check update operation idempotency
    fn check_update(&self) -> IdempotentResult {
        if let Some(current) = &self.current_state {
            if current == &self.desired_state {
                IdempotentResult::NoOp(format!(
                    "{} already in desired state: {}",
                    self.target, current
                ))
            } else {
                IdempotentResult::Proceed
            }
        } else {
            IdempotentResult::Conflict(format!(
                "{} does not exist (cannot update)",
                self.target
            ))
        }
    }

    /// Check delete operation idempotency
    fn check_delete(&self) -> IdempotentResult {
        if self.current_state.is_none() {
            IdempotentResult::NoOp(format!(
                "{} already deleted (does not exist)",
                self.target
            ))
        } else {
            IdempotentResult::Proceed
        }
    }

    /// Check close operation idempotency
    fn check_close(&self) -> IdempotentResult {
        if let Some(current) = &self.current_state {
            if current == "closed" || current == "stopped" {
                IdempotentResult::NoOp(format!(
                    "{} already closed",
                    self.target
                ))
            } else {
                IdempotentResult::Proceed
            }
        } else {
            IdempotentResult::Conflict(format!(
                "{} does not exist (cannot close)",
                self.target
            ))
        }
    }

    /// Check start operation idempotency
    fn check_start(&self) -> IdempotentResult {
        if let Some(current) = &self.current_state {
            if current == "running" || current == "started" {
                IdempotentResult::NoOp(format!(
                    "{} already running",
                    self.target
                ))
            } else {
                IdempotentResult::Proceed
            }
        } else {
            IdempotentResult::Proceed
        }
    }

    /// Check stop operation idempotency
    fn check_stop(&self) -> IdempotentResult {
        if let Some(current) = &self.current_state {
            if current == "stopped" || current == "closed" {
                IdempotentResult::NoOp(format!(
                    "{} already stopped",
                    self.target
                ))
            } else {
                IdempotentResult::Proceed
            }
        } else {
            IdempotentResult::NoOp(format!(
                "{} does not exist (already stopped)",
                self.target
            ))
        }
    }

    /// Check install operation idempotency
    fn check_install(&self) -> IdempotentResult {
        if let Some(current) = &self.current_state {
            if current == "installed" {
                IdempotentResult::NoOp(format!(
                    "{} already installed",
                    self.target
                ))
            } else {
                IdempotentResult::Conflict(format!(
                    "{} exists in unexpected state: {}",
                    self.target, current
                ))
            }
        } else {
            IdempotentResult::Proceed
        }
    }

    /// Check uninstall operation idempotency
    fn check_uninstall(&self) -> IdempotentResult {
        if self.current_state.is_none() {
            IdempotentResult::NoOp(format!(
                "{} already uninstalled (does not exist)",
                self.target
            ))
        } else if let Some(current) = &self.current_state {
            if current == "not_installed" || current == "uninstalled" {
                IdempotentResult::NoOp(format!(
                    "{} already uninstalled",
                    self.target
                ))
            } else {
                IdempotentResult::Proceed
            }
        } else {
            IdempotentResult::Proceed
        }
    }
}

/// Check idempotency for an operation
///
/// This is a convenience function that creates an IdempotentOperation and checks it.
pub fn check_idempotency(
    operation_type: OperationType,
    target: impl Into<String>,
    current_state: Option<impl Into<String>>,
    desired_state: impl Into<String>,
) -> IdempotentResult {
    let op = IdempotentOperation::new(operation_type, target, current_state, desired_state);
    op.check()
}

/// Acknowledge a no-op operation with a descriptive message
///
/// This function should be called when an idempotent operation is a no-op.
/// It returns a Result that can be used to exit with code 0.
pub fn acknowledge_noop(message: impl Into<String>) -> Result<()> {
    let msg = message.into();
    println!("{}", msg);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_create_proceeds_when_not_exists() {
        let result = check_idempotency(
            OperationType::Create,
            "test-resource",
            None::<String>,
            "active",
        );
        assert_eq!(result, IdempotentResult::Proceed);
    }

    #[test]
    fn test_create_noop_when_exists_with_desired_state() {
        let result = check_idempotency(
            OperationType::Create,
            "test-resource",
            Some("active"),
            "active",
        );
        assert!(matches!(result, IdempotentResult::NoOp(_)));
    }

    #[test]
    fn test_create_conflict_when_exists_with_different_state() {
        let result = check_idempotency(
            OperationType::Create,
            "test-resource",
            Some("inactive"),
            "active",
        );
        assert!(matches!(result, IdempotentResult::Conflict(_)));
    }

    #[test]
    fn test_update_proceeds_when_state_differs() {
        let result = check_idempotency(
            OperationType::Update,
            "test-resource",
            Some("inactive"),
            "active",
        );
        assert_eq!(result, IdempotentResult::Proceed);
    }

    #[test]
    fn test_update_noop_when_state_matches() {
        let result = check_idempotency(
            OperationType::Update,
            "test-resource",
            Some("active"),
            "active",
        );
        assert!(matches!(result, IdempotentResult::NoOp(_)));
    }

    #[test]
    fn test_update_conflict_when_not_exists() {
        let result = check_idempotency(
            OperationType::Update,
            "test-resource",
            None::<String>,
            "active",
        );
        assert!(matches!(result, IdempotentResult::Conflict(_)));
    }

    #[test]
    fn test_delete_proceeds_when_exists() {
        let result = check_idempotency(
            OperationType::Delete,
            "test-resource",
            Some("active"),
            "deleted",
        );
        assert_eq!(result, IdempotentResult::Proceed);
    }

    #[test]
    fn test_delete_noop_when_not_exists() {
        let result = check_idempotency(
            OperationType::Delete,
            "test-resource",
            None::<String>,
            "deleted",
        );
        assert!(matches!(result, IdempotentResult::NoOp(_)));
    }

    #[test]
    fn test_close_proceeds_when_open() {
        let result = check_idempotency(
            OperationType::Close,
            "test-resource",
            Some("open"),
            "closed",
        );
        assert_eq!(result, IdempotentResult::Proceed);
    }

    #[test]
    fn test_close_noop_when_already_closed() {
        let result = check_idempotency(
            OperationType::Close,
            "test-resource",
            Some("closed"),
            "closed",
        );
        assert!(matches!(result, IdempotentResult::NoOp(_)));
    }

    #[test]
    fn test_close_noop_when_stopped() {
        let result = check_idempotency(
            OperationType::Close,
            "test-resource",
            Some("stopped"),
            "closed",
        );
        assert!(matches!(result, IdempotentResult::NoOp(_)));
    }

    #[test]
    fn test_start_proceeds_when_not_running() {
        let result = check_idempotency(
            OperationType::Start,
            "test-resource",
            Some("stopped"),
            "running",
        );
        assert_eq!(result, IdempotentResult::Proceed);
    }

    #[test]
    fn test_start_noop_when_already_running() {
        let result = check_idempotency(
            OperationType::Start,
            "test-resource",
            Some("running"),
            "running",
        );
        assert!(matches!(result, IdempotentResult::NoOp(_)));
    }

    #[test]
    fn test_stop_proceeds_when_running() {
        let result = check_idempotency(
            OperationType::Stop,
            "test-resource",
            Some("running"),
            "stopped",
        );
        assert_eq!(result, IdempotentResult::Proceed);
    }

    #[test]
    fn test_stop_noop_when_already_stopped() {
        let result = check_idempotency(
            OperationType::Stop,
            "test-resource",
            Some("stopped"),
            "stopped",
        );
        assert!(matches!(result, IdempotentResult::NoOp(_)));
    }

    #[test]
    fn test_stop_noop_when_not_exists() {
        let result = check_idempotency(
            OperationType::Stop,
            "test-resource",
            None::<String>,
            "stopped",
        );
        assert!(matches!(result, IdempotentResult::NoOp(_)));
    }

    #[test]
    fn test_install_proceeds_when_not_installed() {
        let result = check_idempotency(
            OperationType::Install,
            "test-resource",
            None::<String>,
            "installed",
        );
        assert_eq!(result, IdempotentResult::Proceed);
    }

    #[test]
    fn test_install_noop_when_already_installed() {
        let result = check_idempotency(
            OperationType::Install,
            "test-resource",
            Some("installed"),
            "installed",
        );
        assert!(matches!(result, IdempotentResult::NoOp(_)));
    }

    #[test]
    fn test_install_conflict_when_in_unexpected_state() {
        let result = check_idempotency(
            OperationType::Install,
            "test-resource",
            Some("corrupted"),
            "installed",
        );
        assert!(matches!(result, IdempotentResult::Conflict(_)));
    }

    #[test]
    fn test_uninstall_proceeds_when_installed() {
        let result = check_idempotency(
            OperationType::Uninstall,
            "test-resource",
            Some("installed"),
            "uninstalled",
        );
        assert_eq!(result, IdempotentResult::Proceed);
    }

    #[test]
    fn test_uninstall_noop_when_not_installed() {
        let result = check_idempotency(
            OperationType::Uninstall,
            "test-resource",
            None::<String>,
            "uninstalled",
        );
        assert!(matches!(result, IdempotentResult::NoOp(_)));
    }

    #[test]
    fn test_uninstall_noop_when_already_uninstalled() {
        let result = check_idempotency(
            OperationType::Uninstall,
            "test-resource",
            Some("uninstalled"),
            "uninstalled",
        );
        assert!(matches!(result, IdempotentResult::NoOp(_)));
    }

    #[test]
    fn test_acknowledge_noop() {
        let result = acknowledge_noop("Resource already exists");
        assert!(result.is_ok());
    }

    #[test]
    fn test_operation_type_display() {
        assert_eq!(format!("{}", OperationType::Create), "create");
        assert_eq!(format!("{}", OperationType::Update), "update");
        assert_eq!(format!("{}", OperationType::Delete), "delete");
        assert_eq!(format!("{}", OperationType::Close), "close");
        assert_eq!(format!("{}", OperationType::Start), "start");
        assert_eq!(format!("{}", OperationType::Stop), "stop");
        assert_eq!(format!("{}", OperationType::Install), "install");
        assert_eq!(format!("{}", OperationType::Uninstall), "uninstall");
    }

    #[test]
    fn test_idempotent_result_display() {
        let noop = IdempotentResult::NoOp("test message".to_string());
        assert!(format!("{}", noop).contains("No-op"));
        
        let conflict = IdempotentResult::Conflict("test conflict".to_string());
        assert!(format!("{}", conflict).contains("Conflict"));
        
        let proceed = IdempotentResult::Proceed;
        assert!(format!("{}", proceed).contains("Proceed"));
    }
}
