FROM python:3.13-slim

WORKDIR /experiment
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# TODO: Install pipx
# TODO: Install dbt dbt-starrocks

# Set the default command to run when the container starts
CMD ["dbt", "--version"]
