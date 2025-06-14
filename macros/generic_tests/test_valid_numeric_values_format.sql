{% test test_valid_numeric_values_format(model, column_name) %}
    /**
    Validates that the given column contains values in one of the following formats:
        - (amount, scale)
        - (amount, scale, currency)

    Ensures:
        - 'amount' and 'scale' are non-negative and numeric.
        - If present, 'currency' is a valid 3-letter uppercase code.
    
    Fails for:
        - Improper formatting.
        - Negative or non-numeric values.
        - Missing or invalid currency codes in 3-part strings.

    Args:
        model (ref): The dbt model to test.
        column_name (str): The column to validate.

    Returns:
        Rows that fail validation (i.e., test fails if any rows are returned).
    **/
    select
        *
    from {{ model }}
    where
        case
            -- Validate 2-part format: (amount, scale)
            when array_length(string_to_array({{ column_name }}, ','), 1) = 2 then (
                regexp_match(trim(leading '(' from split_part({{ column_name }}, ',', 1)), '^\d+(\.\d+)?$') is null
                or cast(trim(leading '(' from split_part({{ column_name }}, ',', 1)) as numeric) < 0
                or regexp_match(trim(trailing ')' from split_part({{ column_name }}, ',', 2)), '^\d+(\.\d+)?$') is null
                or cast(trim(trailing ')' from split_part({{ column_name }}, ',', 2)) as numeric) < 0
            )

            -- Validate 3-part format: (amount, scale, currency)
            when array_length(string_to_array({{ column_name }}, ','), 1) = 3 then (
                regexp_match(trim(leading '(' from split_part({{ column_name }}, ',', 1)), '^\d+(\.\d+)?$') is null
                or cast(trim(leading '(' from split_part({{ column_name }}, ',', 1)) as numeric) < 0
                or regexp_match(split_part({{ column_name }}, ',', 2), '^\d+(\.\d+)?$') is null
                or cast(split_part({{ column_name }}, ',', 2) as numeric) < 0
                or regexp_match(trim(trailing ')' from split_part({{ column_name }}, ',', 3)), '^[A-Z]{3}$') is null
                or trim(trailing ')' from split_part({{ column_name }}, ',', 3)) = ''
                or trim(trailing ')' from split_part({{ column_name }}, ',', 3)) is null
            )

            -- Invalid if it doesn't match either pattern
            else true
        end
{% endtest %}
