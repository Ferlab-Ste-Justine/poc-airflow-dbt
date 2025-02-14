{{
    config(
        tags=['tumor_variants_ref'],
    )

}}

with source as (

    select * from {{ source('raw_sources', 'TumorVariantRefDownload_r21') }}

),

renamed as (

    select

        *

    from source

)

select * from renamed
