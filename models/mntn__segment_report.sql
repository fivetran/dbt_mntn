-- One row per audience segment per day
-- MNTN's audience/targeting concept, with no equivalent report type in any other ad_reporting platform
-- (precedent: pinterest_ads__pin_promotion_report). Standalone report, not unioned into any shared-schema layer.

with segment as (

    select *
    from {{ ref('stg_mntn__segment') }}

),

segment_info as (

    select *
    from {{ ref('stg_mntn__segment_info') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['segment.source_relation', 'segment.date_day', 'segment.segment_id']) }} as segment_report_id,
        segment.source_relation,
        segment.date_day,
        segment.segment_id,
        segment.segment_name,
        segment_info.segment_description,
        segment_info.segment_interest,
        sum(segment.impressions) as impressions,
        sum(segment.clicks) as clicks,
        sum(segment.spend) as spend,
        sum(segment.conversions) as conversions,
        sum(segment.conversions_value) as conversions_value

        {{ mntn_persist_pass_through_columns(pass_through_variable='mntn__segment_passthrough_metrics', identifier='segment', transform='sum') }}

    from segment
    left join segment_info
        on segment.segment_id = segment_info.segment_id
        and segment.date_day = segment_info.date_day
        and segment.source_relation = segment_info.source_relation
    {{ dbt_utils.group_by(n=7) }}

)

select *
from final
