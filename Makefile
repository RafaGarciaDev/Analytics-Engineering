.PHONY: help setup up down dbt-run dbt-test dbt-docs lint clean seed validate

# Variables
DOCKER_COMPOSE = docker-compose
DBT = dbt
PYTHON = python3

# Colors for output
BLUE = \033[0;34m
GREEN = \033[0;32m
RED = \033[0;31m
NC = \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)Analytics Engineering Platform - Available Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

setup: ## Initial setup of the project
	@echo "$(BLUE)Setting up the project...$(NC)"
	@cp -n .env.example .env 2>/dev/null || true
	@echo "$(GREEN)✓ Environment file created$(NC)"
	@mkdir -p data/raw data/sample logs
	@echo "$(GREEN)✓ Directories created$(NC)"
	@echo "$(GREEN)✓ Setup complete!$(NC)"

up: ## Start all containers
	@echo "$(BLUE)Starting containers...$(NC)"
	@$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)✓ Containers started$(NC)"
	@echo "Airflow UI: http://localhost:8080"
	@echo "PostgreSQL: localhost:5432"

down: ## Stop all containers
	@echo "$(BLUE)Stopping containers...$(NC)"
	@$(DOCKER_COMPOSE) down
	@echo "$(GREEN)✓ Containers stopped$(NC)"

restart: down up ## Restart all containers

logs: ## Show container logs
	@$(DOCKER_COMPOSE) logs -f

dbt-deps: ## Install dbt dependencies
	@echo "$(BLUE)Installing dbt dependencies...$(NC)"
	@cd dbt && $(DBT) deps
	@echo "$(GREEN)✓ Dependencies installed$(NC)"

dbt-run: ## Run dbt models
	@echo "$(BLUE)Running dbt models...$(NC)"
	@cd dbt && $(DBT) run
	@echo "$(GREEN)✓ Models executed$(NC)"

dbt-run-dev: ## Run dbt models in dev
	@echo "$(BLUE)Running dbt models in dev...$(NC)"
	@cd dbt && $(DBT) run --target dev
	@echo "$(GREEN)✓ Dev models executed$(NC)"

dbt-run-prod: ## Run dbt models in prod
	@echo "$(BLUE)Running dbt models in prod...$(NC)"
	@cd dbt && $(DBT) run --target prod
	@echo "$(GREEN)✓ Prod models executed$(NC)"

dbt-test: ## Run dbt tests
	@echo "$(BLUE)Running dbt tests...$(NC)"
	@cd dbt && $(DBT) test
	@echo "$(GREEN)✓ Tests completed$(NC)"

dbt-docs: ## Generate and serve dbt docs
	@echo "$(BLUE)Generating dbt documentation...$(NC)"
	@cd dbt && $(DBT) docs generate
	@cd dbt && $(DBT) docs serve --port 8081
	@echo "$(GREEN)✓ Docs available at http://localhost:8081$(NC)"

dbt-debug: ## Debug dbt connection
	@echo "$(BLUE)Debugging dbt connection...$(NC)"
	@cd dbt && $(DBT) debug

dbt-compile: ## Compile dbt models
	@echo "$(BLUE)Compiling dbt models...$(NC)"
	@cd dbt && $(DBT) compile
	@echo "$(GREEN)✓ Models compiled$(NC)"

dbt-clean: ## Clean dbt artifacts
	@echo "$(BLUE)Cleaning dbt artifacts...$(NC)"
	@cd dbt && $(DBT) clean
	@echo "$(GREEN)✓ Cleaned$(NC)"

seed: ## Load seed data
	@echo "$(BLUE)Loading seed data...$(NC)"
	@cd dbt && $(DBT) seed
	@echo "$(GREEN)✓ Seed data loaded$(NC)"

snapshot: ## Create dbt snapshots
	@echo "$(BLUE)Creating snapshots...$(NC)"
	@cd dbt && $(DBT) snapshot
	@echo "$(GREEN)✓ Snapshots created$(NC)"

lint: ## Run SQL linting
	@echo "$(BLUE)Running SQL linting...$(NC)"
	@sqlfluff lint dbt/models --dialect postgres || true
	@echo "$(GREEN)✓ Linting complete$(NC)"

format: ## Format SQL files
	@echo "$(BLUE)Formatting SQL files...$(NC)"
	@sqlfluff fix dbt/models --dialect postgres || true
	@echo "$(GREEN)✓ Formatting complete$(NC)"

validate: ## Validate data quality
	@echo "$(BLUE)Validating data quality...$(NC)"
	@$(PYTHON) scripts/validate.py
	@echo "$(GREEN)✓ Validation complete$(NC)"

clean: dbt-clean ## Clean all build artifacts
	@echo "$(BLUE)Cleaning project...$(NC)"
	@rm -rf logs/*.log
	@rm -rf dbt/target
	@rm -rf dbt/dbt_packages
	@echo "$(GREEN)✓ Project cleaned$(NC)"

full-refresh: ## Full refresh of dbt models
	@echo "$(BLUE)Running full refresh...$(NC)"
	@cd dbt && $(DBT) run --full-refresh
	@echo "$(GREEN)✓ Full refresh complete$(NC)"

test-all: dbt-test validate ## Run all tests
	@echo "$(GREEN)✓ All tests complete$(NC)"

build: dbt-deps dbt-run dbt-test ## Build and test everything
	@echo "$(GREEN)✓ Build complete$(NC)"

deploy-dev: ## Deploy to dev environment
	@echo "$(BLUE)Deploying to dev...$(NC)"
	@cd dbt && $(DBT) run --target dev
	@cd dbt && $(DBT) test --target dev
	@echo "$(GREEN)✓ Deployed to dev$(NC)"

deploy-prod: ## Deploy to prod environment
	@echo "$(BLUE)Deploying to prod...$(NC)"
	@cd dbt && $(DBT) run --target prod
	@cd dbt && $(DBT) test --target prod
	@echo "$(GREEN)✓ Deployed to prod$(NC)"

init-db: ## Initialize database with sample data
	@echo "$(BLUE)Initializing database...$(NC)"
	@$(PYTHON) scripts/seed_data.py
	@echo "$(GREEN)✓ Database initialized$(NC)"

airflow-init: ## Initialize Airflow
	@echo "$(BLUE)Initializing Airflow...$(NC)"
	@$(DOCKER_COMPOSE) run --rm airflow-init
	@echo "$(GREEN)✓ Airflow initialized$(NC)"

status: ## Show status of all services
	@echo "$(BLUE)Service Status:$(NC)"
	@$(DOCKER_COMPOSE) ps

install: setup up dbt-deps seed init-db ## Complete installation
	@echo "$(GREEN)✓ Installation complete!$(NC)"
	@echo "You can now access:"
	@echo "  - Airflow: http://localhost:8080"
	@echo "  - PostgreSQL: localhost:5432"
