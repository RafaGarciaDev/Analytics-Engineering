{{
    config(
        materialized='table',
        tags=['core', 'dimensions']
    )
}}

with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

customer_orders as (
    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date,
        count(distinct order_id) as lifetime_orders,
        sum(total_amount) as lifetime_value,
        avg(total_amount) as avg_order_value,
        count(distinct case when status = 'completed' then order_id end) as completed_orders,
        sum(case when status = 'completed' then total_amount else 0 end) as total_revenue
    from orders
    group by customer_id
),

final as (
    select
        -- Customer identifiers
        c.customer_id,
        
        -- Customer info
        c.first_name,
        c.last_name,
        c.full_name,
        c.email,
        c.phone,
        
        -- Location
        c.address,
        c.city,
        c.state,
        c.zip_code,
        c.country,
        
        -- Order metrics
        coalesce(co.lifetime_orders, 0) as lifetime_orders,
        coalesce(co.lifetime_value, 0) as lifetime_value,
        coalesce(co.avg_order_value, 0) as avg_order_value,
        coalesce(co.completed_orders, 0) as completed_orders,
        coalesce(co.total_revenue, 0) as total_revenue,
        
        -- Customer journey
        co.first_order_date,
        co.last_order_date,
        datediff('day', co.first_order_date, co.last_order_date) as customer_tenure_days,
        
        -- Segmentation
        case 
            when co.lifetime_orders is null then 'never_purchased'
            when co.lifetime_orders = 1 then 'one_time_buyer'
            when co.lifetime_orders between 2 and 5 then 'repeat_buyer'
            when co.lifetime_orders > 5 then 'loyal_customer'
        end as customer_segment,
        
        case
            when co.total_revenue >= 1000 then 'high_value'
            when co.total_revenue >= 500 then 'medium_value'
            when co.total_revenue > 0 then 'low_value'
            else 'no_value'
        end as value_segment,
        
        -- Status
        c.is_active,
        
        -- Timestamps
        c.created_at as customer_created_at,
        c.updated_at as customer_updated_at,
        current_timestamp as dbt_updated_at
        
    from customers c
    left join customer_orders co on c.customer_id = co.customer_id
)

select * from final
