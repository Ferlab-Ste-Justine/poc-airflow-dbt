 # Radiant
 
This directory contains POC-related experiments for validating `dbt` usability in StarRocks in multiple scenarios. 

## Setup

- Make sure you are running Python in a virtual environment.
- Install the dependencies (located in `requirements.txt`) by running `make install-deps`.

## Experiments

Experiments are located in `dbt-runs/experiment_*` directories.

### Running Experiments

- Make sure the `iceberg` catalog is created in StarRocks by running `make create-iceberg-catalog`. 
- Navigate to the specific `dbt-runs/experiment_*` directory.
- Run your `dbt` commands. 
- Run `dbt docs generate` followed by `dbt docs serve` to view the experiment's dbt docs.

### Coverage: Experiment #1 

Validates the following:

- We can use external tables (iceberg catalog) as sources.
- We can materialize both those external tables as `view` or `table`.