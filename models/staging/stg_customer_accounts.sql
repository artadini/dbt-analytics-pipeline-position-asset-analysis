WITH
source AS ( SELECT * FROM {{ ref('customer_accounts') }} )

SELECT
    customer_account_id AS customer_account_pk,
    customer_id AS customer_fk,
    partner_id AS partner_fk
FROM source
