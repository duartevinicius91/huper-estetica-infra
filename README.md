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

#### Windows
```powershell
# Usando Chocolatey
choco install nomad

# Ou baixar manualmente de:
# https://releases.hashicorp.com/nomad/
```

## Estrutura do Projeto

```
huper-estetica-infra/
├── nomad/                    # Jobs Nomad
│   ├── postgres.nomad
│   ├── keycloak.nomad
│   ├── ollama.nomad
│   ├── huper-estetica.nomad
│   └── huper-estetica-front.nomad
├── scripts/                  # Scripts de build e deploy
│   ├── clone-repos.sh        # Clonar repositórios
│   ├── build-images.sh       # Build imagens Docker
│   ├── push-images.sh        # Push para Docker Hub
│   ├── deploy.sh             # Deploy no Nomad
│   ├── build-and-deploy.sh   # Script completo
│   └── *.bat                 # Versões Windows
└── .github/workflows/        # CI/CD GitHub Actions
    ├── deploy-backend.yml
    └── deploy-frontend.yml
```

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

**Windows (PowerShell):**
```powershell
$env:DOCKER_HUB_USERNAME="seu_usuario"
$env:DOCKER_HUB_PASSWORD="sua_senha"
$env:NOMAD_ADDR="http://localhost:4646"
# ... etc
```

### 2. Preparar Volumes Nomad

Os jobs Nomad usam volumes para persistência de dados. Configure os volumes no Nomad:

```bash
# Criar volumes (se necessário)
nomad volume create -name postgres_data -type host
nomad volume create -name keycloak_data -type host
nomad volume create -name ollama_data -type host
```

## Deploy Manual

### Opção 1: Script Completo (Recomendado)

**Linux/macOS:**
```bash
chmod +x scripts/*.sh
./scripts/build-and-deploy.sh
```

**Windows:**
```powershell
.\scripts\clone-repos.bat
.\scripts\build-images.bat
.\scripts\push-images.bat
.\scripts\deploy.bat
```

### Opção 2: Passo a Passo

#### 1. Clonar Repositórios
```bash
./scripts/clone-repos.sh
```

#### 2. Build das Imagens Docker
```bash
export DOCKER_HUB_USERNAME=seu_usuario
export VERSION=latest
./scripts/build-images.sh
```

#### 3. Push para Docker Hub
```bash
export DOCKER_HUB_PASSWORD=sua_senha
./scripts/push-images.sh
```

#### 4. Deploy no Nomad
```bash
export NOMAD_ADDR=http://seu-nomad:4646
./scripts/deploy.sh
```

### Opção 3: Deploy Individual

```bash
# Deploy de um serviço específico
nomad job run nomad/postgres.nomad
nomad job run nomad/keycloak.nomad
nomad job run nomad/ollama.nomad
nomad job run nomad/huper-estetica.nomad
nomad job run nomad/huper-estetica-front.nomad
```

## CI/CD

O projeto inclui workflows GitHub Actions para deploy automático.

### Configurar Secrets no GitHub

No repositório GitHub, configure os seguintes secrets:

1. **DOCKER_HUB_USERNAME**: Seu usuário do Docker Hub
2. **DOCKER_HUB_PASSWORD**: Sua senha/token do Docker Hub
3. **NOMAD_ADDR**: Endereço do servidor Nomad (ex: `http://nomad.example.com:4646`)
4. **NOMAD_TOKEN**: Token de autenticação do Nomad (se necessário)

### Como Funciona

- **Backend**: Quando há push na branch `main`/`master` do repositório `huper-estetica`, o workflow:
  1. Faz checkout dos repositórios
  2. Builda a aplicação Java
  3. Cria a imagem Docker
  4. Faz push para Docker Hub
  5. Atualiza o job no Nomad

- **Frontend**: Similar ao backend, mas para o repositório `huper-estetica-front`

### Executar Manualmente

Você pode executar os workflows manualmente através da interface do GitHub:
1. Vá em **Actions**
2. Selecione o workflow desejado
3. Clique em **Run workflow**

## Jobs Nomad

### PostgreSQL
- **Porta**: 5432
- **Volume**: `postgres_data`
- **Recursos**: 500 CPU, 512MB RAM

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
