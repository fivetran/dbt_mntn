-- To disable this model, set the mntn__using_analytics_by_state variable to false in your dbt_project.yml file.

{{ config(enabled=var('mntn__using_analytics_by_state', True)) }}

with region as (

    select *
    from {{ ref('stg_mntn__analytics_by_state') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['region.source_relation', 'region.date_day', 'region.region']) }} as region_report_id,
        region.source_relation,
        region.date_day,
        cast(null as {{ dbt.type_string() }}) as campaign_id,
        cast('Account-level' as {{ dbt.type_string() }}) as campaign_name,
        region.region,
        region.region_code,
        region.region_country_code,
        region.region_unique_code,
        sum(region.impressions) as impressions,
        sum(region.visits) as visits,
        sum(region.spend) as spend,
        sum(region.conversions) as conversions,
        sum(region.conversions_value) as conversions_value

        {{ mntn_persist_pass_through_columns(pass_through_variable='mntn__region_passthrough_metrics', identifier='region', transform='sum') }}

    from region
    {{ dbt_utils.group_by(n=9) }}

)

select *
from final
