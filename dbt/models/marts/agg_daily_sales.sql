{{
    config(
        materialized='table',
        tags=['marts', 'aggregates'],
        indexes=[
            {'columns': ['order_date']}
        ]
    )
}}

with orders as (
    select * from {{ ref('fct_orders') }}
),

daily_metrics as (
    select
        order_date,
        order_year,
        order_month,
        order_quarter,
        order_day_name,
        
        -- Order counts
        count(distinct order_id) as total_orders,
        count(distinct case when is_completed then order_id end) as completed_orders,
        count(distinct case when is_cancelled then order_id end) as cancelled_orders,
        
        -- Customer counts
        count(distinct customer_id) as unique_customers,
        
        -- Revenue metrics
        sum(case when is_completed then total_amount else 0 end) as total_revenue,
        sum(case when is_completed then order_amount else 0 end) as gross_revenue,
        sum(case when is_completed then tax_amount else 0 end) as total_tax,
        sum(case when is_completed then shipping_amount else 0 end) as total_shipping,
        sum(case when is_completed then discount_amount else 0 end) as total_discounts,
        
        -- Average metrics
        avg(case when is_completed then total_amount end) as avg_order_value,
        avg(case when is_completed then discount_amount end) as avg_discount,
        
        -- Discount analysis
        count(distinct case when has_discount and is_completed then order_id end) as orders_with_discount,
        round(
            count(distinct case when has_discount and is_completed then order_id end)::numeric / 
            nullif(count(distinct case when is_completed then order_id end), 0) * 100,
            2
        ) as discount_rate_pct,
        
        -- Payment methods
        count(distinct case when payment_method = 'credit_card' then order_id end) as credit_card_orders,
        count(distinct case when payment_method = 'debit_card' then order_id end) as debit_card_orders,
        count(distinct case when payment_method = 'paypal' then order_id end) as paypal_orders,
        
        -- Metadata
        current_timestamp as dbt_updated_at
        
    from orders
    group by 1, 2, 3, 4, 5
)

select * from daily_metrics
order by order_date desc
