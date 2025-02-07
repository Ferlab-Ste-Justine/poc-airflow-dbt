{{
    config(
        tags=['patients'],
        materialized='incremental',
        on_schema_change='append_new_columns'
    )
 }}

with studies as (

    select * from {{ ref('stg_studies') }}

    {% if is_incremental() %}
        where created_ts > (select max(last_study_completed_ts) from {{ this }})
    {% endif %}

),

biospecimens as (

    select * from {{ ref('stg_biospecimens') }}

    {% if is_incremental() %}
        where created_ts > (select max(last_study_completed_ts) from {{ this }})
    {% endif %}

),

final as (

    select
        biospecimens.patient_id,
        count(distinct studies.bio_id) as biospecimens_count,
        max(studies.created_ts) as last_study_completed_ts,
        'foobar' as new_column

    from biospecimens

    left join studies on biospecimens.bio_id = studies.bio_id

    group by biospecimens.patient_id

)

select * from final