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

### Configurar Nomad como Serviço Systemd (Ubuntu/Debian)

Para rodar o Nomad como daemon no Ubuntu, use o arquivo `nomad.service` incluído:

```bash
# 1. Criar diretório de configuração do Nomad
sudo mkdir -p /etc/nomad.d

# 2. Criar arquivo de configuração básico
# Você pode usar o arquivo nomad.hcl.example como referência
sudo cp nomad.hcl.example /etc/nomad.d/nomad.hcl
# Ou criar manualmente:
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

# 3. Criar diretórios de dados, logs e volumes
sudo mkdir -p /opt/nomad/data
sudo mkdir -p /opt/nomad/volumes/keycloak_data
sudo mkdir -p /opt/nomad/volumes/ollama_data
sudo mkdir -p /var/log/nomad

# Dar permissões adequadas
sudo chown -R root:root /opt/nomad
sudo chmod -R 755 /opt/nomad

# 4. Copiar o arquivo de serviço
sudo cp nomad.service /etc/systemd/system/nomad.service

# 5. Recarregar systemd
sudo systemctl daemon-reload

# 6. Habilitar o serviço para iniciar no boot
sudo systemctl enable nomad

# 7. Iniciar o serviço
sudo systemctl start nomad

# 8. Verificar status
sudo systemctl status nomad

# 9. Ver logs
sudo journalctl -u nomad -f
```

**Comandos úteis:**
```bash
# Parar o serviço
sudo systemctl stop nomad

# Reiniciar o serviço
sudo systemctl restart nomad

# Ver logs em tempo real
sudo journalctl -u nomad -f

# Ver últimas 100 linhas de log
sudo journalctl -u nomad -n 100

# Verificar status
sudo systemctl status nomad
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
├── nomad.service            # Arquivo systemd para rodar Nomad como daemon
├── nomad.hcl.example        # Exemplo de configuração do Nomad
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

### 3. Configurar Volumes Nomad

Os jobs Nomad usam volumes do tipo `host` para persistência de dados. **Volumes host devem ser configurados no arquivo de configuração do cliente Nomad** (`/etc/nomad.d/nomad.hcl`).

**Importante:** Volumes do tipo `host` não podem ser registrados via CLI. Eles devem ser configurados diretamente no arquivo de configuração.

Edite o arquivo `/etc/nomad.d/nomad.hcl` e adicione os volumes host na seção `client`:

```bash
sudo nano /etc/nomad.d/nomad.hcl
```

Adicione ou atualize a seção `client`:

```hcl
client {
  enabled = true
  
  host_volume "keycloak_data" {
    path      = "/opt/nomad/volumes/keycloak_data"
    read_only = false
  }
  
  host_volume "ollama_data" {
    path      = "/opt/nomad/volumes/ollama_data"
    read_only = false
  }
}
```

Crie os diretórios e reinicie o Nomad:

```bash
# Criar diretórios dos volumes
sudo mkdir -p /opt/nomad/volumes/keycloak_data
sudo mkdir -p /opt/nomad/volumes/ollama_data

# Dar permissões adequadas
sudo chown -R root:root /opt/nomad/volumes
sudo chmod -R 755 /opt/nomad/volumes

# Reiniciar Nomad para aplicar mudanças
sudo systemctl restart nomad

# Verificar se os volumes estão disponíveis
nomad node status -self
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

### Erro: "Volume not found" ou "missing compatible host volumes"

**Sintomas:**
```
Constraint "missing compatible host volumes": 1 nodes excluded by filter
```

**Soluções:**

1. **Verificar se os volumes estão configurados no cliente Nomad:**
   ```bash
   # Verificar configuração do cliente
   nomad node status -self
   
   # Ver volumes registrados
   nomad volume status
   ```

2. **Configurar volumes host no arquivo nomad.hcl:**
   ```bash
   # Editar configuração
   sudo nano /etc/nomad.d/nomad.hcl
   
   # Adicionar na seção client:
   client {
     enabled = true
     
     host_volume "keycloak_data" {
       path      = "/opt/nomad/volumes/keycloak_data"
       read_only = false
     }
     
     host_volume "ollama_data" {
       path      = "/opt/nomad/volumes/ollama_data"
       read_only = false
     }
   }
   
   # Criar diretórios
   sudo mkdir -p /opt/nomad/volumes/keycloak_data
   sudo mkdir -p /opt/nomad/volumes/ollama_data
   
   # Reiniciar Nomad
   sudo systemctl restart nomad
   ```

3. **Verificar se os volumes estão configurados corretamente:**
   ```bash
   # Verificar configuração do nó
   nomad node status -self
   
   # Verificar se o Nomad está rodando com a nova configuração
   sudo systemctl status nomad
   ```

4. **Verificar se os diretórios existem e têm permissões corretas:**
   ```bash
   ls -la /opt/nomad/volumes/
   sudo chown -R root:root /opt/nomad/volumes
   sudo chmod -R 755 /opt/nomad/volumes
   ```

### Erro: "Cannot connect to Nomad" ou "connection refused"

**Sintomas:**
```
Error submitting job: Put "http://127.0.0.1:4646/v1/jobs": dial tcp 127.0.0.1:4646: connect: connection refused
```

**Soluções:**

1. **Verificar se o Nomad está rodando:**
   ```bash
   # Verificar status do serviço (Linux)
   sudo systemctl status nomad
   
   # Ou verificar processos
   ps aux | grep nomad
   ```

2. **Iniciar o Nomad em modo dev (para desenvolvimento local):**
   ```bash
   nomad agent -dev
   ```
   Isso iniciará um servidor Nomad local em `http://127.0.0.1:4646`

3. **Configurar NOMAD_ADDR para servidor remoto:**
   ```bash
   export NOMAD_ADDR=http://seu-servidor-nomad:4646
   # ou adicione ao seu arquivo .env
   echo "NOMAD_ADDR=http://seu-servidor-nomad:4646" >> .env
   ```

4. **Verificar conectividade:**
   ```bash
   # Testar conexão
   nomad server members
   # ou
   curl http://127.0.0.1:4646/v1/status/leader
   ```

5. **Se estiver usando um servidor remoto, verifique:**
   - Se o servidor está acessível na rede
   - Se a porta 4646 está aberta no firewall
   - Se há autenticação necessária (configure `NOMAD_TOKEN`)

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
