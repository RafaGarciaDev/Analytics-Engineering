# 🚀 Analytics Engineering Platform

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![dbt](https://img.shields.io/badge/dbt-1.7+-orange.svg)](https://www.getdbt.com/)
[![Python](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/)
[![Airflow](https://img.shields.io/badge/airflow-2.8+-green.svg)](https://airflow.apache.org/)

Uma plataforma moderna de Analytics Engineering construída com as melhores práticas da indústria, demonstrando transformação de dados, orquestração, qualidade e governança.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Tecnologias](#tecnologias)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Início Rápido](#início-rápido)
- [Features](#features)
- [Casos de Uso](#casos-de-uso)

## 🎯 Visão Geral

Este projeto demonstra uma implementação completa de Analytics Engineering, incluindo:

- **Transformação de Dados**: Modelagem dimensional com dbt
- **Orquestração**: Pipelines automatizados com Apache Airflow
- **Qualidade de Dados**: Testes automatizados e validações
- **Documentação**: Documentação automática de dados e linhagem
- **Governança**: Controle de versão e CI/CD

### Caso de Uso: E-commerce Analytics

A plataforma processa dados de um e-commerce fictício, incluindo:
- Dados de vendas e transações
- Informações de clientes e produtos
- Métricas de marketing e campanhas
- Analytics de comportamento do usuário

## 🏗️ Arquitetura

```
┌─────────────────┐
│  Data Sources   │
│  (CSV/API/DB)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Raw Layer     │
│  (Bronze/Raw)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Staging Layer   │
│   (Silver)      │  ◄── dbt Transformations
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Marts Layer    │
│   (Gold)        │  ◄── Business Logic
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Analytics     │
│  (Dashboard/BI) │
└─────────────────┘
```

### Camadas de Dados

1. **Bronze (Raw)**: Dados brutos sem transformação
2. **Silver (Staging)**: Limpeza, padronização e enriquecimento
3. **Gold (Marts)**: Modelos dimensionais para análise

## 🛠️ Tecnologias

### Core Stack
- **dbt** - Transformação de dados e modelagem
- **Apache Airflow** - Orquestração de workflows
- **PostgreSQL** - Data Warehouse (para demo)
- **Docker** - Containerização

### Qualidade & Testes
- dbt Tests - Testes de integridade de dados
- Great Expectations - Validação de qualidade de dados
- SQLFluff - Linting de SQL

## 📁 Estrutura do Projeto

```
analytics-engineering-platform/
│
├── dbt/                          # Projeto dbt
│   ├── models/
│   │   ├── staging/             # Modelos staging (silver)
│   │   ├── intermediate/        # Modelos intermediários
│   │   └── marts/               # Modelos de negócio (gold)
│   ├── macros/                  # Macros reutilizáveis
│   ├── tests/                   # Testes customizados
│   └── seeds/                   # Dados estáticos
│
├── airflow/                     # Apache Airflow
│   ├── dags/                    # DAGs de orquestração
│   ├── plugins/                 # Plugins customizados
│   └── config/                  # Configurações
│
├── data/                        # Dados de exemplo
├── scripts/                     # Scripts utilitários
├── docs/                        # Documentação
└── tests/                       # Testes de integração
```

## 🚀 Início Rápido

### Pré-requisitos
- Docker & Docker Compose
- Python 3.11+
- Git

### Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/analytics-engineering-platform.git
cd analytics-engineering-platform
```

2. **Configure as variáveis de ambiente**
```bash
cp .env.example .env
```

3. **Inicie os containers**
```bash
make setup
make up
```

4. **Execute as transformações dbt**
```bash
make dbt-run
```

5. **Acesse as interfaces**
- Airflow: http://localhost:8080
- dbt Docs: http://localhost:8081
- PostgreSQL: localhost:5432

## ✨ Features

### 1. Transformação de Dados (dbt)
- Modelagem Dimensional: Star schema com fatos e dimensões
- Incremental Models: Processamento eficiente
- Snapshots: Histórico de mudanças (SCD Type 2)
- Testes Automatizados: Validação de qualidade

### 2. Orquestração (Airflow)
- DAGs Modulares: Workflows organizados
- Retry Logic: Tratamento de falhas
- Monitoring: Alertas e notificações
- Scheduling: Execução automatizada

### 3. Qualidade de Dados
- Schema Tests: Validação de estrutura
- Data Tests: Validação de valores
- Freshness Checks: Verificação de atualização

### 4. Documentação
- Auto-generated Docs: Documentação automática via dbt
- Data Lineage: Rastreamento de origem dos dados
- Data Dictionary: Catálogo de dados

## 💼 Casos de Uso

### Dashboard de Vendas
- Análise de receita por período
- Performance de produtos
- Análise de cohort de clientes

### Marketing Analytics
- ROI de campanhas
- Funil de conversão
- Customer Lifetime Value (CLV)

### Finance Analytics
- Métricas MRR/ARR
- Churn analysis
- Forecasting de receita

## 📝 Licença

Este projeto está sob a licença MIT.

## 👤 Autor

**Seu Nome**
- GitHub: [@seu-usuario](https://github.com/seu-usuario)
- LinkedIn: [Seu Perfil](https://linkedin.com/in/seu-perfil)

---

⭐ Se este projeto foi útil, considere dar uma estrela!
