{{
    config(
        tags=['studies'],
    )

}}

with source as (

    select * from {{ source('raw_sources', 'studies') }}

),

renamed as (

    select
        study_id,
        bio_id,
        created_ts

    from source

)

select * from renamed
