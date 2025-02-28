{{
    config(
        tags=['linked_clinvar'],
        materialized='table',
        table_type='PRIMARY',
        keys=['locus_id'],
        distributed_by=['locus_id'],
        buckets='5 ',
        engine='OLAP',
        properties="'compression' = 'LZ4', 'replication_num' = '3', 'colocate_with' = 'build_group_1'"
    )
}}

with final as (

    select
        lut.locus_id as locus_id,
        cl.interpretations,
        cl.locus,
        cl.hash
    from
        {{ ref('stg_clinvar') }} cl,
        {{ ref('1000g_locus_lookup') }} lut
    where
        cl.hash = lut.locus
)

select * from final