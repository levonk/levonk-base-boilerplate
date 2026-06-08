use assert_cmd::Command;
use predicates::prelude::*;
use std::path::Path;

#[test]
fn test_path_normalization_unix() {
    // Test that paths are normalized correctly on Unix systems
    #[cfg(unix)]
    {
        use crate::path::PathUtils;
        
        assert_eq!(PathUtils::normalize("foo/bar"), "foo/bar");
        assert_eq!(PathUtils::normalize("foo\\bar"), "foo/bar");
        assert_eq!(PathUtils::normalize("foo/bar\\baz"), "foo/bar/baz");
    }
}

#[test]
fn test_path_normalization_windows() {
    // Test that paths are normalized correctly on Windows
    #[cfg(windows)]
    {
        use crate::path::PathUtils;
        
        assert_eq!(PathUtils::normalize("foo\\bar"), "foo\\bar");
        assert_eq!(PathUtils::normalize("foo/bar"), "foo\\bar");
        assert_eq!(PathUtils::normalize("foo/bar\\baz"), "foo\\bar\\baz");
    }
}

#[test]
fn test_path_normalization_preserves_unc() {
    // Test that UNC paths are preserved on Windows
    #[cfg(windows)]
    {
        use crate::path::PathUtils;
        
        assert_eq!(PathUtils::normalize("\\\\server\\share"), "\\\\server\\share");
        assert_eq!(PathUtils::normalize("\\\\server/share"), "\\\\server\\share");
    }
}

#[test]
fn test_path_normalization_preserves_drive() {
    // Test that drive letters are preserved on Windows
    #[cfg(windows)]
    {
        use crate::path::PathUtils;
        
        assert_eq!(PathUtils::normalize("C:\\foo"), "C:\\foo");
        assert_eq!(PathUtils::normalize("C:/foo"), "C:\\foo");
    }
}

#[test]
fn test_forward_slash_conversion() {
    use crate::path::PathUtils;
    
    let path = Path::new("foo\\bar\\baz");
    let result = PathUtils::to_forward_slashes(path);
    assert_eq!(result, "foo/bar/baz");
}

#[test]
fn test_backward_slash_conversion() {
    use crate::path::PathUtils;
    
    let path = Path::new("foo/bar/baz");
    let result = PathUtils::to_backward_slashes(path);
    assert_eq!(result, "foo\\bar\\baz");
}

#[test]
fn test_is_absolute_unix() {
    #[cfg(unix)]
    {
        use crate::path::PathUtils;
        
        assert!(PathUtils::is_absolute("/foo/bar"));
        assert!(PathUtils::is_absolute("/"));
        assert!(!PathUtils::is_absolute("foo/bar"));
        assert!(!PathUtils::is_absolute("./foo"));
    }
}

#[test]
fn test_is_absolute_windows() {
    #[cfg(windows)]
    {
        use crate::path::PathUtils;
        
        assert!(PathUtils::is_absolute("C:\\foo"));
        assert!(PathUtils::is_absolute("\\\\server\\share"));
        assert!(!PathUtils::is_absolute("foo\\bar"));
        assert!(!PathUtils::is_absolute("./foo"));
    }
}

#[test]
fn test_unc_path_detection() {
    use crate::path::PathUtils;
    
    assert!(PathUtils::is_unc_path("\\\\server\\share"));
    assert!(PathUtils::is_unc_path("\\\\server/share"));
    assert!(!PathUtils::is_unc_path("C:\\foo"));
    assert!(!PathUtils::is_unc_path("/foo/bar"));
    assert!(!PathUtils::is_unc_path("foo\\bar"));
}

#[test]
fn test_url_detection() {
    use crate::path::PathUtils;
    
    assert!(PathUtils::is_url("http://example.com"));
    assert!(PathUtils::is_url("https://example.com"));
    assert!(PathUtils::is_url("file:///path/to/file"));
    assert!(!PathUtils::is_url("/path/to/file"));
    assert!(!PathUtils::is_url("C:\\path\\to\\file"));
}

#[test]
fn test_path_join() {
    use crate::path::PathUtils;
    
    let result = PathUtils::join(&["foo", "bar", "baz"]);
    let sep = std::path::MAIN_SEPARATOR;
    let expected = format!("foo{}bar{}baz", sep, sep);
    assert_eq!(result, expected);
}

#[test]
fn test_path_join_empty_components() {
    use crate::path::PathUtils;
    
    let result = PathUtils::join(&["foo", "", "bar"]);
    let sep = std::path::MAIN_SEPARATOR;
    let expected = format!("foo{}bar", sep);
    assert_eq!(result, expected);
}

#[test]
fn test_file_name_extraction() {
    use crate::path::PathUtils;
    
    let path = Path::new("/foo/bar/baz.txt");
    assert_eq!(PathUtils::file_name(path), Some("baz.txt"));
    
    let path2 = Path::new("C:\\foo\\bar\\baz.txt");
    assert_eq!(PathUtils::file_name(path2), Some("baz.txt"));
}

#[test]
fn test_extension_extraction() {
    use crate::path::PathUtils;
    
    let path = Path::new("/foo/bar/baz.txt");
    assert_eq!(PathUtils::extension(path), Some("txt"));
    
    let path2 = Path::new("/foo/bar/baz");
    assert_eq!(PathUtils::extension(path2), None);
}

#[test]
fn test_file_stem_extraction() {
    use crate::path::PathUtils;
    
    let path = Path::new("/foo/bar/baz.txt");
    assert_eq!(PathUtils::file_stem(path), Some("baz"));
    
    let path2 = Path::new("/foo/bar/baz.tar.gz");
    assert_eq!(PathUtils::file_stem(path2), Some("baz.tar"));
}

#[test]
fn test_path_validation_safe() {
    use crate::path::PathUtils;
    
    let safe_path = Path::new("/foo/bar");
    assert!(PathUtils::validate_safe(safe_path).is_ok());
    
    let safe_path2 = Path::new("foo/bar");
    assert!(PathUtils::validate_safe(safe_path2).is_ok());
}

#[test]
fn test_path_validation_traversal() {
    use crate::path::PathUtils;
    
    let unsafe_path = Path::new("/foo/../bar");
    assert!(PathUtils::validate_safe(unsafe_path).is_err());
    
    let unsafe_path2 = Path::new("foo/../bar");
    assert!(PathUtils::validate_safe(unsafe_path2).is_err());
}

#[test]
fn test_from_user_input() {
    use crate::path::PathUtils;
    
    let result = PathUtils::from_user_input("foo/bar").unwrap();
    assert_eq!(result, Path::new("foo/bar"));
    
    let result2 = PathUtils::from_user_input("foo\\bar").unwrap();
    // Should be normalized to platform separator
    let expected = if cfg!(windows) { "foo\\bar" } else { "foo/bar" };
    assert_eq!(result2, Path::new(expected));
}

#[test]
fn test_from_user_input_traversal_rejected() {
    use crate::path::PathUtils;
    
    let result = PathUtils::from_user_input("foo/../bar");
    assert!(result.is_err());
}

#[test]
fn test_tilde_expansion() {
    use crate::path::PathUtils;
    
    let result = PathUtils::expand_tilde("~/foo");
    assert!(result.starts_with('/'));
    assert!(result.contains("foo"));
    assert!(!result.starts_with('~'));
}

#[test]
fn test_tilde_expansion_no_tilde() {
    use crate::path::PathUtils;
    
    let result = PathUtils::expand_tilde("/foo/bar");
    assert_eq!(result, "/foo/bar");
}

#[test]
fn test_make_relative_if_possible() {
    use crate::path::PathUtils;
    
    let current_dir = std::env::current_dir().unwrap();
    let test_path = current_dir.join("foo/bar");
    
    let result = PathUtils::make_relative_if_possible(&test_path);
    assert_eq!(result, Path::new("foo/bar"));
}

#[test]
fn test_make_relative_if_possible_absolute() {
    use crate::path::PathUtils;
    
    let absolute_path = Path::new("/tmp/test");
    let result = PathUtils::make_relative_if_possible(absolute_path);
    // Should return the absolute path if it can't be made relative
    assert_eq!(result, absolute_path);
}

#[test]
fn test_cross_platform_glob_pattern() {
    // Test that glob patterns work with both forward and backward slashes
    #[cfg(unix)]
    {
        use crate::path::PathUtils;
        
        let pattern = "foo/**/*.txt";
        let normalized = PathUtils::normalize(pattern);
        assert_eq!(normalized, "foo/**/*.txt");
    }
    
    #[cfg(windows)]
    {
        use crate::path::PathUtils;
        
        let pattern = "foo/**/*.txt";
        let normalized = PathUtils::normalize(pattern);
        assert_eq!(normalized, "foo\\**\\*.txt");
    }
}

#[test]
fn test_mixed_slash_handling() {
    use crate::path::PathUtils;
    
    let path = "foo/bar\\baz/qux";
    let normalized = PathUtils::normalize(path);
    
    if cfg!(unix) {
        assert_eq!(normalized, "foo/bar/baz/qux");
    } else {
        assert_eq!(normalized, "foo\\bar\\baz\\qux");
    }
}
