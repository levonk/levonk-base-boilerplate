//! Default output schemas for CLI commands
//!
//! This module defines the default output schemas for all CLI commands,
//! providing minimal field sets for agent mode while allowing full field
//! access via explicit field selection.

use super::definition::{OutputSchema, FieldDefinition, SchemaRegistry};

/// Create the default schema registry with all command schemas
pub fn create_default_schema_registry() -> SchemaRegistry {
    SchemaRegistry::new()
        .register(config_schema())
        .register(daemon_schema())
        .register(completion_schema())
        .register(doctor_schema())
        .register(export_schema())
        .register(import_schema())
        .register(audit_schema())
        .register(deprecation_schema())
        .register(privacy_schema())
        .register(health_schema())
}

/// Schema for config command
fn config_schema() -> OutputSchema {
    OutputSchema::new("config")
        .add_field(FieldDefinition::new("path", "Configuration file path").default())
        .add_field(FieldDefinition::new("valid", "Configuration validity status").default())
        .add_field(FieldDefinition::new("source", "Configuration source (file, env, defaults)").default())
        .add_field(FieldDefinition::new("settings", "Full configuration settings").long_form())
        .with_list_limit(50)
}

/// Schema for daemon command
fn daemon_schema() -> OutputSchema {
    OutputSchema::new("daemon")
        .add_field(FieldDefinition::new("status", "Daemon status (running, stopped)").default())
        .add_field(FieldDefinition::new("pid", "Process ID").default())
        .add_field(FieldDefinition::new("uptime", "Daemon uptime in seconds").default())
        .add_field(FieldDefinition::new("jobs", "Background job details").long_form())
        .with_list_limit(100)
}

/// Schema for completion command
fn completion_schema() -> OutputSchema {
    OutputSchema::new("completion")
        .add_field(FieldDefinition::new("shell", "Shell type (bash, zsh, fish, etc.)").default())
        .add_field(FieldDefinition::new("path", "Completion script path").default())
        .add_field(FieldDefinition::new("installed", "Installation status").default())
        .add_field(FieldDefinition::new("content", "Completion script content").long_form())
        .with_list_limit(10)
}

/// Schema for doctor command
fn doctor_schema() -> OutputSchema {
    OutputSchema::new("doctor")
        .add_field(FieldDefinition::new("check", "Check name").default())
        .add_field(FieldDefinition::new("status", "Check status (pass, fail, warn)").default())
        .add_field(FieldDefinition::new("message", "Status message").default())
        .add_field(FieldDefinition::new("details", "Detailed check information").long_form())
        .with_list_limit(50)
}

/// Schema for export command
fn export_schema() -> OutputSchema {
    OutputSchema::new("export")
        .add_field(FieldDefinition::new("format", "Export format (json, toon, csv)").default())
        .add_field(FieldDefinition::new("path", "Export file path").default())
        .add_field(FieldDefinition::new("records", "Number of records exported").default())
        .add_field(FieldDefinition::new("data", "Exported data content").long_form())
        .with_list_limit(100)
}

/// Schema for import command
fn import_schema() -> OutputSchema {
    OutputSchema::new("import")
        .add_field(FieldDefinition::new("format", "Import format (json, toon, csv)").default())
        .add_field(FieldDefinition::new("path", "Import file path").default())
        .add_field(FieldDefinition::new("records", "Number of records imported").default())
        .add_field(FieldDefinition::new("errors", "Import errors").long_form())
        .with_list_limit(100)
}

/// Schema for audit command
fn audit_schema() -> OutputSchema {
    OutputSchema::new("audit")
        .add_field(FieldDefinition::new("file", "File path").default())
        .add_field(FieldDefinition::new("status", "Audit status (pass, fail)").default())
        .add_field(FieldDefinition::new("issues", "Number of issues found").default())
        .add_field(FieldDefinition::new("details", "Detailed audit findings").long_form())
        .with_list_limit(100)
}

/// Schema for deprecation command
fn deprecation_schema() -> OutputSchema {
    OutputSchema::new("deprecation")
        .add_field(FieldDefinition::new("feature", "Deprecated feature name").default())
        .add_field(FieldDefinition::new("version", "Version where deprecated").default())
        .add_field(FieldDefinition::new("removal_version", "Version where removal is planned").default())
        .add_field(FieldDefinition::new("alternative", "Recommended alternative").long_form())
        .with_list_limit(50)
}

/// Schema for privacy command
fn privacy_schema() -> OutputSchema {
    OutputSchema::new("privacy")
        .add_field(FieldDefinition::new("file", "File path").default())
        .add_field(FieldDefinition::new("status", "Privacy check status").default())
        .add_field(FieldDefinition::new("identifiers", "Number of identifiers found").default())
        .add_field(FieldDefinition::new("details", "Detailed privacy analysis").long_form())
        .with_list_limit(100)
}

/// Schema for health command
fn health_schema() -> OutputSchema {
    OutputSchema::new("health")
        .add_field(FieldDefinition::new("component", "Component name").default())
        .add_field(FieldDefinition::new("status", "Health status (healthy, unhealthy)").default())
        .add_field(FieldDefinition::new("latency_ms", "Response latency in milliseconds").default())
        .add_field(FieldDefinition::new("details", "Detailed health information").long_form())
        .with_list_limit(50)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_create_default_schema_registry() {
        let registry = create_default_schema_registry();
        let commands = registry.get_commands();
        
        // Should have schemas for all commands
        assert!(commands.contains(&"config".to_string()));
        assert!(commands.contains(&"daemon".to_string()));
        assert!(commands.contains(&"completion".to_string()));
        assert!(commands.contains(&"doctor".to_string()));
        assert!(commands.contains(&"export".to_string()));
        assert!(commands.contains(&"import".to_string()));
        assert!(commands.contains(&"audit".to_string()));
        assert!(commands.contains(&"deprecation".to_string()));
        assert!(commands.contains(&"privacy".to_string()));
        assert!(commands.contains(&"health".to_string()));
    }

    #[test]
    fn test_config_schema() {
        let schema = config_schema();
        assert_eq!(schema.command, "config");
        assert_eq!(schema.fields.len(), 4);
        assert_eq!(schema.default_fields.len(), 3); // path, valid, source
        assert_eq!(schema.list_limit, 50);
    }

    #[test]
    fn test_daemon_schema() {
        let schema = daemon_schema();
        assert_eq!(schema.command, "daemon");
        assert_eq!(schema.fields.len(), 4);
        assert_eq!(schema.default_fields.len(), 3); // status, pid, uptime
        assert_eq!(schema.list_limit, 100);
    }

    #[test]
    fn test_long_form_fields() {
        let schema = config_schema();
        let long_form = schema.get_long_form_fields();
        assert_eq!(long_form.len(), 1);
        assert!(long_form.contains(&"settings".to_string()));
    }
}
