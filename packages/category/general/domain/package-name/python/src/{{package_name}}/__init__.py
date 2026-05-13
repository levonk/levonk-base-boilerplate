"""
{{package_description}}
Author: {{author_name}} <{{author_email}}>
License: {{license}}
"""

import logging
from typing import Any

# Configure module logger
logger = logging.getLogger(__name__)


class Service:
    """Sample service class demonstrating basic functionality and logging."""
    
    def __init__(self):
        """Initialize the service with a logger."""
        self.logger = logger
    
    def process(self, input_data: str, context: str) -> str:
        """
        Process the given input with context-aware logging.
        
        Args:
            input_data: The input string to process
            context: Processing context information
            
        Returns:
            Processed result string
            
        Raises:
            RuntimeError: If processing fails
        """
        self.logger.info("Starting process with context: %s", context)
        self.logger.debug("Input received: %s", input_data)
        
        try:
            result = input_data.upper()
            self.logger.info("Processing completed successfully")
            return result
        except Exception as e:
            self.logger.error("Processing failed", exc_info=True)
            raise RuntimeError("Processing failed") from e
    
    def multiply_by_two(self, value: int) -> int:
        """
        Multiply the given number by two.
        
        Args:
            value: The number to multiply
            
        Returns:
            The result of multiplication
        """
        self.logger.debug("Multiplying %d by 2", value)
        return value * 2


def create_service() -> Service:
    """
    Factory function to create a Service instance.
    
    Returns:
        A new Service instance
    """
    return Service()


# Module-level convenience functions
def process(input_data: str, context: str) -> str:
    """
    Convenience function for processing data.
    
    Args:
        input_data: The input string to process
        context: Processing context information
        
    Returns:
        Processed result string
    """
    service = create_service()
    return service.process(input_data, context)


def multiply_by_two(value: int) -> int:
    """
    Convenience function for multiplication.
    
    Args:
        value: The number to multiply
        
    Returns:
        The result of multiplication
    """
    service = create_service()
    return service.multiply_by_two(value)


__all__ = [
    "Service",
    "create_service", 
    "process",
    "multiply_by_two"
]

# vim: set ft=python:
