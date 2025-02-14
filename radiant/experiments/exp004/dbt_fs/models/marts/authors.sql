{{
    config(
        tags=['authors'],
        materialized='table',
    )
 }}

with morphologies as (

    select Ref_ID, Morphology from {{ ref('stg_tumor_variant') }}

),

variant_references as (

    select Ref_ID, Authors  from {{ ref('stg_tumor_variant_ref') }}

),

final as (

    select
        Authors as author_names,
        Morphology as morphology

    from variant_references

    join morphologies on variant_references.Ref_ID = morphologies.Ref_ID

    group by Authors, Morphology

)

select * from final