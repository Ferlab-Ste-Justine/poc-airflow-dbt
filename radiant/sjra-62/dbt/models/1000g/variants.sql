{{
    config(
        tags=['variants'],

        materialized='table',
        table_type='DUPLICATE',
        keys=['locus_id', 'gnomad_v3_af'],
        distributed_by=['locus_id'],
        buckets='5 ',

        engine='OLAP',
        properties="'compression' = 'LZ4', 'replication_num' = '3', 'colocate_with' = 'query_group'"
    )
}}
{% set lookup_table = ref('1000g_locus_lookup').identifier %}


with variants as (
    select
        lut.locus_id as locus_id,

        -- internal_frequencies_wgs.total.af,
        -- internal_frequencies_wgs.total.pf,
        v.hash,
        v.chromosome,
        v.start,
        v.variant_class,
        -- om.omim_inheritance_code,
        v.symbol,
        v.consequences,
        v.impact,
        v.mane_select,
        v.canonical,
        v.rsnumber,
        v.reference,
        v.alternate,
        v.hgvsg,
        concat_ws('-', v.chromosome, v.start, v.reference, v.alternate) as locus_full,
        v.dna_change

    from
        {{ ref('stg_variants') }} v,
        {{ ref("1000g_locus_lookup") }} lut

    where v.hash = lut.locus
    -- left join omim_gene_inheritance om on om.symbol = c.symbol
),

joined as (
    select
        v.locus_id,
        cast(gn.af as decimal) as gnomad_v3_af,
        v.hash,
        v.chromosome,
        v.start,
        v.variant_class,
        v.symbol,
        v.consequences,
        v.impact,
        v.mane_select,
        v.canonical,
        v.rsnumber,
        v.reference,
        v.alternate,
        v.hgvsg,
        v.locus_full,
        v.dna_change,
        vf.ac,
        vf.pc,
        vf.hom,
        cl.interpretations as clinvar_interpretation

    from variants v

    left join {{ ref('linked_clinvar') }} cl
        on cl.locus_id = v.locus_id

    left join {{ ref('linked_gnomad_genomes_v3') }} gn
        on gn.locus_id = v.locus_id

    left join {{ ref('variants_freq') }} vf
        on vf.locus_id = v.locus_id
)

select * from joined