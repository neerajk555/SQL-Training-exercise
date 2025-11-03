# Quick Warm-Ups — Indexes & Optimization (5–10 min each)

**Beginner Tip:** Indexes speed up SELECT/WHERE/JOIN but slow down INSERT/UPDATE/DELETE. Use EXPLAIN to see if queries use indexes. Index columns used in WHERE, JOIN ON, and ORDER BY clauses!

---

## 1) Create Simple Index — 5 min
```sql
DROP TABLE IF EXISTS wu11_users;
CREATE TABLE wu11_users (
  user_id INT PRIMARY KEY,
  email VARCHAR(100),
  created_at TIMESTAMP
);
INSERT INTO wu11_users VALUES
(1, 'alice@email.com', '2025-01-01 10:00:00'),
(2, 'bob@email.com', '2025-01-15 11:30:00');
```

Task: Create index on `email` column.

Solution:
```sql
CREATE INDEX idx_email ON wu11_users(email);
SHOW INDEXES FROM wu11_users;
```

---

## 2) Analyze Query with EXPLAIN — 6 min
```sql
DROP TABLE IF EXISTS wu11_products;
CREATE TABLE wu11_products (
  product_id INT PRIMARY KEY,
  category VARCHAR(50),
  price DECIMAL(10,2)
);
INSERT INTO wu11_products VALUES
(1, 'Electronics', 299.99),
(2, 'Electronics', 499.99),
(3, 'Clothing', 49.99);
```

Task: Use EXPLAIN to analyze query performance.

Solution:
```sql
-- Before index
EXPLAIN SELECT * FROM wu11_products WHERE category = 'Electronics';
-- Shows type: ALL (full table scan)

-- Create index
CREATE INDEX idx_category ON wu11_products(category);

-- After index
EXPLAIN SELECT * FROM wu11_products WHERE category = 'Electronics';
-- Shows type: ref (uses index)
```

---

## 3) Composite Index — 7 min
```sql
DROP TABLE IF EXISTS wu11_orders;
CREATE TABLE wu11_orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  status VARCHAR(20)
);
INSERT INTO wu11_orders VALUES
(1, 101, '2025-11-01', 'completed'),
(2, 102, '2025-11-02', 'pending'),
(3, 101, '2025-11-03', 'completed');
```

Task: Create composite index on (customer_id, order_date).

Solution:
```sql
CREATE INDEX idx_customer_date ON wu11_orders(customer_id, order_date);

-- This query uses the index efficiently
EXPLAIN SELECT * FROM wu11_orders 
WHERE customer_id = 101 AND order_date >= '2025-11-01';
```

---

## 4) Drop Unused Index — 5 min
```sql
DROP TABLE IF EXISTS wu11_logs;
CREATE TABLE wu11_logs (
  log_id INT PRIMARY KEY,
  message TEXT,
  log_date DATE
);
CREATE INDEX idx_message ON wu11_logs(message(100));  -- Bad idea!
```

Task: Drop the inefficient index on TEXT column.

Solution:
```sql
SHOW INDEXES FROM wu11_logs;
DROP INDEX idx_message ON wu11_logs;
-- Indexing TEXT columns is usually inefficient
```

---

## 5) Optimize Slow Query — 8 min
```sql
DROP TABLE IF EXISTS wu11_employees;
CREATE TABLE wu11_employees (
  emp_id INT PRIMARY KEY,
  dept_id INT,
  salary DECIMAL(10,2),
  hire_date DATE
);
INSERT INTO wu11_employees VALUES
(1, 10, 50000, '2020-01-15'),
(2, 10, 60000, '2021-03-20'),
(3, 20, 55000, '2019-07-10');
```

Task: Optimize query that filters by dept_id and orders by salary.

Solution:
```sql
-- Slow query
EXPLAIN SELECT * FROM wu11_employees 
WHERE dept_id = 10 ORDER BY salary DESC;

-- Create composite index
CREATE INDEX idx_dept_salary ON wu11_employees(dept_id, salary);

-- Now faster!
EXPLAIN SELECT * FROM wu11_employees 
WHERE dept_id = 10 ORDER BY salary DESC;
```

---

## 6) UNIQUE Index — 6 min
```sql
DROP TABLE IF EXISTS wu11_accounts;
CREATE TABLE wu11_accounts (
  account_id INT PRIMARY KEY,
  username VARCHAR(50)
);
```

Task: Add UNIQUE index on username.

Solution:
```sql
CREATE UNIQUE INDEX idx_username ON wu11_accounts(username);

-- Test: This succeeds
INSERT INTO wu11_accounts VALUES (1, 'alice');

-- This fails (duplicate)
-- INSERT INTO wu11_accounts VALUES (2, 'alice');
```

---

## 7) Covering Index — 7 min
```sql
DROP TABLE IF EXISTS wu11_customers;
CREATE TABLE wu11_customers (
  customer_id INT PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100),
  city VARCHAR(50)
);
INSERT INTO wu11_customers VALUES
(1, 'Alice', 'Smith', 'alice@email.com', 'Boston'),
(2, 'Bob', 'Jones', 'bob@email.com', 'New York');
```

Task: Create covering index for query that selects email and city by customer_id.

Solution:
```sql
-- Covering index includes all columns in query
CREATE INDEX idx_covering ON wu11_customers(customer_id, email, city);

EXPLAIN SELECT email, city FROM wu11_customers WHERE customer_id = 1;
-- Using index (no table access needed!)
```

---

## 8) Prefix Index on VARCHAR — 6 min
```sql
DROP TABLE IF EXISTS wu11_articles;
CREATE TABLE wu11_articles (
  article_id INT PRIMARY KEY,
  title VARCHAR(255),
  url VARCHAR(500)
);
```

Task: Create prefix index on first 100 characters of URL.

Solution:
```sql
-- Index only first 100 chars to save space
CREATE INDEX idx_url_prefix ON wu11_articles(url(100));

-- Still helps with searches
SELECT * FROM wu11_articles WHERE url LIKE 'https://example.com%';
```

---

**Key Takeaways:**
- Use EXPLAIN to understand query execution
- Index columns in WHERE, JOIN, ORDER BY
- Composite indexes: most selective column first
- Too many indexes slow down writes
- UNIQUE indexes enforce constraint + improve performance
- Prefix indexes save space on long VARCHAR columns
- Covering indexes avoid table lookups

