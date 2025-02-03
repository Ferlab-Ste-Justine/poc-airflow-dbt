import os

import pandas as pd
import pyarrow as pa

from pyiceberg.catalog import load_catalog


def init_data():

    data_path = "../raw_data"
    data_files = ["raw_orders.csv", "raw_customers.csv", "raw_payments.csv"]

    warehouse = "warehouse"
    namespace = "jaffle_shop"

    # Set up the Iceberg Catalog
    catalog = load_catalog(
        "my_iceberg_catalog",
        type="rest",
        uri="http://localhost:8181",
        warehouse=warehouse,
        **{
            "s3.endpoint": "http://localhost:9000",
            "s3.access-key-id": "admin",
            "s3.secret-access-key": "password"
        },
    )

    # Create namespace
    catalog.create_namespace(namespace)

    # Create and fill tables
    for _f in data_files:
        _df = pd.read_csv(os.path.join(data_path, _f))
        _padf = pa.Table.from_pandas(df=_df)

        _table = catalog.create_table(
            f"{namespace}.{_f.replace('.csv', '')}",
            schema=_padf.schema,
            location=f"s3://{warehouse}/{namespace}/{_f.replace('.csv', '')}"
        )
        _table.append(_padf)

    return catalog


if __name__ == "__main__":
    init_data()
