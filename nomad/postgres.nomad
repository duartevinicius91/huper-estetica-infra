job "postgres" {
  datacenters = ["dc1"]
  type        = "service"

  group "postgres" {
    count = 1

    network {
      port "db" {
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

      config {
        image = "postgres:15-alpine"
        ports = ["db"]
      }

      template {
        data = <<EOH
POSTGRES_PASSWORD="{{ env "POSTGRES_PASSWORD" | default "postgres" }}"
POSTGRES_DB="{{ env "POSTGRES_DB" | default "huperestetica" }}"
POSTGRES_USER="{{ env "POSTGRES_USER" | default "postgres" }}"
EOH
        destination = "secrets/env"
        env         = true
      }

      volume_mount {
        volume      = "postgres_data"
        destination = "/var/lib/postgresql/data"
      }

      resources {
        cpu    = 500
        memory = 512
      }

      service {
        name = "postgres"
        port = "db"

        check {
          type     = "script"
          command  = "pg_isready"
          args     = ["-U", "postgres"]
          interval = "10s"
          timeout  = "5s"
        }
      }
    }
  }
}

