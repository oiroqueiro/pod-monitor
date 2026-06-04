#!/bin/bash

# ----- 1. PATHS & CONFIG -----
PROJECT_DIR=$(cd "$(dirname "$0")/.." && pwd)
cd "$PROJECT_DIR"

# Ensure registry is set, default to user's GHCR if missing
REGISTRY="${GHCR_REGISTRY:-ghcr.io/oiroqueiro}"

# ----- 2. BUILD HARDENED IMAGES -----
echo "🏗️  Building hardened Node Exporter image..."
podman build -t "${REGISTRY}/monitor-node-exporter:latest" -f "$PROJECT_DIR/build/node-exporter.Containerfile" "$PROJECT_DIR"

echo "🏗️  Building hardened Podman Exporter image..."
podman build -t "${REGISTRY}/monitor-podman-exporter:latest" -f "$PROJECT_DIR/build/podman-exporter.Containerfile" "$PROJECT_DIR"

# ----- 3. PUSH IMAGES TO REGISTRY -----
echo "☁️  Pushing images to registry (${REGISTRY})..."
podman push "${REGISTRY}/monitor-node-exporter:latest"
podman push "${REGISTRY}/monitor-podman-exporter:latest"

echo "✅ All monitoring images successfully built and pushed to ${REGISTRY}!"
