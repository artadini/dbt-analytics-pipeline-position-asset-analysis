WITH
-- Source models
trades AS ( SELECT * FROM {{ ref('int_clean_trades') }} ),
date_spine AS ( SELECT trading_day_dt FROM {{ ref('dim_trading_days') }} ),

-- Intermediate CTEs
customers AS ( SELECT DISTINCT customer_account_fk FROM trades ),
instruments AS ( SELECT DISTINCT trade_instrument_fk FROM trades ),
customer_instrument_spine AS (
    SELECT
        date_spine.trading_day_dt,
        customers.customer_account_fk,
        instruments.trade_instrument_fk
    FROM date_spine
    CROSS JOIN customers
    CROSS JOIN instruments
),
trade_agg AS (
    SELECT
        trades.customer_account_fk,
        trades.trade_instrument_fk,
        trades.trade_created_dt,
        SUM(
            CASE 
                WHEN trades.trade_side = 'buy' THEN trades.trade_quantity
                WHEN trades.trade_side = 'sell' THEN -trades.trade_quantity
                ELSE 0
            END
        ) AS net_position
    FROM trades
    GROUP BY trades.customer_account_fk, trades.trade_instrument_fk, trades.trade_created_dt
),
joined AS (
    SELECT
        customer_instrument_spine.trading_day_dt,
        customer_instrument_spine.customer_account_fk,
        customer_instrument_spine.trade_instrument_fk,
        trade_agg.net_position
    FROM customer_instrument_spine
    LEFT JOIN trade_agg
      ON customer_instrument_spine.trading_day_dt = trade_agg.trade_created_dt
     AND customer_instrument_spine.customer_account_fk = trade_agg.customer_account_fk
     AND customer_instrument_spine.trade_instrument_fk = trade_agg.trade_instrument_fk
),
filled_position AS (
    SELECT
        trading_day_dt,
        customer_account_fk,
        trade_instrument_fk,
        SUM(COALESCE(net_position, 0)) OVER (
            PARTITION BY customer_account_fk, trade_instrument_fk
            ORDER BY trading_day_dt
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS position_quantity
    FROM joined
)

-- Final output
SELECT 
    trading_day_dt,
    customer_account_fk,
    trade_instrument_fk,
    position_quantity
FROM filled_position
