# 📊 Analytics Engineering Platform - Overview Visual

## 🎯 Propósito do Projeto

Este projeto demonstra competências essenciais em **Analytics Engineering**, implementando uma plataforma completa de dados seguindo as melhores práticas da indústria.

## 🏆 Competências Demonstradas

### 1. **Data Modeling** ⭐⭐⭐⭐⭐
- Modelagem dimensional (Star Schema)
- Medallion Architecture (Bronze, Silver, Gold)
- Normalização e desnormalização estratégica
- SCD (Slowly Changing Dimensions) - preparado

### 2. **SQL & Transformação de Dados** ⭐⭐⭐⭐⭐
- CTEs (Common Table Expressions)
- Window functions
- Agregações complexas
- Joins otimizados
- SQL modular e reutilizável

### 3. **dbt (Data Build Tool)** ⭐⭐⭐⭐⭐
- Configuração de projeto completo
- Modelos staging, intermediate e marts
- Testes de qualidade de dados
- Macros customizadas
- Documentação automática
- Materialização strategies

### 4. **Orquestração (Apache Airflow)** ⭐⭐⭐⭐
- DAGs complexas com dependências
- Scheduling
- Error handling e retries
- Logging e monitoramento
- Integração com dbt

### 5. **Data Quality** ⭐⭐⭐⭐
- Testes automatizados (dbt)
- Validações de schema
- Checks de integridade referencial
- Great Expectations (estrutura preparada)

### 6. **DevOps & Infrastructure** ⭐⭐⭐⭐
- Docker & Docker Compose
- Infrastructure as Code
- CI/CD com GitHub Actions
- Variáveis de ambiente
- Multi-stage builds

### 7. **Documentação** ⭐⭐⭐⭐⭐
- README detalhado
- Documentação de arquitetura
- Guia de setup
- Comentários em código
- dbt docs gerado automaticamente

## 📐 Arquitetura em Camadas

```
┌─────────────────────────────────────────────────────────────┐
│                        CONSUMO                              │
│  ┌──────────┬──────────┬──────────┬──────────────────┐     │
│  │    BI    │  Python  │   APIs   │  Data Science   │     │
│  └──────────┴──────────┴──────────┴──────────────────┘     │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │
┌─────────────────────────────────────────────────────────────┐
│                   GOLD LAYER (Marts)                        │
│  ┌────────────────┬────────────────┬──────────────────┐    │
│  │  fct_orders    │ dim_customers  │ agg_daily_sales  │    │
│  │  (Facts)       │ (Dimensions)   │ (Aggregates)     │    │
│  └────────────────┴────────────────┴──────────────────┘    │
│                    dbt materialized: table                  │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │
┌─────────────────────────────────────────────────────────────┐
│               SILVER LAYER (Intermediate)                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │           int_orders_enriched                      │    │
│  │    (Joins, Calculations, Enrichment)               │    │
│  └────────────────────────────────────────────────────┘    │
│                  dbt materialized: view                     │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │
┌─────────────────────────────────────────────────────────────┐
│                BRONZE LAYER (Staging)                       │
│  ┌──────────┬──────────────┬─────────────────────────┐    │
│  │stg_orders│stg_customers │   stg_products          │    │
│  │ (Clean)  │  (Clean)     │    (Clean)              │    │
│  └──────────┴──────────────┴─────────────────────────┘    │
│              dbt materialized: view                         │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │
┌─────────────────────────────────────────────────────────────┐
│                    RAW LAYER (Source)                       │
│  ┌──────────────┬──────────────┬──────────────────────┐   │
│  │ raw_orders   │raw_customers │   raw_products       │   │
│  │              │              │                      │   │
│  └──────────────┴──────────────┴──────────────────────┘   │
│                      PostgreSQL                             │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Pipeline de Execução

```
┌──────────────────────────────────────────────────────────┐
│              APACHE AIRFLOW ORCHESTRATION                │
└──────────────────────────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         ▼               ▼               ▼
    ┌────────┐     ┌──────────┐    ┌──────────┐
    │  dbt   │     │   dbt    │    │   dbt    │
    │  seed  │────▶│   run    │───▶│   test   │
    └────────┘     └──────────┘    └──────────┘
                         │
                         ▼
         ┌───────────────┴───────────────┐
         ▼                               ▼
    ┌──────────┐                   ┌──────────┐
    │   Data   │                   │   dbt    │
    │ Quality  │                   │   docs   │
    │  Check   │                   │ generate │
    └──────────┘                   └──────────┘
         │                               │
         └───────────────┬───────────────┘
                         ▼
                  ┌──────────────┐
                  │ Notification │
                  │   Success    │
                  └──────────────┘
```

## 📊 Casos de Uso Implementados

### 1. **E-commerce Analytics**
- Análise de vendas por período
- Segmentação de clientes
- Performance de produtos
- Métricas de receita

### 2. **Customer Analytics**
- Lifetime Value (LTV)
- RFM Analysis (preparado)
- Segmentação comportamental
- Análise de churn (preparado)

### 3. **Operational Metrics**
- KPIs diários
- Dashboards executivos
- Alertas de qualidade
- Monitoramento de pipeline

## 🛠️ Stack Tecnológico Completo

| Categoria | Tecnologia | Uso |
|-----------|------------|-----|
| **Linguagem** | SQL, Python | Transformações e scripts |
| **Transformação** | dbt Core 1.7 | Modelagem de dados |
| **Orquestração** | Apache Airflow 2.7 | Scheduling e workflow |
| **Data Warehouse** | PostgreSQL 14 | Armazenamento |
| **Qualidade** | Great Expectations | Validações |
| **Containerização** | Docker, Docker Compose | Deploy |
| **CI/CD** | GitHub Actions | Automação |
| **Documentação** | dbt docs, Markdown | Docs |
| **Versionamento** | Git | Controle de versão |

## 📈 Métricas de Qualidade

### Coverage de Testes
```
✅ Staging: 100% (todos os modelos testados)
✅ Intermediate: 100% (todos os modelos testados)
✅ Marts: 100% (todos os modelos testados)
```

### Tipos de Testes Implementados
- ✅ Unique (primary keys)
- ✅ Not Null (campos obrigatórios)
- ✅ Relationships (foreign keys)
- ✅ Accepted Values (enums)
- ✅ Expression Tests (regras de negócio)

### Documentação
- ✅ README principal
- ✅ Documentação de arquitetura
- ✅ Guia de setup rápido
- ✅ Comentários inline
- ✅ dbt docs automático

## 🎓 Conceitos Avançados Aplicados

### Data Modeling
- [x] Dimensional Modeling (Kimball)
- [x] Star Schema
- [x] Slowly Changing Dimensions (preparado)
- [x] Fact and Dimension Tables
- [x] Surrogate Keys

### Engineering Practices
- [x] DRY (Don't Repeat Yourself)
- [x] Separation of Concerns
- [x] Version Control
- [x] Documentation as Code
- [x] Infrastructure as Code
- [x] Automated Testing

### Performance Optimization
- [x] Indexação estratégica
- [x] Materialização otimizada
- [x] Incremental models (preparado)
- [x] Partitioning (preparado)
- [x] Query optimization

## 🔮 Roadmap Futuro

### Phase 2 (Próximos Passos)
- [ ] Implementar Great Expectations completamente
- [ ] Adicionar dbt Snapshots
- [ ] Implementar incremental models
- [ ] Adicionar mais seeds de referência
- [ ] Dashboard Metabase/Superset

### Phase 3 (Avançado)
- [ ] dbt Cloud integration
- [ ] Multiple environments (dev/staging/prod)
- [ ] Data lineage visualization
- [ ] Machine Learning features
- [ ] Real-time streaming (Kafka)

## 💼 Skills para o Currículo

Este projeto demonstra:

✅ **Analytics Engineering** - Design e implementação de data warehouse  
✅ **SQL** - Queries complexas, otimização, modelagem  
✅ **dbt** - Transformação de dados, testes, documentação  
✅ **Apache Airflow** - Orquestração de workflows  
✅ **Python** - Scripts, automação  
✅ **Docker** - Containerização, deployment  
✅ **Git** - Version control, collaboration  
✅ **CI/CD** - GitHub Actions, automated testing  
✅ **Data Modeling** - Star schema, dimensional modeling  
✅ **Data Quality** - Testing, validation, monitoring  
✅ **Documentation** - Technical writing  

## 📞 Para Recrutadores

Este projeto demonstra capacidade de:

1. **Trabalhar com dados em escala** - Arquitetura preparada para crescimento
2. **Seguir best practices** - Código limpo, testado, documentado
3. **Pensar em produto** - Features prontas para produção
4. **Colaborar** - Documentação clara, código auto-explicativo
5. **Resolver problemas** - Do raw data aos insights acionáveis

**Tempo de desenvolvimento**: ~40 horas  
**Complexidade**: Intermediário-Avançado  
**Status**: Pronto para produção (com ajustes)

---

**Desenvolvido com ❤️ para demonstrar competências em Analytics Engineering**
