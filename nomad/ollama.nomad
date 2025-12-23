job "ollama" {
  datacenters = ["dc1"]
  type = "service"

  group "ollama" {
    count = 1

    network {
      port "http" {
        static = 11434
      }
    }

    volume "ollama-data" {
      type      = "host"
      source    = "ollama-data"
      read_only = false
    }

    task "ollama" {
      driver = "docker"

      volume_mount {
        volume      = "ollama-data"
        destination = "/root/.ollama"
        read_only   = false
      }

      config {
        image = "ollama/ollama:latest"

        ports = ["http"]

        # Override do entrypoint para baixar o modelo
        entrypoint = ["/bin/sh", "-c"]
        args = [
          <<EOF
          ollama serve &
          sleep 5
          ollama pull gemma3:1b
          wait
          EOF
        ]
      }

      resources {
        cpu    = 2000
        memory = 4096
      }

      service {
        name = "ollama"
        port = "http"

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
