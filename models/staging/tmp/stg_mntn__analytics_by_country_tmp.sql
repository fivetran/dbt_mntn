-- To disable this model, set the mntn__using_analytics_by_country variable to false in your dbt_project.yml file.

{{ config(enabled=var('mntn__using_analytics_by_country', True)) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='mntn_sources',
        single_source_name='mntn',
        single_table_name='analytics_by_country'
    )
}}
