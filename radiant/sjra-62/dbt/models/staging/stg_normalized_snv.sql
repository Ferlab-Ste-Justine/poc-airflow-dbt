{{
    config(
        tags=['stg_normalized_snv'],

        materialized='table',
        table_type='PRIMARY',
        keys=['part', 'seq_id', 'locus_id'],

        distributed_by=['locus_id'],
        buckets='5 ',
        partition_type='Expr',
        partition_by=['(`part`)'],

        engine='OLAP',
        properties="{'compression': 'LZ4', 'replication_num': '3', 'colocate_with': 'group_locus_id5'}",

        pre_hook=["SET SESSION new_planner_optimize_timeout = 6000;"]
    )
}}

-- Filters
{% set study_filter = "'cag'" %}
{% set batch_filter = "'annotated_vcf_cqdg_3'" %}
{% set parts_filter = (58, 59, 60) %}
{% set lookup_table = ref('stg_locus_lookup').identifier %}

-- Normalized SNV data filtered by study and batch
with normalized_variants as (
    select *
    from {{ source('cqdg_datalake', 'normalized_snv') }}

    {% if study_filter is not none %}
        where study_id = {{ study_filter }}
    {% endif %}

    {% if batch_filter is not none %}
        and batch = {{ batch_filter }}
    {% endif %}
),

-- Sequencing experiment data for specific parts
sequencing_data as (
    select
        ldm_sample_id,
        seq_id,
        part
    from {{ source('starrocks', 'sequencing_experiment') }}

    {% if parts_filter is not none %}
        where part in {{ parts_filter }}
    {% endif %}
),

-- Final combined dataset with variant information
final as (
    select
        s.part as part,
        s.seq_id as seq_id,

        dict_mapping(
            "{{ lookup_table }}",
            sha2(concat_ws('-', chromosome, start, reference, alternate), 256),
            'locus_id'
        )
        as locus_id,

        -- Coverage and quality metrics
        o.ad_ratio,
        o.ad_total,
        o.ad_ref,
        o.ad_alt,
        o.dp,
        o.gq,

        -- Variant characteristics
        o.chromosome,
        o.start,
        o.zygosity,
        o.has_alt,
        o.variant_class,
        o.filter,

        -- Population statistics
        o.info_ac,
        o.info_an,
        o.info_af,

        -- Quality scores and bias metrics
        o.info_baseq_rank_sum,
        o.info_excess_het,
        o.info_fs,
        o.info_ds,
        o.info_fraction_informative_reads,
        o.info_inbreed_coeff,
        o.info_mleac,
        o.info_mleaf,
        o.info_mq,
        o.info_m_qrank_sum,
        o.info_qd,
        o.info_r2_5p_bias,
        o.info_read_pos_rank_sum,
        o.info_sor,
        o.info_vqslod,
        o.info_culprit,
        o.info_dp,
        o.info_haplotype_score,

        -- Additional data
        o.calls
    from normalized_variants o
    join [BROADCAST] sequencing_data s
        on s.ldm_sample_id = o.sample_id
)

select * from final
