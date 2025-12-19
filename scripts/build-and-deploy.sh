#!/bin/bash

set -e

# Script completo: clone, build, push e deploy
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="${BASE_DIR:-$(dirname "$SCRIPT_DIR")}"

# Carregar variáveis de ambiente
if [ -f "$SCRIPT_DIR/load-env.sh" ]; then
  source "$SCRIPT_DIR/load-env.sh"
fi

echo "=== Iniciando processo completo de build e deploy ==="

# 1. Clonar repositórios
echo "1. Clonando repositórios..."
"$SCRIPT_DIR/clone-repos.sh"

# 2. Build imagens
echo "2. Construindo imagens Docker..."
"$SCRIPT_DIR/build-images.sh"

# 3. Push para Docker Hub
echo "3. Enviando imagens para Docker Hub..."
"$SCRIPT_DIR/push-images.sh"

# 4. Deploy no Nomad
echo "4. Fazendo deploy no Nomad..."
"$SCRIPT_DIR/deploy.sh"

echo "=== Processo completo finalizado! ==="

