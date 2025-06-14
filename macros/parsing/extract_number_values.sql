{% macro extract_number_values(column_name) %}
    /**
    Extracts a numeric value from a string representation of a tuple.

    The input is expected to be in one of the following formats:
    - (amount, scale)
    - (amount, scale, currency)

    The macro divides the numeric amount by 10 raised to the scale power.
    Currency (if present) is ignored.

    Args:
        column_name (str): The name of the column containing the string-formatted tuple.

    Returns:
        A numeric value adjusted by scale, or 0 if the format is invalid.
    **/
    case
        -- Handle fractional format: (amount, scale)
        when array_length(string_to_array({{ column_name }}, ','), 1) = 2 then
            {{ dbt_utils.safe_divide(
                "trim(leading '(' from split_part(" ~ column_name ~ ", ',', 1))::numeric",
                "nullif(power(10, trim(trailing ')' from split_part(" ~ column_name ~ ", ',', 2))::int), 0)"
            ) }}

        -- Handle monetary format: (amount, scale, currency)
        when array_length(string_to_array({{ column_name }}, ','), 1) = 3 then
            {{ dbt_utils.safe_divide(
                "trim(leading '(' from split_part(" ~ column_name ~ ", ',', 1))::numeric",
                "nullif(power(10, split_part(" ~ column_name ~ ", ',', 2)::int), 0)"
            ) }}

        -- Default to 0 if format doesn't match expected patterns
        else 0
    end
{% endmacro %}
