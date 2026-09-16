-- To disable this model, set the mntn__using_analytics_by_country variable to false in your dbt_project.yml file.

{{ config(enabled=var('mntn__using_analytics_by_country', True)) }}

with country as (

    select *
    from {{ ref('stg_mntn__analytics_by_country') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['country.source_relation', 'country.date_day', 'country.country']) }} as country_report_id,
        country.source_relation,
        country.date_day,
        cast(null as {{ dbt.type_string() }}) as campaign_id,
        cast('Account-level' as {{ dbt.type_string() }}) as campaign_name,
        country.country,
        country.country_iso_code,
        sum(country.impressions) as impressions,
        sum(country.visits) as visits,
        sum(country.spend) as spend,
        sum(country.conversions) as conversions,
        sum(country.conversions_value) as conversions_value

        {{ mntn_persist_pass_through_columns(pass_through_variable='mntn__country_passthrough_metrics', identifier='country', transform='sum') }}

    from country
    {{ dbt_utils.group_by(n=7) }}

)

select *
from final
