# Guided Step-by-Step — Professional Practices

## Activity 1: Refactor Legacy Query

### Original Query:
```sql
SELECT o.id,o.total,u.name,u.email,p.name FROM orders o,users u,products p WHERE o.user_id=u.id AND o.product_id=p.id AND o.status='shipped' AND YEAR(o.created_at)=2024;
```

### Step 1: Break into multiple lines
```sql
SELECT o.id, o.total, u.name, u.email, p.name 
FROM orders o, users u, products p 
WHERE o.user_id = u.id 
  AND o.product_id = p.id 
  AND o.status = 'shipped' 
  AND YEAR(o.created_at) = 2024;
```

### Step 2: Use explicit JOINs
```sql
SELECT 
  o.id,
  o.total,
  u.name,
  u.email,
  p.name
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN products p ON o.product_id = p.id
WHERE o.status = 'shipped'
  AND YEAR(o.created_at) = 2024;
```

### Step 3: Add aliases and optimize date filter
```sql
SELECT 
  o.id AS order_id,
  o.total AS order_total,
  u.name AS customer_name,
  u.email AS customer_email,
  p.name AS product_name
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN products p ON o.product_id = p.id
WHERE o.status = 'shipped'
  AND o.created_at >= '2024-01-01'
  AND o.created_at < '2025-01-01';
```

### Step 4: Add documentation
```sql
-- Get all shipped orders from 2024 with customer and product details
-- Used by: Monthly sales report
-- Performance: Uses index on orders(status, created_at)
SELECT 
  o.id AS order_id,
  o.total AS order_total,
  u.name AS customer_name,
  u.email AS customer_email,
  p.name AS product_name
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN products p ON o.product_id = p.id
WHERE o.status = 'shipped'
  AND o.created_at >= '2024-01-01'
  AND o.created_at < '2025-01-01';
```

---

## Activity 2: Add Comprehensive Documentation

### Step 1: Create schema documentation
```sql
-- ============================================
-- TABLE: users
-- Purpose: Store customer account information
-- Dependencies: None
-- Indexes: email (UNIQUE), created_at
-- ============================================
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Step 2: Document stored procedures
```sql
-- ============================================
-- PROCEDURE: calculate_order_total
-- Purpose: Calculate order total with tax and shipping
-- Parameters:
--   IN p_order_id INT - The order ID to calculate
--   OUT p_total DECIMAL - Total amount including tax/shipping
-- Dependencies: orders, order_items, products
-- Example: CALL calculate_order_total(123, @total);
-- ============================================
DELIMITER //
CREATE PROCEDURE calculate_order_total(
  IN p_order_id INT,
  OUT p_total DECIMAL(10,2)
)
BEGIN
  -- Calculate subtotal from order items
  SELECT SUM(oi.quantity * p.price) INTO p_total
  FROM order_items oi
  JOIN products p ON oi.product_id = p.id
  WHERE oi.order_id = p_order_id;
  
  -- Add tax (8%)
  SET p_total = p_total * 1.08;
  
  -- Add shipping
  SET p_total = p_total + 10.00;
END//
DELIMITER ;
```

### Step 3: Add README documentation
Create a `database/README.md` file:
```markdown
# Database Documentation

## Schema Overview
- `users`: Customer accounts
- `orders`: Order transactions
- `products`: Product catalog

## Common Queries
See `queries/` folder for documented query examples.

## Migration Process
1. Backup: `mysqldump ...`
2. Run migration: `mysql < migration.sql`
3. Verify: Run test suite
```

**Key Takeaways:** Documentation saves time, prevents errors, helps team collaboration.

