{{
    config(
        materialized='view',
        tags=['staging', 'customers']
    )
}}

with source as (
    select * from {{ source('ecommerce', 'raw_customers') }}
),

renamed as (
    select
        -- IDs
        id as customer_id,
        
        -- Customer info
        first_name,
        last_name,
        concat(first_name, ' ', last_name) as full_name,
        email,
        phone,
        
        -- Location
        address,
        city,
        state,
        zip_code,
        country,
        
        -- Metadata
        created_at,
        updated_at,
        is_active,
        
        -- Timestamps
        current_timestamp as loaded_at
        
    from source
    where id is not null
)

select * from renamed
