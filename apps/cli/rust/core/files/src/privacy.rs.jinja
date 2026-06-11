use anyhow::Result;
use regex::Regex;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum IdentifierStatus {
    Unknown,     // Logged but not assigned
    Anonymous,   // Ignored entirely
    Known,       // Tracked normally
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct PrivacyConfig {
    pub enabled: bool,
    pub ignore_patterns: Vec<String>,
    pub privacy_toggles: PrivacyToggles,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default, PartialEq)]
pub struct PrivacyToggles {
    pub disable_analytics: bool,
    pub disable_usage_tracking: bool,
    pub disable_error_reporting: bool,
}

impl Default for PrivacyConfig {
    fn default() -> Self {
        Self {
            enabled: false,
            ignore_patterns: vec![],
            privacy_toggles: PrivacyToggles::default(),
        }
    }
}

pub struct PrivacyManager {
    config: PrivacyConfig,
    ignore_regexes: Vec<Regex>,
}

impl PrivacyManager {
    pub fn new(config: PrivacyConfig) -> Result<Self> {
        let ignore_regexes = config
            .ignore_patterns
            .iter()
            .map(|pattern| Regex::new(pattern))
            .collect::<Result<_, _>>()?;

        Ok(Self {
            config,
            ignore_regexes,
        })
    }

    pub fn is_enabled(&self) -> bool {
        self.config.enabled
    }

    pub fn classify_identifier(&self, identifier: &str) -> IdentifierStatus {
        if !self.config.enabled {
            return IdentifierStatus::Known;
        }

        // Check if identifier matches any ignore pattern
        for regex in &self.ignore_regexes {
            if regex.is_match(identifier) {
                return IdentifierStatus::Anonymous;
            }
        }

        IdentifierStatus::Unknown
    }

    pub fn should_log_analytics(&self) -> bool {
        self.config.enabled && !self.config.privacy_toggles.disable_analytics
    }

    pub fn should_track_usage(&self) -> bool {
        self.config.enabled && !self.config.privacy_toggles.disable_usage_tracking
    }

    pub fn should_report_errors(&self) -> bool {
        self.config.enabled && !self.config.privacy_toggles.disable_error_reporting
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_privacy_config_default() {
        let config = PrivacyConfig::default();
        assert!(!config.enabled);
        assert!(config.ignore_patterns.is_empty());
    }

    #[test]
    fn test_privacy_manager_creation() {
        let config = PrivacyConfig::default();
        let manager = PrivacyManager::new(config).unwrap();
        assert!(!manager.is_enabled());
    }

    #[test]
    fn test_classify_identifier_known() {
        let config = PrivacyConfig::default();
        let manager = PrivacyManager::new(config).unwrap();
        assert_eq!(
            manager.classify_identifier("test-id"),
            IdentifierStatus::Known
        );
    }

    #[test]
    fn test_classify_identifier_anonymous() {
        let config = PrivacyConfig {
            enabled: true,
            ignore_patterns: vec!["user-.*", "session-.*"],
            privacy_toggles: PrivacyToggles::default(),
        };
        let manager = PrivacyManager::new(config).unwrap();
        assert_eq!(
            manager.classify_identifier("user-123"),
            IdentifierStatus::Anonymous
        );
    }

    #[test]
    fn test_classify_identifier_unknown() {
        let config = PrivacyConfig {
            enabled: true,
            ignore_patterns: vec!["user-.*"],
            privacy_toggles: PrivacyToggles::default(),
        };
        let manager = PrivacyManager::new(config).unwrap();
        assert_eq!(
            manager.classify_identifier("session-123"),
            IdentifierStatus::Unknown
        );
    }

    #[test]
    fn test_privacy_toggles() {
        let config = PrivacyConfig {
            enabled: true,
            ignore_patterns: vec![],
            privacy_toggles: PrivacyToggles {
                disable_analytics: true,
                disable_usage_tracking: false,
                disable_error_reporting: false,
            },
        };
        let manager = PrivacyManager::new(config).unwrap();
        assert!(!manager.should_log_analytics());
        assert!(manager.should_track_usage());
        assert!(manager.should_report_errors());
    }
}
