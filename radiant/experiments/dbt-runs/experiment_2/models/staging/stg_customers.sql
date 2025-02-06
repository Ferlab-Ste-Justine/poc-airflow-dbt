{{ config(tags=['customers']) }}

with source as (

    select * from {{ source('raw_sources', 'raw_customers') }}

),

renamed as (

    select
        id as customer_id,
        first_name,
        last_name

    from source

)

select * from renamed
