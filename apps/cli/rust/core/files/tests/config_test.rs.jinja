use tempfile::TempDir;
use std::fs;
use std::path::PathBuf;
use std::io::Write;

#[test]
fn test_config_default_values() {
    let config = config::Config::default();
    assert_eq!(config.version, 1);
    assert_eq!(config.log_level, "info");
    assert_eq!(config.color, true);
    assert_eq!(config.output_format, "text");
    assert_eq!(config.quiet, false);
    assert_eq!(config.max_concurrent, 4);
    assert_eq!(config.timeout, 30);
    assert_eq!(config.experimental, false);
}

#[test]
fn test_config_validation_valid() {
    let config = config::Config::default();
    assert!(config.validate().is_ok());
}

#[test]
fn test_config_validation_invalid_log_level() {
    let mut config = config::Config::default();
    config.log_level = "invalid".to_string();
    assert!(config.validate().is_err());
}

#[test]
fn test_config_validation_invalid_output_format() {
    let mut config = config::Config::default();
    config.output_format = "invalid".to_string();
    assert!(config.validate().is_err());
}

#[test]
fn test_config_validation_invalid_max_concurrent() {
    let mut config = config::Config::default();
    config.max_concurrent = 0;
    assert!(config.validate().is_err());
}

#[test]
fn test_config_validation_invalid_timeout() {
    let mut config = config::Config::default();
    config.timeout = 0;
    assert!(config.validate().is_err());
}

#[test]
fn test_config_parsing_toml() {
    let toml_content = r#"
version = 1
log_level = "debug"
color = false
output_format = "json"
quiet = true
max_concurrent = 8
timeout = 60
experimental = true
"#;
    
    let config: config::Config = toml::from_str(toml_content).unwrap();
    assert_eq!(config.log_level, "debug");
    assert_eq!(config.color, false);
    assert_eq!(config.output_format, "json");
    assert_eq!(config.quiet, true);
    assert_eq!(config.max_concurrent, 8);
    assert_eq!(config.timeout, 60);
    assert_eq!(config.experimental, true);
}

#[test]
fn test_config_parsing_yaml() {
    let yaml_content = r#"
version: 1
log_level: "debug"
color: false
output_format: "json"
quiet: true
max_concurrent: 8
timeout: 60
experimental: true
"#;
    
    let config: config::Config = serde_yaml::from_str(yaml_content).unwrap();
    assert_eq!(config.log_level, "debug");
    assert_eq!(config.color, false);
    assert_eq!(config.output_format, "json");
    assert_eq!(config.quiet, true);
}

#[test]
fn test_config_parsing_json() {
    let json_content = r#"
{
    "version": 1,
    "log_level": "debug",
    "color": false,
    "output_format": "json",
    "quiet": true,
    "max_concurrent": 8,
    "timeout": 60,
    "experimental": true
}
"#;
    
    let config: config::Config = serde_json::from_str(json_content).unwrap();
    assert_eq!(config.log_level, "debug");
    assert_eq!(config.color, false);
    assert_eq!(config.output_format, "json");
    assert_eq!(config.quiet, true);
}

#[test]
fn test_config_manager_load() {
    let manager = config::ConfigManager::new();
    assert!(manager.load().is_ok());
    assert_eq!(manager.config().version, 1);
}

#[test]
fn test_config_manager_load_from_file() {
    let temp_dir = TempDir::new().unwrap();
    let config_path = temp_dir.path().join("config.toml");
    
    let toml_content = r#"
version = 1
log_level = "debug"
color = false
"#;
    
    let mut file = fs::File::create(&config_path).unwrap();
    file.write_all(toml_content.as_bytes()).unwrap();
    
    let mut manager = config::ConfigManager::new();
    manager.load_from_file(&config_path, config::ConfigSource::User).unwrap();
    
    assert_eq!(manager.config().log_level, "debug");
    assert_eq!(manager.config().color, false);
}

#[test]
fn test_config_precedence() {
    let temp_dir = TempDir::new().unwrap();
    let user_config = temp_dir.path().join("user.toml");
    let local_config = temp_dir.path().join("local.toml");
    
    let user_toml = r#"log_level = "warn""#;
    let local_toml = r#"log_level = "debug""#;
    
    fs::write(&user_config, user_toml).unwrap();
    fs::write(&local_config, local_toml).unwrap();
    
    let mut manager = config::ConfigManager::new();
    manager.load_from_file(&user_config, config::ConfigSource::User).unwrap();
    manager.load_from_file(&local_config, config::ConfigSource::Local).unwrap();
    
    // Local config should override user config
    assert_eq!(manager.config().log_level, "debug");
}

#[test]
fn test_config_migration() {
    let temp_dir = TempDir::new().unwrap();
    let config_path = temp_dir.path().join("config.toml");
    
    let old_toml = r#"
version = 0
log_level = "info"
color = true
"#;
    
    fs::write(&config_path, old_toml).unwrap();
    
    let manager = config::ConfigManager::new();
    // This should trigger migration
    let result = manager.load_from_file(&config_path, config::ConfigSource::User);
    
    // Check that backup was created
    assert!(config_path.with_extension("toml.bak").exists());
}

#[test]
fn test_config_write_to_file() {
    let temp_dir = TempDir::new().unwrap();
    let config_path = temp_dir.path().join("config.toml");
    
    let config = config::Config::default();
    let manager = config::ConfigManager::new();
    manager.write_config_to_file(&config, &config_path).unwrap();
    
    assert!(config_path.exists());
    
    // Read back and verify
    let content = fs::read_to_string(&config_path).unwrap();
    assert!(content.contains("version = 1"));
    assert!(content.contains("log_level = \"info\""));
}

#[test]
fn test_config_sources_tracking() {
    let temp_dir = TempDir::new().unwrap();
    let config_path = temp_dir.path().join("config.toml");
    
    let toml_content = r#"version = 1"#;
    fs::write(&config_path, toml_content).unwrap();
    
    let mut manager = config::ConfigManager::new();
    manager.load_from_file(&config_path, config::ConfigSource::User).unwrap();
    
    assert_eq!(manager.sources().len(), 1);
    assert_eq!(manager.sources()[0].0, config::ConfigSource::User);
}
