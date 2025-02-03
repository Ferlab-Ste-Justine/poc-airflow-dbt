from pyiceberg.catalog import load_catalog


def clean_data():
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

    for _table in catalog.list_tables(namespace=namespace):
        catalog.drop_table(_table)

    catalog.drop_namespace(namespace=namespace)


if __name__ == "__main__":
    clean_data()
