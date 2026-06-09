//! Integration tests for aggregate output formatting

use crate::internal::aggregates::*;
use crate::internal::toon::{OutputFormatter, OutputFormat, ToonValue};

#[test]
fn test_aggregate_integration_toon_format() {
    let count = CountInfo::new(30, 847);
    let mut derived = DerivedStatus::new();
    derived.add_field("comments".to_string(), DerivedField::count("Comments", 7));
    derived.add_field("tests".to_string(), DerivedField::ratio("Tests", 3, 3));
    
    let aggregates = AggregateInfo::with_both(count, derived);
    let mut formatter = OutputFormatter::with_aggregates(OutputFormat::Toon, aggregates);
    
    let value = ToonValue::object({
        let mut map = std::collections::BTreeMap::new();
        map.insert("name".to_string(), ToonValue::string("test-item"));
        map.insert("status".to_string(), ToonValue::string("active"));
        map
    });
    
    let result = formatter.format_value(&value).unwrap();
    
    // Verify count information is included
    assert!(result.contains("_count"));
    assert!(result.contains("30"));
    assert!(result.contains("847"));
    
    // Verify derived status is included
    assert!(result.contains("_derived"));
    assert!(result.contains("comments"));
    assert!(result.contains("tests"));
}

#[test]
fn test_aggregate_integration_json_format() {
    let count = CountInfo::new(30, 847);
    let mut derived = DerivedStatus::new();
    derived.add_field("comments".to_string(), DerivedField::count("Comments", 7));
    
    let aggregates = AggregateInfo::with_both(count, derived);
    let mut formatter = OutputFormatter::with_aggregates(OutputFormat::Json, aggregates);
    
    let value = ToonValue::object({
        let mut map = std::collections::BTreeMap::new();
        map.insert("name".to_string(), ToonValue::string("test-item"));
        map
    });
    
    let result = formatter.format_value(&value).unwrap();
    
    // Verify JSON structure
    let json: serde_json::Value = serde_json::from_str(&result).unwrap();
    assert!(json.is_object());
    assert!(json.get("_count").is_some());
    assert!(json.get("_derived").is_some());
    
    // Verify count structure
    let count_obj = json.get("_count").unwrap().as_object().unwrap();
    assert_eq!(count_obj.get("current").unwrap().as_u64().unwrap(), 30);
    assert_eq!(count_obj.get("total").unwrap().as_u64().unwrap(), 847);
    assert!(count_obj.get("formatted").is_some());
    
    // Verify derived structure
    let derived_obj = json.get("_derived").unwrap().as_object().unwrap();
    assert!(derived_obj.get("comments").is_some());
}

#[test]
fn test_aggregate_integration_empty_aggregates() {
    let aggregates = AggregateInfo::empty();
    let mut formatter = OutputFormatter::with_aggregates(OutputFormat::Json, aggregates);
    
    let value = ToonValue::object({
        let mut map = std::collections::BTreeMap::new();
        map.insert("name".to_string(), ToonValue::string("test"));
        map
    });
    
    let result = formatter.format_value(&value).unwrap();
    let json: serde_json::Value = serde_json::from_str(&result).unwrap();
    
    // Empty aggregates should not add fields
    assert!(json.get("_count").is_none());
    assert!(json.get("_derived").is_none());
}

#[test]
fn test_aggregate_integration_count_only() {
    let count = CountInfo::new(100, 100);
    let aggregates = AggregateInfo::with_count(count);
    let mut formatter = OutputFormatter::with_aggregates(OutputFormat::Json, aggregates);
    
    let value = ToonValue::object({
        let mut map = std::collections::BTreeMap::new();
        map.insert("name".to_string(), ToonValue::string("test"));
        map
    });
    
    let result = formatter.format_value(&value).unwrap();
    let json: serde_json::Value = serde_json::from_str(&result).unwrap();
    
    assert!(json.get("_count").is_some());
    assert!(json.get("_derived").is_none());
}

#[test]
fn test_aggregate_integration_derived_only() {
    let mut derived = DerivedStatus::new();
    derived.add_field("status".to_string(), DerivedField::status("State", "active"));
    let aggregates = AggregateInfo::with_derived(derived);
    let mut formatter = OutputFormatter::with_aggregates(OutputFormat::Json, aggregates);
    
    let value = ToonValue::object({
        let mut map = std::collections::BTreeMap::new();
        map.insert("name".to_string(), ToonValue::string("test"));
        map
    });
    
    let result = formatter.format_value(&value).unwrap();
    let json: serde_json::Value = serde_json::from_str(&result).unwrap();
    
    assert!(json.get("_count").is_none());
    assert!(json.get("_derived").is_some());
}

#[test]
fn test_aggregate_integration_array_value() {
    let count = CountInfo::new(3, 10);
    let aggregates = AggregateInfo::with_count(count);
    let mut formatter = OutputFormatter::with_aggregates(OutputFormat::Json, aggregates);
    
    let value = ToonValue::array(vec![
        ToonValue::string("item1"),
        ToonValue::string("item2"),
        ToonValue::string("item3"),
    ]);
    
    let result = formatter.format_value(&value).unwrap();
    let json: serde_json::Value = serde_json::from_str(&result).unwrap();
    
    // Arrays should not get aggregate metadata (only objects)
    assert!(json.is_array());
    assert!(json.get("_count").is_none());
}

#[test]
fn test_aggregate_integration_nested_object() {
    let count = CountInfo::new(1, 1);
    let aggregates = AggregateInfo::with_count(count);
    let mut formatter = OutputFormatter::with_aggregates(OutputFormat::Json, aggregates);
    
    let value = ToonValue::object({
        let mut map = std::collections::BTreeMap::new();
        map.insert("name".to_string(), ToonValue::string("test"));
        map.insert("nested".to_string(), ToonValue::object({
            let mut nested_map = std::collections::BTreeMap::new();
            nested_map.insert("field".to_string(), ToonValue::string("value"));
            nested_map
        }));
        map
    });
    
    let result = formatter.format_value(&value).unwrap();
    let json: serde_json::Value = serde_json::from_str(&result).unwrap();
    
    // Aggregate should be added to top-level object
    assert!(json.get("_count").is_some());
}

#[test]
fn test_aggregate_integration_human_format() {
    let count = CountInfo::new(30, 847);
    let aggregates = AggregateInfo::with_count(count);
    let mut formatter = OutputFormatter::with_aggregates(OutputFormat::Human, aggregates);
    
    let value = ToonValue::object({
        let mut map = std::collections::BTreeMap::new();
        map.insert("name".to_string(), ToonValue::string("test"));
        map
    });
    
    let result = formatter.format_value(&value).unwrap();
    
    // Human format should include aggregates
    assert!(result.contains("_count"));
}
