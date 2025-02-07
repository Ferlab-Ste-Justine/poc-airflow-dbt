{{
    config(
        tags=['biospecimens'],
    )
}}

with source as (

    select * from {{ source('raw_sources', 'biospecimens') }}

),

renamed as (

    select
        bio_id,
        patient_id,
        created_ts

    from source
)

select * from renamed
