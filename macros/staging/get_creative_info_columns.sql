{% macro get_creative_info_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "active", "datatype": "boolean"},
    {"name": "click_url", "datatype": dbt.type_string()},
    {"name": "creative_id", "datatype": dbt.type_string()},
    {"name": "day", "datatype": "date"},
    {"name": "name", "datatype": dbt.type_string()},
] %}

{{ return(columns) }}

{% endmacro %}
