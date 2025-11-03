# Real-World Project — DDL & Schema Design

## Project: Multi-Vendor E-Commerce Platform Database

**Estimated Time:** 90-120 minutes  
**Difficulty:** Advanced  
**Goal:** Design a complete, normalized database schema for a realistic e-commerce platform

---

### Business Requirements

You're building the database for an online marketplace (like Amazon or Etsy) where:
- Multiple vendors can sell products
- Customers browse, add to cart, and place orders
- Orders contain multiple items from potentially different vendors
- System tracks inventory, payments, shipping, and reviews
- Need support for discounts/coupons

### Core Entities Needed

1. **Users & Authentication**
   - Vendors (sellers)
   - Customers (buyers)
   - Addresses (shipping/billing)

2. **Product Catalog**
   - Categories (hierarchical if possible)
   - Products
   - Product variants (size, color, etc.)
   - Inventory tracking

3. **Shopping & Orders**
   - Shopping carts
   - Orders & order items
   - Payment information
   - Shipping information

4. **Reviews & Ratings**
   - Product reviews
   - Vendor ratings

5. **Promotions**
   - Discount codes
   - Usage tracking

---

### Schema Design Tasks

#### Phase 1: User Management (20 min)

```sql
-- Vendors table
CREATE TABLE rw10_vendors (
  vendor_id INT AUTO_INCREMENT PRIMARY KEY,
  business_name VARCHAR(150) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  phone VARCHAR(20),
  description TEXT,
  rating DECIMAL(3,2) DEFAULT 0.00,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_email (email)
);

-- Customers table
CREATE TABLE rw10_customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(100) UNIQUE NOT NULL,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  phone VARCHAR(20),
  date_of_birth DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_email (email)
);

-- Addresses table (for both shipping and billing)
CREATE TABLE rw10_addresses (
  address_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  address_type ENUM('shipping', 'billing') NOT NULL,
  address_line1 VARCHAR(255) NOT NULL,
  address_line2 VARCHAR(255),
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100),
  postal_code VARCHAR(20) NOT NULL,
  country VARCHAR(100) DEFAULT 'USA',
  is_default BOOLEAN DEFAULT FALSE,
  CONSTRAINT fk_addr_customer FOREIGN KEY (customer_id) 
    REFERENCES rw10_customers(customer_id) ON DELETE CASCADE,
  INDEX idx_customer (customer_id)
);
```

#### Phase 2: Product Catalog (25 min)

```sql
-- Categories table
CREATE TABLE rw10_categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(100) UNIQUE NOT NULL,
  parent_category_id INT NULL,
  description TEXT,
  CONSTRAINT fk_parent_category FOREIGN KEY (parent_category_id) 
    REFERENCES rw10_categories(category_id),
  INDEX idx_parent (parent_category_id)
);

-- Products table
CREATE TABLE rw10_products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  vendor_id INT,
  category_id INT,
  product_name VARCHAR(200) NOT NULL,
  description TEXT,
  base_price DECIMAL(10,2) CHECK (base_price >= 0),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_prod_vendor FOREIGN KEY (vendor_id) 
    REFERENCES rw10_vendors(vendor_id),
  CONSTRAINT fk_prod_category FOREIGN KEY (category_id) 
    REFERENCES rw10_categories(category_id),
  INDEX idx_vendor (vendor_id),
  INDEX idx_category (category_id),
  INDEX idx_name (product_name)
);

-- Product variants (size, color, etc.)
CREATE TABLE rw10_product_variants (
  variant_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT,
  sku VARCHAR(100) UNIQUE NOT NULL,
  variant_name VARCHAR(100),  -- e.g., "Large / Red"
  price_adjustment DECIMAL(10,2) DEFAULT 0.00,
  stock_quantity INT DEFAULT 0 CHECK (stock_quantity >= 0),
  CONSTRAINT fk_variant_product FOREIGN KEY (product_id) 
    REFERENCES rw10_products(product_id) ON DELETE CASCADE,
  INDEX idx_product (product_id),
  INDEX idx_sku (sku)
);
```

#### Phase 3: Shopping Cart & Orders (25 min)

```sql
-- Shopping cart
CREATE TABLE rw10_cart_items (
  cart_item_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  variant_id INT,
  quantity INT CHECK (quantity > 0),
  added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_cart_customer FOREIGN KEY (customer_id) 
    REFERENCES rw10_customers(customer_id) ON DELETE CASCADE,
  CONSTRAINT fk_cart_variant FOREIGN KEY (variant_id) 
    REFERENCES rw10_product_variants(variant_id),
  UNIQUE KEY uk_customer_variant (customer_id, variant_id),
  INDEX idx_customer_cart (customer_id)
);

-- Orders table
CREATE TABLE rw10_orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  order_number VARCHAR(50) UNIQUE NOT NULL,
  order_status ENUM('pending', 'paid', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
  subtotal DECIMAL(10,2),
  discount_amount DECIMAL(10,2) DEFAULT 0.00,
  tax_amount DECIMAL(10,2) DEFAULT 0.00,
  shipping_cost DECIMAL(10,2) DEFAULT 0.00,
  total_amount DECIMAL(10,2),
  shipping_address_id INT,
  billing_address_id INT,
  order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) 
    REFERENCES rw10_customers(customer_id),
  CONSTRAINT fk_order_shipping FOREIGN KEY (shipping_address_id) 
    REFERENCES rw10_addresses(address_id),
  CONSTRAINT fk_order_billing FOREIGN KEY (billing_address_id) 
    REFERENCES rw10_addresses(address_id),
  INDEX idx_customer_order (customer_id),
  INDEX idx_order_date (order_date),
  INDEX idx_status (order_status)
);

-- Order items table
CREATE TABLE rw10_order_items (
  order_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT,
  vendor_id INT,
  variant_id INT,
  quantity INT CHECK (quantity > 0),
  unit_price DECIMAL(10,2),
  subtotal DECIMAL(10,2),
  CONSTRAINT fk_item_order FOREIGN KEY (order_id) 
    REFERENCES rw10_orders(order_id) ON DELETE CASCADE,
  CONSTRAINT fk_item_vendor FOREIGN KEY (vendor_id) 
    REFERENCES rw10_vendors(vendor_id),
  CONSTRAINT fk_item_variant FOREIGN KEY (variant_id) 
    REFERENCES rw10_product_variants(variant_id),
  INDEX idx_order (order_id),
  INDEX idx_vendor (vendor_id)
);
```

#### Phase 4: Payments & Reviews (20 min)

```sql
-- Payments table
CREATE TABLE rw10_payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT,
  payment_method ENUM('credit_card', 'debit_card', 'paypal', 'stripe') NOT NULL,
  payment_status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
  amount DECIMAL(10,2),
  transaction_id VARCHAR(100),
  payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_payment_order FOREIGN KEY (order_id) 
    REFERENCES rw10_orders(order_id),
  INDEX idx_order_payment (order_id),
  INDEX idx_status (payment_status)
);

-- Product reviews
CREATE TABLE rw10_product_reviews (
  review_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT,
  customer_id INT,
  rating INT CHECK (rating BETWEEN 1 AND 5),
  review_title VARCHAR(200),
  review_text TEXT,
  is_verified_purchase BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_review_product FOREIGN KEY (product_id) 
    REFERENCES rw10_products(product_id) ON DELETE CASCADE,
  CONSTRAINT fk_review_customer FOREIGN KEY (customer_id) 
    REFERENCES rw10_customers(customer_id),
  INDEX idx_product_review (product_id),
  INDEX idx_customer_review (customer_id)
);

-- Discount codes
CREATE TABLE rw10_discount_codes (
  discount_id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(50) UNIQUE NOT NULL,
  discount_type ENUM('percentage', 'fixed_amount') NOT NULL,
  discount_value DECIMAL(10,2),
  min_purchase_amount DECIMAL(10,2) DEFAULT 0.00,
  max_uses INT DEFAULT NULL,
  times_used INT DEFAULT 0,
  start_date DATE,
  expiry_date DATE,
  is_active BOOLEAN DEFAULT TRUE,
  INDEX idx_code (code)
);
```

### Sample Data & Queries

```sql
-- Insert sample data
INSERT INTO rw10_vendors (business_name, email, description, is_verified) VALUES
('TechGear Pro', 'contact@techgear.com', 'Premium electronics seller', TRUE),
('Fashion Forward', 'info@fashionforward.com', 'Trendy clothing and accessories', TRUE);

INSERT INTO rw10_customers (email, first_name, last_name, phone) VALUES
('alice@email.com', 'Alice', 'Smith', '555-0001'),
('bob@email.com', 'Bob', 'Johnson', '555-0002');

INSERT INTO rw10_categories (category_name, parent_category_id) VALUES
('Electronics', NULL),
('Laptops', 1),
('Clothing', NULL);

INSERT INTO rw10_products (vendor_id, category_id, product_name, description, base_price) VALUES
(1, 2, 'UltraBook Pro', 'Lightweight powerful laptop', 1299.99),
(2, 3, 'Cotton T-Shirt', 'Comfortable everyday wear', 24.99);

INSERT INTO rw10_product_variants (product_id, sku, variant_name, price_adjustment, stock_quantity) VALUES
(1, 'LAPTOP-PRO-256GB', '256GB / Silver', 0.00, 50),
(1, 'LAPTOP-PRO-512GB', '512GB / Silver', 200.00, 30),
(2, 'TSHIRT-M-BLUE', 'Medium / Blue', 0.00, 100);

-- Query: Product catalog with vendor info
SELECT 
  p.product_name,
  v.business_name AS vendor,
  c.category_name,
  pv.variant_name,
  p.base_price + pv.price_adjustment AS final_price,
  pv.stock_quantity
FROM rw10_products p
JOIN rw10_vendors v ON p.vendor_id = v.vendor_id
JOIN rw10_categories c ON p.category_id = c.category_id
JOIN rw10_product_variants pv ON p.product_id = pv.product_id
WHERE p.is_active = TRUE AND pv.stock_quantity > 0;

-- Query: Top rated products
SELECT 
  p.product_name,
  v.business_name AS vendor,
  AVG(r.rating) AS avg_rating,
  COUNT(r.review_id) AS review_count
FROM rw10_products p
JOIN rw10_vendors v ON p.vendor_id = v.vendor_id
LEFT JOIN rw10_product_reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name, v.business_name
HAVING review_count > 0
ORDER BY avg_rating DESC, review_count DESC
LIMIT 10;
```

### Extension Challenges

1. **Add Wishlist Feature:** Create table for customers to save products
2. **Implement Reviews for Vendors:** Separate from product reviews
3. **Shipping Tracking:** Add table for tracking shipment status
4. **Return/Refund System:** Handle order returns and refunds
5. **Product Images:** Store multiple images per product
6. **Inventory Alerts:** Track low stock notifications
7. **Order History:** Optimize queries for customer order history
8. **Analytics Tables:** Aggregate data for reporting

### Evaluation Criteria

- ✅ All required entities created with proper relationships
- ✅ Foreign keys enforce referential integrity
- ✅ Appropriate constraints (CHECK, UNIQUE, NOT NULL)
- ✅ Indexes on frequently queried columns
- ✅ Proper data types chosen
- ✅ Sample data validates schema design
- ✅ Complex queries execute correctly
- ✅ Schema supports business requirements

---

**Key Takeaways:**
- E-commerce schemas are complex with many interdependencies
- Planning relationships before coding saves refactoring time
- Indexes on FK columns are essential for performance
- ENUM types enforce valid status values
- Composite unique constraints prevent duplicate business logic violations
- Timestamps track when data was created/modified
- Soft deletes (is_active flags) preserve business intelligence