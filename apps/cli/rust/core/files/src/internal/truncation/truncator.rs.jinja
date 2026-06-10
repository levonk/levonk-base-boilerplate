//! Text truncation logic with smart word boundary detection
//! 
//! Provides configurable truncation that respects word boundaries
//! and includes metadata about the truncation operation.

use super::metadata::{TruncationMetadata, TruncationInfo};
use std::borrow::Cow;

/// Truncator for reducing text content size
#[derive(Debug, Clone)]
pub struct Truncator {
    /// Maximum character limit for truncation
    limit: usize,
    /// Whether to break at word boundaries
    break_words: bool,
    /// Truncation indicator string
    indicator: String,
}

impl Truncator {
    /// Create a new truncator with default settings
    pub fn new(limit: usize) -> Self {
        Self {
            limit,
            break_words: true,
            indicator: "[...]".to_string(),
        }
    }

    /// Set whether to break at word boundaries
    pub fn with_break_words(mut self, break_words: bool) -> Self {
        self.break_words = break_words;
        self
    }

    /// Set the truncation indicator string
    pub fn with_indicator(mut self, indicator: impl Into<String>) -> Self {
        self.indicator = indicator.into();
        self
    }

    /// Truncate text if it exceeds the limit
    /// 
    /// Returns a tuple of (truncated_text, metadata)
    /// If text is under the limit, returns the original text with metadata indicating no truncation
    pub fn truncate<'a>(&self, text: &'a str) -> (Cow<'a, str>, TruncationMetadata) {
        let original_len = text.chars().count();
        
        if original_len <= self.limit {
            let metadata = TruncationMetadata {
                original_size: original_len,
                truncated_size: original_len,
                was_truncated: false,
                info: None,
            };
            return (Cow::Borrowed(text), metadata);
        }

        let truncated = if self.break_words {
            self.truncate_at_word_boundary(text)
        } else {
            self.truncate_at_char_boundary(text)
        };

        let truncated_len = truncated.chars().count();
        let metadata = TruncationMetadata {
            original_size: original_len,
            truncated_size: truncated_len,
            was_truncated: true,
            info: Some(TruncationInfo {
                limit: self.limit,
                indicator: self.indicator.clone(),
                truncated_chars: original_len - truncated_len,
            }),
        };

        (Cow::Owned(truncated), metadata)
    }

    /// Truncate at character boundary (simple truncation)
    fn truncate_at_char_boundary(&self, text: &str) -> String {
        let indicator_len = self.indicator.chars().count();
        let available = self.limit.saturating_sub(indicator_len);
        
        if available == 0 {
            return self.indicator.clone();
        }

        let truncated: String = text
            .chars()
            .take(available)
            .collect();
        
        format!("{}{}", truncated, self.indicator)
    }

    /// Truncate at word boundary (smart truncation)
    fn truncate_at_word_boundary(&self, text: &str) -> String {
        let indicator_len = self.indicator.chars().count();
        let available = self.limit.saturating_sub(indicator_len);
        
        if available == 0 {
            return self.indicator.clone();
        }

        // Take characters up to the limit
        let truncated_chars: Vec<char> = text.chars().take(available).collect();
        let truncated: String = truncated_chars.iter().collect();
        
        // Find the last word boundary
        if let Some(last_space) = truncated.rfind(' ') {
            // Truncate at the last space
            let at_boundary = &truncated[..last_space];
            format!("{} {}", at_boundary.trim_end(), self.indicator)
        } else {
            // No space found, truncate at character boundary
            format!("{}{}", truncated.trim_end(), self.indicator)
        }
    }

    /// Check if text would be truncated
    pub fn would_truncate(&self, text: &str) -> bool {
        text.chars().count() > self.limit
    }
}

impl Default for Truncator {
    fn default() -> Self {
        Self::new(1000)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_no_truncation_under_limit() {
        let truncator = Truncator::new(100);
        let text = "Short text";
        let (result, metadata) = truncator.truncate(text);
        
        assert_eq!(result.as_ref(), text);
        assert!(!metadata.was_truncated);
        assert_eq!(metadata.original_size, 10);
        assert_eq!(metadata.truncated_size, 10);
    }

    #[test]
    fn test_truncation_over_limit() {
        let truncator = Truncator::new(10);
        let text = "This is a much longer text that needs truncation";
        let (result, metadata) = truncator.truncate(text);
        
        assert!(metadata.was_truncated);
        assert!(metadata.original_size > metadata.truncated_size);
        assert!(result.as_ref().ends_with("[...]"));
        assert!(result.as_ref().len() <= 15); // 10 + indicator
    }

    #[test]
    fn test_word_boundary_truncation() {
        let truncator = Truncator::new(20).with_break_words(true);
        let text = "This is a longer text that should be truncated at a word boundary";
        let (result, metadata) = truncator.truncate(text);
        
        assert!(metadata.was_truncated);
        // Should not cut in the middle of a word
        let before_indicator = result.as_ref().trim_end_matches("[...]");
        assert!(!before_indicator.ends_with(' '));
    }

    #[test]
    fn test_char_boundary_truncation() {
        let truncator = Truncator::new(15).with_break_words(false);
        let text = "This is a longer text that should be truncated";
        let (result, metadata) = truncator.truncate(text);
        
        assert!(metadata.was_truncated);
        // May cut in the middle of a word
        assert!(result.as_ref().len() <= 18); // 15 + indicator
    }

    #[test]
    fn test_custom_indicator() {
        let truncator = Truncator::new(10).with_indicator("...");
        let text = "This is a much longer text";
        let (result, metadata) = truncator.truncate(text);
        
        assert!(metadata.was_truncated);
        assert!(result.as_ref().ends_with("..."));
        assert_eq!(metadata.info.unwrap().indicator, "...");
    }

    #[test]
    fn test_would_truncate() {
        let truncator = Truncator::new(10);
        
        assert!(!truncator.would_truncate("Short"));
        assert!(truncator.would_truncate("This is too long"));
    }

    #[test]
    fn test_empty_text() {
        let truncator = Truncator::new(10);
        let (result, metadata) = truncator.truncate("");
        
        assert_eq!(result.as_ref(), "");
        assert!(!metadata.was_truncated);
        assert_eq!(metadata.original_size, 0);
    }

    #[test]
    fn test_unicode_handling() {
        let truncator = Truncator::new(10);
        let text = "Hello 世界 🌍";
        let (result, metadata) = truncator.truncate(text);
        
        // Should handle unicode characters correctly
        assert!(metadata.original_size > 0);
        assert!(result.as_ref().chars().count() <= 13); // 10 + indicator
    }

    #[test]
    fn test_limit_smaller_than_indicator() {
        let truncator = Truncator::new(2);
        let text = "Long text here";
        let (result, metadata) = truncator.truncate(text);
        
        assert!(metadata.was_truncated);
        // Should only show indicator
        assert_eq!(result.as_ref(), "[...]");
    }
}
