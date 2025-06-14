WITH
-- Source models
positions AS ( SELECT * FROM {{ ref('int_daily_positions') }} ),
daily_price_snapshots AS ( SELECT * FROM {{ ref('int_filled_price_snapshots') }} ),

-- Intermediate CTEs
prices AS (
    SELECT 
        price_snapshots_instrument_fk,
        price_snapshots_price,
        price_snapshots_currency,
        trading_day_dt AS price_snapshots_dt
    FROM daily_price_snapshots
),
joined AS (
    SELECT
        positions.trading_day_dt,
        positions.customer_account_fk,
        positions.trade_instrument_fk,
        positions.position_quantity,
        prices.price_snapshots_price,
        prices.price_snapshots_currency
    FROM positions
    LEFT JOIN prices
        ON positions.trade_instrument_fk = prices.price_snapshots_instrument_fk
        AND positions.trading_day_dt = prices.price_snapshots_dt
),
final AS (
    SELECT
        *,
        position_quantity * price_snapshots_price AS position_value
    FROM joined
)

-- Final output
SELECT
    trading_day_dt,
    customer_account_fk,
    trade_instrument_fk,
    position_quantity,
    price_snapshots_price,
    price_snapshots_currency,
    position_value 
FROM final
WHERE price_snapshots_price IS NOT NULL
