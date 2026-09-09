-- To disable this model, set the mntn__using_creative variable to false in your dbt_project.yml file.

{{ config(enabled=var('mntn__using_creative', True)) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='mntn_sources',
        single_source_name='mntn',
        single_table_name='creative'
    )
}}
