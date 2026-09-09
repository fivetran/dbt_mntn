-- To disable this model, set the mntn__using_campaign_info variable to false in your dbt_project.yml file.

{{ config(enabled=var('mntn__using_campaign_info', True)) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='mntn_sources',
        single_source_name='mntn',
        single_table_name='campaign_info'
    )
}}
