id        = "ollama_data"
name      = "ollama_data"
type      = "host"

plugin_id = "host"

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}

options {
  path = "/opt/nomad/volumes/ollama_data"
}

