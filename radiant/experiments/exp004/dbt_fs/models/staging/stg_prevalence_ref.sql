{{
    config(
        tags=['prevalence_ref'],
    )

}}

with source as (

    select * from {{ source('raw_sources', 'PrevalenceDownloadR249S_r21') }}

),

renamed as (

    select
        Ref_ID,
        Authors

    from source

)

select * from renamed
