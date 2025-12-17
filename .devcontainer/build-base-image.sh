#!/bin/bash
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if docker buildx is available
if ! docker buildx version &> /dev/null; then
    echo "Error: docker buildx is not available"
    exit 1
fi

# Create and use a new builder instance if it doesn't exist
BUILDER_NAME="multiarch-builder"
if ! docker buildx inspect "$BUILDER_NAME" &> /dev/null; then
    echo "Creating new buildx builder: $BUILDER_NAME"
    docker buildx create --name "$BUILDER_NAME" --use
else
    echo "Using existing buildx builder: $BUILDER_NAME"
    docker buildx use "$BUILDER_NAME"
fi

# Build and push multi-platform image
echo "Building and pushing multi-platform image..."
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -t mark24code/claude-in-docker:latest \
    -t mark24code/claude-in-docker:v0.3.0 \
    --push \
    -f Dockerfile.base \
    .

echo "Build and push completed successfully!"