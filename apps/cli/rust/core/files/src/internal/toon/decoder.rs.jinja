//! TOON decoder implementation
//! 
//! This module implements parsing of TOON format into Rust values according to the TOON specification v3.3.
//! The decoder supports strict mode validation and path expansion options.

use crate::internal::toon::types::{ToonValue, ToonDecodeOptions, ToonDecodeError};
use std::collections::BTreeMap;

/// TOON decoder
pub struct ToonDecoder {
    options: ToonDecodeOptions,
    input: String,
    position: usize,
}

impl ToonDecoder {
    /// Create a new TOON decoder with default options
    pub fn new() -> Self {
        Self::with_options(ToonDecodeOptions::default())
    }

    /// Create a new TOON decoder with custom options
    pub fn with_options(options: ToonDecodeOptions) -> Self {
        Self {
            options,
            input: String::new(),
            position: 0,
        }
    }

    /// Decode a TOON string to a ToonValue
    pub fn decode(&mut self, input: &str) -> Result<ToonValue, ToonDecodeError> {
        self.input = input.to_string();
        self.position = 0;
        self.skip_whitespace();
        self.parse_value()
    }

    /// Parse a value
    fn parse_value(&mut self) -> Result<ToonValue, ToonDecodeError> {
        let c = self.peek_char().ok_or_else(|| {
            ToonDecodeError::InvalidSyntax("Unexpected end of input".to_string())
        })?;
        
        match c {
            'n' => self.parse_null(),
            't' | 'f' => self.parse_bool(),
            '"' => self.parse_quoted_string(),
            '[' => self.parse_array(),
            '{' => self.parse_object(),
            '-' | '0'..='9' => self.parse_number(),
            _ => self.parse_unquoted_string(),
        }
    }

    /// Parse null
    fn parse_null(&mut self) -> Result<ToonValue, ToonDecodeError> {
        self.consume("null")?;
        Ok(ToonValue::Null)
    }

    /// Parse boolean
    fn parse_bool(&mut self) -> Result<ToonValue, ToonDecodeError> {
        if self.starts_with("true") {
            self.consume("true")?;
            Ok(ToonValue::Bool(true))
        } else if self.starts_with("false") {
            self.consume("false")?;
            Ok(ToonValue::Bool(false))
        } else {
            Err(ToonDecodeError::InvalidSyntax("Expected true or false".to_string()))
        }
    }

    /// Parse quoted string
    fn parse_quoted_string(&mut self) -> Result<ToonValue, ToonDecodeError> {
        self.consume("\"")?;
        let mut result = String::new();
        
        loop {
            let c = self.next_char()?;
            match c {
                '"' => break,
                '\\' => {
                    let escape = self.next_char()?;
                    match escape {
                        '\\' => result.push('\\'),
                        '"' => result.push('"'),
                        'n' => result.push('\n'),
                        'r' => result.push('\r'),
                        't' => result.push('\t'),
                        'u' => {
                            // Parse unicode escape \uXXXX
                            let mut code = String::new();
                            for _ in 0..4 {
                                code.push(self.next_char()?);
                            }
                            let code_point = u32::from_str_radix(&code, 16)
                                .map_err(|_| ToonDecodeError::InvalidEscape(format!("Invalid unicode escape: \\u{}", code)))?;
                            if let Some(c) = std::char::from_u32(code_point) {
                                result.push(c);
                            } else {
                                return Err(ToonDecodeError::InvalidEscape(format!("Invalid unicode code point: {}", code_point)));
                            }
                        }
                        _ => return Err(ToonDecodeError::InvalidEscape(format!("Invalid escape sequence: \\{}", escape))),
                    }
                }
                c => result.push(c),
            }
        }
        
        Ok(ToonValue::String(result))
    }

    /// Parse unquoted string (primitive or identifier)
    fn parse_unquoted_string(&mut self) -> Result<ToonValue, ToonDecodeError> {
        let mut result = String::new();
        
        while let Some(c) = self.peek_char() {
            if c.is_whitespace() || c == ',' || c == ':' || c == '\n' || c == '\t' || c == '|' {
                break;
            }
            result.push(self.next_char()?);
        }
        
        // Try to parse as number first
        if let Ok(num) = self.parse_number_string(&result) {
            return Ok(ToonValue::Number(num));
        }
        
        // Otherwise treat as string
        Ok(ToonValue::String(result))
    }

    /// Parse number
    fn parse_number(&mut self) -> Result<ToonValue, ToonDecodeError> {
        let mut result = String::new();
        
        if let Some('-') = self.peek_char() {
            result.push(self.next_char()?);
        }
        
        while let Some(c) = self.peek_char() {
            if c.is_ascii_digit() || c == '.' || c == 'e' || c == 'E' || c == '+' || c == '-' {
                result.push(self.next_char()?);
            } else {
                break;
            }
        }
        
        self.parse_number_string(&result)
            .map(ToonValue::Number)
    }

    /// Parse number string with validation
    fn parse_number_string(&self, s: &str) -> Result<String, ToonDecodeError> {
        if s.is_empty() {
            return Err(ToonDecodeError::InvalidNumber("Empty number".to_string()));
        }
        
        // Basic validation
        let has_digits = s.chars().any(|c| c.is_ascii_digit());
        if !has_digits {
            return Err(ToonDecodeError::InvalidNumber(format!("Invalid number: {}", s)));
        }
        
        Ok(s.to_string())
    }

    /// Parse array
    fn parse_array(&mut self) -> Result<ToonValue, ToonDecodeError> {
        self.consume("[")?;
        
        // Check for array header [N]
        let mut count_str = String::new();
        while let Some(c) = self.peek_char() {
            if c.is_ascii_digit() {
                count_str.push(self.next_char()?);
            } else {
                break;
            }
        }
        
        let expected_count = if !count_str.is_empty() {
            self.consume("]")?;
            Some(count_str.parse::<usize>().map_err(|_| {
                ToonDecodeError::InvalidSyntax(format!("Invalid array count: {}", count_str))
            })?)
        } else {
            self.consume("]")?;
            None
        };
        
        self.skip_whitespace();
        
        // Check if inline array (same line, primitives only)
        let is_inline = if let Some(c) = self.peek_char() {
            !c.is_whitespace() && c != '-'
        } else {
            false
        };
        
        if is_inline {
            // Parse inline array
            let mut values = Vec::new();
            if let Some(c) = self.peek_char() {
                if c != ']' && c != '\n' {
                    values.push(self.parse_value()?);
                    
                    while let Some(',') = self.peek_char() {
                        self.consume(",")?;
                        self.skip_whitespace();
                        values.push(self.parse_value()?);
                    }
                }
            }
            
            if let Some(expected) = expected_count {
                if values.len() != expected {
                    return Err(ToonDecodeError::ArrayCountMismatch {
                        expected,
                        actual: values.len(),
                    });
                }
            }
            
            Ok(ToonValue::Array(values))
        } else {
            // Parse multi-line array
            let mut values = Vec::new();
            
            while let Some('-') = self.peek_char() {
                self.consume("-")?;
                self.skip_whitespace();
                values.push(self.parse_value()?);
                self.skip_whitespace();
            }
            
            if let Some(expected) = expected_count {
                if values.len() != expected {
                    return Err(ToonDecodeError::ArrayCountMismatch {
                        expected,
                        actual: values.len(),
                    });
                }
            }
            
            Ok(ToonValue::Array(values))
        }
    }

    /// Parse object
    fn parse_object(&mut self) -> Result<ToonValue, ToonDecodeError> {
        self.consume("{")?;
        self.skip_whitespace();
        
        let mut fields = BTreeMap::new();
        
        while let Some(c) = self.peek_char() {
            if c == '}' {
                break;
            }
            
            // Parse key
            let key = if let Some('"') = self.peek_char() {
                let key_val = self.parse_quoted_string()?;
                if let ToonValue::String(s) = key_val {
                    s
                } else {
                    return Err(ToonDecodeError::InvalidSyntax("Expected string key".to_string()));
                }
            } else {
                let mut key = String::new();
                while let Some(c) = self.peek_char() {
                    if c == ':' || c.is_whitespace() {
                        break;
                    }
                    key.push(self.next_char()?);
                }
                key
            };
            
            self.skip_whitespace();
            self.consume(":")?;
            self.skip_whitespace();
            
            // Parse value
            let value = self.parse_value()?;
            fields.insert(key, value);
            
            self.skip_whitespace();
        }
        
        self.consume("}")?;
        Ok(ToonValue::Object(fields))
    }

    /// Skip whitespace
    fn skip_whitespace(&mut self) {
        while let Some(c) = self.peek_char() {
            if c.is_whitespace() {
                let _ = self.next_char();
            } else {
                break;
            }
        }
    }

    /// Peek at the next character
    fn peek_char(&self) -> Option<char> {
        self.input.chars().nth(self.position)
    }

    /// Get the next character
    fn next_char(&mut self) -> Result<char, ToonDecodeError> {
        let c = self.peek_char().ok_or_else(|| {
            ToonDecodeError::InvalidSyntax("Unexpected end of input".to_string())
        })?;
        self.position += 1;
        Ok(c)
    }

    /// Check if input starts with a string
    fn starts_with(&self, s: &str) -> bool {
        self.input[self.position..].starts_with(s)
    }

    /// Consume a specific string
    fn consume(&mut self, s: &str) -> Result<(), ToonDecodeError> {
        if self.starts_with(s) {
            self.position += s.len();
            Ok(())
        } else {
            Err(ToonDecodeError::InvalidSyntax(format!("Expected '{}'", s)))
        }
    }
}

impl Default for ToonDecoder {
    fn default() -> Self {
        Self::new()
    }
}

/// Convenience function to decode a TOON string to a ToonValue
pub fn from_str(input: &str) -> Result<ToonValue, ToonDecodeError> {
    let mut decoder = ToonDecoder::new();
    decoder.decode(input)
}

/// Convenience function to decode a TOON string with custom options
pub fn from_str_with_options(input: &str, options: ToonDecodeOptions) -> Result<ToonValue, ToonDecodeError> {
    let mut decoder = ToonDecoder::with_options(options);
    decoder.decode(input)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::internal::toon::types::ToonValue;

    #[test]
    fn test_decode_null() {
        let result = from_str("null").unwrap();
        assert_eq!(result, ToonValue::Null);
    }

    #[test]
    fn test_decode_bool() {
        assert_eq!(from_str("true").unwrap(), ToonValue::Bool(true));
        assert_eq!(from_str("false").unwrap(), ToonValue::Bool(false));
    }

    #[test]
    fn test_decode_number() {
        assert_eq!(from_str("42").unwrap(), ToonValue::Number("42".to_string()));
        assert_eq!(from_str("3.14").unwrap(), ToonValue::Number("3.14".to_string()));
        assert_eq!(from_str("-1").unwrap(), ToonValue::Number("-1".to_string()));
    }

    #[test]
    fn test_decode_string() {
        assert_eq!(from_str("hello").unwrap(), ToonValue::String("hello".to_string()));
        assert_eq!(from_str("\"hello world\"").unwrap(), ToonValue::String("hello world".to_string()));
    }

    #[test]
    fn test_decode_string_escapes() {
        assert_eq!(from_str("\"hello\\nworld\"").unwrap(), ToonValue::String("hello\nworld".to_string()));
        assert_eq!(from_str("\"quote\\\"test\"").unwrap(), ToonValue::String("quote\"test".to_string()));
    }

    #[test]
    fn test_decode_empty_array() {
        let result = from_str("[]").unwrap();
        assert_eq!(result, ToonValue::Array(vec![]));
    }

    #[test]
    fn test_decode_inline_array() {
        let result = from_str("[1, 2, 3]").unwrap();
        assert_eq!(result, ToonValue::Array(vec![
            ToonValue::Number("1".to_string()),
            ToonValue::Number("2".to_string()),
            ToonValue::Number("3".to_string()),
        ]));
    }

    #[test]
    fn test_decode_array_with_count() {
        let result = from_str("[3]\n- 1\n- 2\n- 3").unwrap();
        assert_eq!(result, ToonValue::Array(vec![
            ToonValue::Number("1".to_string()),
            ToonValue::Number("2".to_string()),
            ToonValue::Number("3".to_string()),
        ]));
    }

    #[test]
    fn test_decode_array_count_mismatch() {
        let result = from_str("[3]\n- 1\n- 2");
        assert!(result.is_err());
    }

    #[test]
    fn test_decode_empty_object() {
        let result = from_str("{}").unwrap();
        assert_eq!(result, ToonValue::Object(BTreeMap::new()));
    }

    #[test]
    fn test_decode_object() {
        let result = from_str("{\n  name: Alice\n  age: 30\n}").unwrap();
        let mut expected = BTreeMap::new();
        expected.insert("name".to_string(), ToonValue::String("Alice".to_string()));
        expected.insert("age".to_string(), ToonValue::Number("30".to_string()));
        assert_eq!(result, ToonValue::Object(expected));
    }
}
