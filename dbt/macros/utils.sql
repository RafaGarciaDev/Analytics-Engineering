{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}

{% macro cents_to_dollars(column_name, scale=2) %}
    round({{ column_name }} / 100.0, {{ scale }})
{% endmacro %}

{% macro grant_select(role, schema, table) %}
    grant select on {{ schema }}.{{ table }} to {{ role }}
{% endmacro %}

{% macro get_column_values(table, column) %}
    {% set query %}
        select distinct {{ column }} 
        from {{ table }}
        order by 1
    {% endset %}
    
    {% set results = run_query(query) %}
    
    {% if execute %}
        {% set results_list = results.columns[0].values() %}
    {% else %}
        {% set results_list = [] %}
    {% endif %}
    
    {{ return(results_list) }}
{% endmacro %}
