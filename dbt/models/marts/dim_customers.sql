{{
    config(
        materialized='table',
        tags=['marts', 'dimensions'],
        indexes=[
            {'columns': ['customer_id'], 'unique': True},
            {'columns': ['email']}
        ]
    )
}}

with customers as (
    select * from {{ ref('stg_customers') }}
),

customer_orders as (
    select
        customer_id,
        count(distinct order_id) as lifetime_orders,
        sum(total_amount) as lifetime_value,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date,
        avg(total_amount) as avg_order_value
    from {{ ref('fct_orders') }}
    where is_completed = true
    group by customer_id
),

final as (
    select
        -- Primary key
        c.customer_id,
        
        -- Personal info
        c.first_name,
        c.last_name,
        c.full_name,
        c.email,
        
        -- Contact
        c.phone,
        
        -- Address
        c.city,
        c.state,
        c.country,
        c.zip_code,
        
        -- Dates
        c.customer_created_at,
        c.customer_updated_at,
        
        -- Status
        c.customer_status,
        
        -- Metrics
        coalesce(o.lifetime_orders, 0) as lifetime_orders,
        coalesce(o.lifetime_value, 0) as lifetime_value,
        coalesce(o.avg_order_value, 0) as avg_order_value,
        o.first_order_date,
        o.last_order_date,
        
        -- Segments
        case
            when coalesce(o.lifetime_orders, 0) = 0 then 'no_orders'
            when o.lifetime_orders = 1 then 'one_time'
            when o.lifetime_orders between 2 and 5 then 'regular'
            when o.lifetime_orders > 5 then 'loyal'
        end as customer_segment,
        
        case
            when coalesce(o.lifetime_value, 0) = 0 then 'no_value'
            when o.lifetime_value < 100 then 'low_value'
            when o.lifetime_value between 100 and 500 then 'medium_value'
            when o.lifetime_value > 500 then 'high_value'
        end as value_segment,
        
        -- Flags
        case 
            when o.last_order_date >= current_date - interval '90 days' then true 
            else false 
        end as is_active_customer,
        
        -- Metadata
        current_timestamp as dbt_updated_at
        
    from customers c
    left join customer_orders o on c.customer_id = o.customer_id
)

select * from final
