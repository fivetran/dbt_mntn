-- One row per account per day

with account as (

    select *
    from {{ ref('stg_mntn__advertiser') }}

),

account_info as (

    select *
    from {{ ref('stg_mntn__advertiser_info') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['account.source_relation', 'account.date_day', 'account.account_id']) }} as account_report_id,
        account.source_relation,
        account.date_day,
        account.account_id,
        account.account_name,
        account_info.account_time_zone,
        sum(account.impressions) as impressions,
        sum(account.clicks) as clicks,
        sum(account.spend) as spend,
        sum(account.conversions) as conversions,
        sum(account.conversions_value) as conversions_value

        {{ mntn_persist_pass_through_columns(pass_through_variable='mntn__account_passthrough_metrics', identifier='account', transform='sum') }}

    from account
    left join account_info
        on account.account_id = account_info.account_id
        and account.date_day = account_info.date_day
        and account.source_relation = account_info.source_relation
    {{ dbt_utils.group_by(n=6) }}

)

select *
from final
