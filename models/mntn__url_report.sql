-- One row per destination URL per ad per day
-- Sourced from creative_info.click_url, MNTN's only URL field. Parsed with the same generic
-- URL-parsing pattern other ad_reporting platforms use on their own single raw URL field:
-- split_part for base_url, dbt_utils.get_url_host()/get_url_path(), and dbt_utils.get_url_parameter()
-- for UTM extraction. MNTN exposes no native UTM columns, so this is the only source of UTM data.
-- Ads with no click_url are excluded, matching facebook_ads__url_report's null-filtering pattern.
-- Requires both creative (~65% of accounts) and creative_info (~61% of accounts) per Fivetran usage
-- data. Disabled entirely if either is unavailable, since the report has no purpose without a URL
-- to report on.

{{ config(enabled=var('mntn__using_creative', True) and var('mntn__using_creative_info', True)) }}

with ad as (

    select *
    from {{ ref('stg_mntn__creative') }}

),

account as (

    select *
    from {{ ref('stg_mntn__advertiser') }}

),

creative_info as (

    select *
    from {{ ref('stg_mntn__creative_info') }}

),

urls as (

    select
        source_relation,
        date_day,
        ad_id,
        click_url,
        {{ dbt.split_part('click_url', "'?'", 1) }} as base_url,
        {{ dbt_utils.get_url_host('click_url') }} as url_host,
        '/' || {{ dbt_utils.get_url_path('click_url') }} as url_path,
        {{ dbt_utils.get_url_parameter('click_url', 'utm_source') }} as utm_source,
        {{ dbt_utils.get_url_parameter('click_url', 'utm_medium') }} as utm_medium,
        {{ dbt_utils.get_url_parameter('click_url', 'utm_campaign') }} as utm_campaign,
        {{ dbt_utils.get_url_parameter('click_url', 'utm_content') }} as utm_content,
        {{ dbt_utils.get_url_parameter('click_url', 'utm_term') }} as utm_term
    from creative_info
    where click_url is not null

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['ad.source_relation', 'ad.date_day', 'ad.ad_id']) }} as url_report_id,
        ad.source_relation,
        ad.date_day,
        account.account_id,
        account.account_name,
        ad.ad_id,
        ad.ad_name,
        urls.click_url,
        urls.base_url,
        urls.url_host,
        urls.url_path,
        urls.utm_source,
        urls.utm_medium,
        urls.utm_campaign,
        urls.utm_content,
        urls.utm_term,
        sum(ad.impressions) as impressions,
        sum(ad.clicks) as clicks,
        sum(ad.spend) as spend,
        sum(ad.conversions) as conversions,
        sum(ad.conversions_value) as conversions_value
    from ad
    left join account
        on ad.date_day = account.date_day
        and ad.source_relation = account.source_relation
    left join urls
        on ad.ad_id = urls.ad_id
        and ad.date_day = urls.date_day
        and ad.source_relation = urls.source_relation
    where urls.click_url is not null
    {{ dbt_utils.group_by(n=16) }}

)

select *
from final
