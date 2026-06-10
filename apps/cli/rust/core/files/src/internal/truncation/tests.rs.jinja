//! Integration tests for truncation functionality
//! 
//! Tests for --full flag, truncation integration with output formatters,
//! and end-to-end truncation behavior.

use super::*;
use crate::internal::toon::{OutputFormatter, OutputFormat, ToonValue};
use std::collections::BTreeMap;

#[test]
fn test_full_flag_disables_truncation() {
    let formatter_with_truncation = OutputFormatter::with_truncation(OutputFormat::Toon, 100);
    let formatter_without_truncation = OutputFormatter::without_truncation(OutputFormat::Toon);
    
    let long_text = "a".repeat(200);
    let value = ToonValue::string(long_text.clone());
    
    // With truncation
    let (truncated, metadata) = formatter_with_truncation.apply_truncation(&value);
    assert!(metadata.is_some());
    assert!(metadata.unwrap().was_truncated);
    
    // Without truncation (full flag)
    let (not_truncated, metadata) = formatter_without_truncation.apply_truncation(&value);
    assert!(metadata.is_none());
    
    if let ToonValue::String(s) = not_truncated {
        assert_eq!(s, long_text);
    } else {
        panic!("Expected string value");
    }
}

#[test]
fn test_truncation_with_toon_format() {
    let formatter = OutputFormatter::with_truncation(OutputFormat::Toon, 50);
    
    let mut obj = BTreeMap::new();
    obj.insert("name".to_string(), ToonValue::string("Alice"));
    obj.insert("description".to_string(), ToonValue::string("a".repeat(100)));
    let value = ToonValue::Object(obj);
    
    let (truncated, metadata) = formatter.apply_truncation(&value);
    assert!(metadata.is_some());
    assert!(metadata.unwrap().was_truncated);
}

#[test]
fn test_truncation_with_json_format() {
    let formatter = OutputFormatter::with_truncation(OutputFormat::Json, 50);
    
    let long_text = "a".repeat(100);
    let value = ToonValue::string(long_text.clone());
    
    let (truncated, metadata) = formatter.apply_truncation(&value);
    assert!(metadata.is_some());
    assert!(metadata.unwrap().was_truncated);
}

#[test]
fn test_truncation_with_human_format() {
    let formatter = OutputFormatter::with_truncation(OutputFormat::Human, 50);
    
    let long_text = "a".repeat(100);
    let value = ToonValue::string(long_text.clone());
    
    let (truncated, metadata) = formatter.apply_truncation(&value);
    assert!(metadata.is_some());
    assert!(metadata.unwrap().was_truncated);
}

#[test]
fn test_truncation_not_applied_under_limit() {
    let formatter = OutputFormatter::with_truncation(OutputFormat::Toon, 100);
    
    let short_text = "Short text";
    let value = ToonValue::string(short_text.to_string());
    
    let (result, metadata) = formatter.apply_truncation(&value);
    assert!(metadata.is_none());
    
    if let ToonValue::String(s) = result {
        assert_eq!(s, short_text);
    } else {
        panic!("Expected string value");
    }
}

#[test]
fn test_truncation_in_nested_structures() {
    let formatter = OutputFormatter::with_truncation(OutputFormat::Toon, 20);
    
    let mut inner_obj = BTreeMap::new();
    inner_obj.insert("field1".to_string(), ToonValue::string("a".repeat(50)));
    
    let mut outer_obj = BTreeMap::new();
    outer_obj.insert("nested".to_string(), ToonValue::Object(inner_obj));
    outer_obj.insert("other".to_string(), ToonValue::string("b".repeat(50)));
    
    let value = ToonValue::Object(outer_obj);
    
    let (truncated, metadata) = formatter.apply_truncation(&value);
    assert!(metadata.is_some());
    assert!(metadata.unwrap().was_truncated);
}

#[test]
fn test_truncation_in_arrays() {
    let formatter = OutputFormatter::with_truncation(OutputFormat::Toon, 20);
    
    let arr = vec![
        ToonValue::string("a".repeat(50)),
        ToonValue::string("b".repeat(50)),
        ToonValue::string("c".repeat(50)),
    ];
    let value = ToonValue::Array(arr);
    
    let (truncated, metadata) = formatter.apply_truncation(&value);
    assert!(metadata.is_some());
    assert!(metadata.unwrap().was_truncated);
}

#[test]
fn test_auto_detect_with_truncation() {
    use crate::internal::Mode;
    
    // Agent mode with truncation
    let formatter = OutputFormatter::auto_detect_with_truncation(
        Mode::Agent,
        false,
        false,
        None,
        Some(100),
        false,
    ).unwrap();
    
    let long_text = "a".repeat(200);
    let value = ToonValue::string(long_text.clone());
    let (truncated, metadata) = formatter.apply_truncation(&value);
    assert!(metadata.is_some());
    assert!(metadata.unwrap().was_truncated);
}

#[test]
fn test_auto_detect_with_full_flag() {
    use crate::internal::Mode;
    
    // Agent mode with full flag (no truncation)
    let formatter = OutputFormatter::auto_detect_with_truncation(
        Mode::Agent,
        false,
        false,
        None,
        Some(100),
        true, // full flag
    ).unwrap();
    
    let long_text = "a".repeat(200);
    let value = ToonValue::string(long_text.clone());
    let (not_truncated, metadata) = formatter.apply_truncation(&value);
    assert!(metadata.is_none());
    
    if let ToonValue::String(s) = not_truncated {
        assert_eq!(s, long_text);
    } else {
        panic!("Expected string value");
    }
}

#[test]
fn test_truncation_metadata_help_suggestion() {
    let truncator = Truncator::new(100);
    let long_text = "a".repeat(200);
    let (_, metadata) = truncator.truncate(&long_text);
    
    assert!(metadata.was_truncated);
    let suggestion = metadata.help_suggestion();
    assert!(suggestion.is_some());
    assert!(suggestion.unwrap().contains("--full"));
}

#[test]
fn test_truncation_metadata_no_help_suggestion_when_not_truncated() {
    let truncator = Truncator::new(100);
    let short_text = "Short text";
    let (_, metadata) = truncator.truncate(short_text);
    
    assert!(!metadata.was_truncated);
    assert!(metadata.help_suggestion().is_none());
}
