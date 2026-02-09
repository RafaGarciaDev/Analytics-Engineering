{{
    config(
        materialized='view',
        tags=['staging', 'products']
    )
}}

with source as (
    select * from {{ source('ecommerce', 'raw_products') }}
),

renamed as (
    select
        -- IDs
        id as product_id,
        
        -- Product info
        name as product_name,
        description,
        category,
        subcategory,
        brand,
        sku,
        
        -- Pricing
        cost,
        price,
        price - cost as margin,
        round((price - cost) / nullif(price, 0) * 100, 2) as margin_percentage,
        
        -- Inventory
        stock_quantity,
        case 
            when stock_quantity = 0 then 'out_of_stock'
            when stock_quantity < 10 then 'low_stock'
            else 'in_stock'
        end as stock_status,
        
        -- Metadata
        is_active,
        created_at,
        updated_at,
        
        -- Timestamps
        current_timestamp as loaded_at
        
    from source
    where id is not null
)

select * from renamed
