-- One row per country per day
-- MNTN's legacy API returns one table/dimension per request, so country breakdowns carry no campaign_id.
-- campaign_id/campaign_name are hardcoded to null/'Account-level', mirroring facebook_ads__country_report's field_mapping.
-- analytics_by_country is synced by only ~54% of accounts (per Fivetran usage data) — disabled via
-- mntn__using_analytics_by_country when a connection doesn't have it.

{{ config(enabled=var('mntn__using_analytics_by_country', True)) }}

with country as (

    select *
    from {{ ref('stg_mntn__analytics_by_country') }}

),

account as (

    select *
    from {{ ref('stg_mntn__advertiser') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['country.source_relation', 'country.date_day', 'country.country']) }} as country_report_id,
        country.source_relation,
        country.date_day,
        account.account_id,
        account.account_name,
        cast(null as {{ dbt.type_string() }}) as campaign_id,
        cast('Account-level' as {{ dbt.type_string() }}) as campaign_name,
        country.country,
        country.country_iso_code,
        sum(country.impressions) as impressions,
        sum(country.clicks) as clicks,
        sum(country.spend) as spend,
        sum(country.conversions) as conversions,
        sum(country.conversions_value) as conversions_value

        {{ mntn_persist_pass_through_columns(pass_through_variable='mntn__country_passthrough_metrics', identifier='country', transform='sum') }}

    from country
    left join account
        on country.date_day = account.date_day
        and country.source_relation = account.source_relation
    {{ dbt_utils.group_by(n=9) }}

)

select *
from final
