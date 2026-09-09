-- One row per state/province per day
-- MNTN's legacy API returns one table/dimension per request, so region breakdowns carry no campaign_id.
-- campaign_id/campaign_name are hardcoded to null/'Account-level', mirroring facebook_ads__region_report's field_mapping.
-- Sourced from analytics_by_state (chosen over the DMA grain, which has no analog on other platforms).
-- analytics_by_state is synced by only ~61% of accounts (per Fivetran usage data) — disabled via
-- mntn__using_analytics_by_state when a connection doesn't have it.

{{ config(enabled=var('mntn__using_analytics_by_state', True)) }}

with region as (

    select *
    from {{ ref('stg_mntn__analytics_by_state') }}

),

account as (

    select *
    from {{ ref('stg_mntn__advertiser') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['region.source_relation', 'region.date_day', 'region.region']) }} as region_report_id,
        region.source_relation,
        region.date_day,
        account.account_id,
        account.account_name,
        cast(null as {{ dbt.type_string() }}) as campaign_id,
        cast('Account-level' as {{ dbt.type_string() }}) as campaign_name,
        region.region,
        region.region_code,
        region.region_country_code,
        region.region_unique_code,
        sum(region.impressions) as impressions,
        sum(region.clicks) as clicks,
        sum(region.spend) as spend,
        sum(region.conversions) as conversions,
        sum(region.conversions_value) as conversions_value

        {{ mntn_persist_pass_through_columns(pass_through_variable='mntn__region_passthrough_metrics', identifier='region', transform='sum') }}

    from region
    left join account
        on region.date_day = account.date_day
        and region.source_relation = account.source_relation
    {{ dbt_utils.group_by(n=11) }}

)

select *
from final
