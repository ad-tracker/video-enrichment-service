# Video Enrichment Service

A production-ready Spring Boot 4.0.0-RC2 microservice for enriching YouTube video data with metadata, transcripts, and advertisement detection. Built with Java 25, this service fetches comprehensive video information from the YouTube Data API, analyzes content, and persists enriched data to PostgreSQL.

## Features

- **Modern Stack**: Spring Boot 4.0.0-RC2 with Java 25
- **Virtual Threads**: Leverages Java 25 virtual threads for improved scalability
- **YouTube Integration**: Comprehensive YouTube Data API v3 integration
- **Data Enrichment**: Fetches video metadata, statistics, and content details
- **Persistence**: PostgreSQL with JPA/Hibernate for data storage
- **Observability**: Actuator endpoints with Prometheus metrics
- **Production Ready**: Docker support, health checks, and comprehensive logging
- **High Test Coverage**: >80% code coverage with comprehensive unit tests
- **CI/CD Pipeline**: Automated testing and Docker image publishing to GitHub Container Registry

## Technology Stack

- **Framework**: Spring Boot 4.0.0-RC2
- **Language**: Java 25 (with virtual threads support)
- **Build Tool**: Gradle 8.14
- **Database**: PostgreSQL 16
- **Containerization**: Docker with multi-stage builds
- **CI/CD**: GitHub Actions

## Architecture

```
┌─────────────────────────────────┐
│   YouTube Data API              │
└──────────┬──────────────────────┘
           │ API Requests
           ▼
┌─────────────────────────────────┐
│  Video Enrichment Service       │
│                                  │
│  ┌──────────────────────────┐   │
│  │  EnrichmentController    │   │
│  └───────────┬──────────────┘   │
│              ▼                   │
│  ┌──────────────────────────┐   │
│  │  VideoEnrichmentService  │   │
│  └───────────┬──────────────┘   │
│              ▼                   │
│  ┌──────────────────────────┐   │
│  │  YouTubeApiClient        │   │
│  └──────────────────────────┘   │
│              │                   │
│              ▼                   │
│  ┌──────────────────────────┐   │
│  │  PostgreSQL              │   │
│  └──────────────────────────┘   │
└─────────────────────────────────┘
```

## Prerequisites

- **Java 25** (JDK with virtual threads support)
- **Docker** (for containerized deployment)
- **PostgreSQL 16+** (for local development)
- **YouTube Data API Key** (from Google Cloud Console)

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/video-enrichment-service.git
cd video-enrichment-service
```

### 2. Configure Environment Variables

Create a `.env` file or export the following environment variables:

```bash
# Database Configuration
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=adtracker
export DB_USERNAME=postgres
export DB_PASSWORD=your_password

# YouTube API Configuration
export YOUTUBE_API_KEY=your_youtube_api_key
```

### 3. Setup Database Schema

```sql
-- Connect to PostgreSQL and create schema
CREATE SCHEMA IF NOT EXISTS video_enrichment;

-- Create enriched_videos table
CREATE TABLE video_enrichment.enriched_videos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    video_id VARCHAR(50) NOT NULL UNIQUE,
    channel_id VARCHAR(50) NOT NULL,
    title VARCHAR(500),
    description TEXT,
    published_at TIMESTAMP,
    duration_seconds INTEGER,
    view_count BIGINT,
    like_count BIGINT,
    comment_count BIGINT,
    tags TEXT[],
    category_id VARCHAR(50),
    enrichment_status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    enrichment_started_at TIMESTAMP,
    enrichment_completed_at TIMESTAMP,
    enrichment_error TEXT,
    retry_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX idx_enriched_videos_video_id ON video_enrichment.enriched_videos(video_id);
CREATE INDEX idx_enriched_videos_channel_id ON video_enrichment.enriched_videos(channel_id);
CREATE INDEX idx_enriched_videos_status ON video_enrichment.enriched_videos(enrichment_status);
CREATE INDEX idx_enriched_videos_published_at ON video_enrichment.enriched_videos(published_at);
CREATE INDEX idx_enriched_videos_created_at ON video_enrichment.enriched_videos(created_at);
```

### 4. Build the Application

```bash
./gradlew clean build
```

### 5. Run the Application

#### Using Gradle

```bash
./gradlew bootRun
```

#### Using Java

```bash
java -jar build/libs/video-enrichment-service-0.0.1-SNAPSHOT.jar
```

#### Using Docker Compose

```bash
# Start all services (PostgreSQL + Application)
docker-compose up

# Run in detached mode
docker-compose up -d

# View logs
docker-compose logs -f video-enrichment-service

# Stop services
docker-compose down
```

#### Using Docker

```bash
# Build the Docker image
docker build -t video-enrichment-service:latest .

# Run the container
docker run -p 8080:8080 \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=5432 \
  -e DB_NAME=adtracker \
  -e DB_USERNAME=postgres \
  -e DB_PASSWORD=your_password \
  -e YOUTUBE_API_KEY=your_api_key \
  video-enrichment-service:latest
```

## API Endpoints

### Video Enrichment

**POST** `/api/v1/videos/enrich`

Enrich a YouTube video with metadata and statistics.

**Request Body:**
```json
{
  "videoId": "dQw4w9WgXcQ"
}
```

**Response (200 OK):**
```json
{
  "videoId": "dQw4w9WgXcQ",
  "title": "Rick Astley - Never Gonna Give You Up",
  "channelId": "UCuAXFkgsw1L7xaCfnd5JJOw",
  "description": "Official music video...",
  "publishedAt": "2009-10-25T06:57:33Z",
  "viewCount": 1400000000,
  "likeCount": 15000000,
  "status": "ENRICHED"
}
```

### Health Check

**GET** `/actuator/health`

Application health status.

**Response (200 OK):**
```json
{
  "status": "UP"
}
```

### Actuator Endpoints

- **GET** `/actuator/health` - Application health status
- **GET** `/actuator/info` - Application information
- **GET** `/actuator/metrics` - Application metrics
- **GET** `/actuator/prometheus` - Prometheus-formatted metrics

## Configuration

### Application Properties

Key configuration properties in `application.yml`:

```yaml
spring:
  application:
    name: video-enrichment-service

video:
  enrichment:
    youtube:
      api-key: ${YOUTUBE_API_KEY:}
      max-results: 50
      request-timeout: 30000
    processing:
      batch-size: 10
      retry:
        max-attempts: 3
        backoff-delay: 1000
```

### Profiles

- **default**: Development profile with debug logging
- **prod**: Production profile with optimized settings
- **test**: Test profile with H2 in-memory database

Activate a profile:
```bash
./gradlew bootRun --args='--spring.profiles.active=prod'
```

## Testing

### Run All Tests

```bash
./gradlew test
```

### Run Tests with Coverage

```bash
./gradlew test jacocoTestReport
```

Coverage reports are generated in `build/reports/jacoco/test/html/index.html`

### Verify Coverage Threshold

```bash
./gradlew jacocoTestCoverageVerification
```

The project enforces a minimum of 80% code coverage.

## CI/CD

### GitHub Actions Workflows

#### CI Workflow (ci.yml)

Triggered on pull requests to `main` and pushes to feature branches:
- Runs all unit tests
- Generates coverage reports
- Verifies >80% coverage threshold
- Builds application JAR
- Comments coverage on PR
- Uploads test results and coverage reports as artifacts

#### CD Workflow (cd.yml)

Triggered on push to `main` branch:
- Builds application JAR
- Creates multi-stage Docker image
- Pushes to GitHub Container Registry (GHCR)
- Tags with:
  - `latest`
  - `main-{sha}`
  - `{version}` (from build.gradle)
- Includes image metadata (build date, commit SHA, version)

## Docker Deployment

### Pull from GHCR

```bash
docker pull ghcr.io/yourusername/video-enrichment-service:latest
```

### Docker Compose Deployment

The project includes a production-ready `docker-compose.yml` that includes:
- PostgreSQL 16 database
- Video Enrichment Service
- Network configuration
- Volume mounts for data persistence
- Health checks for all services

```bash
# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## Monitoring

### Prometheus Metrics

Scrape endpoint: `http://localhost:8080/actuator/prometheus`

Example Prometheus configuration:

```yaml
scrape_configs:
  - job_name: 'video-enrichment-service'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['localhost:8080']
```

### Health Checks

- **Liveness**: `/actuator/health/liveness`
- **Readiness**: `/actuator/health/readiness`

## Security

- Actuator endpoints protected with authentication
- YouTube API key stored as environment variable
- Database credentials externalized
- Secure-by-default configuration
- Non-root user in Docker container
- Input validation enabled

## Troubleshooting

### Application Won't Start

1. Verify Java 25 is installed: `java -version`
2. Check database connectivity
3. Verify YouTube API key is configured
4. Review logs in `logs/application.log`

### Tests Failing

1. Ensure H2 database dependency is present
2. Check test resources configuration
3. Run with `--stacktrace` for detailed errors:
   ```bash
   ./gradlew test --stacktrace
   ```

### Database Connection Issues

1. Verify PostgreSQL is running:
   ```bash
   docker-compose ps postgres
   ```
2. Check schema exists:
   ```sql
   SELECT schema_name FROM information_schema.schemata;
   ```
3. Verify credentials and permissions

### YouTube API Errors

1. Verify API key is valid and active
2. Check quota limits in Google Cloud Console
3. Ensure YouTube Data API v3 is enabled
4. Review API error messages in logs

## Performance Tuning

### Virtual Threads

The service uses Java 25 virtual threads for improved scalability:

```yaml
spring:
  threads:
    virtual:
      enabled: true
```

### Database Connection Pool

Configured using HikariCP with optimal settings:

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 10
      minimum-idle: 5
      connection-timeout: 30000
```

### JVM Options

Recommended JVM options for production:

```bash
-XX:+UseContainerSupport
-XX:MaxRAMPercentage=75.0
-XX:InitialRAMPercentage=50.0
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push to branch: `git push origin feature/my-feature`
5. Submit a pull request

### Code Quality Standards

- Maintain >80% test coverage
- Follow Spring Boot best practices
- Use constructor injection
- Write meaningful JavaDoc
- Follow RESTful conventions

## License

This project is part of the Ad Tracker system. All rights reserved.

## Contact

For questions or support, please contact the development team or open an issue on GitHub.

## Related Projects

- [Ad Tracker Main Repository](https://github.com/yourusername/ad-tracker)
- [YouTube Webhook Ingestion Service](https://github.com/yourusername/youtube-webhook-ingestion)
- [Ad Detection Service](https://github.com/yourusername/ad-detection-service)

---

**Built with Spring Boot 4.0.0-RC2 and Java 25**
