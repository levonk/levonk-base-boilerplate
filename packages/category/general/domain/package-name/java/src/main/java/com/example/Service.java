package com.example.{{package_name}};

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Sample service class demonstrating basic functionality and logging.
 */
public class Service {
    private static final Logger logger = LoggerFactory.getLogger(Service.class);

    /**
     * Processes the given input with context-aware logging.
     *
     * @param input the input string to process
     * @param context processing context information
     * @return processed result
     */
    public String process(String input, String context) {
        logger.info("Starting process with context: {}", context);
        logger.debug("Input received: {}", input);
        
        try {
            String result = input.toUpperCase();
            logger.info("Processing completed successfully");
            return result;
        } catch (Exception e) {
            logger.error("Processing failed", e);
            throw new RuntimeException("Processing failed", e);
        }
    }

    /**
     * Multiplies the given number by two.
     *
     * @param value the number to multiply
     * @return the result of multiplication
     */
    public int multiplyByTwo(int value) {
        logger.debug("Multiplying {} by 2", value);
        return value * 2;
    }
}
