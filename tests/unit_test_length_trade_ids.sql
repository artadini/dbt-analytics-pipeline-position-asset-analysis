-- Test to check if customer_fk in stg_customer_accounts is always 35 characters long

SELECT
    trade_pk
FROM
    stg_trades
WHERE
    LENGTH(trade_pk) != 35
