use anyhow::Result;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use std::sync::Mutex;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct AuditConfig {
    pub enabled: bool,
    pub retention_days: u32,
    pub audit_log_path: PathBuf,
}

impl Default for AuditConfig {
    fn default() -> Self {
        Self {
            enabled: false,
            retention_days: 90,
            audit_log_path: PathBuf::from("audit.db"),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuditEntry {
    pub id: i64,
    pub timestamp: String,
    pub level: String,
    pub operation: String,
    pub user: Option<String>,
    pub details: String,
}

pub struct AuditLogger {
    config: AuditConfig,
    entries: Mutex<Vec<AuditEntry>>,
    next_id: Mutex<i64>,
}

impl AuditLogger {
    pub fn new(config: AuditConfig) -> Result<Self> {
        Ok(Self {
            config,
            entries: Mutex::new(Vec::new()),
            next_id: Mutex::new(1),
        })
    }
    
    pub fn log(&mut self, level: &str, operation: &str, user: Option<&str>, details: &str) -> Result<()> {
        if self.config.enabled {
            let timestamp = Utc::now().to_rfc3339();
            let mut next_id = self.next_id.lock().unwrap();
            let id = *next_id;
            *next_id += 1;
            
            let entry = AuditEntry {
                id,
                timestamp,
                level: level.to_string(),
                operation: operation.to_string(),
                user: user.map(|u| u.to_string()),
                details: details.to_string(),
            };
            
            self.entries.lock().unwrap().push(entry);
        }
        Ok(())
    }
    
    pub fn prune_old_entries(&self) -> Result<()> {
        if self.config.enabled {
            let cutoff_date = Utc::now() - chrono::Duration::days(self.config.retention_days as i64);
            let mut entries = self.entries.lock().unwrap();
            entries.retain(|entry| {
                if let Ok(dt) = DateTime::parse_from_rfc3339(&entry.timestamp) {
                    dt.with_timezone(&Utc) > cutoff_date
                } else {
                    true
                }
            });
        }
        Ok(())
    }
    
    pub fn export(&self) -> Result<Vec<AuditEntry>> {
        let entries = self.entries.lock().unwrap();
        Ok(entries.clone())
    }
    
    pub fn export_to_json(&self) -> Result<String> {
        let entries = self.export()?;
        serde_json::to_string_pretty(&entries).map_err(|e| anyhow::anyhow!("Failed to serialize audit log: {}", e))
    }
    
    pub fn export_to_csv(&self) -> Result<String> {
        let entries = self.export()?;
        let mut csv = String::new();
        
        csv.push_str("id,timestamp,level,operation,user,details\n");
        
        for entry in entries {
            csv.push_str(&format!(
                "{},{},{},{},{},{}\n",
                entry.id,
                entry.timestamp,
                entry.level,
                entry.operation,
                entry.user.as_deref().unwrap_or(""),
                entry.details.replace(',', "\\,")
            ));
        }
        
        Ok(csv)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_audit_config_default() {
        let config = AuditConfig::default();
        assert!(!config.enabled);
        assert_eq!(config.retention_days, 90);
    }
    
    #[test]
    fn test_audit_logger_disabled() {
        let config = AuditConfig::default();
        let logger = AuditLogger::new(config).unwrap();
        let entries = logger.export().unwrap();
        assert_eq!(entries.len(), 0);
    }
    
    #[test]
    fn test_audit_log_write() -> Result<()> {
        let config = AuditConfig {
            enabled: true,
            retention_days: 90,
            audit_log_path: PathBuf::from("test.db"),
        };
        
        let mut logger = AuditLogger::new(config)?;
        logger.log("INFO", "test_operation", Some("test_user"), "test_details")?;
        
        let entries = logger.export()?;
        assert_eq!(entries.len(), 1);
        assert_eq!(entries[0].operation, "test_operation");
        
        Ok(())
    }
    
    #[test]
    fn test_audit_log_pruning() -> Result<()> {
        let config = AuditConfig {
            enabled: true,
            retention_days: 1,
            audit_log_path: PathBuf::from("test.db"),
        };
        
        let mut logger = AuditLogger::new(config)?;
        
        // Add an old entry by manually inserting
        let old_timestamp = Utc::now() - chrono::Duration::days(2);
        let entry = AuditEntry {
            id: 1,
            timestamp: old_timestamp.to_rfc3339(),
            level: "INFO".to_string(),
            operation: "old_op".to_string(),
            user: None,
            details: "old_details".to_string(),
        };
        logger.entries.lock().unwrap().push(entry);
        
        // Add a recent entry
        logger.log("INFO", "new_operation", Some("test_user"), "new_details")?;
        
        // Prune
        logger.prune_old_entries()?;
        
        let entries = logger.export()?;
        assert_eq!(entries.len(), 1);
        assert_eq!(entries[0].operation, "new_operation");
        
        Ok(())
    }
}
