-- Initialize analytics database
-- Creates schemas and initial tables for the e-commerce analytics platform

-- Create schemas
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS marts;
CREATE SCHEMA IF NOT EXISTS seeds;
CREATE SCHEMA IF NOT EXISTS snapshots;
CREATE SCHEMA IF NOT EXISTS dbt_test_failures;

-- Grant permissions
GRANT ALL PRIVILEGES ON SCHEMA raw TO analytics_user;
GRANT ALL PRIVILEGES ON SCHEMA staging TO analytics_user;
GRANT ALL PRIVILEGES ON SCHEMA marts TO analytics_user;
GRANT ALL PRIVILEGES ON SCHEMA seeds TO analytics_user;
GRANT ALL PRIVILEGES ON SCHEMA snapshots TO analytics_user;
GRANT ALL PRIVILEGES ON SCHEMA dbt_test_failures TO analytics_user;

-- Create raw tables
CREATE TABLE IF NOT EXISTS raw.raw_customers (
    id INTEGER PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(50),
    zip_code VARCHAR(20),
    country VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw.raw_products (
    id INTEGER PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    subcategory VARCHAR(100),
    brand VARCHAR(100),
    sku VARCHAR(100) UNIQUE NOT NULL,
    cost DECIMAL(10, 2),
    price DECIMAL(10, 2),
    stock_quantity INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw.raw_orders (
    id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES raw.raw_customers(id),
    order_date TIMESTAMP,
    status VARCHAR(50),
    subtotal DECIMAL(10, 2),
    tax_amount DECIMAL(10, 2),
    shipping_amount DECIMAL(10, 2),
    discount_amount DECIMAL(10, 2),
    total_amount DECIMAL(10, 2),
    payment_method VARCHAR(50),
    payment_status VARCHAR(50),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw.raw_order_items (
    id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES raw.raw_orders(id),
    product_id INTEGER REFERENCES raw.raw_products(id),
    quantity INTEGER,
    unit_price DECIMAL(10, 2),
    discount DECIMAL(10, 2),
    created_at TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON raw.raw_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON raw.raw_orders(order_date);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON raw.raw_order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON raw.raw_order_items(product_id);

-- Add comments
COMMENT ON SCHEMA raw IS 'Raw data layer - bronze';
COMMENT ON SCHEMA staging IS 'Staging layer - silver';
COMMENT ON SCHEMA marts IS 'Business marts layer - gold';

COMMENT ON TABLE raw.raw_customers IS 'Customer master data';
COMMENT ON TABLE raw.raw_products IS 'Product catalog';
COMMENT ON TABLE raw.raw_orders IS 'Order transactions';
COMMENT ON TABLE raw.raw_order_items IS 'Order line items';

-- Grant table permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA raw TO analytics_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA raw TO analytics_user;

-- Success message
SELECT 'Database initialized successfully!' as status;
