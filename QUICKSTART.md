# Quick Start Guide

Guia rápido para subir a infraestrutura da Abby via Nomad.

## Pré-requisitos Rápidos

1. Nomad instalado e rodando
2. Docker instalado e rodando
3. Acesso ao Docker Hub

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

### 3. Deploy da Infraestrutura

**Via GitHub Actions (Recomendado):**
- Execute o workflow "Deploy Infrastructure" manualmente ou faça push das mudanças

**Via Nomad CLI:**
```bash
export NOMAD_ADDR=http://localhost:4646
nomad job run nomad/keycloak.nomad
nomad job run nomad/ollama.nomad
```

> **Nota:** O PostgreSQL é gerenciado via Supabase e não precisa ser deployado. As aplicações (`huper-estetica` e `huper-estetica-front`) são deployadas automaticamente pelas pipelines de build de cada repositório.

### 4. Verificar Status

```bash
nomad job status
```

### 5. Ver Logs

```bash
nomad job logs postgres
nomad job logs huper-estetica
```

## Deploy Manual de um Serviço de Infraestrutura

Para fazer deploy manual de um serviço específico:

```bash
export NOMAD_ADDR=http://localhost:4646
nomad job run nomad/keycloak.nomad
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
- `KEYCLOAK_HOST`: Host do Keycloak (use `localhost` se estiver no mesmo servidor)
- `API_URL`: URL da API para o frontend (ex: `http://localhost:8080/api`)

## Troubleshooting Rápido

**Erro: "Volume not found"**
```bash
nomad volume create -name keycloak_data -type host
nomad volume create -name ollama_data -type host
```

**Erro: "Cannot connect to Nomad"**
```bash
export NOMAD_ADDR=http://seu-servidor-nomad:4646
```

**Erro: "Image pull failed"**
- Verifique se fez login no Docker Hub: `docker login`
- Verifique se a imagem existe: `docker pull seu-usuario/huper-estetica:latest`

## Próximos Passos

Consulte o [README.md](README.md) completo para mais detalhes.

