# Guided Step-by-Step — DDL & Schema Design (15–20 min each)

Each activity includes business context, database setup, final goal, step-by-step instructions with checkpoints, common mistakes, complete solution, and discussion questions.

## 📋 Before You Start

### Learning Objectives
Through these guided activities, you will:
- Design multi-table schemas with relationships
- Implement referential integrity with foreign keys
- Use constraints to enforce business rules
- Modify schemas with ALTER TABLE
- Test constraints to ensure data quality

### Critical Schema Design Concepts
**Schema Design Process:**
1. Identify entities (things to store: customers, orders, products)
2. Define attributes (columns for each entity)
3. Identify relationships (one-to-many, many-to-many)
4. Choose appropriate data types
5. Add constraints for data integrity

**Referential Integrity:**
- Foreign keys ensure child records reference valid parent records
- Cannot insert child record with non-existent parent ID
- Cannot delete parent if children exist (unless CASCADE configured)
- Maintains data consistency across tables

**Constraint Best Practices:**
- PRIMARY KEY on every table (unique identifier)
- FOREIGN KEY for relationships
- NOT NULL for required fields
- UNIQUE for fields that must be distinct
- CHECK for business rules (price > 0, age >= 18)
- DEFAULT for sensible defaults

### Execution Process
1. **Run setup** to clean slate
2. **Follow each step** in order (parent tables first!)
3. **Verify checkpoints** with DESCRIBE and SELECT
4. **Test constraints** by trying invalid inserts
5. **Study complete solution**

**Beginner Tip:** Follow each step carefully. Schema design is foundational—good structure makes querying easier and enforces data integrity automatically!

---

## Activity 1: E-Commerce Product Catalog Schema — 18 min

### Business Context
You're building an e-commerce platform. Products belong to categories, and you need to track inventory levels. The schema must enforce referential integrity and prevent invalid data.

### Database Setup
```sql
-- Clean slate
DROP TABLE IF EXISTS gs10_products;
DROP TABLE IF EXISTS gs10_categories;
```

### Final Goal
Create a two-table schema where products reference categories, with appropriate constraints to ensure data quality.

### Step-by-Step Instructions

**Step 1: Create Categories Table (3 min)**
Create a table to store product categories with:
- category_id (INT, PRIMARY KEY, AUTO_INCREMENT)
- category_name (VARCHAR(100), UNIQUE, NOT NULL)
- description (TEXT)

```sql
CREATE TABLE gs10_categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(100) UNIQUE NOT NULL,
  description TEXT
);
```

**Checkpoint:** Run `DESCRIBE gs10_categories;` to verify structure.

---

**Step 2: Insert Category Data (2 min)**
Add three categories: Electronics, Clothing, Books.

```sql
INSERT INTO gs10_categories (category_name, description) VALUES
('Electronics', 'Electronic devices and accessories'),
('Clothing', 'Apparel and fashion items'),
('Books', 'Physical and digital books');
```

**Checkpoint:** `SELECT * FROM gs10_categories;` should show 3 rows.

---

**Step 3: Create Products Table with Foreign Key (4 min)**

**Beginner Explanation:**
Now we create the products table that **references** the categories table. This is a parent-child relationship:
- **Parent:** `gs10_categories` (must exist first)
- **Child:** `gs10_products` (references parent via foreign key)

The foreign key ensures every product's `category_id` matches a real category - preventing invalid data!

Create products table with:
- product_id (INT, PK, AUTO_INCREMENT) - unique product identifier
- product_name (VARCHAR(200), NOT NULL) - required field
- category_id (INT, FOREIGN KEY → categories) - links to parent table
- price (DECIMAL(10,2), CHECK > 0) - must be positive
- stock_quantity (INT, DEFAULT 0) - defaults to 0 if not specified
- created_at (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP) - auto-set to current time

```sql
CREATE TABLE gs10_products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  product_name VARCHAR(200) NOT NULL,
  category_id INT,                              -- Will reference categories table
  price DECIMAL(10,2) CHECK (price > 0),        -- MySQL 8.0.16+ for CHECK
  stock_quantity INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_category FOREIGN KEY (category_id) 
    REFERENCES gs10_categories(category_id)     -- Creates the relationship
);
```

**What the Foreign Key Does:**
- Prevents inserting a product with `category_id = 99` if category 99 doesn't exist
- Prevents deleting a category that has products (by default behavior)
- Maintains referential integrity automatically

**Checkpoint:** `SHOW CREATE TABLE gs10_products;` should show the foreign key constraint.

**Understanding the Output:**
Look for this line in the output:
```
CONSTRAINT `fk_category` FOREIGN KEY (`category_id`) REFERENCES `gs10_categories` (`category_id`)
```
This confirms the relationship is properly established!

---

**Step 4: Test Foreign Key Constraint (3 min)**

**Beginner Explanation:**
Now let's test that our foreign key actually works! We'll try inserting valid data (should work) and invalid data (should fail). This verifies our database is protecting data integrity.

Try inserting a product with valid and invalid category_id.

```sql
-- ✅ This works (category_id 1 exists - Electronics):
INSERT INTO gs10_products (product_name, category_id, price, stock_quantity)
VALUES ('Laptop', 1, 1200.00, 10);

-- Query to verify the insert
SELECT p.product_id, p.product_name, c.category_name, p.price, p.stock_quantity
FROM gs10_products p
JOIN gs10_categories c ON p.category_id = c.category_id;

-- ❌ This fails (category_id 99 doesn't exist in categories table):
-- Uncomment to test:
/*
INSERT INTO gs10_products (product_name, category_id, price)
VALUES ('Invalid Product', 99, 50.00);
*/
-- Error: Cannot add or update a child row: a foreign key constraint fails
-- This is GOOD - the database prevented bad data from entering!

-- ✅ This also works (NULL category_id is allowed unless we add NOT NULL):
INSERT INTO gs10_products (product_name, category_id, price, stock_quantity)
VALUES ('Uncategorized Item', NULL, 15.00, 5);

-- Note: If you want to prevent NULL category_id, add NOT NULL constraint:
-- ALTER TABLE gs10_products MODIFY COLUMN category_id INT NOT NULL;
```

**Checkpoint:** 
- First INSERT succeeds (category 1 exists)
- Second INSERT fails with foreign key constraint error (category 99 doesn't exist)
- Third INSERT succeeds (NULL is allowed by default)

**Why This Matters:**
Without the foreign key, you could insert `category_id = 99` even though that category doesn't exist. Then when you try to JOIN products with categories, that product would be orphaned - no matching category! Foreign keys prevent this problem.

---

**Step 5: Add Index for Performance (2 min)**
Add index on category_id for faster JOIN operations.

```sql
CREATE INDEX idx_category ON gs10_products(category_id);
```

**Checkpoint:** `SHOW INDEXES FROM gs10_products;` should show the new index.

---

**Step 6: Modify Schema - Add SKU Column (2 min)**
Business requires unique SKU codes for each product.

```sql
ALTER TABLE gs10_products
ADD COLUMN sku VARCHAR(50) UNIQUE;
```

**Checkpoint:** `DESCRIBE gs10_products;` shows new sku column.

---

**Step 7: Verify Complete Schema (2 min)**
Query products with their category names.

```sql
SELECT 
  p.product_id,
  p.product_name,
  c.category_name,
  p.price,
  p.stock_quantity
FROM gs10_products p
JOIN gs10_categories c ON p.category_id = c.category_id;
```

**Checkpoint:** Results show product with category name.

---

### Common Mistakes
1. **Creating child table before parent**: Always create referenced table (categories) first
2. **Forgetting FK constraint**: Products could reference non-existent categories
3. **Wrong data types**: FK column must match PK column type exactly
4. **Missing NOT NULL on critical fields**: Allows incomplete data
5. **No CHECK constraints**: Allows negative prices or quantities

### Complete Solution
```sql
-- Complete schema creation
DROP TABLE IF EXISTS gs10_products;
DROP TABLE IF EXISTS gs10_categories;

CREATE TABLE gs10_categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(100) UNIQUE NOT NULL,
  description TEXT
);

CREATE TABLE gs10_products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  product_name VARCHAR(200) NOT NULL,
  category_id INT,
  price DECIMAL(10,2) CHECK (price > 0),
  stock_quantity INT DEFAULT 0,
  sku VARCHAR(50) UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_category FOREIGN KEY (category_id) 
    REFERENCES gs10_categories(category_id),
  INDEX idx_category (category_id)
);

-- Sample data
INSERT INTO gs10_categories (category_name, description) VALUES
('Electronics', 'Electronic devices and accessories'),
('Clothing', 'Apparel and fashion items'),
('Books', 'Physical and digital books');

INSERT INTO gs10_products (product_name, category_id, price, stock_quantity, sku) VALUES
('Laptop', 1, 1200.00, 10, 'ELEC-LAP-001'),
('T-Shirt', 2, 25.00, 100, 'CLTH-TSH-001'),
('SQL Guide', 3, 45.00, 50, 'BOOK-SQL-001');
```

### Discussion Questions
1. Why use foreign keys instead of just storing category_id without constraint?
2. When would you use ON DELETE CASCADE vs ON DELETE RESTRICT?
3. What are the trade-offs of adding many indexes?
4. How would you handle products that belong to multiple categories?

---

## Activity 2: User Account System with Audit — 20 min

### Business Context
Build a user management system that tracks account changes. Need users table, roles table, and audit log for compliance.

### Database Setup
```sql
DROP TABLE IF EXISTS gs10_user_audit;
DROP TABLE IF EXISTS gs10_users;
DROP TABLE IF EXISTS gs10_roles;
```

### Final Goal
Create a three-table system with proper relationships and an audit trail structure.

### Step-by-Step Instructions

**Step 1: Create Roles Table (2 min)**
```sql
CREATE TABLE gs10_roles (
  role_id INT AUTO_INCREMENT PRIMARY KEY,
  role_name VARCHAR(50) UNIQUE NOT NULL,
  description VARCHAR(255)
);

INSERT INTO gs10_roles (role_name, description) VALUES
('admin', 'Full system access'),
('user', 'Standard user access'),
('guest', 'Limited read-only access');
```

**Checkpoint:** `SELECT * FROM gs10_roles;` shows 3 roles.

---

**Step 2: Create Users Table (4 min)**
```sql
CREATE TABLE gs10_users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  role_id INT NOT NULL DEFAULT 2,  -- Default to 'user' role
  password_hash VARCHAR(255) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES gs10_roles(role_id),
  INDEX idx_email (email),
  INDEX idx_username (username)
);
```

**Checkpoint:** `SHOW CREATE TABLE gs10_users;` shows FK and indexes.

---

**Step 3: Create Audit Table (3 min)**
Track all changes to user records.

```sql
CREATE TABLE gs10_user_audit (
  audit_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  action VARCHAR(50) NOT NULL,  -- INSERT, UPDATE, DELETE
  changed_field VARCHAR(100),
  old_value VARCHAR(255),
  new_value VARCHAR(255),
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  changed_by VARCHAR(100),
  INDEX idx_user_audit (user_id, changed_at)
);
```

**Checkpoint:** `DESCRIBE gs10_user_audit;` shows structure.

---

**Step 4: Insert Test Users (3 min)**
```sql
INSERT INTO gs10_users (username, email, role_id, password_hash) VALUES
('admin_user', 'admin@company.com', 1, 'hash123'),
('john_doe', 'john@example.com', 2, 'hash456'),
('jane_guest', 'jane@example.com', 3, 'hash789');
```

**Checkpoint:** Query users with role names:
```sql
SELECT u.username, u.email, r.role_name, u.is_active
FROM gs10_users u
JOIN gs10_roles r ON u.role_id = r.role_id;
```

---

**Step 5: Simulate Audit Entry (2 min)**
Manually log a user update.

```sql
INSERT INTO gs10_user_audit 
(user_id, action, changed_field, old_value, new_value, changed_by)
VALUES 
(2, 'UPDATE', 'email', 'john@example.com', 'john.doe@company.com', 'admin_user');
```

**Checkpoint:** `SELECT * FROM gs10_user_audit;` shows the audit record.

---

**Step 6: Add Email Validation Constraint (3 min)**

**Beginner Explanation:**
We can use CHECK constraints to validate data format. Here we ensure emails contain @ and a dot (.) - a basic email validation. More complex validation is better done in application code, but this provides a basic safety net.

**Important:** This requires MySQL 8.0.16 or higher. Older versions will ignore CHECK constraints.

Ensure emails follow basic format:

```sql
-- Add CHECK constraint for basic email validation
ALTER TABLE gs10_users
ADD CONSTRAINT chk_email_format 
CHECK (email LIKE '%@%.%');
-- This checks for: (anything)@(anything).(anything)
-- Examples that pass: user@example.com, alice@company.co.uk
-- Examples that fail: notanemail, user@, @example.com
```

**Checkpoint:** Try inserting valid and invalid emails:
```sql
-- ✅ This should work (valid email format):
INSERT INTO gs10_users (username, email, role_id, password_hash)
VALUES ('testuser', 'test@example.com', 2, 'hash_test');

-- ❌ This should fail (no @ or dot):
/*
INSERT INTO gs10_users (username, email, role_id, password_hash)
VALUES ('baduser', 'notanemail', 2, 'hash000');
*/
-- Error: Check constraint 'chk_email_format' is violated

-- View the constraint
SHOW CREATE TABLE gs10_users;
```

**Verification Query:**
```sql
-- See all users with their roles
SELECT username, email, role_id FROM gs10_users;

-- Clean up test user
DELETE FROM gs10_users WHERE username = 'testuser';
```

**Note:** This is basic validation. Real email validation is more complex and typically handled in application code. But this prevents obviously wrong data at the database level.

---

**Step 7: Query Complete User History (3 min)**
See user details with audit trail.

```sql
SELECT 
  u.username,
  u.email,
  r.role_name,
  a.action,
  a.changed_field,
  a.old_value,
  a.new_value,
  a.changed_at
FROM gs10_users u
JOIN gs10_roles r ON u.role_id = r.role_id
LEFT JOIN gs10_user_audit a ON u.user_id = a.user_id
ORDER BY u.user_id, a.changed_at DESC;
```

---

### Common Mistakes
1. **No DEFAULT for role_id**: Every user should have a role
2. **Missing updated_at auto-update**: Use ON UPDATE CURRENT_TIMESTAMP
3. **Weak email validation**: Use CHECK constraints or triggers
4. **No indexes on lookup columns**: Email and username queries will be slow
5. **Audit table without user_id index**: Slow audit history queries

### Complete Solution
```sql
-- Complete user management system
DROP TABLE IF EXISTS gs10_user_audit;
DROP TABLE IF EXISTS gs10_users;
DROP TABLE IF EXISTS gs10_roles;

CREATE TABLE gs10_roles (
  role_id INT AUTO_INCREMENT PRIMARY KEY,
  role_name VARCHAR(50) UNIQUE NOT NULL,
  description VARCHAR(255)
);

CREATE TABLE gs10_users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  role_id INT NOT NULL DEFAULT 2,
  password_hash VARCHAR(255) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES gs10_roles(role_id),
  CONSTRAINT chk_email_format CHECK (email LIKE '%@%.%'),
  INDEX idx_email (email),
  INDEX idx_username (username)
);

CREATE TABLE gs10_user_audit (
  audit_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  action VARCHAR(50) NOT NULL,
  changed_field VARCHAR(100),
  old_value VARCHAR(255),
  new_value VARCHAR(255),
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  changed_by VARCHAR(100),
  INDEX idx_user_audit (user_id, changed_at)
);

-- Sample data
INSERT INTO gs10_roles (role_name, description) VALUES
('admin', 'Full system access'),
('user', 'Standard user access'),
('guest', 'Limited read-only access');

INSERT INTO gs10_users (username, email, role_id, password_hash) VALUES
('admin_user', 'admin@company.com', 1, 'hash123'),
('john_doe', 'john@example.com', 2, 'hash456'),
('jane_guest', 'jane@example.com', 3, 'hash789');
```

### Discussion Questions
1. Why separate roles into their own table instead of ENUM in users?
2. What are the pros/cons of using BOOLEAN vs TINYINT(1) for is_active?
3. Should password_hash be in a separate table for security?
4. How would you implement soft deletes (mark deleted vs actually DELETE)?

---

**Key Takeaways:**
- Design parent tables (referenced) before child tables (referencing)
- Use constraints to enforce business rules at database level
- Indexes speed up queries but slow down writes—balance carefully
- Audit tables track changes for compliance and debugging
- DEFAULT values and AUTO_INCREMENT reduce application complexity
- CHECK constraints (MySQL 8.0.16+) validate data at insertion time