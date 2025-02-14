import pathlib
import pandas as pd

import pyarrow as pa
from cachetools.func import lru_cache
from pyiceberg.catalog import load_catalog
from pyiceberg.exceptions import NoSuchTableError

RAW_DIR_PATH = "../raw/"
DOWNLOAD_URLS = [
    "https://tp53.cancer.gov/static/data/TumorVariantDownload_r21.csv",
    "https://tp53.cancer.gov/static/data/TumorVariantRefDownload_r21.csv",
    "https://tp53.cancer.gov/static/data/PrevalenceDownload_r21.csv",
    "https://tp53.cancer.gov/static/data/PrevalenceDownloadR249S_r21.csv",
    "https://tp53.cancer.gov/static/data/PrognosisDownload_r21.csv",
]


iceberg_warehouse = "warehouse"
iceberg_namespace = "exp004"


@lru_cache(maxsize=1)
def get_iceberg_catalog():

    catalog = load_catalog(
        "my_iceberg_catalog",
        type="rest",
        uri="http://localhost:8181",
        warehouse=iceberg_warehouse,
        **{
            "s3.endpoint": "http://localhost:9000",
            "s3.access-key-id": "admin",
            "s3.secret-access-key": "password"
        },
    )
    return catalog


def push_data(raw_url: str):

    # Load Catalog
    catalog = get_iceberg_catalog()

    # Create namespace
    catalog.create_namespace_if_not_exists(iceberg_namespace)

    _df = pd.read_csv(raw_url)
    _table_name = pathlib.Path(raw_url).stem

    # # Push studies
    _padf = pa.Table.from_pandas(df=_df)

    try:
        catalog.drop_table(identifier=f"{iceberg_namespace}.{_table_name}")
    except NoSuchTableError:
        pass

    _table = catalog.create_table(
        identifier=f"{iceberg_namespace}.{_table_name}",
        schema=_padf.schema,
        location=f"s3://{iceberg_warehouse}/{iceberg_namespace}/{_table_name}/"
    )
    with _table.transaction() as t:
        t.append(_padf)

    print(f"{iceberg_namespace}.{_table_name}: {len(_table.scan().to_arrow())} rows")


def main():
    for raw_url in DOWNLOAD_URLS:
        push_data(raw_url=raw_url)


if __name__ == "__main__":
    main()
