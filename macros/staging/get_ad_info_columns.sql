{% macro get_ad_info_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "active", "datatype": "boolean"},
    {"name": "ad_code", "datatype": dbt.type_string()},
    {"name": "approved", "datatype": "boolean"},
    {"name": "create_time", "datatype": dbt.type_timestamp()},
    {"name": "creative_id", "datatype": dbt.type_string()},
    {"name": "day", "datatype": "date"},
    {"name": "height", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "width", "datatype": dbt.type_int()},
] %}

{{ return(columns) }}

{% endmacro %}
