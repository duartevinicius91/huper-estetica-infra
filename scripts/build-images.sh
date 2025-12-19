#!/bin/bash

set -e

BASE_DIR="${BASE_DIR:-$(pwd)/..}"
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME:-huperdigital}"
VERSION="${VERSION:-latest}"

echo "Construindo imagens Docker..."

# Build backend
echo "Construindo huper-estetica..."
cd "$BASE_DIR/huper-estetica"
./gradlew build -x test
docker build -f src/main/docker/Dockerfile.jvm -t "$DOCKER_HUB_USERNAME/huper-estetica:$VERSION" .

# Build frontend
echo "Construindo huper-estetica-front..."
cd "$BASE_DIR/huper-estetica-front"
docker build -t "$DOCKER_HUB_USERNAME/huper-estetica-front:$VERSION" .

echo "Imagens construídas com sucesso!"
echo "Backend: $DOCKER_HUB_USERNAME/huper-estetica:$VERSION"
echo "Frontend: $DOCKER_HUB_USERNAME/huper-estetica-front:$VERSION"

