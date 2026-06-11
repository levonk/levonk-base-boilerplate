//! TOON encoder implementation
//! 
//! This module implements encoding of Rust values to TOON format according to the TOON specification v3.3.
//! The encoder produces UTF-8 output with LF line endings and consistent indentation.

use crate::internal::toon::types::{ToonValue, ToonEncodeOptions, ToonEncodeError};

/// TOON encoder
pub struct ToonEncoder {
    options: ToonEncodeOptions,
    output: String,
    indent_level: usize,
}

impl ToonEncoder {
    /// Create a new TOON encoder with default options
    pub fn new() -> Self {
        Self::with_options(ToonEncodeOptions::default())
    }

    /// Create a new TOON encoder with custom options
    pub fn with_options(options: ToonEncodeOptions) -> Self {
        Self {
            options,
            output: String::new(),
            indent_level: 0,
        }
    }

    /// Encode a TOON value to a string
    pub fn encode(&mut self, value: &ToonValue) -> Result<String, ToonEncodeError> {
        self.output.clear();
        self.indent_level = 0;
        self.encode_value(value)?;
        Ok(self.output.clone())
    }

    /// Encode a single value
    fn encode_value(&mut self, value: &ToonValue) -> Result<(), ToonEncodeError> {
        match value {
            ToonValue::Null => self.encode_null(),
            ToonValue::Bool(b) => self.encode_bool(*b),
            ToonValue::Number(n) => self.encode_number(n),
            ToonValue::String(s) => self.encode_string(s),
            ToonValue::Array(arr) => self.encode_array(arr),
            ToonValue::Object(obj) => self.encode_object(obj),
        }
    }

    /// Encode null value
    fn encode_null(&mut self) -> Result<(), ToonEncodeError> {
        self.write_str("null")
    }

    /// Encode boolean value
    fn encode_bool(&mut self, value: bool) -> Result<(), ToonEncodeError> {
        self.write_str(if value { "true" } else { "false" })
    }

    /// Encode number value
    fn encode_number(&mut self, value: &str) -> Result<(), ToonEncodeError> {
        // Validate number format (basic check)
        if value.is_empty() {
            return Err(ToonEncodeError::InvalidNumber("Empty number".to_string()));
        }
        
        // Check for valid number characters (basic validation)
        let has_digits = value.chars().any(|c| c.is_ascii_digit());
        let has_valid_chars = value.chars().all(|c| {
            c.is_ascii_digit() || c == '-' || c == '+' || c == '.' || c == 'e' || c == 'E'
        });
        
        if !has_digits || !has_valid_chars {
            return Err(ToonEncodeError::InvalidNumber(format!("Invalid number format: {}", value)));
        }
        
        self.write_str(value)
    }

    /// Encode string value
    fn encode_string(&mut self, value: &str) -> Result<(), ToonEncodeError> {
        // Check if string needs quoting
        let needs_quoting = self.needs_quoting(value);
        
        if needs_quoting {
            self.write_char('"')?;
            for c in value.chars() {
                match c {
                    '\\' => self.write_str("\\\\")?,
                    '"' => self.write_str("\\\"")?,
                    '\n' => self.write_str("\\n")?,
                    '\r' => self.write_str("\\r")?,
                    '\t' => self.write_str("\\t")?,
                    // Control characters U+0000 to U+001F (except already handled)
                    c if c <= '\u{001f}' => {
                        self.write_str(&format!("\\u{:04x}", c as u32))?
                    }
                    _ => self.write_char(c)?,
                }
            }
            self.write_char('"')?;
        } else {
            self.write_str(value)?;
        }
        
        Ok(())
    }

    /// Determine if a string needs quoting
    fn needs_quoting(&self, value: &str) -> bool {
        if value.is_empty() {
            return true;
        }
        
        for c in value.chars() {
            // Quote if contains active delimiter, colon, or structural characters
            if c == ',' || c == '\t' || c == '|' || c == ':' || c == '{' || c == '}' || c == '[' || c == ']' {
                return true;
            }
            // Quote if contains whitespace
            if c.is_whitespace() {
                return true;
            }
            // Quote if starts with digit (to avoid confusion with numbers)
            if c.is_ascii_digit() && value.starts_with(c) {
                return true;
            }
            // Quote if is a boolean/null literal
            if value == "true" || value == "false" || value == "null" {
                return true;
            }
        }
        
        false
    }

    /// Encode array value
    fn encode_array(&mut self, arr: &[ToonValue]) -> Result<(), ToonEncodeError> {
        if arr.is_empty() {
            // Empty array: []
            self.write_str("[]")?;
            return Ok(());
        }

        // Check if all elements are primitives (inline array)
        let all_primitives = arr.iter().all(|v| {
            matches!(v, ToonValue::Null | ToonValue::Bool(_) | ToonValue::Number(_) | ToonValue::String(_))
        });

        if all_primitives {
            // Inline array: [value1, value2, ...]
            self.write_str("[")?;
            for (i, v) in arr.iter().enumerate() {
                if i > 0 {
                    self.write_str(", ")?;
                }
                self.encode_value(v)?;
            }
            self.write_str("]")?;
        } else {
            // Multi-line array with header
            self.write_str(&format!("[{}]", arr.len()))?;
            self.write_newline()?;
            
            self.indent_level += 1;
            for v in arr {
                self.write_indent()?;
                self.write_str("- ")?;
                self.encode_value(v)?;
                self.write_newline()?;
            }
            self.indent_level -= 1;
        }
        
        Ok(())
    }

    /// Encode object value
    fn encode_object(&mut self, obj: &std::collections::BTreeMap<String, ToonValue>) -> Result<(), ToonEncodeError> {
        if obj.is_empty() {
            // Empty object: {}
            self.write_str("{}")?;
            return Ok(());
        }

        // Multi-line object
        self.write_newline()?;
        self.indent_level += 1;
        
        for (key, value) in obj {
            self.write_indent()?;
            self.encode_string(key)?;
            self.write_str(": ")?;
            self.encode_value(value)?;
            self.write_newline()?;
        }
        
        self.indent_level -= 1;
        Ok(())
    }

    /// Write indentation
    fn write_indent(&mut self) -> Result<(), ToonEncodeError> {
        let spaces = " ".repeat(self.indent_level * self.options.indent_spaces);
        self.write_str(&spaces)
    }

    /// Write a string
    fn write_str(&mut self, s: &str) -> Result<(), ToonEncodeError> {
        self.output.push_str(s);
        Ok(())
    }

    /// Write a single character
    fn write_char(&mut self, c: char) -> Result<(), ToonEncodeError> {
        self.output.push(c);
        Ok(())
    }

    /// Write a newline
    fn write_newline(&mut self) -> Result<(), ToonEncodeError> {
        self.write_char('\n')
    }
}

impl Default for ToonEncoder {
    fn default() -> Self {
        Self::new()
    }
}

/// Convenience function to encode a TOON value to a string
pub fn to_string(value: &ToonValue) -> Result<String, ToonEncodeError> {
    let mut encoder = ToonEncoder::new();
    encoder.encode(value)
}

/// Convenience function to encode a TOON value with custom options
pub fn to_string_with_options(value: &ToonValue, options: ToonEncodeOptions) -> Result<String, ToonEncodeError> {
    let mut encoder = ToonEncoder::with_options(options);
    encoder.encode(value)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::internal::toon::types::ToonValue;

    #[test]
    fn test_encode_null() {
        let value = ToonValue::null();
        let result = to_string(&value).unwrap();
        assert_eq!(result, "null");
    }

    #[test]
    fn test_encode_bool() {
        assert_eq!(to_string(&ToonValue::bool(true)).unwrap(), "true");
        assert_eq!(to_string(&ToonValue::bool(false)).unwrap(), "false");
    }

    #[test]
    fn test_encode_number() {
        assert_eq!(to_string(&ToonValue::number("42")).unwrap(), "42");
        assert_eq!(to_string(&ToonValue::number("3.14")).unwrap(), "3.14");
        assert_eq!(to_string(&ToonValue::number("-1")).unwrap(), "-1");
    }

    #[test]
    fn test_encode_string() {
        assert_eq!(to_string(&ToonValue::string("hello")).unwrap(), "hello");
        assert_eq!(to_string(&ToonValue::string("hello world")).unwrap(), "\"hello world\"");
        assert_eq!(to_string(&ToonValue::string("true")).unwrap(), "\"true\"");
    }

    #[test]
    fn test_encode_string_escapes() {
        assert_eq!(to_string(&ToonValue::string("hello\nworld")).unwrap(), "\"hello\\nworld\"");
        assert_eq!(to_string(&ToonValue::string("quote\"test")).unwrap(), "\"quote\\\"test\"");
    }

    #[test]
    fn test_encode_empty_array() {
        let value = ToonValue::array(vec![]);
        let result = to_string(&value).unwrap();
        assert_eq!(result, "[]");
    }

    #[test]
    fn test_encode_inline_array() {
        let value = ToonValue::array(vec![
            ToonValue::number("1"),
            ToonValue::number("2"),
            ToonValue::number("3"),
        ]);
        let result = to_string(&value).unwrap();
        assert_eq!(result, "[1, 2, 3]");
    }

    #[test]
    fn test_encode_multiline_array() {
        let value = ToonValue::array(vec![
            ToonValue::object({
                let mut map = std::collections::BTreeMap::new();
                map.insert("name".to_string(), ToonValue::string("Alice"));
                map.insert("age".to_string(), ToonValue::number("30"));
                map
            }),
        ]);
        let result = to_string(&value).unwrap();
        assert!(result.starts_with("[1]"));
        assert!(result.contains("- name: Alice"));
    }

    #[test]
    fn test_encode_empty_object() {
        let value = ToonValue::object(std::collections::BTreeMap::new());
        let result = to_string(&value).unwrap();
        assert_eq!(result, "{}");
    }

    #[test]
    fn test_encode_object() {
        let mut obj = std::collections::BTreeMap::new();
        obj.insert("name".to_string(), ToonValue::string("Alice"));
        obj.insert("age".to_string(), ToonValue::number("30"));
        
        let value = ToonValue::object(obj);
        let result = to_string(&value).unwrap();
        assert!(result.contains("name: Alice"));
        assert!(result.contains("age: 30"));
    }
}
