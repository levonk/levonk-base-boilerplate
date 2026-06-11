//! Truncation metadata generation
//! 
//! Provides metadata about truncation operations including total size,
//! truncation indicators, and help suggestions for retrieving full content.

use serde::{Deserialize, Serialize};

/// Metadata about a truncation operation
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct TruncationMetadata {
    /// Original size in characters
    pub original_size: usize,
    
    /// Truncated size in characters
    pub truncated_size: usize,
    
    /// Whether the content was actually truncated
    pub was_truncated: bool,
    
    /// Detailed truncation information (only present if was_truncated is true)
    pub info: Option<TruncationInfo>,
}

impl TruncationMetadata {
    /// Create metadata for non-truncated content
    pub fn not_truncated(size: usize) -> Self {
        Self {
            original_size: size,
            truncated_size: size,
            was_truncated: false,
            info: None,
        }
    }

    /// Create metadata for truncated content
    pub fn truncated(original: usize, truncated: usize, info: TruncationInfo) -> Self {
        Self {
            original_size: original,
            truncated_size: truncated,
            was_truncated: true,
            info: Some(info),
        }
    }

    /// Get the percentage of content retained
    pub fn retention_percentage(&self) -> f64 {
        if self.original_size == 0 {
            100.0
        } else {
            (self.truncated_size as f64 / self.original_size as f64) * 100.0
        }
    }

    /// Generate help suggestion for retrieving full content
    /// Only generates suggestion if content was actually truncated
    pub fn help_suggestion(&self) -> Option<String> {
        if !self.was_truncated {
            return None;
        }

        let _info = self.info.as_ref()?;
        let percentage = self.retention_percentage();
        
        Some(format!(
            "Content truncated (showing {:.0}% of {} chars). Use --full flag to retrieve complete content.",
            percentage,
            self.original_size
        ))
    }

    /// Generate a map representation for serialization
    pub fn to_map(&self) -> std::collections::BTreeMap<String, serde_json::Value> {
        let mut map = std::collections::BTreeMap::new();
        map.insert("original_size".to_string(), serde_json::Value::Number(self.original_size.into()));
        map.insert("truncated_size".to_string(), serde_json::Value::Number(self.truncated_size.into()));
        map.insert("was_truncated".to_string(), serde_json::Value::Bool(self.was_truncated));
        
        if let Some(info) = &self.info {
            map.insert("limit".to_string(), serde_json::Value::Number(info.limit.into()));
            map.insert("truncated_chars".to_string(), serde_json::Value::Number(info.truncated_chars.into()));
        }
        
        map
    }
}

/// Detailed information about truncation
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct TruncationInfo {
    /// The limit used for truncation
    pub limit: usize,
    
    /// The indicator string used
    pub indicator: String,
    
    /// Number of characters removed
    pub truncated_chars: usize,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_not_truncated_metadata() {
        let metadata = TruncationMetadata::not_truncated(100);
        
        assert!(!metadata.was_truncated);
        assert_eq!(metadata.original_size, 100);
        assert_eq!(metadata.truncated_size, 100);
        assert!(metadata.info.is_none());
        assert!(metadata.help_suggestion().is_none());
    }

    #[test]
    fn test_truncated_metadata() {
        let info = TruncationInfo {
            limit: 1000,
            indicator: "[...]".to_string(),
            truncated_chars: 500,
        };
        let metadata = TruncationMetadata::truncated(1000, 500, info);
        
        assert!(metadata.was_truncated);
        assert_eq!(metadata.original_size, 1000);
        assert_eq!(metadata.truncated_size, 500);
        assert!(metadata.info.is_some());
        assert!(metadata.help_suggestion().is_some());
    }

    #[test]
    fn test_retention_percentage() {
        let metadata = TruncationMetadata::truncated(
            1000,
            500,
            TruncationInfo {
                limit: 1000,
                indicator: "[...]".to_string(),
                truncated_chars: 500,
            },
        );
        
        assert_eq!(metadata.retention_percentage(), 50.0);
    }

    #[test]
    fn test_retention_percentage_zero_original() {
        let metadata = TruncationMetadata::not_truncated(0);
        assert_eq!(metadata.retention_percentage(), 100.0);
    }

    #[test]
    fn test_help_suggestion_generation() {
        let metadata = TruncationMetadata::truncated(
            2000,
            1000,
            TruncationInfo {
                limit: 1000,
                indicator: "[...]".to_string(),
                truncated_chars: 1000,
            },
        );
        
        let suggestion = metadata.help_suggestion();
        assert!(suggestion.is_some());
        let suggestion = suggestion.unwrap();
        assert!(suggestion.contains("50%"));
        assert!(suggestion.contains("2000"));
        assert!(suggestion.contains("--full"));
    }

    #[test]
    fn test_help_suggestion_not_truncated() {
        let metadata = TruncationMetadata::not_truncated(100);
        assert!(metadata.help_suggestion().is_none());
    }

    #[test]
    fn test_to_map() {
        let metadata = TruncationMetadata::truncated(
            1000,
            500,
            TruncationInfo {
                limit: 1000,
                indicator: "[...]".to_string(),
                truncated_chars: 500,
            },
        );
        
        let map = metadata.to_map();
        assert_eq!(map.get("original_size"), Some(&serde_json::Value::Number(1000.into())));
        assert_eq!(map.get("truncated_size"), Some(&serde_json::Value::Number(500.into())));
        assert_eq!(map.get("was_truncated"), Some(&serde_json::Value::Bool(true)));
        assert_eq!(map.get("limit"), Some(&serde_json::Value::Number(1000.into())));
        assert_eq!(map.get("truncated_chars"), Some(&serde_json::Value::Number(500.into())));
    }

    #[test]
    fn test_to_map_not_truncated() {
        let metadata = TruncationMetadata::not_truncated(100);
        
        let map = metadata.to_map();
        assert_eq!(map.get("original_size"), Some(&serde_json::Value::Number(100.into())));
        assert_eq!(map.get("truncated_size"), Some(&serde_json::Value::Number(100.into())));
        assert_eq!(map.get("was_truncated"), Some(&serde_json::Value::Bool(false)));
        assert_eq!(map.get("limit"), None);
        assert_eq!(map.get("truncated_chars"), None);
    }
}
