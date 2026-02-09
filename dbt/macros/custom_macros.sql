{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}


{% macro cents_to_dollars(column_name, scale=2) %}
    ({{ column_name }} / 100)::numeric(16, {{ scale }})
{% endmacro %}


{% macro get_fiscal_year(date_column) %}
    case 
        when extract(month from {{ date_column }}) >= 4 
        then extract(year from {{ date_column }})
        else extract(year from {{ date_column }}) - 1
    end
{% endmacro %}


{% macro get_customer_segment(lifetime_value) %}
    case
        when {{ lifetime_value }} >= 1000 then 'VIP'
        when {{ lifetime_value }} >= 500 then 'Gold'
        when {{ lifetime_value }} >= 100 then 'Silver'
        else 'Bronze'
    end
{% endmacro %}


{% macro get_date_parts(date_column) %}
    extract(year from {{ date_column }}) as year,
    extract(month from {{ date_column }}) as month,
    extract(quarter from {{ date_column }}) as quarter,
    extract(day from {{ date_column }}) as day,
    extract(dow from {{ date_column }}) as day_of_week,
    to_char({{ date_column }}, 'Day') as day_name,
    to_char({{ date_column }}, 'Month') as month_name
{% endmacro %}


{% macro surrogate_key(field_list) %}
    md5(
        {% for field in field_list %}
            coalesce(cast({{ field }} as varchar), '')
            {% if not loop.last %}|| '|' || {% endif %}
        {% endfor %}
    )
{% endmacro %}


{% macro union_relations(relations, column_override=none, include=[], exclude=[]) %}
    {%- if relations is not iterable or relations is string -%}
        {%- set relations = [relations] -%}
    {%- endif -%}

    {%- set column_override = column_override if column_override is not none else {} -%}
    {%- set include = include if include is not none else [] -%}
    {%- set exclude = exclude if exclude is not none else [] -%}

    {%- for relation in relations %}
        (
            select
                {% if include|length > 0 -%}
                    {%- for col in include %}
                        {{ column_override.get(col, col) }}{% if not loop.last %},{% endif %}
                    {% endfor -%}
                {%- else -%}
                    *
                {%- endif %}
            from {{ relation }}
        )
        {% if not loop.last %}union all{% endif %}
    {% endfor -%}
{% endmacro %}


{% macro grant_select(role, schema) %}
    {% set sql %}
        grant usage on schema {{ schema }} to {{ role }};
        grant select on all tables in schema {{ schema }} to {{ role }};
        alter default privileges in schema {{ schema }} 
            grant select on tables to {{ role }};
    {% endset %}

    {% do run_query(sql) %}
    {% do log("Granted SELECT on schema " ~ schema ~ " to " ~ role, info=True) %}
{% endmacro %}


{% macro log_model_start() %}
    {% do log("Starting model: " ~ this, info=True) %}
{% endmacro %}


{% macro log_model_end() %}
    {% do log("Completed model: " ~ this, info=True) %}
{% endmacro %}
