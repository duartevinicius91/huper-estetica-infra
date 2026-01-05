job "postgres" {
  datacenters = ["dc1"]
  type        = "service"

  group "postgres" {
    count = 1

    network {
      port "postgres" {
        static = 5432
      }
    }

    volume "postgres_data" {
      type      = "host"
      source    = "postgres_data"
      read_only = false
    }

    task "postgres" {
      driver = "docker"

      template {
        data = <<EOH
POSTGRES_PASSWORD="{{ env "POSTGRES_PASSWORD" }}"
POSTGRES_DB="{{ env "POSTGRES_DB" }}"
POSTGRES_USER="{{ env "POSTGRES_USER" }}"
EOH
        destination = "secrets/env"
        env         = true
      }

      volume_mount {
        volume      = "postgres_data"
        destination = "/var/lib/postgresql/data"
        read_only   = false
      }

      config {
        image = "postgres:15-alpine"
        ports = ["postgres"]
      }

      resources {
        cpu    = 1000
        memory = 2048
      }

      service {
        name = "postgres"
        port = "postgres"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "5s"
        }
      }
    }
  }
}
