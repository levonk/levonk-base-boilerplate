//! TOON data types and structures
//! 
//! This module defines the core data structures for representing TOON (Token-Oriented Object Notation) values.
//! TOON is a line-oriented, indentation-based notation that provides ~40% token savings over JSON.

use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

/// Represents a TOON value
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum ToonValue {
    /// Null value
    Null,
    /// Boolean value
    Bool(bool),
    /// Number value (stored as string to preserve exact formatting)
    Number(String),
    /// String value
    String(String),
    /// Array of values
    Array(Vec<ToonValue>),
    /// Object with string keys and TOON values (BTreeMap preserves key order)
    Object(BTreeMap<String, ToonValue>),
}

impl ToonValue {
    /// Create a null value
    pub fn null() -> Self {
        ToonValue::Null
    }

    /// Create a boolean value
    pub fn bool(value: bool) -> Self {
        ToonValue::Bool(value)
    }

    /// Create a number value from a string
    pub fn number(value: impl Into<String>) -> Self {
        ToonValue::Number(value.into())
    }

    /// Create a string value
    pub fn string(value: impl Into<String>) -> Self {
        ToonValue::String(value.into())
    }

    /// Create an array value
    pub fn array(values: Vec<ToonValue>) -> Self {
        ToonValue::Array(values)
    }

    /// Create an object value
    pub fn object(fields: BTreeMap<String, ToonValue>) -> Self {
        ToonValue::Object(fields)
    }

    /// Check if the value is null
    pub fn is_null(&self) -> bool {
        matches!(self, ToonValue::Null)
    }

    /// Check if the value is a boolean
    pub fn is_bool(&self) -> bool {
        matches!(self, ToonValue::Bool(_))
    }

    /// Check if the value is a number
    pub fn is_number(&self) -> bool {
        matches!(self, ToonValue::Number(_))
    }

    /// Check if the value is a string
    pub fn is_string(&self) -> bool {
        matches!(self, ToonValue::String(_))
    }

    /// Check if the value is an array
    pub fn is_array(&self) -> bool {
        matches!(self, ToonValue::Array(_))
    }

    /// Check if the value is an object
    pub fn is_object(&self) -> bool {
        matches!(self, ToonValue::Object(_))
    }
}

/// TOON encoding options
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ToonEncodeOptions {
    /// Number of spaces for indentation (default: 2)
    pub indent_spaces: usize,
    /// Whether to enable key folding (default: false)
    pub key_folding: bool,
    /// Maximum depth for key folding (default: None = unlimited)
    pub flatten_depth: Option<usize>,
}

impl Default for ToonEncodeOptions {
    fn default() -> Self {
        Self {
            indent_spaces: 2,
            key_folding: false,
            flatten_depth: None,
        }
    }
}

/// TOON decoding options
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ToonDecodeOptions {
    /// Whether to enable strict mode validation (default: true)
    pub strict: bool,
    /// Whether to enable path expansion (default: false)
    pub expand_paths: bool,
}

impl Default for ToonDecodeOptions {
    fn default() -> Self {
        Self {
            strict: true,
            expand_paths: false,
        }
    }
}

/// TOON encoding error
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ToonEncodeError {
    /// Invalid number format
    InvalidNumber(String),
    /// String contains invalid characters
    InvalidString(String),
    /// Key folding collision detected
    KeyFoldingCollision(String),
    /// Other encoding error
    Other(String),
}

impl std::fmt::Display for ToonEncodeError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ToonEncodeError::InvalidNumber(msg) => write!(f, "Invalid number: {}", msg),
            ToonEncodeError::InvalidString(msg) => write!(f, "Invalid string: {}", msg),
            ToonEncodeError::KeyFoldingCollision(key) => write!(f, "Key folding collision: {}", key),
            ToonEncodeError::Other(msg) => write!(f, "Encoding error: {}", msg),
        }
    }
}

impl std::error::Error for ToonEncodeError {}

/// TOON decoding error
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ToonDecodeError {
    /// Invalid syntax
    InvalidSyntax(String),
    /// Invalid escape sequence
    InvalidEscape(String),
    /// Array count mismatch
    ArrayCountMismatch { expected: usize, actual: usize },
    /// Invalid number format
    InvalidNumber(String),
    /// Strict mode violation
    StrictModeViolation(String),
    /// Path expansion conflict
    PathExpansionConflict(String),
    /// Other decoding error
    Other(String),
}

impl std::fmt::Display for ToonDecodeError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ToonDecodeError::InvalidSyntax(msg) => write!(f, "Invalid syntax: {}", msg),
            ToonDecodeError::InvalidEscape(msg) => write!(f, "Invalid escape sequence: {}", msg),
            ToonDecodeError::ArrayCountMismatch { expected, actual } => {
                write!(f, "Array count mismatch: expected {}, got {}", expected, actual)
            }
            ToonDecodeError::InvalidNumber(msg) => write!(f, "Invalid number: {}", msg),
            ToonDecodeError::StrictModeViolation(msg) => write!(f, "Strict mode violation: {}", msg),
            ToonDecodeError::PathExpansionConflict(msg) => write!(f, "Path expansion conflict: {}", msg),
            ToonDecodeError::Other(msg) => write!(f, "Decoding error: {}", msg),
        }
    }
}

impl std::error::Error for ToonDecodeError {}
