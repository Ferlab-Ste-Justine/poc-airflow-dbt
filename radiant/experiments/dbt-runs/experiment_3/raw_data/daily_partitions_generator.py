import argparse
import os
import uuid
from datetime import datetime, timedelta

import pandas as pd
import pyarrow as pa
from pyiceberg.catalog import load_catalog, Catalog

NUM_PARTITIONS_TO_ADD = 2
TIME_DELTA = timedelta(days=1)

def _get_start_from() -> datetime:
    dump_file = '.daily_generator'
    if os.path.exists(dump_file):
        with open(dump_file, "r") as f_in:
            dt = datetime.fromisoformat(f_in.read()) + (TIME_DELTA * NUM_PARTITIONS_TO_ADD)

    else:
        dt = datetime(year=2025, month=1, day=1)  # January 1st 2025

    with open(dump_file, "w") as f_out:
        f_out.write(dt.isoformat())
    return dt

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

ICEBERG_WAREHOUSE = "warehouse"
ICEBERG_NAMESPACE = "exp003"


def get_iceberg_catalog():

    catalog = load_catalog(
        "my_iceberg_catalog",
        type="rest",
        uri="http://localhost:8181",
        warehouse=ICEBERG_WAREHOUSE,
        **{
            "s3.endpoint": "http://localhost:9000",
            "s3.access-key-id": "admin",
            "s3.secret-access-key": "password"
        },
    )
    return catalog


def _get_dfs(dt: datetime, number_of_new_rows: int = 20, study_id: str = None) -> tuple[pd.DataFrame, pd.DataFrame]:
    _new_study_id = study_id or str(uuid.uuid4())[-8:]
    _new_biospecimen_ids = [str(uuid.uuid4())[-8:] for _ in range(number_of_new_rows)]

    _study_content = [{
        "study_id" :_new_study_id,
        "bio_id": _bid,
        "created_ts": dt.timestamp(),
    } for _bid in _new_biospecimen_ids]

    study_df = pd.DataFrame(_study_content).astype(study_schema)

    _bio_content = [{
        'bio_id': _new_biospecimen_ids[i],
        'patient_id': PATIENT_IDS[i % NUM_PATIENTS],  # Round-robin the IDs for POC
        'created_ts': dt.timestamp(),
    } for i in range(number_of_new_rows)]

    bio_df = pd.DataFrame(_bio_content).astype(biospecimen_schema)

    return study_df, bio_df


def push_data(catalog: Catalog, dt: datetime, study_id: str = None):
    # Create namespace
    catalog.create_namespace_if_not_exists(ICEBERG_NAMESPACE)

    _studies_df, _biospecimen_df = _get_dfs(dt=dt, study_id=study_id)

    # Push studies
    _padf = pa.Table.from_pandas(df=_studies_df)
    _studies = catalog.create_table_if_not_exists(
        f"{ICEBERG_NAMESPACE}.daily_partitioned_studies",
        schema=_padf.schema,
        location=f"s3://{ICEBERG_WAREHOUSE}/{ICEBERG_NAMESPACE}/daily_partitioned_studies/"
    )
    with _studies.transaction() as t:
        t.append(_padf)
    print(len(_studies.scan().to_arrow()))

    # Push biospecimens
    _padf = pa.Table.from_pandas(df=_biospecimen_df)
    _biospecimen = catalog.create_table_if_not_exists(
        f"{ICEBERG_NAMESPACE}.daily_partitioned_biospecimens",
        schema=_padf.schema,
        location=f"s3://{ICEBERG_WAREHOUSE}/{ICEBERG_NAMESPACE}/daily_partitioned_biospecimens/"
    )
    with _biospecimen.transaction() as t:
        t.append(_padf)
    print(len(_biospecimen.scan().to_arrow()))


def generate_new_studies_and_biospecimens():
    _date = _get_start_from()
    for i in range(NUM_PARTITIONS_TO_ADD):
        push_data(dt=_date, catalog=get_iceberg_catalog())
        _date += TIME_DELTA


def update_existing_study(study_id: str):
    catalog = get_iceberg_catalog()
    _studies = catalog.load_table(identifier=f"{ICEBERG_NAMESPACE}.daily_partitioned_studies")

    # Validate study_id is in the table
    _filtered = _studies.scan(row_filter=f"study_id == '{study_id}'").to_pandas()
    if not len(_filtered):
        raise ValueError(f"Study ID: {study_id} not found in Iceberg")

    # Extract the latest timestamp and add new biospecimens for this study at +30 mins from last time
    _update_date = datetime.fromtimestamp(_filtered["created_ts"].max()) + timedelta(minutes=30)

    # Push 20 biospecimens for a specific study
    # - This will insert new rows on both tables
    push_data(catalog=catalog, dt=_update_date, study_id=study_id)
    print(f"Added 20 biospecimens to study '{study_id}' at dt='{_update_date.isoformat()}'")


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Add new biospecimens for a study")
    parser.add_argument("--study-id-to-update", type=str, help="The study ID")

    args = parser.parse_args()

    if args.study_id_to_update:
        update_existing_study(args.study_id_to_update)

    else:
        generate_new_studies_and_biospecimens()
