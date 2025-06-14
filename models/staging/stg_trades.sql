WITH
source AS ( SELECT * FROM {{ ref('trades') }} )

SELECT
    id AS trade_pk,
    customer_account_id AS customer_account_fk,
    side AS trade_side,
    instrument AS trade_instrument_fk,
    quantity AS trade_quantity,
    price AS trade_price,
    amount AS trade_amount,
    created_at AS trade_created_dt
FROM source