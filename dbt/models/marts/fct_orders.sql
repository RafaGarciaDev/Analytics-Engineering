{{
    config(
        materialized='table',
        tags=['marts', 'facts'],
        indexes=[
            {'columns': ['order_id'], 'unique': True},
            {'columns': ['customer_id']},
            {'columns': ['order_date']}
        ]
    )
}}

with orders as (
    select * from {{ ref('int_orders_enriched') }}
),

final as (
    select
        -- Primary key
        order_id,
        
        -- Foreign keys
        customer_id,
        
        -- Dates
        order_date,
        created_at as order_created_at,
        order_year,
        order_month,
        order_quarter,
        order_day_of_week,
        order_day_name,
        
        -- Attributes
        order_status,
        payment_method,
        shipping_method,
        
        -- Metrics
        order_amount,
        tax_amount,
        shipping_amount,
        discount_amount,
        total_amount,
        
        -- Flags
        has_discount,
        is_completed,
        is_cancelled,
        
        -- Metadata
        current_timestamp as dbt_updated_at
        
    from orders
)

select * from final
