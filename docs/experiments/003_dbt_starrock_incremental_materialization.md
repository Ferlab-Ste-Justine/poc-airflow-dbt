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
- **Q2**: What happens when we update the schema (add/remove a column)?
- **Q3**: Can we update a single partition (insert overwrite) when data is partitioned by batch?

### Q1. Incremental Materialization

According to the documentation (https://github.com/StarRocks/dbt-starrocks?tab=readme-ov-file#supported-features),
`dbt-starrocks` supports `incremental` materialization. 

### Q2. Updated schema

Validate `on_schema_change` options: 

### Q3. Partitions support

.

## Experiment Design

### Methodology

#### Data Model

The following data model was implemented to validate the `incremental` materialization.

![003_base_data_model.png](resources/003_base_data_model.png)

- A `study` can have `N` biospecimens.
- `biospecimens` are unique and are attached to a `patient_id`
- `patient_id` can be shared across `biospecimens` 

With the desired outcome of the experiment to produce a `patients` table with the following fields:

![003_desired_data_model.png](resources/003_desired_data_model.png)

#### Data flows

![003_base_data_flow.png](resources/003_base_data_flow.png)
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

#### Data Generation

For this experiment, a data generator script was implemented to allow creating new rows on the fly with the updated timestamp. 

This data generator is located in `experiment_3/raw_data/data_generator.py`. 

It generates data using the following schemas:

```
study_schema = {
    'study_id': str,
    'bio_id': str,
    'created_ts': int,
}

biospecimen_schema = {
    'bio_id': str,
    'patient_id': str,
    'created_ts': int,
}
```

## Observations

### Basic `incremental` materialization

1. Run `data_generator.py` to add initial data to your Iceberg tables.
2. Initial `dbt run` produces the following data:

![003_incremental_run_1.png](resources/003_incremental_run_1.png)

2. Run `data_generator.py` to add a new batch of data to Iceberg.

> **Note**:
>
> It's necessary to refresh the external catalog once data has been added, other StarRocks will not
> update its metadata correctly and will miss the new data.
> ```
> REFRESH EXTERNAL TABLE iceberg.exp003.studies;
> REFRESH EXTERNAL TABLE iceberg.exp003.biospecimens;
> ```

3. Second `dbt run` produces the following data:

![003_incremental_run_2.png](resources/003_incremental_run_2.png)

3. Full refresh: `dbt run --full-refresh` produces the following data:

![003_incremental_run_3.png](resources/003_incremental_run_3.png)

4. Run `data_generator.py` to add a new batch of data to Iceberg.

> **Note**:
> Don't forget to refresh the external catalog

5. Adding another batch of `studies` / `biospecimens` and running `dbt run` produces the following data:

![003_incremental_run_4.png](resources/003_incremental_run_4.png)

### Updated schema

To test the schema update operation, the following option was added to `patients.sql`:

```
on_schema_change='sync_all_columns'
```

With the updated `final` schema in `patients.sql`: 

```
'foobar' as new_column
```

We then get the following output:

![003_updated_schema_run_1.png](resources/003_updated_schema_run_1.png)

If we trigger a full-refresh from that point, we get: 

![003_updated_schema_run_2.png](resources/003_updated_schema_run_2.png)

If we remove the `new_column` from the schema and re-run `dbt run` with a new batch of data:

![003_updated_schema_run_3.png](resources/003_updated_schema_run_3.png)

Changing `sync_all_columns` with `append_new_columns` and re-running the previous tests will yield the following table:

![003_updated_schema_run_4.png](resources/003_updated_schema_run_4.png)

### Partitioned `incremental` materialization

## Analysis

### Basic `incremental` materialization

The `materialized: incremental` 

> **Note**: This was tested for both `materialized: [view/table]` for staging models.

### Updated schema

> The current experiments evaluated in more details 2 different options `sync_all_columns` and `append_new_columns` (the other options were tested manually, but not described here in details for simplicity purposes).

Both behaviors yielded the expected tables. 

- `append_new_columns`: Append new columns to the existing table. Note that this setting does not remove columns from the existing table that are not present in the new data.
- `sync_all_columns`: Adds any new columns to the existing table, and removes any columns that are now missing. Note that this is inclusive of data type changes. On BigQuery, changing column types requires a full table scan; be mindful of the trade-offs when implementing.

For more information on schema change: [docs](https://docs.getdbt.com/docs/build/incremental-models#what-if-the-columns-of-my-incremental-model-change)

### Partitioned `incremental` materialization

.

## Conclusion 

- **C1**: `incremental` materialization is supported out-of-the-box in `dbt-starrocks`. (See [Observations: Basic incremental materialization](#basic-incremental-materialization))
- **C2**: Different options for schema change are supported out-of-the-box in `dbt-starrocks` (See [Observations: Updated schema](#updated-schema))
- **C3**: .

## References

- [Experiment #1: External sources](001_dbt_starrock_external_iceberg_catalog_sources.md)
- [Experiment #2: External Materialization](002_dbt_starrock_external_materialization.md)
- [dbt-starrocks (Github)](https://github.com/StarRocks/dbt-starrocks?tab=readme-ov-file#supported-features)
- [dbt `on_schema_change`](https://docs.getdbt.com/docs/build/incremental-models#what-if-the-columns-of-my-incremental-model-change)
