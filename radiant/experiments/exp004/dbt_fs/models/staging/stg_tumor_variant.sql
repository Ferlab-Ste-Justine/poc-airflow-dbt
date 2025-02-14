{{
    config(
        tags=['tumor_variants'],
    )

}}

with source as (

    select * from {{ source('raw_sources', 'TumorVariantDownload_r21') }}

),

renamed as (

    select

        *

    from source

)

select * from renamed
