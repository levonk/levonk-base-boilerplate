//! Count computation and formatting
//! 
//! This module provides efficient count computation for list queries and
//! formatted count output matching the specification "count: 30 of 847 total".

use serde::{Deserialize, Serialize};

/// Count information for list output
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CountInfo {
    /// Current count (number of items in current page/selection)
    pub current: usize,
    /// Total count (total number of items available)
    pub total: usize,
}

impl CountInfo {
    /// Create new count information
    pub fn new(current: usize, total: usize) -> Self {
        Self { current, total }
    }

    /// Check if this is a complete count (current == total)
    pub fn is_complete(&self) -> bool {
        self.current == self.total
    }

    /// Get the percentage of total items shown
    pub fn percentage(&self) -> f64 {
        if self.total == 0 {
            0.0
        } else {
            (self.current as f64 / self.total as f64) * 100.0
        }
    }
}

/// Count formatter for output
pub struct CountFormatter;

impl CountFormatter {
    /// Format count as "count: 30 of 847 total"
    pub fn format(count: &CountInfo) -> String {
        format!("count: {} of {} total", count.current, count.total)
    }

    /// Format count with percentage
    pub fn format_with_percentage(count: &CountInfo) -> String {
        let percentage = count.percentage();
        format!("count: {} of {} total ({:.1}%)", count.current, count.total, percentage)
    }

    /// Format count compactly as "30/847"
    pub fn format_compact(count: &CountInfo) -> String {
        format!("{}/{}", count.current, count.total)
    }
}

/// Compute count from a collection
pub fn compute_count<T>(items: &[T], total: usize) -> CountInfo {
    CountInfo::new(items.len(), total)
}

/// Compute count from an iterator with known total
pub fn compute_count_from_iter<T, I>(iter: I, total: usize) -> CountInfo
where
    I: Iterator<Item = T>,
{
    let current = iter.count();
    CountInfo::new(current, total)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_count_info_creation() {
        let count = CountInfo::new(30, 847);
        assert_eq!(count.current, 30);
        assert_eq!(count.total, 847);
    }

    #[test]
    fn test_count_info_is_complete() {
        let complete = CountInfo::new(847, 847);
        assert!(complete.is_complete());

        let incomplete = CountInfo::new(30, 847);
        assert!(!incomplete.is_complete());
    }

    #[test]
    fn test_count_info_percentage() {
        let count = CountInfo::new(30, 847);
        let percentage = count.percentage();
        assert!((percentage - 3.54).abs() < 0.01);

        let zero_count = CountInfo::new(0, 847);
        assert_eq!(zero_count.percentage(), 0.0);

        let full_count = CountInfo::new(847, 847);
        assert_eq!(full_count.percentage(), 100.0);
    }

    #[test]
    fn test_count_formatter_format() {
        let count = CountInfo::new(30, 847);
        let formatted = CountFormatter::format(&count);
        assert_eq!(formatted, "count: 30 of 847 total");
    }

    #[test]
    fn test_count_formatter_format_with_percentage() {
        let count = CountInfo::new(30, 847);
        let formatted = CountFormatter::format_with_percentage(&count);
        assert!(formatted.contains("count: 30 of 847 total"));
        assert!(formatted.contains("%"));
    }

    #[test]
    fn test_count_formatter_format_compact() {
        let count = CountInfo::new(30, 847);
        let formatted = CountFormatter::format_compact(&count);
        assert_eq!(formatted, "30/847");
    }

    #[test]
    fn test_compute_count() {
        let items = vec![1, 2, 3, 4, 5];
        let count = compute_count(&items, 100);
        assert_eq!(count.current, 5);
        assert_eq!(count.total, 100);
    }

    #[test]
    fn test_compute_count_from_iter() {
        let items = vec![1, 2, 3, 4, 5];
        let count = compute_count_from_iter(items.iter(), 100);
        assert_eq!(count.current, 5);
        assert_eq!(count.total, 100);
    }

    #[test]
    fn test_compute_count_empty() {
        let items: Vec<i32> = vec![];
        let count = compute_count(&items, 0);
        assert_eq!(count.current, 0);
        assert_eq!(count.total, 0);
        assert!(count.is_complete());
    }
}
