# Quick Start Guide

Guia rápido para subir a infraestrutura da Abby via Nomad.

## Pré-requisitos Rápidos

1. Nomad instalado e rodando
2. Docker instalado e rodando
3. Acesso ao Docker Hub

### Iniciar Nomad (se necessário)

**Opção 1: Modo Dev (Desenvolvimento)**
```bash
nomad agent -dev
```

**Opção 2: Como Serviço Systemd (Produção/Ubuntu)**
```bash
# 1. Criar diretório de configuração
sudo mkdir -p /etc/nomad.d

# 2. Criar arquivo de configuração básico
sudo tee /etc/nomad.d/nomad.hcl > /dev/null <<EOF
datacenter = "dc1"
data_dir = "/opt/nomad/data"

server {
  enabled = true
  bootstrap_expect = 1
}

client {
  enabled = true
}
EOF

# 3. Criar diretório de dados
sudo mkdir -p /opt/nomad/data

# 4. Copiar e instalar o serviço
sudo cp nomad.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable nomad
sudo systemctl start nomad

# 5. Verificar status
sudo systemctl status nomad
```

**Para servidor remoto:**
```bash
export NOMAD_ADDR=http://seu-servidor-nomad:4646
```

**Verificar conexão:**
```bash
nomad server members
```

## Passos Rápidos

### 1. Configurar Variáveis

```bash
cp env.example .env
# Edite o .env com suas configurações
```

### 2. Configurar Supabase

Configure as variáveis de ambiente com as credenciais do seu projeto Supabase no arquivo `.env`:

```bash
POSTGRES_HOST=db.xxxxx.supabase.co
POSTGRES_PORT=5432
POSTGRES_DB=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=sua_senha
```

### 3. Configurar Volumes Host

Antes de fazer deploy, configure os volumes host no arquivo de configuração do Nomad:

**Importante:** Volumes do tipo `host` devem ser configurados no arquivo `/etc/nomad.d/nomad.hcl`. Eles não podem ser registrados via CLI.

```bash
# 1. Editar /etc/nomad.d/nomad.hcl e adicionar na seção client:
sudo nano /etc/nomad.d/nomad.hcl

# Adicionar:
client {
  enabled = true
  
  host_volume "ollama_data" {
    path      = "/opt/nomad/volumes/ollama_data"
    read_only = false
  }
}

# 2. Criar diretórios
sudo mkdir -p /opt/nomad/volumes/ollama_data

# 3. Reiniciar Nomad
sudo systemctl restart nomad

# 4. Verificar configuração
nomad node status -self
```

### 4. Deploy da Infraestrutura

**Via GitHub Actions (Recomendado):**
- Execute o workflow "Deploy Infrastructure" manualmente ou faça push das mudanças

**Via Nomad CLI:**
```bash
# Certifique-se de que o Nomad está rodando
# Se estiver em modo dev: nomad agent -dev
# Se for servidor remoto: export NOMAD_ADDR=http://seu-servidor:4646

export NOMAD_ADDR=http://localhost:4646
nomad job run nomad/ollama.nomad
```

> **Nota:** O PostgreSQL é gerenciado via Supabase e não precisa ser deployado. As aplicações (`huper-estetica` e `huper-estetica-front`) são deployadas automaticamente pelas pipelines de build de cada repositório.

### 5. Verificar Status

```bash
nomad job status
```

### 6. Ver Logs

```bash
nomad job logs postgres
nomad job logs huper-estetica
```

## Deploy Manual de um Serviço de Infraestrutura

Para fazer deploy manual de um serviço específico:

```bash
export NOMAD_ADDR=http://localhost:4646
nomad job run nomad/ollama.nomad
```

> **Nota:** O PostgreSQL não é deployado aqui, pois é gerenciado via Supabase.

## Variáveis Importantes

Certifique-se de configurar no `.env`:

- `DOCKER_HUB_USERNAME`: Seu usuário do Docker Hub
- `DOCKER_HUB_PASSWORD`: Sua senha do Docker Hub
- `NOMAD_ADDR`: Endereço do Nomad (ex: `http://localhost:4646`)
- **Supabase (PostgreSQL)**:
  - `POSTGRES_HOST`: Host do Supabase (ex: `db.xxxxx.supabase.co`)
  - `POSTGRES_PORT`: Porta (geralmente `5432`)
  - `POSTGRES_DB`: Nome do banco de dados
  - `POSTGRES_USER`: Usuário do banco
  - `POSTGRES_PASSWORD`: Senha do banco
- `API_URL`: URL da API para o frontend (ex: `http://localhost:8080/api`)

## Troubleshooting Rápido

**Erro: "Volume not found" ou "missing compatible host volumes"**

1. **Configurar volumes no nomad.hcl:**
   ```bash
   # Adicionar na seção client do /etc/nomad.d/nomad.hcl
   client {
     enabled = true
     
     host_volume "ollama_data" {
       path      = "/opt/nomad/volumes/ollama_data"
       read_only = false
     }
   }
   
   # Criar diretórios e reiniciar
   sudo mkdir -p /opt/nomad/volumes/ollama_data
   sudo systemctl restart nomad
   ```

2. **Verificar se a configuração foi aplicada:**
   ```bash
   # Verificar status do nó
   nomad node status -self
   
   # Verificar logs do Nomad
   sudo journalctl -u nomad -n 50
   ```

**Erro: "Cannot connect to Nomad" ou "connection refused"**

1. **Iniciar Nomad em modo dev (local):**
   ```bash
   nomad agent -dev
   ```

2. **Configurar NOMAD_ADDR para servidor remoto:**
   ```bash
   export NOMAD_ADDR=http://seu-servidor-nomad:4646
   ```

3. **Verificar conexão:**
   ```bash
   nomad server members
   ```

**Erro: "Image pull failed"**
- Verifique se fez login no Docker Hub: `docker login`
- Verifique se a imagem existe: `docker pull seu-usuario/huper-estetica:latest`

## Próximos Passos

Consulte o [README.md](README.md) completo para mais detalhes.

