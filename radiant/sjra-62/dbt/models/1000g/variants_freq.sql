{{
    config(
        tags=['variants_freq'],

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
{% set lookup_table = ref('1000g_locus_lookup').identifier %}


with variants_freq as (

    select
        lut.locus_id as locus_id,
        count(1) as pc,
        sum(array_sum(array_filter(x -> x = 1, o.calls))) as ac,
        count(case o.zygosity when 'HOM' THEN 1 ELSE NULL END) as hom

    from
        {{ ref('stg_occurrences') }} o,
        {{ ref('1000g_locus_lookup') }} lut
    where
        has_alt
    and
        o.hash = lut.locus
    group by
        lut.locus_id
)

select * from variants_freq