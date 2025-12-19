#!/bin/bash
set -e

# Inicia o servidor Ollama em background
echo "Iniciando servidor Ollama..."
ollama serve &
OLLAMA_PID=$!

# Aguarda o servidor Ollama estar pronto
echo "Aguardando servidor Ollama iniciar..."
for i in {1..30}; do
  if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "Servidor Ollama está pronto!"
    break
  fi
  if [ $i -eq 30 ]; then
    echo "Erro: Servidor Ollama não iniciou a tempo"
    exit 1
  fi
  sleep 2
done

# Baixa o modelo llama3
echo "Baixando modelo llama3..."
ollama pull llama3 || echo "Aviso: Falha ao baixar llama3 (pode já estar instalado)"

# Mantém o processo principal rodando
echo "Ollama está rodando. Modelo llama3 disponível."
wait $OLLAMA_PID

