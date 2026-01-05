job "keycloak" {
  datacenters = ["dc1"]
  type        = "service"

  group "keycloak" {
    count = 1

    network {
      port "http" {
        static = 7080
      }
      port "https" {
        static = 7443
      }
    }

    volume "keycloak_data" {
      type      = "host"
      source    = "keycloak_data"
      read_only = false
    }

    task "keycloak" {
      driver = "docker"

      config {
        image = "quay.io/keycloak/keycloak:26.4"
        ports = ["http", "https"]
        args = [
          "start-dev",
          "--http-port=7080",
          "--https-port=7443",
          "--import-realm"
        ]
      }

      template {
        data = <<EOH
{{- if env "KEYCLOAK_ADMIN_USERNAME" }}
KC_BOOTSTRAP_ADMIN_USERNAME="{{ env "KEYCLOAK_ADMIN_USERNAME" }}"
{{- else }}
KC_BOOTSTRAP_ADMIN_USERNAME="admin"
{{- end }}
{{- if env "KEYCLOAK_ADMIN_PASSWORD" }}
KC_BOOTSTRAP_ADMIN_PASSWORD="{{ env "KEYCLOAK_ADMIN_PASSWORD" }}"
{{- else }}
KC_BOOTSTRAP_ADMIN_PASSWORD="admin"
{{- end }}
{{- if env "KEYCLOAK_HOSTNAME" }}
KC_HOSTNAME="{{ env "KEYCLOAK_HOSTNAME" }}"
KC_HOSTNAME_STRICT=false
KC_HOSTNAME_STRICT_HTTPS=false
{{- end }}
KC_HTTP_RELATIVE_PATH=/
KC_PROXY=edge
KC_HTTP_ENABLED=true
KC_HTTPS_ENABLED=true
KC_HTTP2_ENABLED=false
EOH
        destination = "secrets/env"
        env         = true
      }

      volume_mount {
        volume      = "keycloak_data"
        destination = "/opt/keycloak/data/import"
      }

      resources {
        cpu    = 1000
        memory = 1024
      }

      service {
        name = "keycloak"
        port = "http"

        check {
          type     = "http"
          path     = "/health"
          interval = "10s"
          timeout  = "5s"
        }
      }
    }
  }
}

