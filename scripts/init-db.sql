-- Script de inicialização do banco de dados
-- Cria schemas e tabelas de exemplo para o projeto

-- Criar database analytics
CREATE DATABASE IF NOT EXISTS analytics;

-- Conectar ao database analytics
\c analytics;

-- Criar schemas
CREATE SCHEMA IF NOT EXISTS public;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS intermediate;
CREATE SCHEMA IF NOT EXISTS marts;
CREATE SCHEMA IF NOT EXISTS seeds;
CREATE SCHEMA IF NOT EXISTS dbt_dev;
CREATE SCHEMA IF NOT EXISTS dbt_prod;

-- Tabela: raw_customers
CREATE TABLE IF NOT EXISTS public.raw_customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(50),
    zip_code VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela: raw_products
CREATE TABLE IF NOT EXISTS public.raw_products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    sub_category VARCHAR(100),
    brand VARCHAR(100),
    supplier VARCHAR(100),
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela: raw_orders
CREATE TABLE IF NOT EXISTS public.raw_orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES public.raw_customers(customer_id),
    order_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    shipping_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    payment_method VARCHAR(50),
    shipping_method VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inserir dados de exemplo em customers
INSERT INTO public.raw_customers (first_name, last_name, email, phone, city, state, country, zip_code) VALUES
    ('João', 'Silva', 'joao.silva@email.com', '11987654321', 'São Paulo', 'SP', 'BR', '01234-567'),
    ('Maria', 'Santos', 'maria.santos@email.com', '21987654321', 'Rio de Janeiro', 'RJ', 'BR', '20000-000'),
    ('Pedro', 'Oliveira', 'pedro.oliveira@email.com', '11976543210', 'São Paulo', 'SP', 'BR', '04567-890'),
    ('Ana', 'Costa', 'ana.costa@email.com', '85987654321', 'Fortaleza', 'CE', 'BR', '60000-000'),
    ('Carlos', 'Ferreira', 'carlos.ferreira@email.com', '31987654321', 'Belo Horizonte', 'MG', 'BR', '30000-000')
ON CONFLICT (email) DO NOTHING;

-- Inserir dados de exemplo em products
INSERT INTO public.raw_products (product_name, category, sub_category, brand, supplier, price, cost, stock_quantity) VALUES
    ('Smartphone XYZ', 'electronics', 'mobile', 'TechBrand', 'Supplier A', 1999.99, 1200.00, 50),
    ('Laptop Pro 15', 'electronics', 'computers', 'TechBrand', 'Supplier A', 4999.99, 3500.00, 25),
    ('Wireless Headphones', 'electronics', 'audio', 'AudioBrand', 'Supplier B', 399.99, 200.00, 100),
    ('Smart Watch', 'electronics', 'wearables', 'TechBrand', 'Supplier A', 899.99, 500.00, 75),
    ('USB-C Cable', 'electronics', 'accessories', 'GenericBrand', 'Supplier C', 29.99, 10.00, 200)
ON CONFLICT DO NOTHING;

-- Inserir dados de exemplo em orders
INSERT INTO public.raw_orders (customer_id, order_date, status, amount, tax_amount, shipping_amount, discount_amount, payment_method, shipping_method) VALUES
    (1, CURRENT_DATE - INTERVAL '5 days', 'completed', 1999.99, 200.00, 50.00, 0.00, 'credit_card', 'express'),
    (2, CURRENT_DATE - INTERVAL '4 days', 'completed', 399.99, 40.00, 20.00, 50.00, 'debit_card', 'standard'),
    (1, CURRENT_DATE - INTERVAL '3 days', 'completed', 29.99, 3.00, 10.00, 0.00, 'credit_card', 'standard'),
    (3, CURRENT_DATE - INTERVAL '2 days', 'processing', 4999.99, 500.00, 0.00, 100.00, 'paypal', 'express'),
    (4, CURRENT_DATE - INTERVAL '1 day', 'completed', 899.99, 90.00, 30.00, 0.00, 'credit_card', 'express'),
    (5, CURRENT_DATE, 'pending', 399.99, 40.00, 20.00, 0.00, 'debit_card', 'standard')
ON CONFLICT DO NOTHING;

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON public.raw_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON public.raw_orders(order_date);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.raw_orders(status);
CREATE INDEX IF NOT EXISTS idx_customers_email ON public.raw_customers(email);
CREATE INDEX IF NOT EXISTS idx_products_category ON public.raw_products(category);

-- Mensagem de sucesso
SELECT 'Database initialized successfully!' as message;
