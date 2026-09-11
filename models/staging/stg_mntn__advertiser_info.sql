with base as (

    select *
    from {{ ref('stg_mntn__advertiser_info_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_mntn__advertiser_info_tmp')),
                staging_columns=get_advertiser_info_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation('mntn') }}
    from base

),

final as (

    select
        source_relation,
        day as date_day,
        cast(advertiser_id as {{ dbt.type_string() }}) as account_id,
        time_zone as account_time_zone,
        cast(create_time as {{ dbt.type_timestamp() }}) as account_created_at
    from fields
    where not coalesce(_fivetran_deleted, false)

)

select *
from final
