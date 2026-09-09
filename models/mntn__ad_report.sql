-- One row per ad per day
-- Sourced from MNTN's creative table (the platform's most granular metrics grain), enriched with
-- creative_info (creative activation status, click-through URL) and ad_info (ad-serving tag attributes).
-- creative_info (~61% of accounts) and ad_info (~65% of accounts) are each independently optional
-- enrichment per Fivetran usage data — the report still builds on creative alone (~65% of accounts,
-- the hard requirement below) if either or both are unavailable for a connection.

{{ config(enabled=var('mntn__using_creative', True)) }}

{% set using_creative_info = var('mntn__using_creative_info', True) %}
{% set using_ad_info = var('mntn__using_ad_info', True) %}

with ad as (

    select *
    from {{ ref('stg_mntn__creative') }}

),

account as (

    select *
    from {{ ref('stg_mntn__advertiser') }}

),

{% if using_creative_info %}
creative_info as (

    select *
    from {{ ref('stg_mntn__creative_info') }}

),
{% endif %}

{% if using_ad_info %}
ad_info as (

    select *
    from {{ ref('stg_mntn__ad_info') }}

),
{% endif %}

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['ad.source_relation', 'ad.date_day', 'ad.ad_id']) }} as ad_report_id,
        ad.source_relation,
        ad.date_day,
        account.account_id,
        account.account_name,
        ad.ad_id,
        ad.ad_name,
        ad.creative_size,
        {% if using_creative_info %}
        creative_info.is_creative_active,
        creative_info.click_url,
        {% endif %}
        {% if using_ad_info %}
        ad_info.ad_code,
        ad_info.is_ad_tag_active,
        ad_info.is_ad_tag_approved,
        ad_info.ad_serving_status,
        ad_info.ad_width,
        ad_info.ad_height,
        ad_info.ad_tag_created_at,
        {% endif %}
        sum(ad.impressions) as impressions,
        sum(ad.clicks) as clicks,
        sum(ad.spend) as spend,
        sum(ad.conversions) as conversions,
        sum(ad.conversions_value) as conversions_value

        {{ mntn_persist_pass_through_columns(pass_through_variable='mntn__ad_passthrough_metrics', identifier='ad', transform='sum') }}

    from ad
    left join account
        on ad.date_day = account.date_day
        and ad.source_relation = account.source_relation
    {% if using_creative_info %}
    left join creative_info
        on ad.ad_id = creative_info.ad_id
        and ad.date_day = creative_info.date_day
        and ad.source_relation = creative_info.source_relation
    {% endif %}
    {% if using_ad_info %}
    left join ad_info
        on ad.ad_id = ad_info.ad_id
        and ad.date_day = ad_info.date_day
        and ad.source_relation = ad_info.source_relation
    {% endif %}
    {% set n = 8 + (2 if using_creative_info else 0) + (7 if using_ad_info else 0) %}
    {{ dbt_utils.group_by(n=n) }}

)

select *
from final
