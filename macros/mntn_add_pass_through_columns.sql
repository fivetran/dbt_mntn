{# Extends a get_*_columns() column list with user-configured passthrough fields, skipping any field
   that duplicates a column name/alias already present in base_columns (case-insensitive) so
   fill_staging_columns doesn't choke on a duplicate column. #}

{% macro mntn_add_pass_through_columns(base_columns, pass_through_fields) %}

{% if pass_through_fields %}

    {% set existing_columns = [] %}
    {% for base_column in base_columns %}
        {% do existing_columns.append((base_column.alias if base_column.alias else base_column.name) | lower) %}
    {% endfor %}

    {% for column in pass_through_fields %}

        {% if column is mapping %}
            {% set output_name = (column.alias if column.alias else column.name) | lower %}
            {% if output_name not in existing_columns %}
                {% if column.alias %}
                    {% do base_columns.append({ "name": column.name, "alias": column.alias, "datatype": column.datatype if column.datatype else dbt.type_string() }) %}
                {% else %}
                    {% do base_columns.append({ "name": column.name, "datatype": column.datatype if column.datatype else dbt.type_string() }) %}
                {% endif %}
            {% endif %}
        {% else %}
            {% if column | lower not in existing_columns %}
                {% do base_columns.append({ "name": column, "datatype": dbt.type_string() }) %}
            {% endif %}
        {% endif %}

    {% endfor %}

{% endif %}

{% endmacro %}
