.PHONY: all

AIRFLOW_COMPOSE_FILE := ./exp004/docker-compose.yml
AIRFLOW_DOCKERFILE_LOC := ./exp004/
AIRFLOW_IMAGE_NAME := airflow-cosmos

COMPOSE_FILE := ../iceberg/docker-compose.yml
DOCKER_COMPOSE := $(shell if command -v docker compose >/dev/null 2>&1; then echo "docker compose"; else echo "docker-compose"; fi)
SQL_PATH := ./sql/

# Start Airflow stack
airflow-run:
	@AIRFLOW_IMAGE_NAME=$(AIRFLOW_IMAGE_NAME) $(DOCKER_COMPOSE) -f $(AIRFLOW_COMPOSE_FILE) up

# Stop Airflow stack
airflow-down:
	@$(DOCKER_COMPOSE) -f $(AIRFLOW_COMPOSE_FILE) down

# Build custom Airflow Docker image
build-airflow-cosmos:
	docker build -t $(AIRFLOW_IMAGE_NAME) $(AIRFLOW_DOCKERFILE_LOC)
# Create external Iceberg catalog
create-iceberg-catalog:
	@cd $(SQL_PATH) && python create_iceberg_catalog.py && cd -

# Shutdown DB container
docker-down:
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) down

# Create DB container
docker-run:
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up

# Open SQL prompt
open-sql-prompt:
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) exec starrocks-fe mysql -P 9030 -h 127.0.0.1 -u root --prompt="StarRocks > "

# Setup for running the tests
install-deps:
	@pip install -r requirements.txt