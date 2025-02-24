{% test is_unique(model, column_name) %}

with validation as (
    select count( {{ column_name }} ) = count(distinct {{ column_name }}) as is_equal
    from {{ model }}
),

validation_errors as (
    select
        is_equal
    from validation
    where is_equal != 1
)

select *
from validation_errors

{% endtest %}