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
      }

      volume_mount {
        volume      = "ollama_data"
        destination = "/root/.ollama"
      }

      resources {
        cpu    = 2000
        memory = 4096
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

