{% macro get_advertiser_info_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "advertiser_id", "datatype": dbt.type_string()},
    {"name": "contact_email", "datatype": dbt.type_string()},
    {"name": "contact_first_name", "datatype": dbt.type_string()},
    {"name": "contact_last_name", "datatype": dbt.type_string()},
    {"name": "contact_mobile_phone", "datatype": dbt.type_string()},
    {"name": "contact_office_phone", "datatype": dbt.type_string()},
    {"name": "create_time", "datatype": dbt.type_timestamp()},
    {"name": "day", "datatype": "date"},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "time_zone", "datatype": dbt.type_string()},
] %}

{{ return(columns) }}

{% endmacro %}
