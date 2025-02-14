# poc-airflow-dbt

This repository contains the documentation and code related to the Radiant POC.

## Directory structure

- `docs/experiments`: Experiment journals and resources (image files). 
- `radiant`: Various code files
  - `radiant/experiments`: Contains all the experiments' code and configuration.  
  - `radiant/iceberg`: `docker-compose.yml` specification & is used as the `docker compose` workspace. 

> **Note**:
> 
> Experiments `exp001`, `exp002`, `exp004` all use the same Stack, specified by the `radiant/iceberg/docker-compose.yml` file.
> 
> However, `exp004` which adds the `airflow` stack, has its own specific `docker-compose.yml`.
> See [Experiment #4: Airflow + Cosmos](docs/experiments/004_airflow_cosmos.md) for more details. 

## Experiments

- [Experiment #1: External sources](docs/experiments/001_dbt_starrock_external_iceberg_catalog_sources.md)
- [Experiment #2: External Materialization](docs/experiments/002_dbt_starrock_external_materialization.md)
- [Experiment #3: Incremental Materialization](docs/experiments/003_dbt_starrock_incremental_materialization.md)
- [Experiment #4: Airflow + Cosmos](docs/experiments/004_airflow_cosmos.md)