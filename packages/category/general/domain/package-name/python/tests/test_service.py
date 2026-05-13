"""Tests for the {{package_name}} service."""

import unittest
import logging
from unittest.mock import patch, MagicMock

from {{package_name}} import Service, process, multiply_by_two


class TestService(unittest.TestCase):
    """Test cases for the Service class."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.service = Service()
        # Capture log output for testing
        self.logger = logging.getLogger('{{package_name}}')
        self.logger.setLevel(logging.DEBUG)
    
    def test_service_initialization(self):
        """Test that Service initializes correctly."""
        service = Service()
        self.assertIsNotNone(service)
        self.assertEqual(service.logger.name, '{{package_name}}')
    
    def test_process_basic(self):
        """Test basic process functionality."""
        input_data = "hello"
        context = "test-context"
        expected = "HELLO"
        
        result = self.service.process(input_data, context)
        
        self.assertEqual(result, expected)
    
    def test_process_empty_string(self):
        """Test process with empty string."""
        input_data = ""
        context = "test-context"
        expected = ""
        
        result = self.service.process(input_data, context)
        
        self.assertEqual(result, expected)
    
    def test_process_special_characters(self):
        """Test process with special characters."""
        input_data = "hello@world#123"
        context = "test-context"
        expected = "HELLO@WORLD#123"
        
        result = self.service.process(input_data, context)
        
        self.assertEqual(result, expected)
    
    def test_process_with_logging(self):
        """Test that process method logs correctly."""
        with patch.object(self.service.logger, 'info') as mock_info:
            input_data = "test"
            context = "test-context"
            
            self.service.process(input_data, context)
            
            mock_info.assert_called()
            # Check that the log contains expected information
            call_args = mock_info.call_args[0][0]
            self.assertIn("Processing", call_args)
            self.assertIn(input_data, call_args)
            self.assertIn(context, call_args)
    
    def test_multiply_by_two_basic(self):
        """Test basic multiply_by_two functionality."""
        value = 5
        expected = 10
        
        result = self.service.multiply_by_two(value)
        
        self.assertEqual(result, expected)
    
    def test_multiply_by_two_zero(self):
        """Test multiply_by_two with zero."""
        value = 0
        expected = 0
        
        result = self.service.multiply_by_two(value)
        
        self.assertEqual(result, expected)
    
    def test_multiply_by_two_negative(self):
        """Test multiply_by_two with negative numbers."""
        value = -3
        expected = -6
        
        result = self.service.multiply_by_two(value)
        
        self.assertEqual(result, expected)
    
    def test_multiply_by_two_large_number(self):
        """Test multiply_by_two with large numbers."""
        value = 1000000
        expected = 2000000
        
        result = self.service.multiply_by_two(value)
        
        self.assertEqual(result, expected)
    
    def test_multiply_by_two_with_logging(self):
        """Test that multiply_by_two method logs correctly."""
        with patch.object(self.service.logger, 'info') as mock_info:
            value = 5
            
            self.service.multiply_by_two(value)
            
            mock_info.assert_called()
            # Check that the log contains expected information
            call_args = mock_info.call_args[0][0]
            self.assertIn("Multiplying", call_args)
            self.assertIn(str(value), call_args)


class TestConvenienceFunctions(unittest.TestCase):
    """Test cases for convenience functions."""
    
    def test_process_function(self):
        """Test the process convenience function."""
        input_data = "hello"
        context = "test-context"
        expected = "HELLO"
        
        result = process(input_data, context)
        
        self.assertEqual(result, expected)
    
    def test_multiply_by_two_function(self):
        """Test the multiply_by_two convenience function."""
        value = 5
        expected = 10
        
        result = multiply_by_two(value)
        
        self.assertEqual(result, expected)


class TestLoggingConfiguration(unittest.TestCase):
    """Test cases for logging configuration."""
    
    def test_logger_configuration(self):
        """Test that logger is configured correctly."""
        service = Service()
        
        # Check that logger has the expected name
        self.assertEqual(service.logger.name, '{{package_name}}')
        
        # Check that logger is a Logger instance
        self.assertIsInstance(service.logger, logging.Logger)
    
    @patch('logging.getLogger')
    def test_logger_creation(self, mock_get_logger):
        """Test that logger is created correctly."""
        mock_logger = MagicMock()
        mock_get_logger.return_value = mock_logger
        
        service = Service()
        
        mock_get_logger.assert_called_once_with('{{package_name}}')
        self.assertEqual(service.logger, mock_logger)


if __name__ == '__main__':
    # Configure logging for tests
    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    
    unittest.main()

# vim: set ft=python:
