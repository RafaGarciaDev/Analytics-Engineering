{{
    config(
        materialized='view',
        tags=['staging', 'orders']
    )
}}

with source as (
    select * from {{ source('ecommerce', 'raw_orders') }}
),

renamed as (
    select
        -- IDs
        id as order_id,
        customer_id,
        
        -- Order details
        order_date,
        status,
        
        -- Financial
        subtotal,
        tax_amount,
        shipping_amount,
        discount_amount,
        total_amount,
        
        -- Payment
        payment_method,
        payment_status,
        
        -- Metadata
        created_at,
        updated_at,
        
        -- Timestamps
        current_timestamp as loaded_at
        
    from source
    where id is not null
)

select * from renamed
