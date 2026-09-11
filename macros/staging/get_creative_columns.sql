{% macro get_creative_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "average_order_value", "datatype": dbt.type_float()},
    {"name": "completed_view_rate", "datatype": dbt.type_float()},
    {"name": "completed_views", "datatype": dbt.type_int()},
    {"name": "conversion_rate", "datatype": dbt.type_float()},
    {"name": "conversions", "datatype": dbt.type_int()},
    {"name": "cost_per_completed_view", "datatype": dbt.type_float()},
    {"name": "cost_per_visit", "datatype": dbt.type_float()},
    {"name": "cpa", "datatype": dbt.type_float()},
    {"name": "day", "datatype": "date"},
    {"name": "existing_site_visitors", "datatype": dbt.type_int()},
    {"name": "existing_users_reached", "datatype": dbt.type_int()},
    {"name": "frequency", "datatype": dbt.type_float()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "impression_conversion_rate", "datatype": dbt.type_float()},
    {"name": "impression_visit_rate", "datatype": dbt.type_float()},
    {"name": "impressions", "datatype": dbt.type_int()},
    {"name": "multi_touch_impressions", "datatype": dbt.type_int()},
    {"name": "multi_touch_spend", "datatype": dbt.type_float()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "new_site_visitors", "datatype": dbt.type_int()},
    {"name": "new_users_reached", "datatype": dbt.type_int()},
    {"name": "order_value", "datatype": dbt.type_float()},
    {"name": "roas", "datatype": dbt.type_float()},
    {"name": "roi", "datatype": dbt.type_float()},
    {"name": "site_visitors", "datatype": dbt.type_int()},
    {"name": "size", "datatype": dbt.type_string()},
    {"name": "spend", "datatype": dbt.type_float()},
    {"name": "tv_commercials_aired", "datatype": dbt.type_int()},
    {"name": "tv_spend", "datatype": dbt.type_float()},
    {"name": "user_conversion_rate", "datatype": dbt.type_float()},
    {"name": "user_visit_rate", "datatype": dbt.type_float()},
    {"name": "users_reached", "datatype": dbt.type_int()},
    {"name": "viewable_impression_rate", "datatype": dbt.type_float()},
    {"name": "viewable_impressions", "datatype": dbt.type_int()},
    {"name": "visit_conversion_rate", "datatype": dbt.type_float()},
    {"name": "visit_rate", "datatype": dbt.type_float()},
    {"name": "visits", "datatype": dbt.type_int()},
] %}

{{ mntn_add_pass_through_columns(base_columns=columns, pass_through_fields=var('mntn__ad_passthrough_metrics', none)) }}

{{ return(columns) }}

{% endmacro %}
