{{
    config(
        tags=['stg_locus_locup'],

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

    select distinct sha2(concat_ws('-', chromosome, start, reference, alternate), 256) as locus
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