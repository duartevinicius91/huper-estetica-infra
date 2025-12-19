#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Carregar variáveis de ambiente
if [ -f "$SCRIPT_DIR/load-env.sh" ]; then
  source "$SCRIPT_DIR/load-env.sh"
fi

NOMAD_ADDR="${NOMAD_ADDR:-http://localhost:4646}"
NOMAD_DIR="${NOMAD_DIR:-$(dirname "$SCRIPT_DIR")/nomad}"
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME:-huperdigital}"
VERSION="${VERSION:-latest}"

echo "Fazendo deploy dos jobs Nomad..."
echo "NOMAD_ADDR: $NOMAD_ADDR"
echo "DOCKER_HUB_USERNAME: $DOCKER_HUB_USERNAME"
echo "VERSION: $VERSION"

# Deploy infrastructure services first
echo "Deployando PostgreSQL..."
nomad job run -address="$NOMAD_ADDR" "$NOMAD_DIR/postgres.nomad"

echo "Aguardando PostgreSQL estar pronto..."
sleep 10

echo "Deployando Keycloak..."
nomad job run -address="$NOMAD_ADDR" "$NOMAD_DIR/keycloak.nomad"

echo "Deployando Ollama..."
nomad job run -address="$NOMAD_ADDR" "$NOMAD_DIR/ollama.nomad"

# Deploy application services
echo "Deployando huper-estetica (backend)..."
# Exportar variáveis necessárias para o template do Nomad
export DOCKER_HUB_USERNAME
export VERSION
export POSTGRES_PASSWORD
export POSTGRES_DB
export POSTGRES_USER
export POSTGRES_HOST
export POSTGRES_PORT
export KEYCLOAK_ADMIN
export KEYCLOAK_ADMIN_PASSWORD
export KEYCLOAK_HOST
export KEYCLOAK_PORT
export OPENAI_API_KEY
export STRIPE_SECRET_KEY
export STRIPE_PUBLISHABLE_KEY
export STRIPE_WEBHOOK_SECRET
export FACEBOOK_APP_ID
nomad job run -address="$NOMAD_ADDR" "$NOMAD_DIR/huper-estetica.nomad"

echo "Deployando huper-estetica-front..."
export API_URL
nomad job run -address="$NOMAD_ADDR" "$NOMAD_DIR/huper-estetica-front.nomad"

echo "Deploy concluído!"
echo "Verifique o status com: nomad job status"

