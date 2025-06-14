{% test test_no_future_dates(model, column_name) %}
    /**
    Validates that the specified date column does not contain any future dates.

    This test fails if:
        - Any value in the column is greater than the current date (i.e., lies in the future).

    Args:
        model (ref): The dbt model to test.
        column_name (str): The date column to validate.

    Returns:
        Rows where the column contains a future date.
    **/
    select *
    from {{ model }}
    where {{ column_name }} > current_date
{% endtest %}
