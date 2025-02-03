 # Radiant
 
This directory contains POC-related experiments for validating `dbt` usability in StarRocks. 

## Setup

- Build the test run by calling: `buil`

## Experiments

Experiments are located in `dbt-runs/experiment_*` directories.

### Coverage: Experiment #1

Validates the following:

- We can use external tables (iceberg catalog) as sources.
- We can materialize both those external tables as `view` or `table`.
