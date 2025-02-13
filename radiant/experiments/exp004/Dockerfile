FROM apache/airflow:2.10.5

# install astronomer-cosmos in the global environment
RUN pip install --no-cache-dir astronomer-cosmos==1.8.2

# install dbt into a virtual environment
RUN python -m venv dbt_venv && source dbt_venv/bin/activate && \
    pip install --no-cache-dir dbt-starrocks==1.7.0 && deactivate
