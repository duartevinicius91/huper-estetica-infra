id        = "keycloak_data"
name      = "keycloak_data"
type      = "host"

plugin_id = "host"

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}

options {
  path = "/opt/nomad/volumes/keycloak_data"
}

