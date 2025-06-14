WITH
source AS ( SELECT * FROM {{ ref('price_snapshots') }} )

SELECT
    instrument AS price_snapshots_instrument_fk,
    price AS price_snapshots_price,
    timestamp AS price_snapshots_dt
FROM source
