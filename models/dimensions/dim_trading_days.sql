{{ config(
    materialized='table',
    schema='intermediate',
    alias='dim_trading_days'
) }}

WITH
date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('" ~ var('seed_date') ~ "' as date)",
        end_date="(select max(trade_created_dt) from " + ref('stg_trades') | string + " )"
    ) }}
)

SELECT date_day::date AS trading_day_dt FROM date_spine
