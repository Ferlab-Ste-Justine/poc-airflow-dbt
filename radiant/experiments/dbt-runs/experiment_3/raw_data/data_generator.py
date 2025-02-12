import time
import uuid

import pandas as pd
import pyarrow as pa
from pyiceberg.catalog import load_catalog, Catalog

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

NUM_PATIENTS = 5
PATIENT_IDS = [f"patient_{i}" for i in range(NUM_PATIENTS)]

iceberg_warehouse = "warehouse"
iceberg_namespace = "exp003"


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


def _get_dfs(number_of_new_rows: int = 20) -> tuple[pd.DataFrame, pd.DataFrame]:
    _new_study_id = str(uuid.uuid4())[-8:]
    _new_biospecimen_ids = [str(uuid.uuid4())[-8:] for _ in range(number_of_new_rows)]

    _study_content = [{
        "study_id" :_new_study_id,
        "bio_id": _bid,
        "created_ts": int(time.time()),
    } for _bid in _new_biospecimen_ids]

    study_df = pd.DataFrame(_study_content).astype(study_schema)

    _bio_content = [{
        'bio_id': _new_biospecimen_ids[i],
        'patient_id': PATIENT_IDS[i % NUM_PATIENTS],  # Round-robin the IDs for POC
        'created_ts': int(time.time()) ,
    } for i in range(number_of_new_rows)]

    bio_df = pd.DataFrame(_bio_content).astype(biospecimen_schema)

    return study_df, bio_df


def push_data(catalog: Catalog):
    # Create namespace
    catalog.create_namespace_if_not_exists(iceberg_namespace)

    _studies_df, _biospecimen_df = _get_dfs()

    # Push studies
    _padf = pa.Table.from_pandas(df=_studies_df)
    _studies = catalog.create_table_if_not_exists(
        f"{iceberg_namespace}.studies",
        schema=_padf.schema,
        location=f"s3://{iceberg_warehouse}/{iceberg_namespace}/studies/"
    )
    with _studies.transaction() as t:
        t.append(_padf)
    print(len(_studies.scan().to_arrow()))

    # Push biospecimens
    _padf = pa.Table.from_pandas(df=_biospecimen_df)
    _biospecimen = catalog.create_table_if_not_exists(
        f"{iceberg_namespace}.biospecimens",
        schema=_padf.schema,
        location=f"s3://{iceberg_warehouse}/{iceberg_namespace}/biospecimens/"
    )
    with _biospecimen.transaction() as t:
        t.append(_padf)
    print(len(_biospecimen.scan().to_arrow()))


if __name__ == "__main__":
    push_data(catalog=get_iceberg_catalog())
