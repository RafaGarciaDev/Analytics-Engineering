# Arquitetura da Plataforma de Analytics Engineering

## Visão Geral

Esta plataforma implementa uma arquitetura moderna de Analytics Engineering seguindo o padrão **Medallion Architecture** (Bronze, Silver, Gold) com foco em qualidade, governança e escalabilidade.

## Componentes Principais

### 1. Camada de Ingestão (Bronze/Raw)

**Responsabilidade**: Armazenar dados brutos sem transformação

- **Localização**: Schema `raw`
- **Formato**: Dados tal como extraídos das fontes
- **Fontes de Dados**:
  - Banco de dados transacional (PostgreSQL)
  - APIs externas
  - Arquivos CSV/JSON
  - Event streams

**Características**:
- Imutabilidade dos dados
- Timestamping de ingestão
- Preservação da estrutura original
- Auditoria completa

### 2. Camada de Staging (Silver)

**Responsabilidade**: Limpeza, padronização e enriquecimento

- **Localização**: Schema `staging`
- **Materialização**: Views (para eficiência)
- **Transformações**:
  - Renomeação de colunas para padrão snake_case
  - Conversão de tipos de dados
  - Cálculos básicos (margens, totais)
  - Flags e categorizações simples
  - Remoção de duplicatas
  - Tratamento de valores nulos

**Modelos**:
- `stg_customers` - Dados de clientes limpos
- `stg_orders` - Pedidos padronizados
- `stg_products` - Catálogo de produtos
- `stg_order_items` - Itens de pedidos

### 3. Camada Intermediate

**Responsabilidade**: Lógica de negócio complexa e agregações intermediárias

- **Materialização**: Ephemeral (não persiste)
- **Uso**: Módulos reutilizáveis entre marts
- **Exemplos**:
  - Cálculos de cohort
  - Agregações temporárias
  - Joins complexos

### 4. Camada de Marts (Gold)

**Responsabilidade**: Modelos otimizados para consumo analítico

- **Localização**: Schema `marts`
- **Materialização**: Tables (para performance)
- **Estrutura**: Organizado por domínio de negócio

#### 4.1 Core Marts

**Fatos (Facts)**:
- `fct_orders` - Transações de pedidos com métricas
  - Grain: Um registro por pedido
  - Métricas: Receita, itens, descontos
  - Dimensões: Customer, Order Status, Payment

**Dimensões (Dimensions)**:
- `dim_customers` - Dimensão de clientes
  - SCD Type 1 (slowly changing dimension)
  - Métricas de lifetime: LTV, total orders
  - Segmentação: RFM, valor, comportamento
  
- `dim_products` - Dimensão de produtos
  - Catálogo completo
  - Métricas de performance
  - Classificação por vendas

- `dim_date` - Dimensão calendário
  - Granularidade diária
  - Atributos: ano, mês, trimestre, semana
  - Flags: dia útil, feriado

#### 4.2 Finance Marts

- `revenue_metrics` - Métricas financeiras
  - Receita diária/mensal
  - Crescimento WoW/MoM
  - Running totals
  - KPIs financeiros

#### 4.3 Marketing Marts

- `customer_metrics` - Métricas de cliente
  - Análise de cohort
  - CLV (Customer Lifetime Value)
  - Retenção
  - Segmentação

## Stack Tecnológico

### Transformação de Dados
- **dbt (Data Build Tool)**
  - Transformações SQL declarativas
  - Versionamento de código
  - Testes automatizados
  - Documentação gerada automaticamente
  - Linhagem de dados (lineage)

### Orquestração
- **Apache Airflow**
  - Agendamento de pipelines
  - Retry logic
  - Monitoring e alertas
  - Dependency management

### Data Warehouse
- **PostgreSQL** (Demo)
  - Pode ser substituído por:
    - Snowflake
    - BigQuery
    - Redshift
    - Databricks

### Qualidade de Dados
- **dbt Tests**
  - Schema tests (unique, not_null, relationships)
  - Data tests (accepted values, ranges)
  - Custom tests
  - Freshness checks

- **Great Expectations** (planejado)
  - Validações avançadas
  - Profiling de dados
  - Data quality reports

### CI/CD
- **GitHub Actions**
  - Testes automatizados em PRs
  - Deployment automático
  - Linting de SQL (SQLFluff)
  - Validação de modelos

## Padrões e Convenções

### Nomenclatura

**Fontes (Sources)**:
- Prefixo: `raw_`
- Exemplo: `raw_customers`, `raw_orders`

**Staging**:
- Prefixo: `stg_`
- Exemplo: `stg_customers`, `stg_orders`

**Intermediate**:
- Prefixo: `int_`
- Exemplo: `int_customer_orders`

**Facts**:
- Prefixo: `fct_`
- Exemplo: `fct_orders`, `fct_sessions`

**Dimensions**:
- Prefixo: `dim_`
- Exemplo: `dim_customers`, `dim_products`

**Metrics/Reports**:
- Sufixo descritivo
- Exemplo: `revenue_metrics`, `customer_metrics`

### Materializações

| Camada | Materialização | Motivo |
|--------|---------------|---------|
| Staging | View | Sempre dados frescos, transformações leves |
| Intermediate | Ephemeral | Não precisa persistir |
| Marts | Table | Performance para queries analíticas |
| Metrics | Table | Cálculos complexos, uso frequente |

### Testes

**Por Modelo**:
- Primary keys: unique + not_null
- Foreign keys: relationships
- Business rules: custom tests
- Freshness: quando aplicável

**Cobertura**:
- 100% dos fatos e dimensões
- Validação de métricas críticas
- Testes de integridade referencial

## Fluxo de Dados

```
┌─────────────┐
│   Sources   │ (raw_*)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Staging   │ (stg_*)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│Intermediate │ (int_*)
└──────┬──────┘
       │
       ├─────────────┬─────────────┐
       ▼             ▼             ▼
┌──────────┐  ┌──────────┐  ┌──────────┐
│   Core   │  │ Finance  │  │Marketing │
│ (fct_*,  │  │ (*metrics)│  │(*metrics)│
│  dim_*)  │  │          │  │          │
└──────────┘  └──────────┘  └──────────┘
```

## Governança de Dados

### Documentação
- Todas as tabelas documentadas
- Todas as colunas com descrições
- Linhagem de dados visível
- Dicionário de dados mantido

### Qualidade
- Testes em todos os modelos
- Monitoramento de freshness
- Alertas de falhas
- SLAs definidos

### Segurança
- Controle de acesso por schema
- Dados sensíveis mascarados
- Auditoria de acessos
- Compliance (LGPD/GDPR)

## Performance

### Otimizações Implementadas
- Modelos incrementais para grandes volumes
- Particionamento por data
- Índices em chaves primárias
- Agregações pré-calculadas

### Monitoramento
- Tempo de execução dos modelos
- Uso de recursos
- Qualidade dos dados
- Freshness

## Escalabilidade

### Horizontal
- Novos modelos facilmente adicionados
- Estrutura modular
- Reutilização de código via macros

### Vertical
- Pode escalar para cloud warehouses
- Suporta grandes volumes
- Processamento distribuído (se necessário)

## Próximos Passos

1. **Adicionar mais fontes de dados**
   - API integrations
   - Event streaming (Kafka)
   
2. **Expandir testes**
   - Great Expectations
   - Deequ (data quality)

3. **Melhorar observabilidade**
   - Data lineage visual
   - Impact analysis
   - Cost monitoring

4. **Adicionar BI layer**
   - Metabase
   - Looker
   - Tableau

5. **MLOps integration**
   - Feature store
   - Model monitoring
   - A/B testing framework
