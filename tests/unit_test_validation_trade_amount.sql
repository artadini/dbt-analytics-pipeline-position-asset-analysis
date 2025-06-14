-- This test checks that the trade_amount is correctly calculated as trade_quantity * trade_price

SELECT
    *
FROM
    {{ ref('int_cleaned_trades') }}
WHERE
    abs(trade_quantity * trade_price - trade_amount) > 0.01
 