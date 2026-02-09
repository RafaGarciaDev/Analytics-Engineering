{{
    config(
        materialized='view',
        tags=['intermediate', 'orders']
    )
}}

with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

enriched as (
    select
        -- Order info
        o.order_id,
        o.order_date,
        o.order_status,
        o.created_at,
        
        -- Customer info
        o.customer_id,
        c.full_name as customer_name,
        c.email as customer_email,
        c.city,
        c.state,
        c.country,
        
        -- Amounts
        o.order_amount,
        o.tax_amount,
        o.shipping_amount,
        o.discount_amount,
        o.total_amount,
        
        -- Payment and shipping
        o.payment_method,
        o.shipping_method,
        
        -- Flags
        case when o.discount_amount > 0 then true else false end as has_discount,
        case when o.order_status = 'completed' then true else false end as is_completed,
        case when o.order_status = 'cancelled' then true else false end as is_cancelled,
        
        -- Date parts
        extract(year from o.order_date) as order_year,
        extract(month from o.order_date) as order_month,
        extract(quarter from o.order_date) as order_quarter,
        extract(dow from o.order_date) as order_day_of_week,
        to_char(o.order_date, 'Day') as order_day_name,
        
        -- Customer tenure at order time
        date_part('day', o.order_date - c.customer_created_at) as customer_tenure_days
        
    from orders o
    left join customers c on o.customer_id = c.customer_id
)

select * from enriched
