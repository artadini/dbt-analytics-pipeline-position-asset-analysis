WITH 
-- Source models
price_snapshots AS ( SELECT * FROM {{ ref('int_price_snapshots') }} ),
date_spine AS ( SELECT trading_day_dt FROM {{ ref('dim_trading_days') }} ),

-- Intermediate CTEs
instruments AS ( SELECT DISTINCT price_snapshots_instrument_fk FROM price_snapshots ),

crossed AS (
    SELECT
        date_spine.trading_day_dt,
        instruments.price_snapshots_instrument_fk
    FROM date_spine
    CROSS JOIN instruments
),

joined AS (
    SELECT
        crossed.trading_day_dt,
        crossed.price_snapshots_instrument_fk,
        price_snapshots.price_snapshots_price,
        price_snapshots.price_snapshots_currency
    FROM crossed
    LEFT JOIN price_snapshots
      ON crossed.trading_day_dt = price_snapshots.price_snapshots_dt
     AND crossed.price_snapshots_instrument_fk = price_snapshots.price_snapshots_instrument_fk
),

partitioned AS (
    SELECT *,
        sum(case when price_snapshots_price is null then 0 else 1 end)
            OVER (PARTITION BY price_snapshots_instrument_fk ORDER BY trading_day_dt)
            AS value_partition
    FROM joined
),

filled AS (
    SELECT
        trading_day_dt,
        price_snapshots_instrument_fk,
        first_value(price_snapshots_price) OVER windowed AS price_snapshots_price,
        first_value(price_snapshots_currency) OVER windowed AS price_snapshots_currency
    FROM partitioned
    WINDOW windowed AS (
        PARTITION BY price_snapshots_instrument_fk, value_partition
        ORDER BY trading_day_dt
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    )
)

-- Final output
SELECT
    trading_day_dt,
    price_snapshots_instrument_fk,
    price_snapshots_price,
    price_snapshots_currency
FROM filled
WHERE price_snapshots_price IS NOT NULL
