package com.adtracker.videoenrichment;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ApplicationContext;
import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Integration tests for the Video Enrichment Service application.
 *
 * These tests verify that the Spring application context loads successfully
 * and all beans are properly configured.
 */
@SpringBootTest
@ActiveProfiles("test")
class VideoEnrichmentApplicationTests {

    @Autowired
    private ApplicationContext applicationContext;

    /**
     * Test that the Spring application context loads successfully.
     * This verifies all Spring beans are properly configured and autowired.
     */
    @Test
    void contextLoads() {
        // If the application context fails to load, this test will fail
        // This is a basic smoke test to ensure the application starts correctly
        assertThat(applicationContext).isNotNull();
    }

    /**
     * Test that the main application bean is created and configured.
     */
    @Test
    void applicationBeanExists() {
        assertThat(applicationContext.containsBean("videoEnrichmentApplication")).isTrue();
    }

    /**
     * Test that the application name is correctly configured.
     */
    @Test
    void applicationNameIsConfigured() {
        String applicationName = applicationContext.getEnvironment()
            .getProperty("spring.application.name");
        assertThat(applicationName).isEqualTo("video-enrichment-service-test");
    }
}
