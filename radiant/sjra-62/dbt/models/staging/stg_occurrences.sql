{{
    config(
        tags=['stg_occurrences'],
        materialized='view',
    )
}}


with final as (

    select
        sample_id,
        chromosome,
        start,
        reference,
        alternate,
        hgvsg,
        variant_class,
        name,
        calls,
        filters,
        info_ac,
        info_an,
        info_af,
        has_alt,
        locus,
        hash,
        zygosity,
        ad_total,
        ad_ratio,
        ad_alt,
        ad_ref,
        info_r2_5p_bias,
        info_excess_fs,
        info_read_pos_rank_sum,
        info_qd,
        info_mq,
        info_baseq_rank_sum,
        info_excess_het,
        info_fraction_informative_reads,
        info_vqslod,
        info_m_qrank_sum,
        info_dp,
        info_ds,
        info_mleaf,
        info_mleac,
        info_haplotype_score,
        info_inbreed_coeff,
        info_culprit,
        part,
        seq_id

    from {{ source('iceberg', 'occurrences') }}
)

select * from final