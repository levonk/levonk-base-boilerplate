//! Aggregate computation for CLI output
//! 
//! This module provides pre-computed aggregates (total counts, derived status fields)
//! to reduce the need for follow-up API calls. This optimizes agent interactions by
//! providing commonly-needed data upfront.

pub mod counter;
pub mod derived;
#[cfg(test)]
mod integration_tests;

pub use counter::{CountInfo, CountFormatter, compute_count};
pub use derived::{DerivedStatus, DerivedField, compute_derived_status};

use serde::{Deserialize, Serialize};

/// Aggregate information that can be attached to output
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AggregateInfo {
    /// Total count information
    pub count: Option<CountInfo>,
    /// Derived status information
    pub derived: Option<DerivedStatus>,
}

impl AggregateInfo {
    /// Create empty aggregate info
    pub fn empty() -> Self {
        Self {
            count: None,
            derived: None,
        }
    }

    /// Create aggregate info with count
    pub fn with_count(count: CountInfo) -> Self {
        Self {
            count: Some(count),
            derived: None,
        }
    }

    /// Create aggregate info with derived status
    pub fn with_derived(derived: DerivedStatus) -> Self {
        Self {
            count: None,
            derived: Some(derived),
        }
    }

    /// Create aggregate info with both count and derived status
    pub fn with_both(count: CountInfo, derived: DerivedStatus) -> Self {
        Self {
            count: Some(count),
            derived: Some(derived),
        }
    }

    /// Check if aggregate info is empty
    pub fn is_empty(&self) -> bool {
        self.count.is_none() && self.derived.is_none()
    }
}

impl Default for AggregateInfo {
    fn default() -> Self {
        Self::empty()
    }
}
