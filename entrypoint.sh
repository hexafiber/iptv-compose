#!/bin/bash
set -e

# entrypoint.sh - Enhanced entrypoint with cleanup and logging


# Default values
INPUT_URL=${INPUT_URL:-"http://host.docker.internal:4022/udp/239.2.2.2:3000"}
OUTPUT_PATH=${OUTPUT_PATH:-"/output/index.m3u8"}
HLS_TIME=${HLS_TIME:-2}
HLS_LIST_SIZE=${HLS_LIST_SIZE:-10}
LOG_LEVEL=${LOG_LEVEL:-"warning"}
CLEANUP_BEFORE_START=${CLEANUP_BEFORE_START:-"true"}

# Cleanup function
cleanup_output() {
    if [ "$CLEANUP_BEFORE_START" = "true" ]; then
        echo "$(date): Cleaning output directory..."
        rm -rf /output/*
        echo "$(date): Output directory cleaned"
    fi
}

# Error handler
handle_error() {
    echo "$(date): FFmpeg process terminated with error code $1"
    exit $1
}

# Signal handler for graceful shutdown
graceful_shutdown() {
    echo "$(date): Received shutdown signal, stopping FFmpeg..."
    kill $FFMPEG_PID 2>/dev/null || true
    wait $FFMPEG_PID 2>/dev/null || true
    echo "$(date): FFmpeg stopped gracefully"
    exit 0
}

# Set up signal handlers
trap graceful_shutdown SIGTERM SIGINT

# Cleanup before start
cleanup_output

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT_PATH")"

echo "$(date): Starting FFmpeg with the following configuration:"
echo "  Input URL: $INPUT_URL"
echo "  Output Path: $OUTPUT_PATH"
echo "  HLS Time: ${HLS_TIME}s"
echo "  HLS List Size: $HLS_LIST_SIZE"
echo "  Log Level: $LOG_LEVEL"

# Start FFmpeg in background
ffmpeg \
  -loglevel "$LOG_LEVEL" \
  -hide_banner \
  -nostats \
  -i "$INPUT_URL" \
  -c:a copy \
  -c:v copy \
  -f hls \
  -hls_time "$HLS_TIME" \
  -hls_list_size "$HLS_LIST_SIZE" \
  -hls_flags delete_segments \
  -hls_segment_filename "/output/segment_%03d.ts" \
  -hls_playlist_type live \
  -hls_delete_threshold 1 \
  "$OUTPUT_PATH" &

FFMPEG_PID=$!

# Wait for FFmpeg process
wait $FFMPEG_PID || handle_error $?

echo "$(date): FFmpeg process completed successfully"