-- One row per ad group per day
-- Sourced from MNTN's creative_group table: one TV commercial plus its tracking (and Multi-Touch group, if used).
-- creative_group is synced by only ~67% of accounts (per Fivetran usage data) — disabled via
-- mntn__using_creative_group when a connection doesn't have it.

{{ config(enabled=var('mntn__using_creative_group', True)) }}

with ad_group as (

    select *
    from {{ ref('stg_mntn__creative_group') }}

),

account as (

    select *
    from {{ ref('stg_mntn__advertiser') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['ad_group.source_relation', 'ad_group.date_day', 'ad_group.ad_group_id']) }} as ad_group_report_id,
        ad_group.source_relation,
        ad_group.date_day,
        account.account_id,
        account.account_name,
        ad_group.ad_group_id,
        ad_group.ad_group_name,
        sum(ad_group.impressions) as impressions,
        sum(ad_group.clicks) as clicks,
        sum(ad_group.spend) as spend,
        sum(ad_group.conversions) as conversions,
        sum(ad_group.conversions_value) as conversions_value

        {{ mntn_persist_pass_through_columns(pass_through_variable='mntn__ad_group_passthrough_metrics', identifier='ad_group', transform='sum') }}

    from ad_group
    left join account
        on ad_group.date_day = account.date_day
        and ad_group.source_relation = account.source_relation
    {{ dbt_utils.group_by(n=7) }}

)

select *
from final
