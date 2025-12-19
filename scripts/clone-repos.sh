#!/bin/bash

set -e

BASE_DIR="${BASE_DIR:-$(pwd)/..}"
REPOS=(
  "huper-estetica"
  "huper-estetica-front"
)

echo "Clonando repositórios..."

for repo in "${REPOS[@]}"; do
  if [ ! -d "$BASE_DIR/$repo" ]; then
    echo "Clonando $repo..."
    git clone "https://github.com/huperdigital/$repo.git" "$BASE_DIR/$repo" || {
      echo "Erro ao clonar $repo. Verifique se o repositório existe e você tem acesso."
      exit 1
    }
  else
    echo "$repo já existe, atualizando..."
    cd "$BASE_DIR/$repo"
    git pull
  fi
done

echo "Repositórios clonados/atualizados com sucesso!"

