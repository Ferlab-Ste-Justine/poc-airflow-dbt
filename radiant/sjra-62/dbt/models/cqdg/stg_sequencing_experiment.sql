{{
    config(
        tags=['stg_sequencing_experiment'],
        materialized='view',
    )
}}


with final as (
    select
        ldm_sample_id,
        seq_id,
        part
    from {{ source('starrocks', 'sequencing_experiment') }}
)

select * from final