# Real-World Project — Complete E-Commerce Trigger System

## 🎯 Project Overview

**Project Name:** E-Commerce Data Integrity & Automation System  
**Difficulty:** Advanced  
**Goal:** Build a production-ready trigger system for a complete e-commerce platform

### 📖 Business Context

You're building the database layer for "TechStore", an online electronics retailer. The system must:
- Maintain data integrity across all tables
- Automatically calculate derived values
- Track all changes for compliance
- Enforce complex business rules
- Prevent invalid operations
- Alert on critical conditions

This project simulates a real production system where triggers ensure data consistency even when accessed by multiple applications.

---

## 🏗️ Database Schema

### Step 1: Create Complete Schema

```sql
-- Clean slate
DROP DATABASE IF EXISTS rw14_techstore;
CREATE DATABASE rw14_techstore;
USE rw14_techstore;

-- ============================================
-- MAIN TABLES
-- ============================================

-- Products catalog
CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  category VARCHAR(50),
  price DECIMAL(10,2) NOT NULL,
  cost DECIMAL(10,2) NOT NULL,  -- What we pay to get it
  stock INT NOT NULL DEFAULT 0,
  min_stock INT NOT NULL DEFAULT 10,
  max_stock INT NOT NULL DEFAULT 1000,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,  -- Soft delete
  INDEX idx_category (category),
  INDEX idx_active (is_active)
);

-- Customer accounts
CREATE TABLE customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  phone VARCHAR(20),
  credit_limit DECIMAL(10,2) DEFAULT 5000.00,
  current_balance DECIMAL(10,2) DEFAULT 0.00,
  loyalty_points INT DEFAULT 0,
  account_status VARCHAR(20) DEFAULT 'active',  -- active, suspended, closed
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  INDEX idx_email (email),
  INDEX idx_status (account_status)
);

-- Orders
CREATE TABLE orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  subtotal DECIMAL(10,2) DEFAULT 0.00,
  tax_amount DECIMAL(10,2) DEFAULT 0.00,
  discount_amount DECIMAL(10,2) DEFAULT 0.00,
  total_amount DECIMAL(10,2) DEFAULT 0.00,
  status VARCHAR(20) DEFAULT 'pending',  -- pending, confirmed, shipped, delivered, cancelled
  payment_status VARCHAR(20) DEFAULT 'pending',  -- pending, paid, refunded
  shipping_address TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  INDEX idx_customer (customer_id),
  INDEX idx_status (status),
  INDEX idx_date (order_date)
);

-- Order items (line items)
CREATE TABLE order_items (
  item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  discount_percent DECIMAL(5,2) DEFAULT 0.00,
  line_total DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id),
  INDEX idx_order (order_id),
  INDEX idx_product (product_id)
);

-- ============================================
-- AUDIT & HISTORY TABLES
-- ============================================

-- Comprehensive audit log
CREATE TABLE audit_log (
  audit_id INT AUTO_INCREMENT PRIMARY KEY,
  table_name VARCHAR(50) NOT NULL,
  record_id INT NOT NULL,
  action VARCHAR(20) NOT NULL,  -- INSERT, UPDATE, DELETE
  old_values TEXT,
  new_values TEXT,
  changed_by VARCHAR(100),  -- Could link to users table
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_table (table_name),
  INDEX idx_record (record_id),
  INDEX idx_date (changed_at)
);

-- Price history for products
CREATE TABLE price_history (
  history_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  old_price DECIMAL(10,2),
  new_price DECIMAL(10,2),
  change_amount DECIMAL(10,2),
  change_percent DECIMAL(5,2),
  reason VARCHAR(100),
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(product_id),
  INDEX idx_product (product_id),
  INDEX idx_date (changed_at)
);

-- Inventory movements
CREATE TABLE inventory_movements (
  movement_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  movement_type VARCHAR(20) NOT NULL,  -- sale, restock, adjustment, return
  quantity INT NOT NULL,  -- Negative for outgoing, positive for incoming
  old_stock INT,
  new_stock INT,
  reference_id INT,  -- Order ID, purchase order ID, etc.
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(product_id),
  INDEX idx_product (product_id),
  INDEX idx_type (movement_type),
  INDEX idx_date (created_at)
);

-- Low stock alerts
CREATE TABLE stock_alerts (
  alert_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  alert_type VARCHAR(20) NOT NULL,  -- low_stock, out_of_stock, overstock
  current_stock INT NOT NULL,
  threshold_value INT NOT NULL,
  severity VARCHAR(20) DEFAULT 'medium',  -- low, medium, high, critical
  resolved BOOLEAN DEFAULT FALSE,
  resolved_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(product_id),
  INDEX idx_product (product_id),
  INDEX idx_resolved (resolved),
  INDEX idx_severity (severity)
);

-- Customer activity log
CREATE TABLE customer_activities (
  activity_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  activity_type VARCHAR(50) NOT NULL,  -- order_placed, payment_made, status_change
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  INDEX idx_customer (customer_id),
  INDEX idx_type (activity_type),
  INDEX idx_date (created_at)
);
```

---

## 🛠️ Project Requirements

### Trigger System Requirements

**You must build at least 10 triggers covering:**

1. ✅ Product Validation (BEFORE INSERT/UPDATE)
2. ✅ Product Price History Tracking (BEFORE UPDATE)
3. ✅ Product Audit Logging (AFTER INSERT/UPDATE/DELETE)
4. ✅ Order Item Calculation (BEFORE INSERT/UPDATE)
5. ✅ Order Totals Calculation (AFTER INSERT/UPDATE/DELETE on order_items)
6. ✅ Inventory Deduction (AFTER INSERT on order_items)
7. ✅ Stock Alert System (AFTER UPDATE on products)
8. ✅ Customer Balance Update (AFTER INSERT on orders)
9. ✅ Customer Activity Logging (AFTER INSERT on orders)
10. ✅ Soft Delete Implementation (BEFORE DELETE)

### Business Rules to Enforce

**Product Rules:**
- Price must be > 0
- Cost must be >= 0 and <= price (can't sell below cost)
- Stock must be >= 0
- min_stock <= max_stock
- Deleted products cannot be ordered

**Customer Rules:**
- Email format validation
- current_balance cannot exceed credit_limit
- Suspended/closed accounts cannot place orders
- Deleted customers cannot place orders

**Order Rules:**
- Orders can only be placed by active customers
- Order items must reference active products
- Quantities must be positive
- Stock must be available
- Order totals must be calculated automatically
- Tax is 8% of subtotal
- Discounts cannot exceed 50%

**Inventory Rules:**
- Alert when stock < min_stock
- Alert when stock = 0 (out of stock)
- Alert when stock > max_stock (overstock)
- Track all inventory movements

---

## 📝 Implementation Guide

### Phase 1: Validation Triggers

#### Trigger 1: Product Validation

```sql
DELIMITER //
CREATE TRIGGER tr_validate_product
BEFORE INSERT ON products
FOR EACH ROW
BEGIN
  -- Validate price
  IF NEW.price <= 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Product price must be greater than 0';
  END IF;
  
  -- Validate cost
  IF NEW.cost < 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Product cost cannot be negative';
  END IF;
  
  -- Validate cost vs price (can't sell below cost)
  IF NEW.cost > NEW.price THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Product cost cannot exceed selling price';
  END IF;
  
  -- Validate stock
  IF NEW.stock < 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Stock cannot be negative';
  END IF;
  
  -- Validate min/max stock
  IF NEW.min_stock > NEW.max_stock THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Minimum stock cannot exceed maximum stock';
  END IF;
  
  -- Set timestamps
  SET NEW.created_at = NOW();
  SET NEW.updated_at = NOW();
END //
DELIMITER ;

-- Same validation for UPDATE
DELIMITER //
CREATE TRIGGER tr_validate_product_update
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
  -- Same validations as INSERT
  IF NEW.price <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product price must be greater than 0';
  END IF;
  
  IF NEW.cost < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product cost cannot be negative';
  END IF;
  
  IF NEW.cost > NEW.price THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product cost cannot exceed selling price';
  END IF;
  
  IF NEW.stock < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock cannot be negative';
  END IF;
  
  IF NEW.min_stock > NEW.max_stock THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Minimum stock cannot exceed maximum stock';
  END IF;
END //
DELIMITER ;
```

#### Trigger 2: Customer Validation

```sql
DELIMITER //
CREATE TRIGGER tr_validate_customer
BEFORE INSERT ON customers
FOR EACH ROW
BEGIN
  -- Email format validation
  -- Pattern: %_@__%.__%' means:
  -- % = any characters, _ = at least one character, @ = literal @, then domain with dot
  IF NEW.email NOT LIKE '%_@__%.__%' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid email format - must be like user@domain.com';
  END IF;
  
  -- Credit limit validation
  IF NEW.credit_limit < 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Credit limit cannot be negative';
  END IF;
  
  -- Balance cannot exceed credit limit
  IF NEW.current_balance > NEW.credit_limit THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Current balance cannot exceed credit limit';
  END IF;
  
  -- Ensure proper account status
  IF NEW.account_status NOT IN ('active', 'suspended', 'closed') THEN
    SET NEW.account_status = 'active';
  END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_validate_customer_update
BEFORE UPDATE ON customers
FOR EACH ROW
BEGIN
  -- Same validations
  IF NEW.email NOT LIKE '%_@__%.__%' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid email format';
  END IF;
  
  IF NEW.credit_limit < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Credit limit cannot be negative';
  END IF;
  
  IF NEW.current_balance > NEW.credit_limit THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Current balance exceeds credit limit';
  END IF;
END //
DELIMITER ;
```

### Phase 2: Calculation Triggers

#### Trigger 3: Order Item Calculations

```sql
DELIMITER //
CREATE TRIGGER tr_calculate_order_item
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
  DECLARE product_price DECIMAL(10,2);
  DECLARE product_stock INT;
  DECLARE product_active BOOLEAN;
  
  -- Get product details
  SELECT price, stock, is_active 
  INTO product_price, product_stock, product_active
  FROM products 
  WHERE product_id = NEW.product_id;
  
  -- Validate product exists and is active
  IF product_price IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Product not found';
  END IF;
  
  IF product_active = FALSE THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot order inactive product';
  END IF;
  
  -- Validate quantity
  IF NEW.quantity <= 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Quantity must be positive';
  END IF;
  
  -- Check stock availability
  IF product_stock < NEW.quantity THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Insufficient stock for this order';
  END IF;
  
  -- Validate discount
  IF NEW.discount_percent < 0 OR NEW.discount_percent > 50 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Discount must be between 0% and 50%';
  END IF;
  
  -- Set unit price from product
  SET NEW.unit_price = product_price;
  
  -- Calculate line total with discount
  -- Formula: quantity × price × (1 - discount%)
  -- Example: 10 items × $100 × (1 - 20/100) = 10 × 100 × 0.8 = $800
  SET NEW.line_total = NEW.quantity * NEW.unit_price * 
                       (1 - NEW.discount_percent / 100);
END //
DELIMITER ;
```

#### Trigger 4: Update Order Totals

```sql
DELIMITER //
CREATE TRIGGER tr_update_order_totals_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
  DECLARE order_subtotal DECIMAL(10,2);
  DECLARE order_tax DECIMAL(10,2);
  DECLARE order_discount DECIMAL(10,2);
  DECLARE order_total DECIMAL(10,2);
  
  -- Calculate subtotal (sum of all line totals for this order)
  -- COALESCE returns 0 if SUM is NULL (when no items exist)
  SELECT COALESCE(SUM(line_total), 0)
  INTO order_subtotal
  FROM order_items
  WHERE order_id = NEW.order_id;
  
  -- Calculate tax (8% of subtotal)
  -- Example: $100 subtotal × 0.08 = $8 tax
  SET order_tax = order_subtotal * 0.08;
  
  -- Get existing discount
  SELECT discount_amount INTO order_discount
  FROM orders WHERE order_id = NEW.order_id;
  
  -- Calculate total
  SET order_total = order_subtotal + order_tax - COALESCE(order_discount, 0);
  
  -- Update order
  UPDATE orders
  SET subtotal = order_subtotal,
      tax_amount = order_tax,
      total_amount = order_total,
      updated_at = NOW()
  WHERE order_id = NEW.order_id;
END //
DELIMITER ;

-- Similar triggers for UPDATE and DELETE on order_items
DELIMITER //
CREATE TRIGGER tr_update_order_totals_update
AFTER UPDATE ON order_items
FOR EACH ROW
BEGIN
  DECLARE order_subtotal DECIMAL(10,2);
  DECLARE order_tax DECIMAL(10,2);
  DECLARE order_discount DECIMAL(10,2);
  DECLARE order_total DECIMAL(10,2);
  
  SELECT COALESCE(SUM(line_total), 0) INTO order_subtotal
  FROM order_items WHERE order_id = NEW.order_id;
  
  SET order_tax = order_subtotal * 0.08;
  
  SELECT discount_amount INTO order_discount
  FROM orders WHERE order_id = NEW.order_id;
  
  SET order_total = order_subtotal + order_tax - COALESCE(order_discount, 0);
  
  UPDATE orders
  SET subtotal = order_subtotal,
      tax_amount = order_tax,
      total_amount = order_total,
      updated_at = NOW()
  WHERE order_id = NEW.order_id;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_update_order_totals_delete
AFTER DELETE ON order_items
FOR EACH ROW
BEGIN
  DECLARE order_subtotal DECIMAL(10,2);
  DECLARE order_tax DECIMAL(10,2);
  DECLARE order_discount DECIMAL(10,2);
  DECLARE order_total DECIMAL(10,2);
  
  SELECT COALESCE(SUM(line_total), 0) INTO order_subtotal
  FROM order_items WHERE order_id = OLD.order_id;
  
  SET order_tax = order_subtotal * 0.08;
  
  SELECT discount_amount INTO order_discount
  FROM orders WHERE order_id = OLD.order_id;
  
  SET order_total = order_subtotal + order_tax - COALESCE(order_discount, 0);
  
  UPDATE orders
  SET subtotal = order_subtotal,
      tax_amount = order_tax,
      total_amount = order_total,
      updated_at = NOW()
  WHERE order_id = OLD.order_id;
END //
DELIMITER ;
```

### Phase 3: Inventory Management Triggers

#### Trigger 5: Inventory Deduction

```sql
DELIMITER //
CREATE TRIGGER tr_deduct_inventory
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
  DECLARE old_stock INT;
  DECLARE new_stock INT;
  
  -- Get current stock
  SELECT stock INTO old_stock
  FROM products
  WHERE product_id = NEW.product_id;
  
  -- Update stock
  UPDATE products
  SET stock = stock - NEW.quantity
  WHERE product_id = NEW.product_id;
  
  -- Get new stock
  SELECT stock INTO new_stock
  FROM products
  WHERE product_id = NEW.product_id;
  
  -- Log inventory movement
  INSERT INTO inventory_movements (
    product_id, movement_type, quantity, 
    old_stock, new_stock, reference_id, notes
  )
  VALUES (
    NEW.product_id, 'sale', -NEW.quantity,
    old_stock, new_stock, NEW.order_id,
    CONCAT('Order #', NEW.order_id, ', Item #', NEW.item_id)
  );
END //
DELIMITER ;
```

#### Trigger 6: Stock Alert System

```sql
DELIMITER //
CREATE TRIGGER tr_check_stock_levels
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
  -- Check if stock changed
  IF OLD.stock != NEW.stock THEN
    
    -- Out of stock alert (critical)
    IF NEW.stock = 0 AND OLD.stock > 0 THEN
      INSERT INTO stock_alerts (
        product_id, alert_type, current_stock,
        threshold_value, severity
      )
      VALUES (
        NEW.product_id, 'out_of_stock', NEW.stock,
        0, 'critical'
      );
    
    -- Low stock alert (high)
    ELSEIF NEW.stock < NEW.min_stock AND NEW.stock > 0 THEN
      INSERT INTO stock_alerts (
        product_id, alert_type, current_stock,
        threshold_value, severity
      )
      VALUES (
        NEW.product_id, 'low_stock', NEW.stock,
        NEW.min_stock, 'high'
      );
    
    -- Overstock alert (medium)
    ELSEIF NEW.stock > NEW.max_stock THEN
      INSERT INTO stock_alerts (
        product_id, alert_type, current_stock,
        threshold_value, severity
      )
      VALUES (
        NEW.product_id, 'overstock', NEW.stock,
        NEW.max_stock, 'medium'
      );
    END IF;
    
  END IF;
END //
DELIMITER ;
```

### Phase 4: Audit & History Triggers

#### Trigger 7: Price History Tracking

```sql
DELIMITER //
CREATE TRIGGER tr_track_price_changes
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
  IF OLD.price != NEW.price THEN
    INSERT INTO price_history (
      product_id, old_price, new_price,
      change_amount, change_percent, reason
    )
    VALUES (
      NEW.product_id,
      OLD.price,
      NEW.price,
      NEW.price - OLD.price,
      CASE 
        WHEN OLD.price = 0 THEN NULL
        ELSE ((NEW.price - OLD.price) / OLD.price) * 100
      END,
      'Price update'
    );
  END IF;
END //
DELIMITER ;
```

#### Trigger 8: Comprehensive Audit Logging

```sql
DELIMITER //
CREATE TRIGGER tr_audit_product_insert
AFTER INSERT ON products
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (table_name, record_id, action, new_values)
  VALUES (
    'products',
    NEW.product_id,
    'INSERT',
    JSON_OBJECT(
      'name', NEW.name,
      'price', NEW.price,
      'cost', NEW.cost,
      'stock', NEW.stock
    )
  );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_audit_product_update
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (table_name, record_id, action, old_values, new_values)
  VALUES (
    'products',
    NEW.product_id,
    'UPDATE',
    JSON_OBJECT(
      'name', OLD.name,
      'price', OLD.price,
      'cost', OLD.cost,
      'stock', OLD.stock
    ),
    JSON_OBJECT(
      'name', NEW.name,
      'price', NEW.price,
      'cost', NEW.cost,
      'stock', NEW.stock
    )
  );
END //
DELIMITER ;
```

#### Trigger 9: Customer Activity Tracking

```sql
DELIMITER //
CREATE TRIGGER tr_log_customer_activity
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
  INSERT INTO customer_activities (
    customer_id, activity_type, description
  )
  VALUES (
    NEW.customer_id,
    'order_placed',
    CONCAT(
      'Order #', NEW.order_id,
      ' placed for $', NEW.total_amount
    )
  );
END //
DELIMITER ;
```

### Phase 5: Advanced Features

#### Trigger 10: Customer Balance Management

```sql
DELIMITER //
CREATE TRIGGER tr_update_customer_balance
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
  DECLARE customer_limit DECIMAL(10,2);
  DECLARE customer_balance DECIMAL(10,2);
  
  -- Get customer credit info
  SELECT credit_limit, current_balance
  INTO customer_limit, customer_balance
  FROM customers
  WHERE customer_id = NEW.customer_id;
  
  -- Check if order would exceed credit limit
  IF (customer_balance + NEW.total_amount) > customer_limit THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Order would exceed customer credit limit';
  END IF;
  
  -- Update customer balance
  UPDATE customers
  SET current_balance = current_balance + NEW.total_amount,
      loyalty_points = loyalty_points + FLOOR(NEW.total_amount)
  WHERE customer_id = NEW.customer_id;
END //
DELIMITER ;
```

---

## 🧪 Comprehensive Testing Suite

### Test Data Setup

```sql
-- Insert test products
INSERT INTO products (name, category, price, cost, stock, min_stock, max_stock) VALUES
('Gaming Laptop', 'Computers', 1299.99, 900.00, 25, 5, 50),
('Wireless Mouse', 'Accessories', 29.99, 15.00, 150, 20, 200),
('Mechanical Keyboard', 'Accessories', 89.99, 50.00, 75, 15, 100),
('4K Monitor', 'Monitors', 399.99, 250.00, 30, 10, 60),
('USB-C Cable', 'Accessories', 19.99, 8.00, 200, 50, 500);

-- Insert test customers
INSERT INTO customers (first_name, last_name, email, phone, credit_limit) VALUES
('John', 'Doe', 'john.doe@example.com', '555-0101', 10000.00),
('Jane', 'Smith', 'jane.smith@example.com', '555-0102', 5000.00),
('Bob', 'Johnson', 'bob.johnson@example.com', '555-0103', 7500.00);
```

### Test Cases

**Test 1: Valid Order Flow**
```sql
-- Create order
INSERT INTO orders (customer_id, shipping_address)
VALUES (1, '123 Main St, City, State 12345');

-- Add items to order
INSERT INTO order_items (order_id, product_id, quantity, discount_percent)
VALUES 
  (LAST_INSERT_ID(), 1, 2, 10),  -- 2 laptops with 10% discount
  (LAST_INSERT_ID(), 2, 5, 0);   -- 5 mice, no discount

-- Verify results
SELECT * FROM orders WHERE order_id = LAST_INSERT_ID();
SELECT * FROM order_items WHERE order_id = LAST_INSERT_ID();
SELECT * FROM inventory_movements ORDER BY created_at DESC LIMIT 5;
```

**Test 2: Insufficient Stock (should fail)**
```sql
-- Try to order more than available
-- INSERT INTO order_items (order_id, product_id, quantity)
-- VALUES (1, 3, 1000);  -- Only 75 keyboards available
-- Expected: Error 'Insufficient stock'
```

**Test 3: Price Change Tracking**
```sql
-- Change product price
UPDATE products SET price = 1399.99 WHERE product_id = 1;

-- Check price history
SELECT * FROM price_history WHERE product_id = 1;
```

**Test 4: Stock Alerts**
```sql
-- Reduce stock to trigger low stock alert
UPDATE products SET stock = 3 WHERE product_id = 1;

-- Check alerts
SELECT * FROM stock_alerts WHERE product_id = 1;
```

---

## 📊 Deliverables Checklist

- [ ] All 10+ triggers created and documented
- [ ] Test data inserted successfully
- [ ] All test cases pass
- [ ] Audit logs populated correctly
- [ ] Performance tested with 100+ orders
- [ ] Trigger dependency diagram created
- [ ] README with system overview
- [ ] List of business rules enforced
- [ ] Known limitations documented

---

## 🎓 Success Criteria

**Functionality (60 points)**
- All triggers execute without errors
- Business rules enforced correctly
- Calculations accurate
- Audit trails complete

**Code Quality (20 points)**
- Clear naming conventions
- Comments explaining complex logic
- Proper error messages
- Efficient queries

**Testing (20 points)**
- Comprehensive test coverage
- Edge cases handled
- Performance acceptable
- Documentation complete

---

## 🚀 Extension Challenges

1. **Order Cancellation System**
   - Restore inventory when order cancelled
   - Reverse customer balance
   - Update loyalty points

2. **Promotional Pricing**
   - Temporary price reductions
   - Bulk purchase discounts
   - Customer tier pricing

3. **Advanced Reporting**
   - Sales by category dashboard
   - Customer lifetime value
   - Inventory turnover rate
   - Profit margin analysis

4. **Integration Points**
   - Email notifications on low stock
   - Order confirmation triggers
   - Customer welcome emails

**Congratulations on completing this comprehensive project! You now have production-level trigger expertise!**

