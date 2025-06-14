{% macro extract_currency_values(column_name) %}
    /**
    Extracts the currency code from a string formatted as:
    (amount, decimal_places, currency_code)

    The macro assumes the input is a string representing a tuple of three elements.
    It parses and returns the currency code (e.g., 'EUR') as a string.

    Args:
        column_name (str): The name of the column containing the formatted string.

    Returns:
        str: The extracted currency code if present, otherwise NULL.
    **/
    case
        -- Extract currency from well-formed 3-part string
        when array_length(string_to_array({{ column_name }}, ','), 1) = 3 then
            trim(trailing ')' from split_part({{ column_name }}, ',', 3))
        else null
    end
{% endmacro %}
