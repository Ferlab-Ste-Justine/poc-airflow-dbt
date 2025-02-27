{% macro generate_locus_fields_hash(fields) %}
    sha2(concat_ws('-', {{ fields | join(', ') }}), '256')
{% endmacro %}
