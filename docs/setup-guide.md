# Guia de Setup - Analytics Engineering Platform

## Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- **Docker** (versão 20.10+)
- **Docker Compose** (versão 2.0+)
- **Git**
- **Python 3.11+** (opcional, para desenvolvimento local)
- **Make** (opcional, mas recomendado)

## Setup Rápido

### 1. Clone o Repositório

```bash
git clone https://github.com/seu-usuario/analytics-engineering-platform.git
cd analytics-engineering-platform
```

### 2. Configuração Inicial

Execute o comando de setup que irá:
- Criar o arquivo `.env` a partir do `.env.example`
- Criar os diretórios necessários

```bash
make setup
```

### 3. Inicie os Containers

```bash
make up
```

Este comando irá iniciar:
- PostgreSQL (porta 5432)
- Airflow Webserver (porta 8080)
- Airflow Scheduler
- dbt Docs Server (porta 8081)

### 4. Acesse as Interfaces

Aguarde alguns minutos para os serviços iniciarem completamente, então acesse:

- **Airflow**: http://localhost:8080
  - Usuário: `admin`
  - Senha: `admin`

- **dbt Docs**: http://localhost:8081 (será gerado após primeira execução)

- **PostgreSQL**: 
  - Host: `localhost`
  - Port: `5432`
  - Database: `analytics`
  - User: `analytics_user`
  - Password: `analytics_password`

### 5. Execute os Modelos dbt

```bash
# Instalar dependências do dbt
make dbt-deps

# Carregar dados seed (se disponível)
make seed

# Executar todos os modelos
make dbt-run

# Executar testes
make dbt-test

# Gerar documentação
make dbt-docs
```

## Setup Detalhado

### Instalação Local (sem Docker)

Se você preferir executar localmente:

#### 1. Crie um Ambiente Virtual

```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate  # Windows
```

#### 2. Instale as Dependências

```bash
pip install -r requirements.txt
```

#### 3. Configure o PostgreSQL

Certifique-se de ter o PostgreSQL instalado e rodando, então crie o banco:

```bash
createdb analytics
```

#### 4. Configure o arquivo profiles.yml

Edite `dbt/profiles.yml` com suas credenciais locais.

#### 5. Execute os Comandos dbt

```bash
cd dbt

# Testar conexão
dbt debug

# Instalar dependências
dbt deps

# Executar modelos
dbt run

# Executar testes
dbt test

# Gerar documentação
dbt docs generate
dbt docs serve
```

## Estrutura de Comandos Make

### Comandos Principais

```bash
make help           # Mostra todos os comandos disponíveis
make setup          # Setup inicial do projeto
make up             # Inicia os containers
make down           # Para os containers
make restart        # Reinicia os containers
make logs           # Mostra logs dos containers
```

### Comandos dbt

```bash
make dbt-deps       # Instala dependências dbt
make dbt-run        # Executa modelos
make dbt-test       # Executa testes
make dbt-docs       # Gera e serve documentação
make dbt-debug      # Debug de conexão
make dbt-compile    # Compila modelos
make dbt-clean      # Limpa artefatos
```

### Comandos de Dados

```bash
make seed           # Carrega dados seed
make snapshot       # Cria snapshots
make init-db        # Inicializa DB com dados sample
```

### Comandos de Qualidade

```bash
make lint           # Executa linting SQL
make format         # Formata arquivos SQL
make validate       # Valida qualidade dos dados
make test-all       # Executa todos os testes
```

### Comandos de Deploy

```bash
make build          # Build completo (deps + run + test)
make deploy-dev     # Deploy para dev
make deploy-prod    # Deploy para prod
make full-refresh   # Full refresh dos modelos
```

### Comandos de Limpeza

```bash
make clean          # Limpa artefatos do projeto
make dbt-clean      # Limpa artefatos dbt
```

## Configuração do Ambiente

### Variáveis de Ambiente

Edite o arquivo `.env` conforme necessário:

```bash
# Database
DB_HOST=postgres
DB_PORT=5432
DB_NAME=analytics
DB_USER=analytics_user
DB_PASSWORD=analytics_password

# Airflow
AIRFLOW_UID=50000
_AIRFLOW_WWW_USER_USERNAME=admin
_AIRFLOW_WWW_USER_PASSWORD=admin

# dbt
DBT_PROFILES_DIR=/dbt

# Environment
ENVIRONMENT=dev
```

## Gerando Dados de Teste

Para gerar dados de teste:

```bash
# Instalar dependências (se rodando local)
pip install faker

# Executar script de seed
python scripts/seed_data.py

# Os dados serão gerados em data/sample/
```

## Troubleshooting

### Containers não iniciam

```bash
# Verifique os logs
docker-compose logs

# Recrie os containers
make down
make up
```

### Erro de conexão com PostgreSQL

```bash
# Verifique se o PostgreSQL está rodando
docker-compose ps

# Teste a conexão
docker-compose exec postgres psql -U analytics_user -d analytics
```

### dbt não encontra os modelos

```bash
# Verifique o dbt_project.yml
cd dbt
dbt debug

# Limpe e reconstrua
dbt clean
dbt deps
dbt run
```

### Permissões no Linux

Se você tiver problemas de permissão no Linux:

```bash
# Ajuste o AIRFLOW_UID no .env
echo "AIRFLOW_UID=$(id -u)" >> .env

# Recrie os containers
make down
make up
```

### Porta já em uso

Se alguma porta estiver em uso, você pode alterar no `docker-compose.yml`:

```yaml
ports:
  - "8080:8080"  # Altere para "8081:8080" se a porta 8080 estiver ocupada
```

## Próximos Passos

Após o setup bem-sucedido:

1. ✅ Explore a documentação do dbt em http://localhost:8081
2. ✅ Verifique os DAGs no Airflow em http://localhost:8080
3. ✅ Execute os modelos e valide os resultados
4. ✅ Conecte uma ferramenta de BI (Metabase, Looker, etc.)
5. ✅ Personalize os modelos para seu caso de uso

## Recursos Adicionais

- [Documentação do dbt](https://docs.getdbt.com/)
- [Documentação do Airflow](https://airflow.apache.org/docs/)
- [Best Practices de Analytics Engineering](https://www.getdbt.com/analytics-engineering/)

## Suporte

Se você encontrar problemas:

1. Verifique a seção de Troubleshooting acima
2. Consulte os logs: `make logs`
3. Abra uma issue no GitHub
4. Entre em contato: seu.email@exemplo.com
