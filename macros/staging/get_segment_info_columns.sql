{% macro get_segment_info_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "day", "datatype": "date"},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "interest", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "segment_id", "datatype": dbt.type_string()},
] %}

{{ return(columns) }}

{% endmacro %}
