{{
    config(
        tags=['prevalence'],
    )

}}

with source as (

    select * from {{ source('raw_sources', 'PrevalenceDownload_r21') }}

),

renamed as (

    select

        *

    from source

)

select * from renamed
