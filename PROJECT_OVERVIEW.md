# 📊 Analytics Engineering Platform - Visão Geral do Projeto

## 🎯 Objetivo do Portfólio

Este projeto demonstra competências completas em Analytics Engineering, incluindo:
- Modelagem de dados dimensional
- Transformações SQL com dbt
- Orquestração de pipelines
- Testes e qualidade de dados
- CI/CD e DevOps
- Documentação técnica

---

## 🏗️ Arquitetura Simplificada

```
Fontes de Dados → Bronze (Raw) → Silver (Staging) → Gold (Marts) → BI/Analytics
                      ↓              ↓                  ↓
                   Imutável     Padronizado      Otimizado
```

---

## 📁 Principais Componentes

### 1. **dbt (Transformação)**
```
dbt/
├── models/
│   ├── staging/          # Limpeza e padronização
│   │   ├── stg_customers.sql
│   │   ├── stg_orders.sql
│   │   ├── stg_products.sql
│   │   └── stg_order_items.sql
│   │
│   └── marts/            # Modelos de negócio
│       ├── core/         # Fatos e dimensões principais
│       │   ├── fct_orders.sql
│       │   ├── dim_customers.sql
│       │   └── dim_products.sql
│       │
│       ├── finance/      # Métricas financeiras
│       │   └── revenue_metrics.sql
│       │
│       └── marketing/    # Métricas de marketing
│           └── customer_metrics.sql
```

### 2. **Airflow (Orquestração)**
```
airflow/dags/
├── daily_analytics.py    # Pipeline diário
└── weekly_reports.py     # Relatórios semanais
```

### 3. **Testes e Qualidade**
- Testes de schema (unique, not_null)
- Testes de relacionamento (foreign keys)
- Testes customizados de negócio
- Freshness checks

### 4. **CI/CD**
- GitHub Actions para testes automatizados
- Validação em cada pull request
- Deploy automatizado

---

## 💡 Conceitos Demonstrados

### Analytics Engineering
- ✅ Modelagem dimensional (Star Schema)
- ✅ Slowly Changing Dimensions (SCD)
- ✅ Incremental models
- ✅ Snapshots para histórico

### Data Quality
- ✅ Testes automatizados em múltiplas camadas
- ✅ Validação de integridade referencial
- ✅ Monitoramento de freshness
- ✅ Data lineage (linhagem)

### DevOps/DataOps
- ✅ Infrastructure as Code (Docker)
- ✅ Versionamento de transformações
- ✅ CI/CD pipeline
- ✅ Documentação como código

### Best Practices
- ✅ Código modular e reutilizável (macros)
- ✅ Nomenclatura consistente
- ✅ Separação de camadas (bronze/silver/gold)
- ✅ DRY (Don't Repeat Yourself)

---

## 📊 Modelos de Dados

### Staging Layer (Silver)
| Modelo | Descrição | Materialização |
|--------|-----------|----------------|
| `stg_customers` | Clientes limpos e padronizados | View |
| `stg_orders` | Pedidos com totais calculados | View |
| `stg_products` | Produtos com margens | View |
| `stg_order_items` | Itens de pedidos | View |

### Marts Layer (Gold)
| Modelo | Tipo | Descrição |
|--------|------|-----------|
| `fct_orders` | Fact | Transações com métricas completas |
| `dim_customers` | Dimension | Clientes com segmentação e LTV |
| `dim_products` | Dimension | Produtos com performance |
| `revenue_metrics` | Metric | KPIs financeiros diários |
| `customer_metrics` | Metric | Análise de cohort e retenção |

---

## 🚀 Como Executar

### Quick Start
```bash
# 1. Setup inicial
make setup

# 2. Iniciar containers
make up

# 3. Executar transformações
make dbt-run

# 4. Executar testes
make dbt-test

# 5. Ver documentação
make dbt-docs
```

### Acessar Interfaces
- **Airflow**: http://localhost:8080 (admin/admin)
- **dbt Docs**: http://localhost:8081
- **PostgreSQL**: localhost:5432

---

## 📈 Métricas e KPIs

### Finance
- Receita bruta/líquida
- Crescimento WoW/MoM
- Average Order Value (AOV)
- Receita acumulada

### Marketing
- Customer Lifetime Value (CLV)
- Análise de cohort
- Taxa de retenção
- Segmentação RFM

### Operacional
- Número de pedidos
- Itens por pedido
- Taxa de conversão
- Performance de produtos

---

## 🎨 Diferenciais do Projeto

1. **Arquitetura Completa**: Não é apenas SQL, mas uma solução end-to-end
2. **Production-Ready**: CI/CD, testes, documentação
3. **Modern Data Stack**: Ferramentas modernas da indústria
4. **Escalável**: Pode ser adaptado para qualquer warehouse
5. **Bem Documentado**: README, arquitetura, setup guide
6. **Código Limpo**: Seguindo best practices

---

## 🛠️ Stack Tecnológico

| Categoria | Tecnologia | Propósito |
|-----------|-----------|-----------|
| Transformação | dbt | SQL transformations |
| Orquestração | Apache Airflow | Pipeline scheduling |
| Warehouse | PostgreSQL | Data storage (demo) |
| CI/CD | GitHub Actions | Automated testing |
| Containerização | Docker | Environment consistency |
| Linting | SQLFluff | Code quality |
| Docs | dbt docs | Auto-generated documentation |

---

## 📚 Habilidades Demonstradas

### Técnicas
- SQL avançado (window functions, CTEs, aggregations)
- Modelagem dimensional
- Python (para scripts utilitários)
- Docker e containerização
- Git e versionamento

### Conceituais
- Data warehousing
- Analytics engineering
- Data quality
- CI/CD
- Documentation

### Ferramentas
- dbt
- Airflow
- PostgreSQL
- Docker
- GitHub Actions
- Make

---

## 🎓 Para Recrutadores

Este projeto demonstra:

1. **Conhecimento Profundo**: Entendimento completo do ciclo de Analytics Engineering
2. **Hands-on Experience**: Código real, funcional e testado
3. **Best Practices**: Seguindo padrões da indústria
4. **Documentação**: Capacidade de comunicar decisões técnicas
5. **Autonomia**: Projeto desenvolvido de forma independente
6. **Visão de Produto**: Pensando em escalabilidade e manutenção

---

## 📞 Contato

**[Seu Nome]**
- 📧 Email: seu.email@exemplo.com
- 💼 LinkedIn: [seu-perfil](https://linkedin.com/in/seu-perfil)
- 🐙 GitHub: [@seu-usuario](https://github.com/seu-usuario)

---

## ⭐ Próximos Passos

Melhorias futuras planejadas:
- [ ] Integração com Great Expectations
- [ ] Dashboard com Metabase/Looker
- [ ] dbt Cloud integration
- [ ] Feature store para ML
- [ ] Data catalog (DataHub)
- [ ] Cost monitoring

---

**⭐ Se este projeto foi útil para você, considere dar uma estrela no GitHub!**
