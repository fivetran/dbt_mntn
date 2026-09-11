-- To disable this model, set the mntn__using_campaign_info variable to false in your dbt_project.yml file.

{{ config(enabled=var('mntn__using_campaign_info', True)) }}

with base as (

    select *
    from {{ ref('stg_mntn__campaign_info_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_mntn__campaign_info_tmp')),
                staging_columns=get_campaign_info_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation('mntn') }}
    from base

),

final as (

    select
        source_relation,
        day as date_day,
        -- campaign_id here is MNTN's finer campaign_id grain, a distinct id space from campaign_group's id (mapped to campaign_id in stg_mntn__campaign_group). The cardinality between the two is unconfirmed, so this model is not joined into mntn__campaign_report yet.
        cast(campaign_id as {{ dbt.type_string() }}) as campaign_id,
        name as campaign_name,
        status as campaign_status,
        cast(start_time as {{ dbt.type_timestamp() }}) as campaign_created_at,
        cast(end_time as {{ dbt.type_timestamp() }}) as campaign_ended_at,
        cast(flight_start_time as {{ dbt.type_timestamp() }}) as flight_start_at,
        cast(flight_end_time as {{ dbt.type_timestamp() }}) as flight_end_at
    from fields
    where not coalesce(_fivetran_deleted, false)

)

select *
from final
