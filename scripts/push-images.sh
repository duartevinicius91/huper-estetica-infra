#!/bin/bash

set -e

DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME:-huperdigital}"
VERSION="${VERSION:-latest}"

if [ -z "$DOCKER_HUB_PASSWORD" ]; then
  echo "Erro: DOCKER_HUB_PASSWORD não está definido"
  echo "Execute: export DOCKER_HUB_PASSWORD=seu_password"
  exit 1
fi

echo "Fazendo login no Docker Hub..."
echo "$DOCKER_HUB_PASSWORD" | docker login -u "$DOCKER_HUB_USERNAME" --password-stdin

echo "Enviando imagens para Docker Hub..."

# Push backend
echo "Enviando huper-estetica..."
docker push "$DOCKER_HUB_USERNAME/huper-estetica:$VERSION"

# Push frontend
echo "Enviando huper-estetica-front..."
docker push "$DOCKER_HUB_USERNAME/huper-estetica-front:$VERSION"

echo "Imagens enviadas com sucesso!"

