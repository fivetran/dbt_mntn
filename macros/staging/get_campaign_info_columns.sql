{% macro get_campaign_info_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "campaign_id", "datatype": dbt.type_string()},
    {"name": "day", "datatype": "date"},
    {"name": "end_time", "datatype": dbt.type_timestamp()},
    {"name": "flight_end_time", "datatype": dbt.type_timestamp()},
    {"name": "flight_start_time", "datatype": dbt.type_timestamp()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "start_time", "datatype": dbt.type_timestamp()},
    {"name": "status", "datatype": dbt.type_string()},
] %}

{{ return(columns) }}

{% endmacro %}
