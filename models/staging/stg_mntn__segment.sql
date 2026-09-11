with base as (

    select *
    from {{ ref('stg_mntn__segment_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_mntn__segment_tmp')),
                staging_columns=get_segment_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation('mntn') }}
    from base

),

final as (

    select
        source_relation,
        day as date_day,
        cast(id as {{ dbt.type_string() }}) as segment_id,
        name as segment_name,
        {{ dbt_utils.generate_surrogate_key(['source_relation', 'day', 'id', 'name']) }} as segment_report_pk,
        impressions,
        -- MNTN CTV inventory has no native click event; visits (site visits) is the closest engagement metric available and is mapped to clicks for cross-platform consistency.
        visits as clicks,
        spend,
        conversions,
        order_value as conversions_value
        -- Five columns added June 2026 (site_visitor, existing_site_visitor, new_site_visitor, existing_user_reached, new_user_reached) are singular in the MNTN source, unlike the plural convention (*_visitors, *_reached) used everywhere else in this package. Opt into them via mntn__segment_passthrough_metrics using {name: 'site_visitor', transform_sql: 'site_visitor', alias: 'site_visitors'} (transform_sql plus alias is required to rename on the way in — alias alone is read as the literal source column name by fivetran_utils.fill_pass_through_columns).
        {{ fivetran_utils.fill_pass_through_columns('mntn__segment_passthrough_metrics') }}
    from fields
    where not coalesce(_fivetran_deleted, false)

)

select *
from final
