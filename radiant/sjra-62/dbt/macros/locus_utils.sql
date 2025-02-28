{% macro generate_locus_fields_hash(fields) %}
    sha2(concat_ws('-', {{ fields | join(', ') }}), '256')
{% endmacro %}

{% macro get_locus_lookup(lookup_table, fields, key_name) %}
    dict_mapping(
            "{{ lookup_table }}",
            {{ generate_locus_fields_hash(fields) }},
            "{{ key_name }}"
    )
{% endmacro %}