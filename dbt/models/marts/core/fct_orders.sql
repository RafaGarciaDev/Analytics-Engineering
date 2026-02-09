{{
    config(
        materialized='table',
        tags=['core', 'facts']
    )
}}

with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

order_items as (
    select 
        order_id,
        count(*) as number_of_items,
        sum(quantity) as total_quantity,
        sum(line_total) as items_subtotal,
        sum(discount) as total_discount
    from {{ ref('stg_order_items') }}
    group by order_id
),

final as (
    select
        -- Order identifiers
        o.order_id,
        o.customer_id,
        
        -- Customer info
        c.full_name as customer_name,
        c.email as customer_email,
        c.city as customer_city,
        c.state as customer_state,
        c.country as customer_country,
        
        -- Order details
        o.order_date,
        o.status as order_status,
        o.payment_method,
        o.payment_status,
        
        -- Order metrics
        oi.number_of_items,
        oi.total_quantity,
        
        -- Financial metrics
        o.subtotal,
        o.tax_amount,
        o.shipping_amount,
        oi.total_discount,
        o.total_amount,
        
        -- Derived metrics
        o.total_amount - oi.total_discount as net_revenue,
        
        -- Flags
        case when o.status = 'completed' then 1 else 0 end as is_completed,
        case when o.payment_status = 'paid' then 1 else 0 end as is_paid,
        
        -- Timestamps
        o.created_at,
        o.updated_at,
        current_timestamp as dbt_updated_at
        
    from orders o
    left join customers c on o.customer_id = c.customer_id
    left join order_items oi on o.order_id = oi.order_id
)

select * from final
