-- Database initialization script for Video Enrichment Service
-- This script creates the necessary schema and tables for the service

-- Create schema
CREATE SCHEMA IF NOT EXISTS video_enrichment;

-- Grant privileges
GRANT ALL PRIVILEGES ON SCHEMA video_enrichment TO postgres;

-- Set search path
SET search_path TO video_enrichment;

-- Placeholder table for enriched video data
-- This will be replaced by proper schema when entities are implemented
CREATE TABLE IF NOT EXISTS enriched_videos (
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

    -- Enrichment metadata
    enrichment_status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    enrichment_started_at TIMESTAMP,
    enrichment_completed_at TIMESTAMP,
    enrichment_error TEXT,
    retry_count INTEGER NOT NULL DEFAULT 0,

    -- Audit fields
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_enriched_videos_video_id ON video_enrichment.enriched_videos(video_id);
CREATE INDEX IF NOT EXISTS idx_enriched_videos_channel_id ON video_enrichment.enriched_videos(channel_id);
CREATE INDEX IF NOT EXISTS idx_enriched_videos_status ON video_enrichment.enriched_videos(enrichment_status);
CREATE INDEX IF NOT EXISTS idx_enriched_videos_published_at ON video_enrichment.enriched_videos(published_at);
CREATE INDEX IF NOT EXISTS idx_enriched_videos_created_at ON video_enrichment.enriched_videos(created_at);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION video_enrichment.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for updated_at
DROP TRIGGER IF EXISTS update_enriched_videos_updated_at ON video_enrichment.enriched_videos;
CREATE TRIGGER update_enriched_videos_updated_at
    BEFORE UPDATE ON video_enrichment.enriched_videos
    FOR EACH ROW
    EXECUTE FUNCTION video_enrichment.update_updated_at_column();

-- Comments for documentation
COMMENT ON SCHEMA video_enrichment IS 'Schema for YouTube video enrichment data';
COMMENT ON TABLE video_enrichment.enriched_videos IS 'Stores enriched YouTube video metadata and processing status';
