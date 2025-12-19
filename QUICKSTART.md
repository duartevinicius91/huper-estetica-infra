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

### 2. Deploy Completo (Recomendado)

**Linux/macOS:**
```bash
chmod +x scripts/*.sh
./scripts/build-and-deploy.sh
```

### 3. Verificar Status

```bash
nomad job status
```

### 4. Ver Logs

```bash
nomad job logs postgres
nomad job logs huper-estetica
```

## Deploy Apenas no Nomad (sem build)

Se as imagens já estiverem no Docker Hub:

```bash
./scripts/deploy.sh
```

## Variáveis Importantes

Certifique-se de configurar no `.env`:

- `DOCKER_HUB_USERNAME`: Seu usuário do Docker Hub
- `DOCKER_HUB_PASSWORD`: Sua senha do Docker Hub
- `NOMAD_ADDR`: Endereço do Nomad (ex: `http://localhost:4646`)
- `POSTGRES_HOST`: Host do PostgreSQL (use `localhost` se estiver no mesmo servidor)
- `KEYCLOAK_HOST`: Host do Keycloak (use `localhost` se estiver no mesmo servidor)
- `API_URL`: URL da API para o frontend (ex: `http://localhost:8080/api`)

## Troubleshooting Rápido

**Erro: "Volume not found"**
```bash
nomad volume create -name postgres_data -type host
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

