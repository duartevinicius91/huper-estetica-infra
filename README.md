# Infraestrutura Huper Estética - Nomad

Este repositório contém a configuração de infraestrutura para o sistema Huper Estética usando HashiCorp Nomad.

> 💡 **Quer começar rapidamente?** Veja o [QUICKSTART.md](QUICKSTART.md) para um guia rápido de deploy.

## 📋 Índice

- [Pré-requisitos](#pré-requisitos)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Configuração Inicial](#configuração-inicial)
- [Deploy Manual](#deploy-manual)
- [CI/CD](#cicd)
- [Jobs Nomad](#jobs-nomad)
- [Variáveis de Ambiente](#variáveis-de-ambiente)
- [Troubleshooting](#troubleshooting)

## Pré-requisitos

- **Nomad** instalado e configurado (versão 1.5+)
- **Docker** instalado e em execução
- **Git** para clonar repositórios
- **Docker Hub** account (ou registry alternativo)
- Acesso ao cluster Nomad

### Instalação do Nomad

#### Linux/macOS
```bash
# Baixar e instalar
wget https://releases.hashicorp.com/nomad/1.7.0/nomad_1.7.0_linux_amd64.zip
unzip nomad_1.7.0_linux_amd64.zip
sudo mv nomad /usr/local/bin/
```

## Estrutura do Projeto

```
huper-estetica-infra/
├── nomad/                    # Jobs Nomad
│   ├── postgres.nomad        # Infraestrutura (não utilizado - usa Supabase)
│   ├── keycloak.nomad        # Infraestrutura
│   ├── ollama.nomad          # Infraestrutura
│   ├── huper-estetica.nomad  # Aplicação (deploy via pipeline do serviço)
│   └── huper-estetica-front.nomad  # Aplicação (deploy via pipeline do serviço)
└── .github/workflows/        # CI/CD GitHub Actions
    └── deploy-infrastructure.yml  # Deploy apenas da infraestrutura
```

> **Nota:** Este repositório gerencia apenas a infraestrutura (Keycloak, Ollama). O banco de dados PostgreSQL é gerenciado via Supabase (não é deployado aqui). Os containers das aplicações (`huper-estetica` e `huper-estetica-front`) são atualizados automaticamente pelas pipelines de build de cada repositório de serviço.

## Configuração Inicial

### 1. Configurar Variáveis de Ambiente

Copie o arquivo de exemplo e configure suas variáveis:

```bash
cp env.example .env
```

Edite o arquivo `.env` com suas configurações:

```bash
# Docker Hub
export DOCKER_HUB_USERNAME=seu_usuario
export DOCKER_HUB_PASSWORD=sua_senha

# Nomad
export NOMAD_ADDR=http://localhost:4646

# Versão das imagens
export VERSION=latest

# PostgreSQL
export POSTGRES_PASSWORD=senha_segura
export POSTGRES_DB=huperestetica
export POSTGRES_USER=postgres

# Keycloak
export KEYCLOAK_ADMIN_USERNAME=admin
export KEYCLOAK_ADMIN_PASSWORD=senha_segura

# Backend
export OPENAI_API_KEY=sua_chave
export STRIPE_SECRET_KEY=sua_chave
export STRIPE_PUBLISHABLE_KEY=sua_chave
export STRIPE_WEBHOOK_SECRET=sua_chave
export FACEBOOK_APP_ID=seu_id
```

### 2. Configurar Supabase

O banco de dados PostgreSQL é gerenciado via Supabase. Configure as variáveis de ambiente com as credenciais do seu projeto Supabase:

- `POSTGRES_HOST`: Host do Supabase (ex: `db.xxxxx.supabase.co`)
- `POSTGRES_PORT`: Porta (geralmente `5432`)
- `POSTGRES_DB`: Nome do banco de dados
- `POSTGRES_USER`: Usuário do banco
- `POSTGRES_PASSWORD`: Senha do banco

### 3. Preparar Volumes Nomad

Os jobs Nomad usam volumes para persistência de dados. Configure os volumes no Nomad:

```bash
# Criar volumes (se necessário)
nomad volume create -name keycloak_data -type host
nomad volume create -name ollama_data -type host
```

## Deploy Manual

### Deploy da Infraestrutura

A infraestrutura (Keycloak, Ollama) pode ser deployada via:

> **Nota:** O banco de dados PostgreSQL é gerenciado via Supabase e não precisa ser deployado.

**Opção 1: Via GitHub Actions (Recomendado)**
```bash
# Execute o workflow "Deploy Infrastructure" manualmente ou faça push das mudanças nos jobs Nomad
```

**Opção 2: Via Nomad CLI**
```bash
export NOMAD_ADDR=http://seu-nomad:4646
nomad job run nomad/keycloak.nomad
nomad job run nomad/ollama.nomad
```

### Deploy das Aplicações

As aplicações (`huper-estetica` e `huper-estetica-front`) são deployadas automaticamente pelas pipelines de build de cada repositório. Não é necessário fazer deploy manual aqui.

### Deploy Individual

```bash
# Deploy de um serviço específico de infraestrutura
nomad job run nomad/keycloak.nomad
nomad job run nomad/ollama.nomad

# Deploy das aplicações (geralmente feito via pipelines)
nomad job run nomad/huper-estetica.nomad
nomad job run nomad/huper-estetica-front.nomad
```

## CI/CD

### Fluxo de Deploy

1. **Infraestrutura**: Este repositório contém um workflow que faz deploy apenas da infraestrutura (Keycloak, Ollama) quando há mudanças nos jobs Nomad correspondentes. O banco de dados PostgreSQL é gerenciado via Supabase.

2. **Aplicações**: Cada repositório de aplicação (`huper-estetica` e `huper-estetica-front`) possui sua própria pipeline de build que:
   - Constrói a aplicação
   - Cria a imagem Docker
   - Faz push para Docker Hub
   - **Faz deploy automático no Nomad** usando os jobs deste repositório

### Configurar Secrets no GitHub

No repositório de infraestrutura (`huper-estetica-infra`), configure:

1. **NOMAD_ADDR**: Endereço do servidor Nomad (ex: `http://nomad.example.com:4646`)
2. **KEYCLOAK_ADMIN_USERNAME**: Usuário admin do Keycloak
3. **KEYCLOAK_ADMIN_PASSWORD**: Senha admin do Keycloak

Nos repositórios de aplicação (`huper-estetica` e `huper-estetica-front`), configure:

1. **DOCKERHUB_USERNAME**: Seu usuário do Docker Hub
2. **DOCKERHUB_ACCESS_TOKEN**: Token de acesso do Docker Hub
3. **NOMAD_ADDR**: Endereço do servidor Nomad
4. **INFRA_REPO_TOKEN**: Token para acessar o repositório de infraestrutura (opcional, pode usar GITHUB_TOKEN)
5. **Variáveis do Supabase**:
   - **POSTGRES_HOST**: Host do Supabase (ex: `db.xxxxx.supabase.co`)
   - **POSTGRES_PORT**: Porta (geralmente `5432`)
   - **POSTGRES_DB**: Nome do banco de dados
   - **POSTGRES_USER**: Usuário do banco
   - **POSTGRES_PASSWORD**: Senha do banco
6. Todas as outras variáveis de ambiente necessárias para as aplicações (KEYCLOAK_*, etc.)

### Executar Deploy da Infraestrutura Manualmente

1. Vá em **Actions** neste repositório
2. Selecione o workflow "Deploy Infrastructure"
3. Clique em **Run workflow**

## Jobs Nomad

### PostgreSQL
> **Nota:** O PostgreSQL não é deployado via Nomad. O banco de dados é gerenciado via Supabase. Configure as variáveis de ambiente `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER` e `POSTGRES_PASSWORD` com as credenciais do seu projeto Supabase.

### Keycloak
- **Portas**: 7080 (HTTP), 7443 (HTTPS)
- **Volume**: `keycloak_data`
- **Recursos**: 1000 CPU, 1GB RAM

### Ollama
- **Porta**: 11434
- **Volume**: `ollama_data`
- **Recursos**: 2000 CPU, 4GB RAM

### Huper Estética (Backend)
- **Porta**: 8080
- **Recursos**: 1000 CPU, 2GB RAM
- **Dependências**: PostgreSQL, Keycloak

### Huper Estética Front (Frontend)
- **Porta**: 80
- **Recursos**: 200 CPU, 256MB RAM

## Variáveis de Ambiente

### Variáveis Globais
- `NOMAD_ADDR`: Endereço do servidor Nomad
- `DOCKER_HUB_USERNAME`: Usuário do Docker Hub
- `VERSION`: Versão/tag das imagens Docker

### Variáveis por Serviço

#### PostgreSQL
- `POSTGRES_PASSWORD`: Senha do PostgreSQL
- `POSTGRES_DB`: Nome do banco de dados
- `POSTGRES_USER`: Usuário do PostgreSQL

#### Keycloak
- `KEYCLOAK_ADMIN_USERNAME`: Usuário admin do Keycloak
- `KEYCLOAK_ADMIN_PASSWORD`: Senha admin do Keycloak

#### Backend (huper-estetica)
- `POSTGRES_PASSWORD`: Senha do PostgreSQL
- `POSTGRES_JDBC_URL`: URL de conexão JDBC
- `POSTGRES_USER`: Usuário do PostgreSQL
- `KEYCLOAK_AUTH_SERVER_URL`: URL do servidor Keycloak
- `KEYCLOAK_ADMIN`: Usuário admin do Keycloak
- `KEYCLOAK_ADMIN_PASSWORD`: Senha admin do Keycloak
- `OPENAI_API_KEY`: Chave da API OpenAI
- `STRIPE_SECRET_KEY`: Chave secreta do Stripe
- `STRIPE_PUBLISHABLE_KEY`: Chave pública do Stripe
- `STRIPE_WEBHOOK_SECRET`: Secret do webhook Stripe
- `FACEBOOK_APP_ID`: ID da aplicação Facebook

## Comandos Úteis

### Verificar Status dos Jobs
```bash
nomad job status
nomad job status postgres
nomad job status huper-estetica
```

### Ver Logs
```bash
nomad alloc logs <allocation-id>
nomad job logs postgres
nomad job logs huper-estetica
```

### Parar um Job
```bash
nomad job stop postgres
```

### Reiniciar um Job
```bash
nomad job restart postgres
```

### Atualizar um Job
```bash
nomad job run nomad/huper-estetica.nomad
```

### Ver Informações de um Job
```bash
nomad job inspect postgres
```

### Ver Alocações
```bash
nomad alloc status
```

## Troubleshooting

### Erro: "Volume not found"
**Solução**: Crie os volumes necessários:
```bash
nomad volume create -name postgres_data -type host
```

### Erro: "Cannot connect to Nomad"
**Solução**: Verifique se o Nomad está rodando e se `NOMAD_ADDR` está correto:
```bash
nomad server members
```

### Erro: "Image pull failed"
**Solução**: 
1. Verifique se a imagem existe no Docker Hub
2. Verifique as credenciais do Docker Hub
3. Verifique se o Nomad tem acesso ao Docker Hub

### Erro: "Service check failed"
**Solução**: 
1. Verifique os logs do serviço: `nomad job logs <job-name>`
2. Verifique se as dependências estão rodando
3. Verifique as variáveis de ambiente

### Backend não consegue conectar ao PostgreSQL
**Solução**: 
1. Verifique se o PostgreSQL está rodando: `nomad job status postgres`
2. Verifique a URL de conexão JDBC nas variáveis de ambiente
3. Verifique se o serviço está registrado corretamente no Consul (se estiver usando)

### Frontend não consegue acessar a API
**Solução**:
1. Verifique se o backend está rodando
2. Verifique a variável `VITE_HUPER_ABBY_API_URL` no job do frontend
3. Verifique as configurações de CORS no backend

## Próximos Passos

- [ ] Configurar Traefik para roteamento reverso
- [ ] Adicionar health checks mais robustos
- [ ] Configurar backups automáticos
- [ ] Adicionar monitoramento (Prometheus/Grafana)
- [ ] Configurar autoscaling
- [ ] Adicionar secrets management (Vault)

## Suporte

Para problemas ou dúvidas, abra uma issue no repositório ou entre em contato com a equipe de infraestrutura.
