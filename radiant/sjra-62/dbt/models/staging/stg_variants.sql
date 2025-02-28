{{
    config(
        tags=['stg_variants'],
        materialized='view',
    )
}}

with final as (

    select
        chromosome,
        start,
        reference,
        alternate,
        rsnumber,
        hgvsg,
        variant_class,
        consequences,
        symbol,
        impact,
        mane_select,
        canonical,
        dna_change,
        locus,
        hash
    from {{ source('iceberg', 'variants') }}
)

select * from final