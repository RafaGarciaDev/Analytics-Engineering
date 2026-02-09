{{
    config(
        materialized='table',
        tags=['finance', 'metrics']
    )
}}

with orders as (
    select * from {{ ref('fct_orders') }}
),

daily_metrics as (
    select
        date_trunc('day', order_date) as date,
        
        -- Order counts
        count(distinct order_id) as total_orders,
        count(distinct case when is_completed = 1 then order_id end) as completed_orders,
        count(distinct customer_id) as unique_customers,
        
        -- Revenue metrics
        sum(case when is_completed = 1 then total_amount else 0 end) as gross_revenue,
        sum(case when is_completed = 1 then net_revenue else 0 end) as net_revenue,
        sum(case when is_completed = 1 then tax_amount else 0 end) as total_tax,
        sum(case when is_completed = 1 then shipping_amount else 0 end) as total_shipping,
        sum(case when is_completed = 1 then total_discount else 0 end) as total_discounts,
        
        -- Average metrics
        avg(case when is_completed = 1 then total_amount end) as avg_order_value,
        avg(case when is_completed = 1 then number_of_items end) as avg_items_per_order,
        
    from orders
    group by date_trunc('day', order_date)
),

with_running_totals as (
    select
        *,
        
        -- Running totals
        sum(gross_revenue) over (order by date rows between unbounded preceding and current row) as cumulative_revenue,
        sum(total_orders) over (order by date rows between unbounded preceding and current row) as cumulative_orders,
        
        -- Week over week growth
        lag(gross_revenue, 7) over (order by date) as revenue_7d_ago,
        (gross_revenue - lag(gross_revenue, 7) over (order by date)) / nullif(lag(gross_revenue, 7) over (order by date), 0) * 100 as wow_revenue_growth_pct,
        
        -- Month over month
        lag(gross_revenue, 30) over (order by date) as revenue_30d_ago,
        
    from daily_metrics
),

final as (
    select
        date,
        
        -- Order metrics
        total_orders,
        completed_orders,
        unique_customers,
        
        -- Revenue
        round(gross_revenue, 2) as gross_revenue,
        round(net_revenue, 2) as net_revenue,
        round(total_tax, 2) as total_tax,
        round(total_shipping, 2) as total_shipping,
        round(total_discounts, 2) as total_discounts,
        
        -- Averages
        round(avg_order_value, 2) as avg_order_value,
        round(avg_items_per_order, 2) as avg_items_per_order,
        
        -- Running totals
        round(cumulative_revenue, 2) as cumulative_revenue,
        cumulative_orders,
        
        -- Growth
        round(wow_revenue_growth_pct, 2) as wow_revenue_growth_pct,
        
        -- Timestamp
        current_timestamp as dbt_updated_at
        
    from with_running_totals
)

select * from final
order by date desc
