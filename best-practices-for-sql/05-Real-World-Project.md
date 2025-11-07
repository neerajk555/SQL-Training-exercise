# Real-World Project — Best Practices for SQL

## 📋 Before You Start

### Learning Objectives
By completing this real-world project, you will:
- Apply professional SQL standards to production systems
- Practice secure coding (prevent SQL injection)
- Work with realistic deployment and documentation requirements
- Build production-ready database systems
- Develop professional development workflows

### Project Approach
**Time Allocation (90-120 minutes):**
- 📖 **15 min**: Read all requirements, understand production standards
- 🔧 **15 min**: Plan schema, security, and deployment strategy
- 💻 **60-70 min**: Build system with documentation and tests
- ✅ **20 min**: Code review, security audit, deployment checklist

**Success Tips:**
- ✅ Use parameterized queries (never concatenate user input)
- ✅ Document all tables, columns, procedures with comments
- ✅ Follow naming conventions consistently
- ✅ Format code for readability (indentation, spacing)
- ✅ Test security vulnerabilities explicitly

---

## Project: Production-Ready E-Commerce Database

### Overview:
Build a complete, production-ready e-commerce database system from scratch. This project brings together everything you've learned about professional SQL practices: security, documentation, testing, monitoring, and deployment.

**What You're Building:**
A full e-commerce platform database that handles:
- User accounts and authentication
- Product catalog with inventory
- Shopping cart and checkout
- Order processing and fulfillment
- Audit logging and compliance

**Professional Standards:**
Every aspect must meet production quality:
- ✅ Secure (no SQL injection, encrypted sensitive data)
- ✅ Documented (comprehensive comments and README)
- ✅ Tested (unit tests for all procedures)
- ✅ Monitored (performance tracking and alerts)
- ✅ Maintainable (clear code, version controlled)

**Skill Level:** Intermediate to Advanced (combines all previous modules)

---

## Phase 1: Schema Design with Documentation

```sql
-- ============================================
-- E-COMMERCE DATABASE SCHEMA
-- Version: 1.0.0
-- Author: Development Team
-- Last Updated: 2024-01-15
-- Dependencies: MySQL 8.0+
-- ============================================

-- ============================================
-- TABLE: users
-- Purpose: Customer accounts and authentication
-- Security: bcrypt password hashing required
-- Indexes: email (unique), username (unique)
-- ============================================
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash CHAR(60) NOT NULL COMMENT 'bcrypt hash',
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  phone VARCHAR(20),
  status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
  email_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  last_login_at TIMESTAMP NULL,
  
  INDEX idx_email (email),
  INDEX idx_status (status),
  INDEX idx_created_at (created_at)
) COMMENT='Customer user accounts';

-- ============================================
-- TABLE: products
-- Purpose: Product catalog with inventory
-- Business Rules: Price must be positive
-- ============================================
CREATE TABLE products (
  id INT PRIMARY KEY AUTO_INCREMENT,
  sku VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(200) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  cost DECIMAL(10,2) NOT NULL CHECK (cost >= 0),
  stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
  category_id INT,
  status ENUM('active', 'inactive', 'discontinued') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_category (category_id),
  INDEX idx_status (status),
  INDEX idx_sku (sku),
  FULLTEXT KEY ft_search (name, description)
) COMMENT='Product catalog and inventory';

-- ============================================
-- TABLE: orders
-- Purpose: Customer orders with status tracking
-- Dependencies: users, addresses
-- ============================================
CREATE TABLE orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  order_number VARCHAR(50) UNIQUE NOT NULL,
  user_id INT NOT NULL,
  status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
  subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
  tax_amount DECIMAL(10,2) NOT NULL CHECK (tax_amount >= 0),
  shipping_amount DECIMAL(10,2) NOT NULL CHECK (shipping_amount >= 0),
  total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
  shipping_address_id INT,
  billing_address_id INT,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  shipped_at TIMESTAMP NULL,
  delivered_at TIMESTAMP NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id),
  INDEX idx_user_id (user_id),
  INDEX idx_status (status),
  INDEX idx_order_number (order_number),
  INDEX idx_created_at (created_at)
) COMMENT='Customer orders';

-- ============================================
-- TABLE: order_items
-- Purpose: Line items for each order
-- Dependencies: orders, products
-- ============================================
CREATE TABLE order_items (
  id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
  discount_amount DECIMAL(10,2) DEFAULT 0 CHECK (discount_amount >= 0),
  line_total DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price - discount_amount) STORED,
  
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id),
  INDEX idx_order_id (order_id),
  INDEX idx_product_id (product_id)
) COMMENT='Order line items';
```

---

## Phase 2: Security Implementation

```sql
-- ============================================
-- SECURITY: Database Users and Permissions
-- ============================================

-- Read-only user for reporting
CREATE USER 'ecommerce_readonly'@'localhost' IDENTIFIED BY 'secure_password_here';
GRANT SELECT ON ecommerce.* TO 'ecommerce_readonly'@'localhost';

-- Application user with limited permissions
CREATE USER 'ecommerce_app'@'localhost' IDENTIFIED BY 'secure_password_here';
GRANT SELECT, INSERT, UPDATE ON ecommerce.users TO 'ecommerce_app'@'localhost';
GRANT SELECT, INSERT, UPDATE ON ecommerce.orders TO 'ecommerce_app'@'localhost';
GRANT SELECT, INSERT, UPDATE ON ecommerce.order_items TO 'ecommerce_app'@'localhost';
GRANT SELECT ON ecommerce.products TO 'ecommerce_app'@'localhost';
GRANT EXECUTE ON PROCEDURE ecommerce.create_order TO 'ecommerce_app'@'localhost';

-- ============================================
-- SECURITY: Input Validation Procedure
-- ============================================
DELIMITER //
CREATE PROCEDURE validate_email(IN p_email VARCHAR(255))
BEGIN
  IF p_email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid email format';
  END IF;
END//
DELIMITER ;
```

---

## Phase 3: Business Logic with Error Handling

```sql
-- ============================================
-- PROCEDURE: create_order
-- Purpose: Create order with inventory validation
-- Security: Transaction-safe with rollback
-- Parameters:
--   IN p_user_id INT - Customer ID
--   IN p_items JSON - Array of {product_id, quantity}
--   OUT p_order_id INT - Created order ID
-- Example:
--   CALL create_order(1, '[{"product_id":1,"quantity":2}]', @order_id);
-- ============================================
DELIMITER //
CREATE PROCEDURE create_order(
  IN p_user_id INT,
  IN p_items JSON,
  OUT p_order_id INT
)
BEGIN
  DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0;
  DECLARE v_tax DECIMAL(10,2) DEFAULT 0;
  DECLARE v_shipping DECIMAL(10,2) DEFAULT 10.00;
  DECLARE v_total DECIMAL(10,2) DEFAULT 0;
  DECLARE v_order_number VARCHAR(50);
  DECLARE v_item_count INT DEFAULT 0;
  
  -- Error handlers
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order creation failed';
  END;
  
  START TRANSACTION;
  
  -- Validate user exists and is active
  IF NOT EXISTS (SELECT 1 FROM users WHERE id = p_user_id AND status = 'active') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid or inactive user';
  END IF;
  
  -- Validate items JSON
  SET v_item_count = JSON_LENGTH(p_items);
  IF v_item_count = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order must contain at least one item';
  END IF;
  
  -- Generate unique order number
  SET v_order_number = CONCAT('ORD-', DATE_FORMAT(NOW(), '%Y%m%d'), '-', LPAD(FLOOR(RAND() * 10000), 4, '0'));
  
  -- Create order record
  INSERT INTO orders (order_number, user_id, subtotal, tax_amount, shipping_amount, total_amount)
  VALUES (v_order_number, p_user_id, 0, 0, v_shipping, 0);
  
  SET p_order_id = LAST_INSERT_ID();
  
  -- Process each item
  BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    
    WHILE i < v_item_count DO
      -- Extract item data
      SET v_product_id = JSON_EXTRACT(p_items, CONCAT('$[', i, '].product_id'));
      SET v_quantity = JSON_EXTRACT(p_items, CONCAT('$[', i, '].quantity'));
      
      -- Get product details and check stock
      SELECT price, stock_quantity INTO v_price, v_stock
      FROM products
      WHERE id = v_product_id AND status = 'active'
      FOR UPDATE;
      
      IF v_price IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product not found or inactive';
      END IF;
      
      IF v_stock < v_quantity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock';
      END IF;
      
      -- Create order item
      INSERT INTO order_items (order_id, product_id, quantity, unit_price)
      VALUES (p_order_id, v_product_id, v_quantity, v_price);
      
      -- Update inventory
      UPDATE products 
      SET stock_quantity = stock_quantity - v_quantity
      WHERE id = v_product_id;
      
      -- Accumulate subtotal
      SET v_subtotal = v_subtotal + (v_quantity * v_price);
      
      SET i = i + 1;
    END WHILE;
  END;
  
  -- Calculate totals
  SET v_tax = v_subtotal * 0.08;  -- 8% tax
  SET v_total = v_subtotal + v_tax + v_shipping;
  
  -- Update order totals
  UPDATE orders
  SET subtotal = v_subtotal,
      tax_amount = v_tax,
      total_amount = v_total
  WHERE id = p_order_id;
  
  COMMIT;
END//
DELIMITER ;
```

---

## Phase 4: Audit and Monitoring

```sql
-- ============================================
-- TABLE: audit_log
-- Purpose: Track all data modifications
-- ============================================
CREATE TABLE audit_log (
  id INT PRIMARY KEY AUTO_INCREMENT,
  table_name VARCHAR(50) NOT NULL,
  record_id INT NOT NULL,
  action ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
  old_values JSON,
  new_values JSON,
  user VARCHAR(100),
  ip_address VARCHAR(45),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_table_record (table_name, record_id),
  INDEX idx_timestamp (timestamp)
);

-- ============================================
-- TRIGGER: audit_orders
-- ============================================
DELIMITER //
CREATE TRIGGER audit_orders_update
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, user)
  VALUES (
    'orders',
    NEW.id,
    'UPDATE',
    JSON_OBJECT('status', OLD.status, 'total_amount', OLD.total_amount),
    JSON_OBJECT('status', NEW.status, 'total_amount', NEW.total_amount),
    CURRENT_USER()
  );
END//
DELIMITER ;
```

---

## Phase 5: Testing & Validation

```sql
-- ============================================
-- TEST CASES
-- ============================================

-- Test 1: Create valid order
CALL create_order(1, '[{"product_id":1,"quantity":2}]', @order_id);
SELECT @order_id;  -- Should return order ID

-- Test 2: Insufficient stock (should fail)
CALL create_order(1, '[{"product_id":1,"quantity":99999}]', @order_id);

-- Test 3: Invalid user (should fail)
CALL create_order(99999, '[{"product_id":1,"quantity":1}]', @order_id);

-- Test 4: Verify audit log
SELECT * FROM audit_log ORDER BY timestamp DESC LIMIT 10;
```

---

## Phase 6: Performance Optimization

```sql
-- Check slow queries
SHOW VARIABLES LIKE 'slow_query%';

-- Analyze query performance
EXPLAIN SELECT * FROM orders WHERE user_id = 1;

-- Add covering index for common queries
CREATE INDEX idx_orders_user_status ON orders(user_id, status, created_at);
```

---

## Deployment Checklist:

- ✅ All tables documented with purpose and dependencies
- ✅ Proper indexes for query performance
- ✅ Foreign keys with CASCADE rules
- ✅ CHECK constraints for data validation
- ✅ Separate database users with minimal permissions
- ✅ Input validation in stored procedures
- ✅ Transaction safety with error handling
- ✅ Audit logging for compliance
- ✅ Test cases covering success and failure scenarios
- ✅ Performance indexes analyzed with EXPLAIN
- ✅ Backup strategy documented
- ✅ Migration scripts version controlled

**Key Takeaways:**
Professional databases require security, documentation, testing, monitoring, and maintenance planning from day one.

