use anyhow::Result;
use chrono::{DateTime, Utc, Duration};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeprecationPolicy {
    pub feature_name: String,
    #[serde(with = "chrono::serde::ts_seconds")]
    pub announced_date: DateTime<Utc>,
    #[serde(with = "chrono::serde::ts_seconds")]
    pub end_of_support_date: DateTime<Utc>,
    pub description: String,
    pub migration_guide: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeprecationWarning {
    pub feature: String,
    pub days_until_eos: i64,
    pub message: String,
    pub severity: DeprecationSeverity,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum DeprecationSeverity {
    Info,
    Warning,
    Critical,
}

pub struct DeprecationManager {
    policies: HashMap<String, DeprecationPolicy>,
}

impl DeprecationManager {
    pub fn new() -> Self {
        Self {
            policies: HashMap::new(),
        }
    }
    
    pub fn add_policy(&mut self, policy: DeprecationPolicy) -> Result<()> {
        // Validate minimum 6 months from announcement to end-of-support
        let min_eos = policy.announced_date + Duration::days(180);
        if policy.end_of_support_date < min_eos {
            anyhow::bail!(
                "End-of-support date must be at least 6 months from announcement date. Announced: {}, Minimum EOS: {}",
                policy.announced_date.format("%Y-%m-%d"),
                min_eos.format("%Y-%m-%d")
            );
        }
        
        self.policies.insert(policy.feature_name.clone(), policy);
        Ok(())
    }
    
    pub fn get_policy(&self, feature: &str) -> Option<&DeprecationPolicy> {
        self.policies.get(feature)
    }
    
    pub fn check_feature(&self, feature: &str) -> Option<DeprecationWarning> {
        if let Some(policy) = self.policies.get(feature) {
            let now = Utc::now();
            let days_until_eos = (policy.end_of_support_date - now).num_days();
            
            let severity = if days_until_eos < 30 {
                DeprecationSeverity::Critical
            } else if days_until_eos < 90 {
                DeprecationSeverity::Warning
            } else {
                DeprecationSeverity::Info
            };
            
            Some(DeprecationWarning {
                feature: feature.to_string(),
                days_until_eos,
                message: format!(
                    "{}: {} will be deprecated on {}. {}",
                    severity.as_str(),
                    feature,
                    policy.end_of_support_date.format("%Y-%m-%d"),
                    policy.description
                ),
                severity,
            })
        } else {
            None
        }
    }
    
    pub fn is_feature_removed(&self, feature: &str) -> bool {
        if let Some(policy) = self.policies.get(feature) {
            Utc::now() > policy.end_of_support_date
        } else {
            false
        }
    }
    
    pub fn warn_if_deprecated(&self, feature: &str) {
        if let Some(warning) = self.check_feature(feature) {
            eprintln!("DEPRECATION WARNING: {}", warning.message);
        }
    }
}

impl Default for DeprecationManager {
    fn default() -> Self {
        Self::new()
    }
}

impl DeprecationSeverity {
    fn as_str(&self) -> &'static str {
        match self {
            DeprecationSeverity::Info => "INFO",
            DeprecationSeverity::Warning => "WARNING",
            DeprecationSeverity::Critical => "CRITICAL",
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use chrono::{Duration, Timelike};
    
    #[test]
    fn test_deprecation_manager_creation() {
        let manager = DeprecationManager::new();
        assert!(manager.policies.is_empty());
    }
    
    #[test]
    fn test_add_policy_valid() {
        let mut manager = DeprecationManager::new();
        
        let announced = Utc::now();
        let eos = announced + Duration::days(180);
        
        let policy = DeprecationPolicy {
            feature_name: "old-feature".to_string(),
            announced_date: announced,
            end_of_support_date: eos,
            description: "This feature is being replaced".to_string(),
            migration_guide: None,
        };
        
        assert!(manager.add_policy(policy).is_ok());
    }
    
    #[test]
    fn test_add_policy_invalid() {
        let mut manager = DeprecationManager::new();
        
        let announced = Utc::now();
        let eos = announced + Duration::days(90); // Only 3 months - too short
        
        let policy = DeprecationPolicy {
            feature_name: "old-feature".to_string(),
            announced_date: announced,
            end_of_support_date: eos,
            description: "This feature is being replaced".to_string(),
            migration_guide: None,
        };
        
        assert!(manager.add_policy(policy).is_err());
    }
    
    #[test]
fn test_check_feature_not_deprecated() {
        let manager = DeprecationManager::new();
        assert!(manager.check_feature("unknown-feature").is_none());
    }
    
    #[test]
fn test_check_feature_deprecated() {
        let mut manager = DeprecationManager::new();
        
        let announced = Utc::now();
        let eos = announced + Duration::days(180);
        
        let policy = DeprecationPolicy {
            feature_name: "old-feature".to_string(),
            announced_date: announced,
            end_of_support_date: eos,
            description: "This feature is being replaced".to_string(),
            migration_guide: None,
        };
        
        manager.add_policy(policy).unwrap();
        
        let warning = manager.check_feature("old-feature").unwrap();
        assert_eq!(warning.feature, "old-feature");
        assert!(warning.days_until_eos >= 180);
    }
    
    #[test]
    fn test_is_feature_removed() {
        let mut manager = DeprecationManager::new();
        
        let announced = Utc::now() - Duration::days(200);
        let eos = announced + Duration::days(180);
        
        let policy = DeprecationPolicy {
            feature_name: "old-feature".to_string(),
            announced_date: announced,
            end_of_support_date: eos,
            description: "This feature is being replaced".to_string(),
            migration_guide: None,
        };
        
        manager.add_policy(policy).unwrap();
        assert!(manager.is_feature_removed("old-feature"));
    }
    
    #[test]
fn test_severity_levels() {
        let mut manager = DeprecationManager::new();
        
        let announced = Utc::now();
        
        // Critical: < 30 days
        let eos_critical = announced + Duration::days(20);
        let policy_critical = DeprecationPolicy {
            feature_name: "critical-feature".to_string(),
            announced_date: announced,
            end_of_support_date: eos_critical,
            description: "Critical deprecation".to_string(),
            migration_guide: None,
        };
        manager.add_policy(policy_critical).unwrap();
        
        let warning = manager.check_feature("critical-feature").unwrap();
        assert_eq!(warning.severity, DeprecationSeverity::Critical);
        
        // Warning: < 90 days
        let eos_warning = announced + Duration::days(60);
        let policy_warning = DeprecationPolicy {
            feature_name: "warning-feature".to_string(),
            announced_date: announced,
            end_of_support_date: eos_warning,
            description: "Warning deprecation".to_string(),
            migration_guide: None,
        };
        manager.add_policy(policy_warning).unwrap();
        
        let warning = manager.check_feature("warning-feature").unwrap();
        assert_eq!(warning.severity, DeprecationSeverity::Warning);
        
        // Info: >= 90 days
        let eos_info = announced + Duration::days(180);
        let policy_info = DeprecationPolicy {
            feature_name: "info-feature".to_string(),
            announced_date: announced,
            end_of_support_date: eos_info,
            description: "Info deprecation".to_string(),
            migration_guide: None,
        };
        manager.add_policy(policy_info).unwrap();
        
        let warning = manager.check_feature("info-feature").unwrap();
        assert_eq!(warning.severity, DeprecationSeverity::Info);
    }
}
