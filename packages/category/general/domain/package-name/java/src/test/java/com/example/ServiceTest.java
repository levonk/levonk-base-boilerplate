package com.example.{{package_name}};

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.junit.jupiter.api.Assertions.*;

class ServiceTest {
    private static final Logger logger = LoggerFactory.getLogger(ServiceTest.class);
    
    private Service service;
    
    @BeforeEach
    void setUp() {
        logger.info("Setting up test service");
        service = new Service();
    }
    
    @Test
    void testProcess() {
        logger.info("Testing process method");
        
        String input = "hello";
        String context = "test-context";
        String expected = "HELLO";
        
        String result = service.process(input, context);
        
        assertEquals(expected, result, "Process should convert input to uppercase");
        logger.info("Process test passed: {} -> {}", input, result);
    }
    
    @Test
    void testProcessWithEmptyInput() {
        logger.info("Testing process method with empty input");
        
        String input = "";
        String context = "test-context";
        String expected = "";
        
        String result = service.process(input, context);
        
        assertEquals(expected, result, "Process should handle empty input");
        logger.info("Empty input test passed");
    }
    
    @Test
    void testMultiplyByTwo() {
        logger.info("Testing multiplyByTwo method");
        
        int input = 5;
        int expected = 10;
        
        int result = service.multiplyByTwo(input);
        
        assertEquals(expected, result, "Multiply by two should work correctly");
        logger.info("Multiply test passed: {} -> {}", input, result);
    }
    
    @Test
    void testMultiplyByTwoWithZero() {
        logger.info("Testing multiplyByTwo method with zero");
        
        int input = 0;
        int expected = 0;
        
        int result = service.multiplyByTwo(input);
        
        assertEquals(expected, result, "Multiply by two should handle zero");
        logger.info("Zero multiplication test passed");
    }
    
    @Test
    void testMultiplyByTwoWithNegative() {
        logger.info("Testing multiplyByTwo method with negative number");
        
        int input = -3;
        int expected = -6;
        
        int result = service.multiplyByTwo(input);
        
        assertEquals(expected, result, "Multiply by two should handle negative numbers");
        logger.info("Negative multiplication test passed: {} -> {}", input, result);
    }
    
    @Test
    void testServiceCreation() {
        logger.info("Testing service creation");
        
        Service newService = new Service();
        
        assertNotNull(newService, "Service should be created successfully");
        logger.info("Service creation test passed");
    }
}
