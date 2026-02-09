{{
    config(
        materialized='table',
        tags=['marts', 'dimensions'],
        indexes=[
            {'columns': ['product_id'], 'unique': True},
            {'columns': ['category']}
        ]
    )
}}

with products as (
    select * from {{ ref('stg_products') }}
),

final as (
    select
        -- Primary key
        product_id,
        
        -- Product info
        product_name,
        category,
        sub_category,
        brand,
        supplier,
        
        -- Pricing
        price,
        cost,
        margin,
        round((margin / nullif(price, 0)) * 100, 2) as margin_percentage,
        
        -- Inventory
        stock_quantity,
        stock_level,
        
        -- Dates
        product_created_at,
        product_updated_at,
        
        -- Status
        product_status,
        
        -- Flags
        case when stock_quantity > 0 then true else false end as is_in_stock,
        case when margin > 0 then true else false end as is_profitable,
        
        -- Metadata
        current_timestamp as dbt_updated_at
        
    from products
)

select * from final
