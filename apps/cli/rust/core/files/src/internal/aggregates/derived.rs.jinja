//! Derived status field computation
//! 
//! This module provides lightweight derived status field computation for detail views,
//! such as "3/3 passed", "7 comments", etc. These fields provide commonly-needed
//! summaries without requiring additional API calls.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Derived status information
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DerivedStatus {
    /// Derived fields keyed by field name
    pub fields: HashMap<String, DerivedField>,
}

impl DerivedStatus {
    /// Create new derived status
    pub fn new() -> Self {
        Self {
            fields: HashMap::new(),
        }
    }

    /// Add a derived field
    pub fn add_field(&mut self, name: String, field: DerivedField) {
        self.fields.insert(name, field);
    }

    /// Get a derived field by name
    pub fn get_field(&self, name: &str) -> Option<&DerivedField> {
        self.fields.get(name)
    }

    /// Check if derived status is empty
    pub fn is_empty(&self) -> bool {
        self.fields.is_empty()
    }

    /// Get the number of derived fields
    pub fn field_count(&self) -> usize {
        self.fields.len()
    }
}

impl Default for DerivedStatus {
    fn default() -> Self {
        Self::new()
    }
}

/// A derived field value
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type")]
pub enum DerivedField {
    /// Count field (e.g., "7 comments")
    Count {
        label: String,
        value: usize,
    },
    /// Ratio field (e.g., "3/3 passed")
    Ratio {
        label: String,
        numerator: usize,
        denominator: usize,
    },
    /// Status field (e.g., "active", "completed")
    Status {
        label: String,
        value: String,
    },
    /// Duration field (e.g., "5m 30s")
    Duration {
        label: String,
        seconds: u64,
    },
}

impl DerivedField {
    /// Format the derived field as a string
    pub fn format(&self) -> String {
        match self {
            DerivedField::Count { label, value } => {
                format!("{}: {}", label, value)
            }
            DerivedField::Ratio { label, numerator, denominator } => {
                format!("{}: {}/{}", label, numerator, denominator)
            }
            DerivedField::Status { label, value } => {
                format!("{}: {}", label, value)
            }
            DerivedField::Duration { label, seconds } => {
                let duration = format_duration(*seconds);
                format!("{}: {}", label, duration)
            }
        }
    }

    /// Create a count field
    pub fn count(label: impl Into<String>, value: usize) -> Self {
        DerivedField::Count {
            label: label.into(),
            value,
        }
    }

    /// Create a ratio field
    pub fn ratio(label: impl Into<String>, numerator: usize, denominator: usize) -> Self {
        DerivedField::Ratio {
            label: label.into(),
            numerator,
            denominator,
        }
    }

    /// Create a status field
    pub fn status(label: impl Into<String>, value: impl Into<String>) -> Self {
        DerivedField::Status {
            label: label.into(),
            value: value.into(),
        }
    }

    /// Create a duration field
    pub fn duration(label: impl Into<String>, seconds: u64) -> Self {
        DerivedField::Duration {
            label: label.into(),
            seconds,
        }
    }
}

/// Format seconds as human-readable duration
fn format_duration(seconds: u64) -> String {
    if seconds < 60 {
        format!("{}s", seconds)
    } else if seconds < 3600 {
        let minutes = seconds / 60;
        let secs = seconds % 60;
        if secs == 0 {
            format!("{}m", minutes)
        } else {
            format!("{}m {}s", minutes, secs)
        }
    } else {
        let hours = seconds / 3600;
        let minutes = (seconds % 3600) / 60;
        let secs = seconds % 60;
        if minutes == 0 && secs == 0 {
            format!("{}h", hours)
        } else if secs == 0 {
            format!("{}h {}m", hours, minutes)
        } else {
            format!("{}h {}m {}s", hours, minutes, secs)
        }
    }
}

/// Compute derived status from a data structure
pub fn compute_derived_status<T>(data: &T) -> DerivedStatus
where
    T: Derivable,
{
    data.derive_status()
}

/// Trait for types that can derive status information
pub trait Derivable {
    /// Compute derived status from this type
    fn derive_status(&self) -> DerivedStatus;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_derived_status_creation() {
        let status = DerivedStatus::new();
        assert!(status.is_empty());
        assert_eq!(status.field_count(), 0);
    }

    #[test]
    fn test_derived_status_add_field() {
        let mut status = DerivedStatus::new();
        status.add_field("comments".to_string(), DerivedField::count("Comments", 7));
        assert!(!status.is_empty());
        assert_eq!(status.field_count(), 1);
    }

    #[test]
    fn test_derived_status_get_field() {
        let mut status = DerivedStatus::new();
        let field = DerivedField::count("Comments", 7);
        status.add_field("comments".to_string(), field.clone());
        
        let retrieved = status.get_field("comments");
        assert!(retrieved.is_some());
    }

    #[test]
    fn test_derived_field_format_count() {
        let field = DerivedField::count("Comments", 7);
        let formatted = field.format();
        assert_eq!(formatted, "Comments: 7");
    }

    #[test]
    fn test_derived_field_format_ratio() {
        let field = DerivedField::ratio("Tests", 3, 3);
        let formatted = field.format();
        assert_eq!(formatted, "Tests: 3/3");
    }

    #[test]
    fn test_derived_field_format_status() {
        let field = DerivedField::status("State", "active");
        let formatted = field.format();
        assert_eq!(formatted, "State: active");
    }

    #[test]
    fn test_derived_field_format_duration() {
        let field = DerivedField::duration("Runtime", 330);
        let formatted = field.format();
        assert_eq!(formatted, "Runtime: 5m 30s");
    }

    #[test]
    fn test_format_duration_seconds() {
        assert_eq!(format_duration(30), "30s");
        assert_eq!(format_duration(59), "59s");
    }

    #[test]
    fn test_format_duration_minutes() {
        assert_eq!(format_duration(60), "1m");
        assert_eq!(format_duration(90), "1m 30s");
        assert_eq!(format_duration(3599), "59m 59s");
    }

    #[test]
    fn test_format_duration_hours() {
        assert_eq!(format_duration(3600), "1h");
        assert_eq!(format_duration(3661), "1h 1m");
        assert_eq!(format_duration(3665), "1h 1m 5s");
        assert_eq!(format_duration(7200), "2h");
    }

    #[test]
    fn test_derived_field_constructors() {
        let count = DerivedField::count("Comments", 7);
        let ratio = DerivedField::ratio("Tests", 3, 3);
        let status = DerivedField::status("State", "active");
        let duration = DerivedField::duration("Runtime", 330);

        assert!(matches!(count, DerivedField::Count { .. }));
        assert!(matches!(ratio, DerivedField::Ratio { .. }));
        assert!(matches!(status, DerivedField::Status { .. }));
        assert!(matches!(duration, DerivedField::Duration { .. }));
    }

    #[test]
    fn test_derived_status_default() {
        let status = DerivedStatus::default();
        assert!(status.is_empty());
    }
}
