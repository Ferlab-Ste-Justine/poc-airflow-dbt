{{
    config(
        tags=['daily_partitioned_biospecimens'],
    )
}}

with source as (

    select * from {{ source('raw_sources', 'daily_partitioned_biospecimens') }}

),

renamed as (

    select
        bio_id,
        patient_id,
        created_ts

    from source
)

select * from renamed
