.PHONY: all

COMPOSE_FILE := ../iceberg/docker-compose.yml
DOCKER_COMPOSE := $(shell if command -v docker compose >/dev/null 2>&1; then echo "docker compose"; else echo "docker-compose"; fi)
SQL_PATH := ./sql/create_iceberg_catalog.sql

# Create external Iceberg catalog
create-iceberg-catalog:
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) exec -T starrocks-fe mysql -P 9030 -h 127.0.0.1 -u root < $(SQL_PATH)

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