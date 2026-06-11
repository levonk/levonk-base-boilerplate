//! Tests for content selection and state summary

use super::*;
use crate::internal::aggregates::{CountInfo, DerivedStatus};

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_content_context_detection() {
        let context = ContentContext::detect();
        // Should not panic and should return a valid context
        assert!(!context.cwd.is_empty());
    }

    #[test]
    fn test_content_selector_creation() {
        let context = ContentContext::detect();
        let selector = ContentSelector::new(context);
        // Should not panic
        let content_type = selector.select_content_type();
        // Should return a valid content type
        match content_type {
            ContentType::ProjectState
            | ContentType::ProjectOverview
            | ContentType::StateOnly
            | ContentType::GeneralHelp => {}
        }
    }

    #[test]
    fn test_content_selector_suggestions() {
        let context = ContentContext::detect();
        let selector = ContentSelector::new(context);
        let suggestions = selector.get_suggestions();
        // Should always include at least the help suggestion
        assert!(!suggestions.is_empty());
        assert!(suggestions.iter().any(|s| s.contains("--help")));
    }

    #[test]
    fn test_select_content_function() {
        let (content_type, suggestions) = select_content();
        // Should return valid content type and suggestions
        match content_type {
            ContentType::ProjectState
            | ContentType::ProjectOverview
            | ContentType::StateOnly
            | ContentType::GeneralHelp => {}
        }
        assert!(!suggestions.is_empty());
    }

    #[test]
    fn test_state_summary_creation() {
        let summary = StateSummary::new(
            "test_content".to_string(),
            AggregateInfo::empty(),
            "/test/path".to_string(),
            vec![("key".to_string(), "value".to_string())],
        );
        assert_eq!(summary.content_type, "test_content");
        assert_eq!(summary.cwd, "/test/path");
        assert_eq!(summary.context.len(), 1);
    }

    #[test]
    fn test_state_summary_generate() {
        let aggregates = AggregateInfo::with_count(CountInfo {
            total: 100,
            current: 10,
        });
        let summary = generate_summary("test_type", aggregates);
        assert_eq!(summary.content_type, "test_type");
        assert!(!summary.cwd.is_empty());
    }

    #[test]
    fn test_state_summary_format_toon() {
        let summary = StateSummary::new(
            "test".to_string(),
            AggregateInfo::empty(),
            "/test".to_string(),
            vec![],
        );
        let output = summary.format_toon();
        assert!(output.contains("content_type: test"));
        assert!(output.contains("cwd: /test"));
    }

    #[test]
    fn test_state_summary_format_human() {
        let summary = StateSummary::new(
            "test".to_string(),
            AggregateInfo::empty(),
            "/test".to_string(),
            vec![],
        );
        let output = summary.format_human();
        assert!(output.contains("test"));
        assert!(output.contains("Location: /test"));
    }

    #[test]
    fn test_content_first_output_format_toon() {
        let summary = StateSummary::new(
            "test".to_string(),
            AggregateInfo::empty(),
            "/test".to_string(),
            vec![],
        );
        let suggestions = vec!["cmd1".to_string(), "cmd2".to_string()];
        let output = ContentFirstOutput::new(summary, suggestions, true);
        let formatted = output.format();
        assert!(formatted.contains("content_type: test"));
        assert!(formatted.contains("help[2]"));
    }

    #[test]
    fn test_content_first_output_format_human() {
        let summary = StateSummary::new(
            "test".to_string(),
            AggregateInfo::empty(),
            "/test".to_string(),
            vec![],
        );
        let suggestions = vec!["cmd1".to_string(), "cmd2".to_string()];
        let output = ContentFirstOutput::new(summary, suggestions, false);
        let formatted = output.format();
        assert!(formatted.contains("test"));
        assert!(formatted.contains("Suggested commands:"));
    }
}
