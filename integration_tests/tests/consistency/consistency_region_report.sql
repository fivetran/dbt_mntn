{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with prod as (
    select *
    from {{ target.schema }}_mntn_prod.mntn__region_report
),

dev as (
    select *
    from {{ target.schema }}_mntn_dev.mntn__region_report
),

prod_not_in_dev as (
    select * from prod
    except distinct
    select * from dev
),

dev_not_in_prod as (
    select * from dev
    except distinct
    select * from prod
),

final as (
    select
        *,
        'from prod' as source
    from prod_not_in_dev

    union all

    select
        *,
        'from dev' as source
    from dev_not_in_prod
)

select *
from final
