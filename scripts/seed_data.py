#!/usr/bin/env python3
"""
Seed Data Generator
Generates sample e-commerce data for the analytics platform.
"""

import random
import csv
from datetime import datetime, timedelta
from faker import Faker

fake = Faker()
Faker.seed(42)
random.seed(42)

# Configuration
NUM_CUSTOMERS = 1000
NUM_PRODUCTS = 200
NUM_ORDERS = 5000

OUTPUT_DIR = 'data/sample'

def generate_customers(num_customers):
    """Generate customer data"""
    customers = []
    for i in range(1, num_customers + 1):
        customers.append({
            'id': i,
            'first_name': fake.first_name(),
            'last_name': fake.last_name(),
            'email': fake.email(),
            'phone': fake.phone_number(),
            'address': fake.street_address(),
            'city': fake.city(),
            'state': fake.state_abbr(),
            'zip_code': fake.zipcode(),
            'country': 'USA',
            'is_active': random.choice([True, False]),
            'created_at': fake.date_time_between(start_date='-2y', end_date='now'),
            'updated_at': fake.date_time_between(start_date='-30d', end_date='now'),
        })
    return customers

def generate_products(num_products):
    """Generate product data"""
    categories = ['Electronics', 'Clothing', 'Home & Garden', 'Sports', 'Books', 'Toys']
    brands = ['BrandA', 'BrandB', 'BrandC', 'BrandD', 'BrandE']
    
    products = []
    for i in range(1, num_products + 1):
        cost = round(random.uniform(10, 500), 2)
        price = round(cost * random.uniform(1.3, 2.5), 2)
        
        products.append({
            'id': i,
            'name': fake.catch_phrase(),
            'description': fake.text(max_nb_chars=200),
            'category': random.choice(categories),
            'subcategory': fake.word(),
            'brand': random.choice(brands),
            'sku': f'SKU-{i:05d}',
            'cost': cost,
            'price': price,
            'stock_quantity': random.randint(0, 500),
            'is_active': random.choice([True, True, True, False]),  # 75% active
            'created_at': fake.date_time_between(start_date='-3y', end_date='-1y'),
            'updated_at': fake.date_time_between(start_date='-30d', end_date='now'),
        })
    return products

def generate_orders(num_orders, customers, products):
    """Generate order data"""
    statuses = ['pending', 'processing', 'completed', 'cancelled']
    payment_methods = ['credit_card', 'debit_card', 'paypal', 'bank_transfer']
    payment_statuses = ['paid', 'pending', 'failed']
    
    orders = []
    order_items = []
    order_item_id = 1
    
    for i in range(1, num_orders + 1):
        customer = random.choice(customers)
        order_date = fake.date_time_between(start_date='-1y', end_date='now')
        status = random.choice(statuses)
        
        # Generate order items
        num_items = random.randint(1, 5)
        items_subtotal = 0
        items_discount = 0
        
        for _ in range(num_items):
            product = random.choice(products)
            quantity = random.randint(1, 3)
            unit_price = product['price']
            discount = round(random.uniform(0, unit_price * 0.2), 2)
            
            order_items.append({
                'id': order_item_id,
                'order_id': i,
                'product_id': product['id'],
                'quantity': quantity,
                'unit_price': unit_price,
                'discount': discount,
                'created_at': order_date,
            })
            
            items_subtotal += quantity * unit_price
            items_discount += discount
            order_item_id += 1
        
        subtotal = round(items_subtotal, 2)
        discount_amount = round(items_discount, 2)
        tax_amount = round(subtotal * 0.08, 2)  # 8% tax
        shipping_amount = round(random.uniform(5, 15), 2) if subtotal < 100 else 0
        total_amount = round(subtotal + tax_amount + shipping_amount - discount_amount, 2)
        
        orders.append({
            'id': i,
            'customer_id': customer['id'],
            'order_date': order_date,
            'status': status,
            'subtotal': subtotal,
            'tax_amount': tax_amount,
            'shipping_amount': shipping_amount,
            'discount_amount': discount_amount,
            'total_amount': total_amount,
            'payment_method': random.choice(payment_methods),
            'payment_status': 'paid' if status == 'completed' else random.choice(payment_statuses),
            'created_at': order_date,
            'updated_at': fake.date_time_between(start_date=order_date, end_date='now'),
        })
    
    return orders, order_items

def write_csv(filename, data, fieldnames):
    """Write data to CSV file"""
    with open(f'{OUTPUT_DIR}/{filename}', 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(data)
    print(f'✓ Generated {filename} with {len(data)} records')

def main():
    """Main function to generate all sample data"""
    print('Generating sample data for e-commerce analytics platform...')
    print()
    
    # Generate data
    customers = generate_customers(NUM_CUSTOMERS)
    products = generate_products(NUM_PRODUCTS)
    orders, order_items = generate_orders(NUM_ORDERS, customers, products)
    
    # Write to CSV files
    write_csv('raw_customers.csv', customers, customers[0].keys())
    write_csv('raw_products.csv', products, products[0].keys())
    write_csv('raw_orders.csv', orders, orders[0].keys())
    write_csv('raw_order_items.csv', order_items, order_items[0].keys())
    
    print()
    print('✓ Sample data generation complete!')
    print(f'  - {len(customers)} customers')
    print(f'  - {len(products)} products')
    print(f'  - {len(orders)} orders')
    print(f'  - {len(order_items)} order items')

if __name__ == '__main__':
    main()
