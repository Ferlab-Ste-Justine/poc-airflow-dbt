 # POC Experiments
 
This repository contains Proof of Concept (POC) experiments for validating `dbt` usability in StarRocks across multiple scenarios. 
These experiments aim to demonstrate the integration capabilities and performance of `dbt` with StarRocks.
## Setup

1. Ensure you are running Python in a virtual environment.
2. Install the dependencies (located in `requirements.txt`) by running `make install-deps`.

## Loading Data

The `utils/` directory contains Python scripts that helps to load data into Iceberg and to clean it as well.
 
## Experiments

Experiments are located in `dbt-runs/experiment_*` directories.

### Running Experiments

1. Make sure the `iceberg` catalog is created in StarRocks by running `make create-iceberg-catalog`. 
2. Navigate to the `dbt-runs/experiment_*` directory of the experiment you want to run.
3. Run your `dbt` commands. 
4. Run `dbt docs generate` followed by `dbt docs serve` to view the experiment's dbt docs.

### Coverage: Experiment #1 

Validates the following:

- We can use external tables (iceberg catalog) as sources.
- We can materialize both those external tables as `view` or `table`.