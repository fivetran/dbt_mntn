-- To disable this model, set the mntn__using_ad_info variable to false in your dbt_project.yml file.

{{ config(enabled=var('mntn__using_ad_info', True)) }}

with base as (

    select *
    from {{ ref('stg_mntn__ad_info_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_mntn__ad_info_tmp')),
                staging_columns=get_ad_info_columns()
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
        ad_code,
        -- renamed from the source's "active" to disambiguate from stg_mntn__creative_info.is_creative_active, a different metadata facet at the same (day, creative_id) grain.
        active as is_ad_tag_active,
        approved as is_ad_tag_approved,
        status as ad_serving_status,
        width as ad_width,
        height as ad_height,
        cast(create_time as {{ dbt.type_timestamp() }}) as ad_tag_created_at
    from fields
    where not coalesce(_fivetran_deleted, false)

)

select *
from final
