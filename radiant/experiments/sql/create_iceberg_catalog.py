from sqlalchemy import create_engine, text

# Create a connection to StarRocks
engine = create_engine('starrocks://root@localhost:9030')

# Load the SQL code
with open('create_iceberg_catalog.sql', 'r') as f_in:
    sql_script = f_in.read()

# Execute SQL command
with engine.connect() as connection:
    _ = connection.execute(text(sql_script))
