job "ollama" {
  datacenters = ["dc1"]
  type        = "service"

  group "ollama" {
    count = 1

    network {
      port "api" {
        static = 11434
      }
    }

    volume "ollama_data" {
      type      = "host"
      source    = "ollama_data"
      read_only = false
    }

    task "ollama" {
      driver = "docker"

      config {
        image = "ollama/ollama:latest"
        ports = ["api"]
        entrypoint = ["/bin/bash"]
        command = "/local/init-ollama.sh"
      }

      template {
        data = <<EOH
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
EOH
        destination = "local/init-ollama.sh"
        perms       = "755"
      }

      volume_mount {
        volume      = "ollama_data"
        destination = "/root/.ollama"
      }

      resources {
        cpu    = 2000
        memory = 5120
      }

      service {
        name = "ollama"
        port = "api"

        check {
          type     = "http"
          path     = "/api/tags"
          interval = "30s"
          timeout  = "10s"
        }
      }
    }
  }
}

