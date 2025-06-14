WITH
-- Source models
customer_positions AS ( SELECT * FROM {{ ref('mart_customer_daily_holdings') }} ),
accounts AS ( SELECT customer_account_pk, partner_fk FROM {{ ref('stg_customer_accounts') }} ),

-- Intermediate CTEs
partners AS ( SELECT DISTINCT partner_fk FROM accounts ),
instruments AS ( SELECT DISTINCT trade_instrument_fk FROM customer_positions ),
date_spine AS ( SELECT DISTINCT trading_day_dt FROM customer_positions ),

partner_instrument_spine AS (
    SELECT
        date_spine.trading_day_dt,
        partners.partner_fk,
        instruments.trade_instrument_fk
    FROM date_spine
    CROSS JOIN partners
    CROSS JOIN instruments
),
customer_partner_positions AS (
    SELECT
        customer_positions.trading_day_dt,
        accounts.partner_fk,
        customer_positions.trade_instrument_fk,
        customer_positions.position_quantity,
        customer_positions.position_value,
        customer_positions.price_snapshots_currency
    FROM customer_positions
    JOIN accounts
      ON customer_positions.customer_account_fk = accounts.customer_account_pk
),
agg AS (
    SELECT
        partner_instrument_spine.trading_day_dt,
        partner_instrument_spine.partner_fk,
        partner_instrument_spine.trade_instrument_fk,
        -- Assuming all currencies are the same per instrument per day, use MIN() as a safe pick
        MIN(customer_partner_positions.price_snapshots_currency) AS price_snapshots_currency,
        SUM(coalesce(customer_partner_positions.position_quantity, 0)) AS total_position_quantity,
        SUM(coalesce(customer_partner_positions.position_value, 0)) AS total_position_value
    FROM partner_instrument_spine
    LEFT JOIN customer_partner_positions
      ON partner_instrument_spine.trading_day_dt = customer_partner_positions.trading_day_dt
     AND partner_instrument_spine.partner_fk = customer_partner_positions.partner_fk
     AND partner_instrument_spine.trade_instrument_fk = customer_partner_positions.trade_instrument_fk
    GROUP BY 1, 2, 3
)

-- Final output
SELECT 
    trading_day_dt,
    partner_fk,
    trade_instrument_fk,
    price_snapshots_currency,
    total_position_quantity,
    total_position_value
FROM agg
WHERE total_position_quantity != 0 OR total_position_value != 0
ORDER BY trading_day_dt, partner_fk, trade_instrument_fk
