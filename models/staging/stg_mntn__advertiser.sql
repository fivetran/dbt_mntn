with base as (

    select *
    from {{ ref('stg_mntn__advertiser_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_mntn__advertiser_tmp')),
                staging_columns=get_advertiser_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation('mntn') }}
    from base

),

final as (

    select
        source_relation,
        day as date_day,
        cast(id as {{ dbt.type_string() }}) as account_id,
        name as account_name,
        impressions,
        -- MNTN CTV inventory has no native click event; visits (site visits) is the closest engagement metric available and is mapped to clicks for cross-platform consistency.
        visits as clicks,
        spend,
        conversions,
        order_value as conversions_value
        {{ fivetran_utils.fill_pass_through_columns('mntn__account_passthrough_metrics') }}
    from fields
    where not coalesce(_fivetran_deleted, false)

)

select *
from final
