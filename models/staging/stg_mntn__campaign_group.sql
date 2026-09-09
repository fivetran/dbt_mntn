with base as (

    select *
    from {{ ref('stg_mntn__campaign_group_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_mntn__campaign_group_tmp')),
                staging_columns=get_campaign_group_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation('mntn') }}
    from base

),

final as (

    select
        source_relation,
        day as date_day,
        -- campaign_group is MNTN's documented preferred grain for campaign-level reporting, so its id is mapped to the canonical campaign_id.
        cast(id as {{ dbt.type_string() }}) as campaign_id,
        name as campaign_name,
        impressions,
        -- MNTN CTV inventory has no native click event; visits (site visits) is the closest engagement metric available and is mapped to clicks for cross-platform consistency.
        visits as clicks,
        spend,
        conversions,
        order_value as conversions_value
        {{ fivetran_utils.fill_pass_through_columns('mntn__campaign_passthrough_metrics') }}
    from fields
    where not coalesce(_fivetran_deleted, false)

)

select *
from final
