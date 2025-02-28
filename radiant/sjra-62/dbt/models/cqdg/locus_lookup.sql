{{
    config(
        tags=['locus_lookup'],

        materialized='table',
        table_type='PRIMARY',
        keys=['locus'],
        distributed_by=['locus'],
        buckets='5 ',

        engine='OLAP',
        properties="{'compression': 'LZ4', 'replication_num': '3', 'colocate_with': 'group_locus_id5'}"
    )
}}

with locuses as (

    select distinct {{ generate_locus_fields_hash(['chromosome', 'start', 'reference', 'alternate']) }} as locus
    from {{ source('cqdg_datalake', 'normalized_snv') }}
),

combined as (
    select
        l.locus as locus,
        uuid_numeric() as locus_id
    from
        locuses l
)

select * from combined