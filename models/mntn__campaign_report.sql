-- One row per campaign per day
-- Sourced from MNTN's campaign_group table, the platform's preferred campaign-level reporting grain.
-- Not joined to stg_mntn__campaign_info: the cardinality between campaign_group's campaign_id and campaign_info's campaign_id is unconfirmed (see the package README).

with campaign as (

    select *
    from {{ ref('stg_mntn__campaign_group') }}

),

account as (

    select *
    from {{ ref('stg_mntn__advertiser') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['campaign.source_relation', 'campaign.date_day', 'campaign.campaign_id']) }} as campaign_report_id,
        campaign.source_relation,
        campaign.date_day,
        account.account_id,
        account.account_name,
        campaign.campaign_id,
        campaign.campaign_name,
        sum(campaign.impressions) as impressions,
        sum(campaign.clicks) as clicks,
        sum(campaign.spend) as spend,
        sum(campaign.conversions) as conversions,
        sum(campaign.conversions_value) as conversions_value

        {{ mntn_persist_pass_through_columns(pass_through_variable='mntn__campaign_passthrough_metrics', identifier='campaign', transform='sum') }}

    from campaign
    left join account
        on campaign.date_day = account.date_day
        and campaign.source_relation = account.source_relation
    {{ dbt_utils.group_by(n=7) }}

)

select *
from final
