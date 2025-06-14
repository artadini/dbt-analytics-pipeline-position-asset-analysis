WITH
source AS ( SELECT * FROM {{ ref('stg_price_snapshots') }} )

SELECT
    price_snapshots_instrument_fk,
    {{ extract_number_values('price_snapshots_price') }} AS price_snapshots_price,
    UPPER({{ extract_currency_values('price_snapshots_price') }}) AS price_snapshots_currency,
    price_snapshots_dt
FROM source