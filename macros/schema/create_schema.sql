{#
    This macro overwrites the built-in default__create_schema
    to apply target-specific schema options such as expiration settings.
#}

{% macro default__create_schema(relation) %}
    {% call statement('create_schema') %}
        create schema if not exists {{ relation.schema }}
    {% endcall %}
{% endmacro %}

