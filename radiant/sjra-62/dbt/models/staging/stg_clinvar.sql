{{
    config(
        tags=['stg_clinvar'],
        materialized='view',
    )
}}

with final as (

    select
        *
    from {{ source('iceberg', 'clinvar') }}
)

select * from final