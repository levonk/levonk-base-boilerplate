use assert_cmd::Command;
use predicates::prelude::*;
use std::fs;
use std::path::Path;
use tempfile::TempDir;

#[test]
fn test_secret_redaction_password() {
    use crate::security::SecurityUtils;
    
    let input = "password=secret123";
    let redacted = SecurityUtils::redact_secrets(input);
    assert!(!redacted.contains("secret123"));
    assert!(redacted.contains("*****"));
}

#[test]
fn test_secret_redaction_token() {
    use crate::security::SecurityUtils;
    
    let input = "token=abc123xyz";
    let redacted = SecurityUtils::redact_secrets(input);
    assert!(!redacted.contains("abc123xyz"));
    assert!(redacted.contains("*****"));
}

#[test]
fn test_secret_redaction_api_key() {
    use crate::security::SecurityUtils;
    
    let input = "api_key=12345";
    let redacted = SecurityUtils::redact_secrets(input);
    assert!(!redacted.contains("12345"));
    assert!(redacted.contains("*****"));
}

#[test]
fn test_secret_redaction_multiple() {
    use crate::security::SecurityUtils;
    
    let input = "password=secret token=abc api_key=123";
    let redacted = SecurityUtils::redact_secrets(input);
    assert!(!redacted.contains("secret"));
    assert!(!redacted.contains("abc"));
    assert!(!redacted.contains("123"));
}

#[test]
fn test_secret_redaction_colon_format() {
    use crate::security::SecurityUtils;
    
    let input = "password: secret123";
    let redacted = SecurityUtils::redact_secrets(input);
    assert!(!redacted.contains("secret123"));
}

#[test]
fn test_secret_redaction_no_match() {
    use crate::security::SecurityUtils;
    
    let input = "name=value";
    let redacted = SecurityUtils::redact_secrets(input);
    assert_eq!(redacted, "name=value");
}

#[test]
fn test_contains_secret_true() {
    use crate::security::SecurityUtils;
    
    assert!(SecurityUtils::contains_secret("password=123"));
    assert!(SecurityUtils::contains_secret("TOKEN=abc"));
    assert!(SecurityUtils::contains_secret("secret_key=xyz"));
}

#[test]
fn test_contains_secret_false() {
    use crate::security::SecurityUtils;
    
    assert!(!SecurityUtils::contains_secret("name=value"));
    assert!(!SecurityUtils::contains_secret("username=john"));
    assert!(!SecurityUtils::contains_secret("email=test@example.com"));
}

#[test]
fn test_zero_string() {
    use crate::security::SecurityUtils;
    
    let mut s = String::from("secret");
    SecurityUtils::zero_string(&mut s);
    assert!(s.is_empty() || s.chars().all(|c| c == '\0'));
}

#[test]
fn test_zero_bytes() {
    use crate::security::SecurityUtils;
    
    let mut bytes = vec![1u8, 2, 3, 4, 5];
    SecurityUtils::zero_bytes(&mut bytes);
    assert!(bytes.iter().all(|&b| b == 0));
}

#[test]
fn test_validate_input_safe() {
    use crate::security::SecurityUtils;
    
    assert!(SecurityUtils::validate_input("safe_input").is_ok());
    assert!(SecurityUtils::validate_input("another-safe").is_ok());
    assert!(SecurityUtils::validate_input("test123").is_ok());
}

#[test]
fn test_validate_input_unsafe_semicolon() {
    use crate::security::SecurityUtils;
    
    assert!(SecurityUtils::validate_input("rm -rf /").is_err());
    assert!(SecurityUtils::validate_input("echo test; ls").is_err());
}

#[test]
fn test_validate_input_unsafe_pipe() {
    use crate::security::SecurityUtils;
    
    assert!(SecurityUtils::validate_input("cat file | grep test").is_err());
}

#[test]
fn test_validate_input_unsafe_backtick() {
    use crate::security::SecurityUtils;
    
    assert!(SecurityUtils::validate_input("echo `whoami`").is_err());
}

#[test]
fn test_validate_input_unsafe_dollar() {
    use crate::security::SecurityUtils;
    
    assert!(SecurityUtils::validate_input("echo $(whoami)").is_err());
}

#[test]
fn test_validate_input_path_traversal() {
    use crate::security::SecurityUtils;
    
    assert!(SecurityUtils::validate_input("../../../etc/passwd").is_err());
    assert!(SecurityUtils::validate_input("foo/../bar").is_err());
}

#[test]
fn test_sanitize_input_quotes() {
    use crate::security::SecurityUtils;
    
    let input = "test\"value";
    let sanitized = SecurityUtils::sanitize_input(input);
    assert!(sanitized.contains("\\\""));
    assert!(!sanitized.contains("\""));
}

#[test]
fn test_sanitize_input_backslash() {
    use crate::security::SecurityUtils;
    
    let input = "path\\to\\file";
    let sanitized = SecurityUtils::sanitize_input(input);
    assert!(sanitized.contains("\\\\"));
}

#[test]
fn test_sanitize_input_dollar() {
    use crate::security::SecurityUtils;
    
    let input = "$HOME";
    let sanitized = SecurityUtils::sanitize_input(input);
    assert!(sanitized.contains("\\$"));
}

#[test]
fn test_secure_string_creation() {
    use crate::security::SecureString;
    
    let secure = SecureString::new("secret".to_string());
    assert_eq!(secure.len(), 6);
    assert!(!secure.is_empty());
    assert_eq!(secure.expose(), "secret");
}

#[test]
fn test_secure_string_from_str() {
    use crate::security::SecureString;
    
    let secure: SecureString = "secret".into();
    assert_eq!(secure.len(), 6);
}

#[test]
fn test_secure_string_from_string() {
    use crate::security::SecureString;
    
    let secure: SecureString = String::from("secret").into();
    assert_eq!(secure.len(), 6);
}

#[test]
fn test_insecure_config_warning() {
    use crate::security::SecurityUtils;
    
    let warning = SecurityUtils::insecure_config_warning("plaintext");
    assert!(warning.contains("WARNING"));
    assert!(warning.contains("plaintext"));
    assert!(warning.contains("insecure"));
}

#[test]
fn test_config_permission_validation_missing_file() {
    use crate::security::SecurityUtils;
    
    let result = SecurityUtils::validate_config_permissions(Path::new("/nonexistent/file"));
    assert!(result.is_ok());
    assert!(!result.unwrap()); // File doesn't exist
}

#[test]
fn test_config_permission_validation_secure() {
    use crate::security::SecurityUtils;
    use tempfile::NamedTempFile;
    
    let temp_file = NamedTempFile::new().unwrap();
    let path = temp_file.path();
    
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        let mut perms = fs::metadata(path).unwrap().permissions();
        perms.set_mode(0o600);
        fs::set_permissions(path, perms).unwrap();
        
        let result = SecurityUtils::validate_config_permissions(path);
        assert!(result.is_ok());
        assert!(result.unwrap()); // Permissions are secure
    }
    
    #[cfg(not(unix))]
    {
        // On non-Unix systems, we can't test Unix permissions
        let result = SecurityUtils::validate_config_permissions(path);
        assert!(result.is_ok());
    }
}

#[test]
fn test_config_permission_validation_insecure() {
    use crate::security::SecurityUtils;
    use tempfile::NamedTempFile;
    
    let temp_file = NamedTempFile::new().unwrap();
    let path = temp_file.path();
    
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        let mut perms = fs::metadata(path).unwrap().permissions();
        perms.set_mode(0o644); // World-readable
        fs::set_permissions(path, perms).unwrap();
        
        let result = SecurityUtils::validate_config_permissions(path);
        assert!(result.is_ok());
        assert!(!result.unwrap()); // Permissions are insecure
    }
    
    #[cfg(not(unix))]
    {
        // On non-Unix systems, we can't test Unix permissions
        let result = SecurityUtils::validate_config_permissions(path);
        assert!(result.is_ok());
    }
}

#[test]
fn test_set_secure_permissions() {
    use crate::security::SecurityUtils;
    use tempfile::NamedTempFile;
    
    let temp_file = NamedTempFile::new().unwrap();
    let path = temp_file.path();
    
    let result = SecurityUtils::set_secure_permissions(path);
    assert!(result.is_ok());
    
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        let perms = fs::metadata(path).unwrap().permissions();
        let mode = perms.mode() & 0o777;
        assert_eq!(mode, 0o600);
    }
}

#[test]
fn test_secure_environment_check() {
    use crate::security::SecurityUtils;
    
    // This test just ensures the function runs without panicking
    let result = SecurityUtils::is_secure_environment();
    // The result depends on the environment, so we just check it returns a bool
    assert!(result == true || result == false);
}

#[test]
fn test_secret_patterns_comprehensive() {
    use crate::security::SecurityUtils;
    
    // Test all secret patterns
    let patterns = vec![
        "password", "passwd", "pwd", "token", "api_key", "apikey",
        "secret", "private_key", "privatekey", "auth", "credential",
        "cred", "bearer", "session", "cookie"
    ];
    
    for pattern in patterns {
        let input = format!("{}=value", pattern);
        assert!(SecurityUtils::contains_secret(&input), "Pattern '{}' should be detected as secret", pattern);
    }
}
