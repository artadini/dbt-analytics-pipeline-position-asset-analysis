WITH
source AS ( SELECT * FROM {{ ref('stg_trades') }} )

SELECT
    trade_pk,
    customer_account_fk,
    trade_instrument_fk,
    trade_side,
    trade_created_dt,
    -- Extracting number and currency values using macros
    {{extract_number_values('trade_quantity')}} AS trade_quantity,
    {{extract_number_values('trade_price')}} AS trade_price,
    UPPER({{extract_currency_values('trade_price')}}) AS trade_price_currency,
    {{extract_number_values('trade_amount')}} AS trade_amount,
    UPPER({{extract_currency_values('trade_amount')}}) AS trade_amount_currency
FROM source