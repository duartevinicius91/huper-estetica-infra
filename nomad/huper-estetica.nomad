job "huper-estetica" {
  datacenters = ["dc1"]
  type        = "service"

  group "huper-estetica" {
    count = 1

    network {
      port "http" {
        static = 8080
      }
    }

    task "huper-estetica" {
      driver = "docker"

      template {
        data = <<EOH
DOCKER_HUB_USERNAME="{{ env "DOCKER_HUB_USERNAME" }}"
VERSION="{{ env "VERSION" }}"
POSTGRES_PASSWORD="{{ env "POSTGRES_PASSWORD" }}"
POSTGRES_DB="{{ env "POSTGRES_DB" }}"
POSTGRES_USER="{{ env "POSTGRES_USER" }}"
POSTGRES_HOST="{{ env "POSTGRES_HOST" }}"
POSTGRES_PORT="{{ env "POSTGRES_PORT" }}"
POSTGRES_JDBC_URL="jdbc:postgresql://${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"
EOH
        destination = "secrets/env"
        env         = true
      }

      config {
        image = "{{ env "DOCKER_HUB_USERNAME" }}/huper-estetica:{{ env "VERSION" }}"
        ports = ["http"]
      }

      resources {
        cpu    = 1000
        memory = 2048
      }

      service {
        name = "huper-estetica"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.huper-estetica.rule=PathPrefix(`/api`)",
          "traefik.http.routers.huper-estetica.entrypoints=web"
        ]

        check {
          type     = "http"
          path     = "/api/health"
          interval = "10s"
          timeout  = "5s"
        }
      }
    }
  }
}

