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
KC_BOOTSTRAP_ADMIN_USERNAME="{{ env "KEYCLOAK_ADMIN_USERNAME" | default "admin" }}"
KC_BOOTSTRAP_ADMIN_PASSWORD="{{ env "KEYCLOAK_ADMIN_PASSWORD" | default "admin" }}"
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

