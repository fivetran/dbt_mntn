with base as (

    select *
    from {{ ref('stg_mntn__segment_info_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_mntn__segment_info_tmp')),
                staging_columns=get_segment_info_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation('mntn') }}
    from base

),

final as (

    select
        source_relation,
        day as date_day,
        cast(segment_id as {{ dbt.type_string() }}) as segment_id,
        description as segment_description,
        interest as segment_interest
    from fields
    where not coalesce(_fivetran_deleted, false)

)

select *
from final
