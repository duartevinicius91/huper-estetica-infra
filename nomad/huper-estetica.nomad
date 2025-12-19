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
{{- if env "DOCKER_HUB_USERNAME" }}
DOCKER_HUB_USERNAME="{{ env "DOCKER_HUB_USERNAME" }}"
{{- else }}
DOCKER_HUB_USERNAME="huperdigital"
{{- end }}
{{- if env "VERSION" }}
VERSION="{{ env "VERSION" }}"
{{- else }}
VERSION="latest"
{{- end }}
{{- if env "POSTGRES_PASSWORD" }}
POSTGRES_PASSWORD="{{ env "POSTGRES_PASSWORD" }}"
{{- else }}
POSTGRES_PASSWORD="postgres"
{{- end }}
{{- if env "POSTGRES_DB" }}
POSTGRES_DB="{{ env "POSTGRES_DB" }}"
{{- else }}
POSTGRES_DB="huperestetica"
{{- end }}
{{- if env "POSTGRES_USER" }}
POSTGRES_USER="{{ env "POSTGRES_USER" }}"
{{- else }}
POSTGRES_USER="postgres"
{{- end }}
{{- if env "POSTGRES_HOST" }}
POSTGRES_HOST="{{ env "POSTGRES_HOST" }}"
{{- else }}
POSTGRES_HOST="localhost"
{{- end }}
{{- if env "POSTGRES_PORT" }}
POSTGRES_PORT="{{ env "POSTGRES_PORT" }}"
{{- else }}
POSTGRES_PORT="5432"
{{- end }}
{{- if env "KEYCLOAK_ADMIN" }}
KEYCLOAK_ADMIN="{{ env "KEYCLOAK_ADMIN" }}"
{{- else }}
KEYCLOAK_ADMIN="admin"
{{- end }}
{{- if env "KEYCLOAK_ADMIN_PASSWORD" }}
KEYCLOAK_ADMIN_PASSWORD="{{ env "KEYCLOAK_ADMIN_PASSWORD" }}"
{{- else }}
KEYCLOAK_ADMIN_PASSWORD="admin"
{{- end }}
{{- if env "KEYCLOAK_HOST" }}
KEYCLOAK_HOST="{{ env "KEYCLOAK_HOST" }}"
{{- else }}
KEYCLOAK_HOST="localhost"
{{- end }}
{{- if env "KEYCLOAK_PORT" }}
KEYCLOAK_PORT="{{ env "KEYCLOAK_PORT" }}"
{{- else }}
KEYCLOAK_PORT="7080"
{{- end }}
{{- if env "OPENAI_API_KEY" }}
OPENAI_API_KEY="{{ env "OPENAI_API_KEY" }}"
{{- end }}
{{- if env "STRIPE_SECRET_KEY" }}
STRIPE_SECRET_KEY="{{ env "STRIPE_SECRET_KEY" }}"
{{- end }}
{{- if env "STRIPE_PUBLISHABLE_KEY" }}
STRIPE_PUBLISHABLE_KEY="{{ env "STRIPE_PUBLISHABLE_KEY" }}"
{{- end }}
{{- if env "STRIPE_WEBHOOK_SECRET" }}
STRIPE_WEBHOOK_SECRET="{{ env "STRIPE_WEBHOOK_SECRET" }}"
{{- end }}
{{- if env "FACEBOOK_APP_ID" }}
FACEBOOK_APP_ID="{{ env "FACEBOOK_APP_ID" }}"
{{- end }}
POSTGRES_JDBC_URL="jdbc:postgresql://${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"
KEYCLOAK_AUTH_SERVER_URL="http://${KEYCLOAK_HOST}:${KEYCLOAK_PORT}/realms/huper-abby"
EOH
        destination = "secrets/env"
        env         = true
      }

      config {
        image = "{{ if env "DOCKER_HUB_USERNAME" }}{{ env "DOCKER_HUB_USERNAME" }}{{ else }}huperdigital{{ end }}/huper-estetica:{{ if env "VERSION" }}{{ env "VERSION" }}{{ else }}latest{{ end }}"
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

