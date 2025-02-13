{{
    config(
        tags=['prognosis'],
    )

}}

with source as (

    select * from {{ source('raw_sources', 'PrognosisDownload_r21') }}

),

renamed as (

    select
        *
    from source

)

select * from renamed
