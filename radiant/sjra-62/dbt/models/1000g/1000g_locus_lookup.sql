{{
    config(
        tags=['1000g_locus_lookup'],

        materialized='table',
        table_type='PRIMARY',
        keys=['locus_id'],
        distributed_by=['locus_id'],
        buckets='5 ',

        engine='OLAP',
        properties={
            'compression': 'LZ4',
            'replication_num': '3',
            'colocate_with': 'build_group'
        }
    )
}}

with occurence_locuses as (
    select distinct hash from {{ ref('stg_occurrences') }}
),

variant_locuses as (
    select distinct hash from {{ ref('stg_variants') }}
),

combined as (
    select hash from occurence_locuses
    union all select hash from variant_locuses
),

final as (
    select
        uuid_numeric() as locus_id,
        c.hash as locus
    from
        combined c
    group by locus
)

select * from final