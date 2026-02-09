{{
    config(
        materialized='table',
        tags=['marketing', 'metrics']
    )
}}

with customers as (
    select * from {{ ref('dim_customers') }}
),

orders as (
    select * from {{ ref('fct_orders') }}
),

cohort_analysis as (
    select
        date_trunc('month', first_order_date) as cohort_month,
        count(distinct customer_id) as cohort_size,
        sum(lifetime_value) as cohort_ltv,
        avg(lifetime_value) as avg_customer_ltv,
        avg(lifetime_orders) as avg_orders_per_customer
    from customers
    where first_order_date is not null
    group by date_trunc('month', first_order_date)
),

retention as (
    select
        date_trunc('month', c.first_order_date) as cohort_month,
        date_trunc('month', o.order_date) as order_month,
        count(distinct o.customer_id) as returning_customers
    from customers c
    inner join orders o on c.customer_id = o.customer_id
    where o.is_completed = 1
    group by 
        date_trunc('month', c.first_order_date),
        date_trunc('month', o.order_date)
),

customer_segments as (
    select
        customer_segment,
        value_segment,
        count(*) as customer_count,
        sum(lifetime_value) as total_value,
        avg(lifetime_value) as avg_value,
        avg(lifetime_orders) as avg_orders
    from customers
    group by customer_segment, value_segment
),

final as (
    select
        -- Cohort analysis
        ca.cohort_month,
        ca.cohort_size,
        round(ca.cohort_ltv, 2) as cohort_ltv,
        round(ca.avg_customer_ltv, 2) as avg_customer_ltv,
        round(ca.avg_orders_per_customer, 2) as avg_orders_per_customer,
        
        -- Overall metrics
        (select count(*) from customers) as total_customers,
        (select count(*) from customers where customer_segment != 'never_purchased') as active_customers,
        (select round(avg(lifetime_value), 2) from customers where customer_segment != 'never_purchased') as overall_avg_ltv,
        
        -- Timestamp
        current_timestamp as dbt_updated_at
        
    from cohort_analysis ca
)

select * from final
order by cohort_month desc
