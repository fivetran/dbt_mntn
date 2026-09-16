-- To disable this model, set the mntn__using_creative_group variable to false in your dbt_project.yml file.

{{ config(enabled=var('mntn__using_creative_group', True)) }}

with ad_group as (

    select *
    from {{ ref('stg_mntn__creative_group') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['ad_group.source_relation', 'ad_group.date_day', 'ad_group.ad_group_id']) }} as ad_group_report_id,
        ad_group.source_relation,
        ad_group.date_day,
        ad_group.ad_group_id,
        ad_group.ad_group_name,
        sum(ad_group.impressions) as impressions,
        sum(ad_group.visits) as visits,
        sum(ad_group.spend) as spend,
        sum(ad_group.conversions) as conversions,
        sum(ad_group.conversions_value) as conversions_value

        {{ mntn_persist_pass_through_columns(pass_through_variable='mntn__ad_group_passthrough_metrics', identifier='ad_group', transform='sum') }}

    from ad_group
    {{ dbt_utils.group_by(n=5) }}

)

select *
from final
