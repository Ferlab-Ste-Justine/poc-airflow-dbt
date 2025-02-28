{{
    config(
        tags=['stg_gnomad_genomes_v3'],
        materialized='view',
    )
}}

with final as (

    select
        *
    from {{ source('iceberg', 'gnomad_genomes_v3') }}
)

select * from final