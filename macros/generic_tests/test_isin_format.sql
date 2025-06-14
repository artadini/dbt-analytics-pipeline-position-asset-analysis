{% test test_isin_format(model, column_name) %}
    /**
    Validates that the specified column contains properly formatted ISIN codes.

    ISINs must:
        - Be exactly 12 characters long.
        - Match the pattern: 2 uppercase letters, 9 alphanumeric characters, and end with 1 digit.
          (Regex: ^[A-Z]{2}[A-Z0-9]{9}[0-9]$)

    Args:
        model (ref): The dbt model to test.
        column_name (str): The column containing ISIN values.

    Returns:
        Rows where the ISIN format is invalid.
    **/

    select *
    from {{ model }}
    where
        length({{ column_name }}) != 12
        or {{ column_name }} !~ '^[A-Z]{2}[A-Z0-9]{9}[0-9]$'
{% endtest %}
