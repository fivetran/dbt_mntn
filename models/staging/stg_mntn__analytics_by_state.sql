-- To disable this model, set the mntn__using_analytics_by_state variable to false in your dbt_project.yml file.

{{ config(enabled=var('mntn__using_analytics_by_state', True)) }}

with base as (

    select *
    from {{ ref('stg_mntn__analytics_by_state_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_mntn__analytics_by_state_tmp')),
                staging_columns=get_analytics_by_state_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation('mntn') }}
    from base

),

final as (

    select
        source_relation,
        _fivetran_id,
        day as date_day,
        name as region,
        code as region_code,
        parent_code as region_country_code,
        unique_code as region_unique_code,
        impressions,
        -- MNTN CTV inventory has no native click event; visits (site visits) is the closest engagement metric available and is mapped to clicks for cross-platform consistency.
        visits as clicks,
        spend,
        conversions,
        order_value as conversions_value
        {{ fivetran_utils.fill_pass_through_columns('mntn__region_passthrough_metrics') }}
    from fields
    where not coalesce(_fivetran_deleted, false)

)

select *
from final
