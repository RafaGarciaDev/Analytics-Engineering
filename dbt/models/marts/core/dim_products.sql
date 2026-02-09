{{
    config(
        materialized='table',
        tags=['core', 'dimensions']
    )
}}

with products as (
    select * from {{ ref('stg_products') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

product_performance as (
    select
        product_id,
        count(distinct order_id) as times_ordered,
        sum(quantity) as total_quantity_sold,
        sum(line_total_after_discount) as total_revenue,
        avg(unit_price) as avg_selling_price
    from order_items
    group by product_id
),

final as (
    select
        -- Product identifiers
        p.product_id,
        p.sku,
        
        -- Product info
        p.product_name,
        p.description,
        p.category,
        p.subcategory,
        p.brand,
        
        -- Pricing
        p.cost,
        p.price as list_price,
        p.margin,
        p.margin_percentage,
        coalesce(pp.avg_selling_price, p.price) as avg_selling_price,
        
        -- Inventory
        p.stock_quantity,
        p.stock_status,
        
        -- Performance metrics
        coalesce(pp.times_ordered, 0) as times_ordered,
        coalesce(pp.total_quantity_sold, 0) as total_quantity_sold,
        coalesce(pp.total_revenue, 0) as total_revenue,
        
        -- Product classification
        case
            when pp.total_revenue >= 10000 then 'top_seller'
            when pp.total_revenue >= 5000 then 'good_seller'
            when pp.total_revenue >= 1000 then 'average_seller'
            when pp.total_revenue > 0 then 'low_seller'
            else 'no_sales'
        end as performance_tier,
        
        -- Status
        p.is_active,
        
        -- Timestamps
        p.created_at as product_created_at,
        p.updated_at as product_updated_at,
        current_timestamp as dbt_updated_at
        
    from products p
    left join product_performance pp on p.product_id = pp.product_id
)

select * from final
