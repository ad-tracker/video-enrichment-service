package com.adtracker.videoenrichment;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Main application class for the Video Enrichment Service.
 *
 * This service is responsible for enriching YouTube video data by:
 * - Fetching video metadata from YouTube Data API
 * - Analyzing video transcripts
 * - Detecting and cataloging advertisements
 * - Persisting enriched data to PostgreSQL
 *
 * Built with Spring Boot 4.0.0-RC2 and Java 25 with virtual threads support
 * for improved scalability and performance.
 */
@SpringBootApplication
public class VideoEnrichmentApplication {

    public static void main(String[] args) {
        SpringApplication.run(VideoEnrichmentApplication.class, args);
    }
}
