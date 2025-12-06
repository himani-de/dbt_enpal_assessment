{#- Sets the datasets name, based on the target environment and the models parent folders -#}
{% macro generate_schema_name(custom_schema_name= name, node=name) -%}

    {# 1. Add prefix for dev/test environments #}
    {% set prefix = dataset_prefix() %}

     {#- 2. Determine schema part based on folder structure -#}
     {%- if node.fqn[2] is defined -%}
        {{- node.fqn[1] -}}
     {%- else -%}
        {{- node.package_name -}}
     {%- endif -%}

{%- endmacro %}
