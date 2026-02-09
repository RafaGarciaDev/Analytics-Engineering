# 🚀 Guia de Setup Rápido

Este guia vai te ajudar a colocar a plataforma de analytics engineering rodando em menos de 10 minutos.

## Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- ✅ [Docker](https://docs.docker.com/get-docker/) (v20.10+)
- ✅ [Docker Compose](https://docs.docker.com/compose/install/) (v2.0+)
- ✅ [Git](https://git-scm.com/downloads)
- ✅ [Make](https://www.gnu.org/software/make/) (opcional, mas recomendado)

### Verificar instalação:

```bash
docker --version
docker-compose --version
git --version
make --version  # opcional
```

## Setup em 5 Passos

### 1️⃣ Clone o repositório

```bash
git clone https://github.com/seu-usuario/analytics-engineering-platform.git
cd analytics-engineering-platform
```

### 2️⃣ Configure as variáveis de ambiente

```bash
# Usando Make (recomendado)
make setup

# OU manualmente
cp .env.example .env
mkdir -p airflow/logs airflow/plugins data/raw data/processed
```

**Opcional:** Edite o arquivo `.env` se quiser customizar as credenciais.

### 3️⃣ Inicie os containers

```bash
# Com Make
make up

# OU com Docker Compose
docker-compose up -d
```

Este comando irá:
- Baixar as imagens Docker necessárias
- Criar e iniciar os containers
- Inicializar o banco de dados com dados de exemplo
- Configurar o Airflow

⏱️ **Tempo estimado:** 3-5 minutos (primeira vez)

### 4️⃣ Aguarde os serviços iniciarem

```bash
# Verificar status dos containers
docker-compose ps

# Acompanhar os logs
docker-compose logs -f
```

Aguarde até ver mensagens como:
```
airflow-webserver | Airflow is ready
postgres | database system is ready to accept connections
```

### 5️⃣ Acesse as interfaces

Abra seu navegador e acesse:

| Serviço | URL | Credenciais |
|---------|-----|-------------|
| **Airflow** | http://localhost:8080 | admin / admin |
| **dbt Docs** | http://localhost:8081 | - |
| **PostgreSQL** | localhost:5432 | airflow / airflow |

## Executar o Pipeline

### Opção 1: Via Airflow UI

1. Acesse http://localhost:8080
2. Login com `admin` / `admin`
3. Encontre a DAG `analytics_pipeline`
4. Clique no botão ▶️ (trigger) para executar

### Opção 2: Via linha de comando

```bash
# Com Make
make pipeline

# OU com docker-compose
docker-compose exec dbt dbt deps
docker-compose exec dbt dbt seed --profiles-dir .
docker-compose exec dbt dbt run --profiles-dir .
docker-compose exec dbt dbt test --profiles-dir .
docker-compose exec dbt dbt docs generate --profiles-dir .
```

## Verificar Resultados

### 1. Checar tabelas criadas

```bash
# Conectar ao PostgreSQL
docker-compose exec postgres psql -U airflow -d analytics

# Listar schemas
\dn

# Listar tabelas do schema marts
\dt marts.*

# Query de exemplo
SELECT * FROM marts.dim_customers LIMIT 5;
SELECT * FROM marts.fct_orders LIMIT 5;
SELECT * FROM marts.agg_daily_sales ORDER BY order_date DESC LIMIT 7;

# Sair
\q
```

### 2. Ver documentação do dbt

Acesse http://localhost:8081 para explorar:
- 📊 Lineage graph (dependências entre modelos)
- 📝 Documentação de cada modelo
- ✅ Testes aplicados
- 📈 Métricas de execução

### 3. Explorar logs do Airflow

```bash
# Logs gerais
docker-compose logs airflow-scheduler

# Logs de uma task específica
# Vá para Airflow UI → DAGs → analytics_pipeline → Graph → Clique em uma task → Logs
```

## Comandos Úteis

### Gestão de Containers

```bash
# Parar todos os serviços
make down
# OU
docker-compose down

# Reiniciar serviços
make restart

# Ver logs em tempo real
make logs
```

### Comandos dbt

```bash
# Executar apenas staging
make dbt-run-staging

# Executar apenas marts
make dbt-run-marts

# Executar testes
make dbt-test

# Compilar modelos (sem executar)
make dbt-compile

# Debug de conexão
make dbt-debug
```

### Banco de Dados

```bash
# Conectar ao PostgreSQL
make db-connect

# Reinicializar dados de exemplo
make db-init
```

## Estrutura de Dados

### Tabelas Raw (public schema)

- `raw_customers` - Dados de clientes
- `raw_products` - Catálogo de produtos
- `raw_orders` - Pedidos

### Modelos dbt

**Staging (bronze):**
- `stg_orders` - Pedidos limpos
- `stg_customers` - Clientes limpos
- `stg_products` - Produtos limpos

**Intermediate (silver):**
- `int_orders_enriched` - Pedidos enriquecidos com dados de clientes

**Marts (gold):**
- `fct_orders` - Fatos de pedidos
- `dim_customers` - Dimensão de clientes
- `dim_products` - Dimensão de produtos
- `agg_daily_sales` - Agregações diárias

## Exemplos de Queries

### 1. Total de vendas por categoria

```sql
SELECT 
    p.category,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(o.total_amount) as total_revenue,
    AVG(o.total_amount) as avg_order_value
FROM marts.fct_orders o
JOIN marts.dim_products p ON o.product_id = p.product_id
WHERE o.is_completed = true
GROUP BY p.category
ORDER BY total_revenue DESC;
```

### 2. Clientes por segmento

```sql
SELECT 
    customer_segment,
    COUNT(*) as customer_count,
    SUM(lifetime_value) as total_ltv,
    AVG(lifetime_value) as avg_ltv
FROM marts.dim_customers
GROUP BY customer_segment
ORDER BY total_ltv DESC;
```

### 3. Tendência de vendas diárias

```sql
SELECT 
    order_date,
    total_revenue,
    total_orders,
    avg_order_value,
    unique_customers
FROM marts.agg_daily_sales
ORDER BY order_date DESC
LIMIT 30;
```

## Solução de Problemas

### Problema: Containers não iniciam

```bash
# Verificar logs
docker-compose logs

# Verificar se as portas estão em uso
sudo lsof -i :8080  # Airflow
sudo lsof -i :5432  # PostgreSQL

# Limpar tudo e começar de novo
make clean
make up
```

### Problema: dbt não encontra tabelas

```bash
# Verificar conexão
make dbt-debug

# Recriar banco de dados
make db-init

# Executar seeds
make dbt-seed
```

### Problema: Airflow DAG não aparece

```bash
# Reiniciar scheduler
docker-compose restart airflow-scheduler

# Verificar logs
docker-compose logs airflow-scheduler

# Aguardar alguns segundos - DAGs são escaneadas periodicamente
```

### Problema: Permissões no Linux

```bash
# Ajustar UID do Airflow
echo "AIRFLOW_UID=$(id -u)" >> .env

# Recriar containers
make down
make up
```

## Próximos Passos

Agora que sua plataforma está rodando:

1. 📚 Leia a [Documentação de Arquitetura](docs/ARCHITECTURE.md)
2. 🧪 Experimente modificar os modelos dbt
3. 📊 Crie novos modelos e métricas
4. 🔄 Configure a DAG para rodar periodicamente
5. 📈 Conecte uma ferramenta de BI (Metabase, Superset, etc.)

## Recursos Adicionais

- [dbt Documentation](https://docs.getdbt.com/)
- [Airflow Documentation](https://airflow.apache.org/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Documentation](https://docs.docker.com/)

## Suporte

Encontrou algum problema? 

1. Verifique os [Issues](https://github.com/seu-usuario/analytics-engineering-platform/issues)
2. Consulte a documentação
3. Abra uma issue detalhando o problema

---

**Parabéns! 🎉** Sua plataforma de Analytics Engineering está pronta para uso!
