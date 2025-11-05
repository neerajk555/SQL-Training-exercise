# Take-Home Challenges — DDL & Schema Design

**Purpose:** Advanced schema design challenges for deeper learning. Research, experiment, and think critically about database design decisions!

**Time Commitment:** Each challenge: 2-4 hours  
**Difficulty:** Advanced to Expert  
**Prerequisites:** Complete Modules 1-10

**How to Approach:**
1. Research the concepts (use documentation, articles, forums)
2. Design on paper first - sketch your schema
3. Consider trade-offs of different approaches
4. Implement and test your solution
5. Document your decisions and reasoning

---

## Challenge 1: Schema Migration Strategy

**Difficulty:** ⭐⭐⭐ Advanced  
**Time Estimate:** 2-3 hours

**Context:**
In real-world projects, you often inherit poorly designed databases. This challenge simulates migrating from a denormalized "flat" structure to a properly normalized relational schema.

**The Problem - Bad Schema:**
```sql
-- This is an example of a TERRIBLE database design!
-- All data crammed into one table with comma-separated values
CREATE TABLE bad_orders (
  order_id INT PRIMARY KEY,
  customer_name VARCHAR(100),
  customer_email VARCHAR(100),
  product_names TEXT,        -- ❌ Comma-separated: "Laptop,Mouse,Keyboard"
  prices TEXT,               -- ❌ Comma-separated: "999.99,25.00,75.00"
  quantities TEXT            -- ❌ Comma-separated: "1,2,1"
);

-- Sample bad data
INSERT INTO bad_orders VALUES 
(1, 'Alice Smith', 'alice@email.com', 'Laptop,Mouse', '999.99,25.00', '1,2'),
(2, 'Bob Jones', 'bob@email.com', 'Keyboard', '75.00', '1'),
(3, 'Alice Smith', 'alice@email.com', 'Monitor', '299.99', '2');
-- Notice: Alice appears twice with same email (data duplication!)
```

**Problems with This Design:**
- ❌ Violates 1st Normal Form (atomic values)
- ❌ Can't query individual products easily
- ❌ Duplicate customer data (Alice appears twice)
- ❌ Can't enforce referential integrity
- ❌ Hard to calculate totals
- ❌ Wastes storage space
- ❌ Prone to data inconsistencies

**Your Mission:**
1. **Design normalized schema** with separate tables:
   - `customers` (customer_id, name, email)
   - `products` (product_id, product_name, price)
   - `orders` (order_id, customer_id, order_date)
   - `order_items` (order_item_id, order_id, product_id, quantity, unit_price)

2. **Write CREATE statements** for the new schema with proper constraints

3. **Write migration queries** using INSERT...SELECT to move data:
   - Extract unique customers
   - Extract unique products
   - Create orders linked to customers
   - Parse comma-separated values into order_items

4. **Handle inconsistencies:**
   - Duplicate customer data (same person, different spellings)
   - Invalid prices (negative, non-numeric)
   - Mismatched array lengths (3 products but 2 prices)

**Hints:**
```sql
-- MySQL string functions you'll need:
SUBSTRING_INDEX(str, delimiter, count)  -- Extract part of delimited string
FIND_IN_SET(str, str_list)              -- Find position in comma-separated list
CHAR_LENGTH(str) - CHAR_LENGTH(REPLACE(str, ',', '')) + 1  -- Count delimited items

-- Example: Extract first product name
SELECT SUBSTRING_INDEX(product_names, ',', 1) FROM bad_orders;
```

**Evaluation Criteria:**
- [ ] New schema properly normalized (3NF or higher)
- [ ] All constraints defined (PK, FK, UNIQUE, NOT NULL)
- [ ] Migration preserves all valid data
- [ ] Invalid/inconsistent data handled gracefully
- [ ] Queries demonstrate data integrity improvements
- [ ] Documentation of design decisions

---

## Challenge 2: Multi-Tenancy Schema Design

**Difficulty:** ⭐⭐⭐⭐ Expert  
**Time Estimate:** 3-4 hours

**Context:**
Multi-tenancy is crucial for SaaS (Software as a Service) applications. Multiple customers (tenants) use the same application, but their data must be completely isolated. Example: A project management tool used by 1000 different companies.

**Business Requirements:**
- Support 1000+ tenants (companies/organizations)
- Each tenant has: users, projects, tasks, comments
- **Complete data isolation** - Company A cannot see Company B's data
- Efficient tenant-specific queries (most queries filter by one tenant)
- Scalability for growth
- Cost-effective (shared infrastructure)
- Easy tenant onboarding/offboarding

**Three Approaches to Research:**

### Approach 1: Shared Schema (Single Database, tenant_id everywhere)
```sql
-- Every table has tenant_id column
CREATE TABLE tenants (
  tenant_id INT PRIMARY KEY AUTO_INCREMENT,
  tenant_name VARCHAR(100),
  subscription_plan VARCHAR(50)
);

CREATE TABLE users (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  tenant_id INT,                              -- Every table!
  username VARCHAR(50),
  FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
  INDEX idx_tenant (tenant_id)                -- Critical for performance
);

CREATE TABLE projects (
  project_id INT PRIMARY KEY AUTO_INCREMENT,
  tenant_id INT,                              -- Every table!
  user_id INT,
  project_name VARCHAR(200),
  FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
  INDEX idx_tenant (tenant_id)
);

-- All queries must filter by tenant_id
SELECT * FROM projects WHERE tenant_id = 123;
```

**Pros:**
- ✅ Simple to implement and maintain
- ✅ Cost-effective (one database)
- ✅ Easy to add new tenants (just insert row)
- ✅ Easy cross-tenant analytics

**Cons:**
- ❌ Risk of data leakage (forgot WHERE tenant_id = ?)
- ❌ Noisy neighbor problem (one tenant's heavy load affects others)
- ❌ Hard to scale individual tenants
- ❌ Backup/restore affects all tenants

### Approach 2: Separate Schemas (Multiple schemas in one database)
```sql
-- Each tenant gets their own schema
CREATE SCHEMA tenant_123;
CREATE SCHEMA tenant_456;

-- Each schema has same table structure
CREATE TABLE tenant_123.users (...);
CREATE TABLE tenant_123.projects (...);

CREATE TABLE tenant_456.users (...);
CREATE TABLE tenant_456.projects (...);

-- Query specific tenant's schema
SELECT * FROM tenant_123.projects;
```

**Pros:**
- ✅ Better isolation than shared schema
- ✅ Easier to backup/restore individual tenants
- ✅ Can apply schema changes selectively

**Cons:**
- ❌ Schema management complexity (1000 schemas!)
- ❌ Database connection management
- ❌ Cross-tenant queries difficult
- ❌ Limited by database schema limits

### Approach 3: Separate Databases (One database per tenant)
```sql
-- Completely separate databases
CREATE DATABASE tenant_123;
CREATE DATABASE tenant_456;

USE tenant_123;
CREATE TABLE users (...);
CREATE TABLE projects (...);

USE tenant_456;
CREATE TABLE users (...);
CREATE TABLE projects (...);
```

**Pros:**
- ✅ Maximum isolation and security
- ✅ Independent scaling per tenant
- ✅ Easy to backup/restore/migrate individual tenants
- ✅ Can use different servers for large tenants

**Cons:**
- ❌ Highest infrastructure cost
- ❌ Schema migrations complex (1000 databases!)
- ❌ Cross-tenant analytics very difficult
- ❌ Connection pool management challenging

**Your Mission:**
1. Choose ONE approach and justify your decision
2. Implement complete schema for a project management SaaS
3. Include: tenants, users, projects, tasks, comments, file_attachments
4. Write queries demonstrating:
   - Tenant isolation (can't access other tenant's data)
   - Performance optimization
   - Tenant onboarding (add new tenant)
   - Tenant offboarding (remove tenant and all data)
5. Document trade-offs and when you'd choose differently

**Evaluation Criteria:**
- [ ] Clear reasoning for approach chosen
- [ ] Complete working schema
- [ ] Proper indexing strategy
- [ ] Security considerations addressed
- [ ] Performance considerations addressed
- [ ] Migration strategy documented
- [ ] Alternative approaches discussed

---

## Challenge 3: Temporal Tables (History Tracking)

**Task:** Implement a system to track all changes to a users table.

**Requirements:**
- Every UPDATE creates history record
- Query user state at any point in time
- Implement using triggers or application logic
- Compare approaches

```sql
-- Users table
CREATE TABLE users (
  user_id INT PRIMARY KEY,
  email VARCHAR(100),
  name VARCHAR(100),
  updated_at TIMESTAMP
);

-- History table design?
-- How to query historical state?
```

---

## Challenge 4: Polymorphic Associations

**Task:** Design a comments system where comments can be on posts, photos, OR videos.

**Research:**
- Single Table Inheritance
- Class Table Inheritance  
- Shared Primary Key

**Implement and test:**
```sql
-- How to structure so a comment can belong to different entity types?
-- How to maintain referential integrity?
```

---

## Challenge 5: Performance-Oriented Schema

**Task:** Design a high-performance analytics schema for billion-row dataset.

**Scenario:** E-commerce click tracking
- 100M clicks per day
- Need aggregated reports (hourly, daily, monthly)
- Real-time dashboard queries

**Considerations:**
- Partitioning strategies
- Summary tables
- Indexing strategy
- Archiving old data

---

## Challenge 6: Schema Versioning System

**Task:** Build a migration system to track schema changes over time.

**Requirements:**
```sql
CREATE TABLE schema_migrations (
  version INT PRIMARY KEY,
  description VARCHAR(255),
  applied_at TIMESTAMP,
  migration_sql TEXT
);

-- Write migrations for common operations
-- Up/down migration pairs
-- Rollback capability
```

---

## Challenge 7: Soft Delete Patterns

**Difficulty:** ⭐⭐⭐ Advanced  
**Time Estimate:** 2-3 hours

**Context:**
**Soft delete** means marking records as deleted without actually removing them from the database. This is essential for:
- Audit trails (who deleted what and when?)
- Undo functionality (restore deleted items)
- Compliance requirements (must retain data for X years)
- Referential integrity (can't delete if other records depend on it)

**Hard Delete vs Soft Delete:**
```sql
-- Hard delete: GONE FOREVER
DELETE FROM users WHERE user_id = 5;

-- Soft delete: Still in database, just marked as deleted
UPDATE users SET is_deleted = TRUE WHERE user_id = 5;
```

**Your Mission:** Implement and compare THREE soft delete strategies:

### Strategy 1: Boolean Flag (`is_deleted`)
```sql
CREATE TABLE users (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50),
  email VARCHAR(100),
  is_deleted BOOLEAN DEFAULT FALSE,
  INDEX idx_deleted (is_deleted)
);

-- "Delete" a user
UPDATE users SET is_deleted = TRUE WHERE user_id = 5;

-- Query active users
SELECT * FROM users WHERE is_deleted = FALSE;

-- Query deleted users
SELECT * FROM users WHERE is_deleted = TRUE;
```

**Pros:**
- ✅ Simple to implement
- ✅ Easy to query active vs deleted
- ✅ Small storage overhead (1 byte per row)

**Cons:**
- ❌ Doesn't track WHEN deleted
- ❌ Doesn't track WHO deleted
- ❌ Can't handle multiple soft deletes (undo/redo)

### Strategy 2: Timestamp (`deleted_at`)
```sql
CREATE TABLE users (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50),
  email VARCHAR(100),
  deleted_at TIMESTAMP NULL DEFAULT NULL,
  deleted_by INT NULL,  -- Optional: track who deleted
  INDEX idx_deleted (deleted_at)
);

-- "Delete" a user
UPDATE users SET deleted_at = NOW(), deleted_by = 123 WHERE user_id = 5;

-- Query active users (NULL = not deleted)
SELECT * FROM users WHERE deleted_at IS NULL;

-- Query deleted users
SELECT * FROM users WHERE deleted_at IS NOT NULL;

-- Query recently deleted (last 7 days)
SELECT * FROM users 
WHERE deleted_at > DATE_SUB(NOW(), INTERVAL 7 DAY);
```

**Pros:**
- ✅ Tracks deletion timestamp
- ✅ Can track who deleted (add deleted_by column)
- ✅ Can query by deletion date
- ✅ NULL = active is intuitive

**Cons:**
- ❌ Larger storage than boolean (8 bytes vs 1 byte)
- ❌ Must remember to check IS NULL in all queries
- ❌ Can't handle multiple soft deletes

### Strategy 3: Archive Table
```sql
-- Active records table
CREATE TABLE users (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50),
  email VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Deleted records archive
CREATE TABLE users_deleted (
  user_id INT PRIMARY KEY,
  username VARCHAR(50),
  email VARCHAR(100),
  created_at TIMESTAMP,
  deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_by INT
);

-- "Delete" a user (move to archive)
INSERT INTO users_deleted (user_id, username, email, created_at, deleted_by)
SELECT user_id, username, email, created_at, 123
FROM users WHERE user_id = 5;

DELETE FROM users WHERE user_id = 5;

-- Query active users (just query users table)
SELECT * FROM users;

-- Query deleted users (query archive)
SELECT * FROM users_deleted;
```

**Pros:**
- ✅ Active table stays small and fast
- ✅ No need to filter is_deleted in every query
- ✅ Can add extra columns to archive (deleted_reason, etc.)
- ✅ Easy to purge old deleted records

**Cons:**
- ❌ More complex to implement
- ❌ Must maintain two tables with same schema
- ❌ "Undelete" requires moving record back
- ❌ Foreign key challenges (active vs archived records)

**Your Tasks:**
1. Implement all three strategies for a `products` table
2. Create test data and benchmark query performance
3. Handle foreign key relationships (orders referencing deleted products)
4. Implement "undelete" functionality for each strategy
5. Write a purge script (permanently delete records older than 1 year)
6. Document which strategy to use when

**Evaluation Criteria:**
- [ ] All three strategies implemented correctly
- [ ] Foreign key handling demonstrated
- [ ] Performance comparison documented
- [ ] Undelete functionality works
- [ ] Purge strategy implemented
- [ ] Recommendations for each use case

---

## Bonus Challenge: Temporal Tables (System-Versioned Tables)

**Research MySQL's support for temporal tables or implement your own history tracking:**

```sql
-- Current data
CREATE TABLE employees (
  emp_id INT PRIMARY KEY,
  name VARCHAR(100),
  salary DECIMAL(10,2),
  dept_id INT,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Historical data (every change is recorded)
CREATE TABLE employees_history (
  history_id INT PRIMARY KEY AUTO_INCREMENT,
  emp_id INT,
  name VARCHAR(100),
  salary DECIMAL(10,2),
  dept_id INT,
  valid_from TIMESTAMP,
  valid_to TIMESTAMP,
  INDEX idx_emp_time (emp_id, valid_from, valid_to)
);

-- Query: What was employee 5's salary on 2024-06-15?
SELECT salary FROM employees_history
WHERE emp_id = 5 
  AND '2024-06-15' BETWEEN valid_from AND valid_to;
```

---

**Research Tips:**
- 📚 Read MySQL documentation on advanced features
- 🔍 Study open-source project schemas on GitHub
- ⚡ Consider performance implications of each design
- 📊 Test with realistic data volumes (millions of rows)
- 📝 Document trade-offs of your choices
- 🧪 Benchmark query performance
- 🎯 Think about real-world use cases

**Learning Resources:**
- MySQL Documentation: https://dev.mysql.com/doc/
- Database Normalization: 1NF, 2NF, 3NF, BCNF
- Martin Fowler's Patterns: https://martinfowler.com/eaaCatalog/
- Open Source Examples: Examine schemas from WordPress, Magento, Laravel projects

**Remember:** There's no "perfect" schema design - only trade-offs. The best design depends on your specific requirements, query patterns, and scale!