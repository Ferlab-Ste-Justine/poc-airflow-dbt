# Experimentation Journal: Incremental materialization

## Experiment Metadata
- **Date Initiated:** 2025-02-06
- **Date Completed:** Ongoing
- **Related Issue number(s):** 
  - https://d3b.atlassian.net/browse/SJRA-42

## Background and Context

As part of the Radiant project, several key technologies were identified as good candidates to power the data platform.

The experiment therefore as the following constraints: 

- Use `dbt` to transform data.
- Use StarRocks as the data warehouse technology. 
- Leverage external Iceberg as the data lake format.

**Previous related experiments**
- [Experiment #1: External sources](001_dbt_starrock_external_iceberg_catalog_sources.md).
- [Experiment #2: External Materialization](002_dbt_starrock_external_materialization.md).

## Problem Statement

**Problem:**
- **Q1**: Is `incremental` supported out-of-the-box by `dbt-starrocks`?
- **Q2**: Can we update a single partition (insert overwrite) when data is partitioned by batch? 
- **Q3**: What happens when we update the schema (add a new column)?

### Q1. Incremental Materialization

According to the documentation (https://github.com/StarRocks/dbt-starrocks?tab=readme-ov-file#supported-features),
`dbt-starrocks` supports `incremental` materialization. 

### Q2. Partitions support

.

### Q3. Updated schema

.

## Experiment Design

### Methodology

Given the constraints and context, perform the following: 

1. Identify the source dataset.
2. Load the source data into an Iceberg table. 
3. Run `dbt build` (combination of `run` and `test`) to transform the data and test it.

#### Data flows



### Tools and Resources

#### Environment & Tools

Experimental files located in `radiant/experiments/dbt-runs/experiment_3`

The following diagram presents the local experimental setup.
> A `docker-compose.yml` file was used to specify required services. 

![001_stack.png](resources/001_stack.png)

The experimental stack is composed of the following tech/tools: 

- `MinIO` (https://min.io/): Distributed object store.
- `Iceberg` (https://iceberg.apache.org/): Open table format.
- `StarRocks` (https://www.starrocks.io/): Analytical data warehouse.
- `dbt` (https://www.getdbt.com/): Data transformation. 
- `python` (https://www.python.org/): Used to build scripts to load/clean the data.

#### Data

For this experiment, a data generator script was implemented to allow creating new rows on the fly with the updated timestamp. 

This data generator is located in `experiment_3/raw_data/data_generator.py`. (For details on how to use the script, call `data_generator.py --help`)

## Observations


## Analysis


## Conclusion 

- **C1**: 
- **C2**:
- **C3**:

## References

- [Experiment #1: External sources](001_dbt_starrock_external_iceberg_catalog_sources.md).
- [Experiment #2: External Materialization](002_dbt_starrock_external_materialization.md).
- [dbt-starrocks (Github)](https://github.com/StarRocks/dbt-starrocks?tab=readme-ov-file#supported-features).
