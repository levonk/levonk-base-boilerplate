//! Empty state detection logic
//! 
//! This module provides utilities for detecting when command results are empty
//! and building context for empty state messages.

use std::collections::HashMap;

/// Context information for empty state detection
#[derive(Debug, Clone, Default)]
pub struct EmptyStateContext {
    /// The command that was executed
    pub command: String,
    /// Filter criteria applied (if any)
    pub filters: HashMap<String, String>,
    /// Scope of the query (e.g., "all", "active", "pending")
    pub scope: Option<String>,
    /// Additional context information
    pub extra: HashMap<String, String>,
}

impl EmptyStateContext {
    /// Create a new empty state context
    pub fn new(command: impl Into<String>) -> Self {
        Self {
            command: command.into(),
            ..Default::default()
        }
    }

    /// Add a filter to the context
    pub fn with_filter(mut self, key: impl Into<String>, value: impl Into<String>) -> Self {
        self.filters.insert(key.into(), value.into());
        self
    }

    /// Set the scope of the query
    pub fn with_scope(mut self, scope: impl Into<String>) -> Self {
        self.scope = Some(scope.into());
        self
    }

    /// Add extra context information
    pub fn with_extra(mut self, key: impl Into<String>, value: impl Into<String>) -> Self {
        self.extra.insert(key.into(), value.into());
        self
    }
}

/// Empty state detector
#[derive(Debug, Clone)]
pub struct EmptyStateDetector;

impl EmptyStateDetector {
    /// Detect if a result is empty
    pub fn is_empty<T>(&self, result: &T) -> bool
    where
        T: EmptyCheck,
    {
        result.is_empty()
    }

    /// Detect if a result is empty with context
    pub fn is_empty_with_context<T>(
        &self,
        result: &T,
        _context: &EmptyStateContext,
    ) -> bool
    where
        T: EmptyCheck,
    {
        result.is_empty()
    }
}

/// Trait for types that can be checked for emptiness
pub trait EmptyCheck {
    /// Check if the value is empty
    fn is_empty(&self) -> bool;
}

// Implement EmptyCheck for common types
impl<T> EmptyCheck for Vec<T> {
    fn is_empty(&self) -> bool {
        Vec::is_empty(self)
    }
}

impl<T> EmptyCheck for Option<T> {
    fn is_empty(&self) -> bool {
        self.is_none()
    }
}

impl EmptyCheck for String {
    fn is_empty(&self) -> bool {
        String::is_empty(self)
    }
}

impl EmptyCheck for &str {
    fn is_empty(&self) -> bool {
        str::is_empty(self)
    }
}

impl<K, V> EmptyCheck for HashMap<K, V> {
    fn is_empty(&self) -> bool {
        HashMap::is_empty(self)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_empty_state_context_creation() {
        let context = EmptyStateContext::new("list")
            .with_filter("status", "active")
            .with_scope("all")
            .with_extra("user", "test");

        assert_eq!(context.command, "list");
        assert_eq!(context.filters.get("status"), Some(&"active".to_string()));
        assert_eq!(context.scope, Some("all".to_string()));
        assert_eq!(context.extra.get("user"), Some(&"test".to_string()));
    }

    #[test]
    fn test_empty_state_context_default() {
        let context = EmptyStateContext::default();
        assert!(context.command.is_empty());
        assert!(context.filters.is_empty());
        assert!(context.scope.is_none());
        assert!(context.extra.is_empty());
    }

    #[test]
    fn test_detector_empty_vec() {
        let detector = EmptyStateDetector;
        let empty_vec: Vec<i32> = vec![];
        let non_empty_vec = vec![1, 2, 3];

        assert!(detector.is_empty(&empty_vec));
        assert!(!detector.is_empty(&non_empty_vec));
    }

    #[test]
    fn test_detector_empty_option() {
        let detector = EmptyStateDetector;
        let empty_option: Option<i32> = None;
        let non_empty_option = Some(42);

        assert!(detector.is_empty(&empty_option));
        assert!(!detector.is_empty(&non_empty_option));
    }

    #[test]
    fn test_detector_empty_string() {
        let detector = EmptyStateDetector;
        let empty_string = "";
        let non_empty_string = "test";

        assert!(detector.is_empty(&empty_string));
        assert!(!detector.is_empty(&non_empty_string));
    }

    #[test]
    fn test_detector_empty_hashmap() {
        let detector = EmptyStateDetector;
        let empty_map: HashMap<String, i32> = HashMap::new();
        let mut non_empty_map = HashMap::new();
        non_empty_map.insert("key".to_string(), 42);

        assert!(detector.is_empty(&empty_map));
        assert!(!detector.is_empty(&non_empty_map));
    }

    #[test]
    fn test_detector_with_context() {
        let detector = EmptyStateDetector;
        let context = EmptyStateContext::new("list").with_filter("status", "active");
        let empty_vec: Vec<i32> = vec![];

        assert!(detector.is_empty_with_context(&empty_vec, &context));
    }
}
