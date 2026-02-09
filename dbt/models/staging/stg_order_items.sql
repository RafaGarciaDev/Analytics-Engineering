{{
    config(
        materialized='view',
        tags=['staging', 'order_items']
    )
}}

with source as (
    select * from {{ source('ecommerce', 'raw_order_items') }}
),

renamed as (
    select
        -- IDs
        id as order_item_id,
        order_id,
        product_id,
        
        -- Item details
        quantity,
        unit_price,
        discount,
        
        -- Calculated fields
        quantity * unit_price as line_total,
        quantity * unit_price - discount as line_total_after_discount,
        
        -- Metadata
        created_at,
        
        -- Timestamps
        current_timestamp as loaded_at
        
    from source
    where id is not null
)

select * from renamed
