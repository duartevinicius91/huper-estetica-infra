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
DOCKER_HUB_USERNAME="{{ env "DOCKER_HUB_USERNAME" | default "huperdigital" }}"
VERSION="{{ env "VERSION" | default "latest" }}"
POSTGRES_PASSWORD="{{ env "POSTGRES_PASSWORD" | default "postgres" }}"
POSTGRES_DB="{{ env "POSTGRES_DB" | default "huperestetica" }}"
POSTGRES_USER="{{ env "POSTGRES_USER" | default "postgres" }}"
POSTGRES_HOST="{{ env "POSTGRES_HOST" | default "localhost" }}"
POSTGRES_PORT="{{ env "POSTGRES_PORT" | default "5432" }}"
KEYCLOAK_ADMIN="{{ env "KEYCLOAK_ADMIN" | default "admin" }}"
KEYCLOAK_ADMIN_PASSWORD="{{ env "KEYCLOAK_ADMIN_PASSWORD" | default "admin" }}"
KEYCLOAK_HOST="{{ env "KEYCLOAK_HOST" | default "localhost" }}"
KEYCLOAK_PORT="{{ env "KEYCLOAK_PORT" | default "7080" }}"
OPENAI_API_KEY="{{ env "OPENAI_API_KEY" }}"
STRIPE_SECRET_KEY="{{ env "STRIPE_SECRET_KEY" }}"
STRIPE_PUBLISHABLE_KEY="{{ env "STRIPE_PUBLISHABLE_KEY" }}"
STRIPE_WEBHOOK_SECRET="{{ env "STRIPE_WEBHOOK_SECRET" }}"
FACEBOOK_APP_ID="{{ env "FACEBOOK_APP_ID" }}"
POSTGRES_JDBC_URL="jdbc:postgresql://${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"
KEYCLOAK_AUTH_SERVER_URL="http://${KEYCLOAK_HOST}:${KEYCLOAK_PORT}/realms/huper-abby"
EOH
        destination = "secrets/env"
        env         = true
      }

      config {
        image = "{{ env "DOCKER_HUB_USERNAME" | default "huperdigital" }}/huper-estetica:{{ env "VERSION" | default "latest" }}"
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

