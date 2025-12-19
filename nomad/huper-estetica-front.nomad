job "huper-estetica-front" {
  datacenters = ["dc1"]
  type        = "service"

  group "huper-estetica-front" {
    count = 1

    network {
      port "http" {
        static = 80
      }
    }

    task "huper-estetica-front" {
      driver = "docker"

      config {
        image = "{{ env "DOCKER_HUB_USERNAME" | default "huperdigital" }}/huper-estetica-front:{{ env "VERSION" | default "latest" }}"
        ports = ["http"]
      }

      template {
        data = <<EOH
DOCKER_HUB_USERNAME="{{ env "DOCKER_HUB_USERNAME" | default "huperdigital" }}"
VERSION="{{ env "VERSION" | default "latest" }}"
API_URL="{{ env "API_URL" | default "http://localhost:8080/api" }}"
EOH
        destination = "secrets/env"
        env         = true
      }

      env {
        VITE_HUPER_ABBY_API_URL = "${API_URL}"
      }

      resources {
        cpu    = 200
        memory = 256
      }

      service {
        name = "huper-estetica-front"
        port = "http"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.huper-estetica-front.rule=Host(`vps-d71f499b.vps.ovh.net`)",
          "traefik.http.routers.huper-estetica-front.entrypoints=web"
        ]

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "5s"
        }
      }
    }
  }
}

