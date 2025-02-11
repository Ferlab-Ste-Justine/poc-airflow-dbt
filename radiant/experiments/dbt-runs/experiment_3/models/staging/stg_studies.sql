{{
    config(
        tags=['daily_partitioned_studies'],
    )

}}

with source as (

    select * from {{ source('raw_sources', 'daily_partitioned_studies') }}

),

renamed as (

    select
        study_id,
        bio_id,
        created_ts

    from source

)

select * from renamed
