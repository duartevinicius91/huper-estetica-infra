#!/bin/bash

# Script para carregar variáveis de ambiente de um arquivo .env

ENV_FILE="${ENV_FILE:-$(dirname "$0")/../.env}"

if [ -f "$ENV_FILE" ]; then
  echo "Carregando variáveis de ambiente de $ENV_FILE"
  set -a
  source "$ENV_FILE"
  set +a
  echo "Variáveis de ambiente carregadas!"
else
  echo "Arquivo .env não encontrado em $ENV_FILE"
  echo "Usando variáveis de ambiente do sistema ou valores padrão"
fi

