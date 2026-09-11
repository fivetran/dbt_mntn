-- To disable this model, set the mntn__using_creative variable to false in your dbt_project.yml file.

{{ config(enabled=var('mntn__using_creative', True)) }}

with base as (

    select *
    from {{ ref('stg_mntn__creative_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_mntn__creative_tmp')),
                staging_columns=get_creative_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation('mntn') }}
    from base

),

final as (

    select
        source_relation,
        day as date_day,
        -- creative is MNTN's ad-equivalent and most granular metrics grain, mapped to the canonical ad_id.
        cast(id as {{ dbt.type_string() }}) as ad_id,
        name as ad_name,
        size as creative_size,
        impressions,
        -- MNTN CTV inventory has no native click event; visits (site visits) is the closest engagement metric available and is mapped to clicks for cross-platform consistency.
        visits as clicks,
        spend,
        conversions,
        order_value as conversions_value
        {{ fivetran_utils.fill_pass_through_columns('mntn__ad_passthrough_metrics') }}
    from fields
    where not coalesce(_fivetran_deleted, false)

)

select *
from final
