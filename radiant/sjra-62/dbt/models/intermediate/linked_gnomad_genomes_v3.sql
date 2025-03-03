{{
    config(
        tags=['linked_gnomad_genomes_v3'],
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

with final as (

    select
        lut.locus_id as locus_id,
        gn.locus,
        gn.hash,
        gn.af
    from
        {{ ref('stg_gnomad_genomes_v3') }} gn,
        {{ ref('1000g_locus_lookup') }} lut
    where
        gn.hash = lut.locus
)

select * from final