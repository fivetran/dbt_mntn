-- To disable this model, set the mntn__using_creative_info variable to false in your dbt_project.yml file.

{{ config(enabled=var('mntn__using_creative_info', True)) }}

with base as (

    select *
    from {{ ref('stg_mntn__creative_info_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_mntn__creative_info_tmp')),
                staging_columns=get_creative_info_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation('mntn') }}
    from base

),

final as (

    select
        source_relation,
        day as date_day,
        cast(creative_id as {{ dbt.type_string() }}) as ad_id,
        active as is_creative_active,
        click_url
    from fields
    where not coalesce(_fivetran_deleted, false)

)

select *
from final
