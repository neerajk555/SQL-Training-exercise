# Quick Warm-Ups — Advanced MySQL Concepts (5–10 min each)

**Beginner Tip:** JSON stores structured data in single column. Full-text search finds words in text. Recursive CTEs traverse hierarchical data. Generated columns auto-calculate values!

---

## 1) JSON Column — 6 min
```sql
DROP TABLE IF EXISTS wu15_users;
CREATE TABLE wu15_users (
  user_id INT PRIMARY KEY,
  profile JSON
);

INSERT INTO wu15_users VALUES
(1, '{"name": "Alice", "age": 30, "skills": ["SQL", "Python"]}'),
(2, '{"name": "Bob", "age": 25, "skills": ["Java", "Go"]}');

SELECT user_id, JSON_EXTRACT(profile, '$.name') AS name FROM wu15_users;
SELECT user_id, profile->'$.age' AS age FROM wu15_users;
```

---

## 2) JSON_CONTAINS — 6 min
```sql
-- Find users with SQL skill
SELECT * FROM wu15_users
WHERE JSON_CONTAINS(profile->'$.skills', '"SQL"');
```

---

## 3) Full-Text Search — 7 min
```sql
DROP TABLE IF EXISTS wu15_articles;
CREATE TABLE wu15_articles (
  article_id INT PRIMARY KEY,
  title VARCHAR(200),
  content TEXT,
  FULLTEXT(title, content)
);

INSERT INTO wu15_articles VALUES
(1, 'SQL Tutorial', 'Learn SQL basics and advanced concepts'),
(2, 'Python Guide', 'Python programming for beginners'),
(3, 'Database Design', 'SQL database schema design patterns');

SELECT * FROM wu15_articles
WHERE MATCH(title, content) AGAINST('SQL database');
```

---

## 4) Recursive CTE — 8 min
```sql
-- Generate numbers 1 to 5
WITH RECURSIVE numbers AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM numbers WHERE n < 5
)
SELECT * FROM numbers;
```

---

## 5) Hierarchical Data with Recursive CTE — 8 min
```sql
DROP TABLE IF EXISTS wu15_employees;
CREATE TABLE wu15_employees (
  emp_id INT PRIMARY KEY,
  name VARCHAR(50),
  manager_id INT
);

INSERT INTO wu15_employees VALUES
(1, 'CEO', NULL),
(2, 'CTO', 1),
(3, 'CFO', 1),
(4, 'Dev Lead', 2),
(5, 'Developer', 4);

WITH RECURSIVE emp_hierarchy AS (
  SELECT emp_id, name, manager_id, 0 AS level
  FROM wu15_employees WHERE manager_id IS NULL
  UNION ALL
  SELECT e.emp_id, e.name, e.manager_id, h.level + 1
  FROM wu15_employees e
  JOIN emp_hierarchy h ON e.manager_id = h.emp_id
)
SELECT * FROM emp_hierarchy ORDER BY level, name;
```

---

## 6) Generated Column — 6 min
```sql
DROP TABLE IF EXISTS wu15_products;
CREATE TABLE wu15_products (
  product_id INT PRIMARY KEY,
  price DECIMAL(10,2),
  tax_rate DECIMAL(4,3),
  total_price DECIMAL(10,2) GENERATED ALWAYS AS (price * (1 + tax_rate)) STORED
);

INSERT INTO wu15_products (product_id, price, tax_rate) VALUES
(1, 100.00, 0.08);

SELECT * FROM wu15_products;  -- total_price calculated automatically
```

---

## 7) JSON Table Function — 7 min
```sql
-- Convert JSON array to rows
SELECT * FROM JSON_TABLE(
  '[{"name":"Alice","age":30},{"name":"Bob","age":25}]',
  '$[*]' COLUMNS(
    name VARCHAR(50) PATH '$.name',
    age INT PATH '$.age'
  )
) AS jt;
```

---

## 8) Window Function with JSON — 7 min
```sql
DROP TABLE IF EXISTS wu15_sales;
CREATE TABLE wu15_sales (
  sale_id INT PRIMARY KEY,
  product_name VARCHAR(100),
  amount DECIMAL(10,2),
  sale_date DATE
);

INSERT INTO wu15_sales VALUES
(1, 'Laptop', 1200, '2025-11-01'),
(2, 'Mouse', 25, '2025-11-01'),
(3, 'Laptop', 1300, '2025-11-02');

SELECT 
  product_name,
  amount,
  ROW_NUMBER() OVER (PARTITION BY product_name ORDER BY amount DESC) AS rank
FROM wu15_sales;
```

---

**Key Takeaways:**
- JSON: Store flexible data, query with JSON_EXTRACT or ->
- Full-Text: Use MATCH...AGAINST for text search
- Recursive CTEs: WITH RECURSIVE for hierarchical data
- Generated columns: Auto-calculated, can be STORED or VIRTUAL
- JSON_TABLE: Convert JSON to relational format
- Combine modern features for powerful queries!

