# Independent Practice — Subqueries & CTEs (7 exercises)

Includes 3 easy, 3 medium, and 1 challenge. Each exercise has a time estimate, scenario, schema with data (10–20 rows overall per exercise set), requirements, example output, success criteria, tiered hints, and detailed solutions with alternatives.

## 📋 Before You Start

### Learning Objectives
Through independent practice, you will:
- Apply subqueries without step-by-step guidance
- Choose appropriate subquery type for each problem
- Write CTEs for multi-step logic
- Handle NULL safely with NOT EXISTS
- Implement complex analytical patterns

### Difficulty Progression
- 🟢 **Easy (1-3)**: Simple subqueries, EXISTS, scalar subqueries, 10-12 minutes
- 🟡 **Medium (4-6)**: Derived tables, CTEs, correlated subqueries, 15-20 minutes
- 🔴 **Challenge (7)**: Multi-level subqueries or complex CTEs, 25-30 minutes

### Problem-Solving Strategy
1. **READ** requirements and identify the complexity
2. **SETUP** sample data
3. **PLAN** your approach:
   - Can this be a simple JOIN? (try that first!)
   - Do I need a subquery? What type?
   - Scalar (one value), table (multiple rows), or EXISTS (check existence)?
   - Would a CTE make this clearer?
4. **TEST inner queries** separately first
5. **TRY** solving independently
6. **VERIFY** results match expected output
7. **USE HINTS** if stuck
8. **REVIEW** solution for alternative approaches

**Common Subquery Pitfalls:**
- ❌ `NOT IN` with NULLs: Returns empty set! Use NOT EXISTS instead
- ❌ Forgetting alias for derived tables in FROM
- ❌ Correlated subquery without correlation (returns same value for all rows)
- ❌ Multiple rows returned from scalar subquery (causes error)
- ✅ Test subqueries independently before nesting them!

**When to Use What:**
- **EXISTS**: Checking if related records exist (customers with orders)
- **Scalar subquery**: Comparing to a single value (price > average)
- **Derived table**: Pre-aggregating before joining
- **CTE**: Multi-step logic, recursive queries, or improving readability

**Debugging Strategy:**
1. Run the subquery alone—does it return what you expect?
2. Check for NULLs in key columns
3. Verify scalar subqueries return exactly one value
4. With CTEs, query each CTE separately to verify intermediate results

**Beginner Tip:** Subqueries and CTEs let you break complex problems into smaller pieces. Test the inner query first before using it in a larger query. WITH (CTE) syntax makes code easier to read and debug. Start with Easy exercises and work your way up!

---

## Easy 🟢 (10–12 min each)

### E1) Customers with Orders (EXISTS)
Scenario: Show customers who have at least one order.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip6_e1_customers;
CREATE TABLE ip6_e1_customers (customer_id INT PRIMARY KEY, full_name VARCHAR(60));
INSERT INTO ip6_e1_customers VALUES (1,'Ava'),(2,'Noah'),(3,'Mia'),(4,'Leo');

DROP TABLE IF EXISTS ip6_e1_orders;
CREATE TABLE ip6_e1_orders (order_id INT PRIMARY KEY, customer_id INT);
INSERT INTO ip6_e1_orders VALUES (100,1),(101,1),(102,2);
```
Requirements
- Return full_name for customers with orders.
- Alphabetical order.

Example output
```
full_name
Ava
Noah
```
Success criteria
- Uses EXISTS (semi-join) rather than JOIN + DISTINCT.

Hints
- L1: EXISTS is true if a related row exists.
- L2: Correlate on customer_id.
- L3: SELECT 1 in the subquery.

Solution
```sql
SELECT c.full_name
FROM ip6_e1_customers c
WHERE EXISTS (
  SELECT 1 FROM ip6_e1_orders o WHERE o.customer_id = c.customer_id
)
ORDER BY c.full_name;
```

---

### E2) Above/Below Average Price (Scalar Subquery)
Scenario: Label each product as 'above' or 'below_or_equal' the average price.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip6_e2_products;
CREATE TABLE ip6_e2_products (product_id INT PRIMARY KEY, name VARCHAR(60), price DECIMAL(7,2));
INSERT INTO ip6_e2_products VALUES
(1,'Notebook',4.99),(2,'Lamp',12.00),(3,'Mug',7.99),(4,'Pen',2.50),(5,'Keyboard',39.00);
```
Requirements
- Compute global AVG(price) via scalar subquery.
- Output: name, price, avg_price, label.

Example output (abridged)
```
name     | price | avg_price | label
Keyboard | 39.00 | 13.70     | above
Pen      | 2.50  | 13.70     | below_or_equal
```
Success criteria
- Single pass SELECT with scalar subquery reused.

Hints
- L1: Place (SELECT AVG(price) FROM ip6_e2_products) in SELECT.
- L2: Use CASE to label.
- L3: Reuse the same scalar subquery for display and CASE.

Solution
```sql
SELECT p.name, p.price,
  (SELECT AVG(price) FROM ip6_e2_products) AS avg_price,
  CASE WHEN p.price > (SELECT AVG(price) FROM ip6_e2_products)
       THEN 'above' ELSE 'below_or_equal' END AS label
FROM ip6_e2_products p
ORDER BY p.price DESC;
```

---

### E3) Orders per Customer (Derived Table)
Scenario: Count orders for each customer and include customers with 0.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip6_e3_customers;
CREATE TABLE ip6_e3_customers (customer_id INT PRIMARY KEY, full_name VARCHAR(60));
INSERT INTO ip6_e3_customers VALUES
(1,'Ava'),(2,'Noah'),(3,'Mia'),(4,'Leo'),(5,'Zoe');

DROP TABLE IF EXISTS ip6_e3_orders;
CREATE TABLE ip6_e3_orders (order_id INT PRIMARY KEY, customer_id INT);
INSERT INTO ip6_e3_orders VALUES
(100,1),(101,1),(102,2),(103,5);
```
Requirements
- Return full_name and order_count using a derived table that groups orders.

Example output
```
full_name | order_count
Ava       | 2
Leo       | 0
Mia       | 0
Noah      | 1
Zoe       | 1
```
Success criteria
- Correct LEFT JOIN to the derived table with COALESCE.

Hints
- L1: Derived table with COUNT(*) per customer_id.
- L2: LEFT JOIN customers to it.
- L3: COALESCE null counts to 0.

Solution
```sql
SELECT c.full_name, COALESCE(t.order_count,0) AS order_count
FROM ip6_e3_customers c
LEFT JOIN (
  SELECT customer_id, COUNT(*) AS order_count
  FROM ip6_e3_orders
  GROUP BY customer_id
) t ON t.customer_id = c.customer_id
ORDER BY c.full_name;
```

---

## Medium 🟡 (15–18 min each)

### M1) Above-Avg Spenders (Subquery in WHERE)
Scenario: Find customers whose total spend is above the overall average customer spend.

Schema and sample data (≈12 rows)
```sql
DROP TABLE IF EXISTS ip6_m1_customers;
CREATE TABLE ip6_m1_customers (customer_id INT PRIMARY KEY, full_name VARCHAR(60));
INSERT INTO ip6_m1_customers VALUES (1,'Ava'),(2,'Noah'),(3,'Mia'),(4,'Leo');

DROP TABLE IF EXISTS ip6_m1_orders;
CREATE TABLE ip6_m1_orders (order_id INT PRIMARY KEY, customer_id INT);
INSERT INTO ip6_m1_orders VALUES (100,1),(101,1),(102,2),(103,4);

DROP TABLE IF EXISTS ip6_m1_items;
CREATE TABLE ip6_m1_items (order_item_id INT PRIMARY KEY, order_id INT, price DECIMAL(7,2), qty INT);
INSERT INTO ip6_m1_items VALUES
(1,100,4.99,2),(2,101,7.99,1),(3,102,12.00,1),(4,103,2.50,3);
```
Requirements
- Compute spend per customer via subquery/derived table.
- Filter to those above the average spend across customers.

Example output
```
full_name | total_spend
Ava       | 17.97
Noah      | 12.00
```
Success criteria
- Two-stage logic: per-customer aggregation, then compare to overall avg of those totals.

Hints
- L1: Build per-customer totals in a derived table t.
- L2: Compute AVG(t.total_spend) in WHERE/HAVING.
- L3: Order by total_spend desc.

Solution
```sql
SELECT t.full_name, t.total_spend
FROM (
  SELECT c.full_name, SUM(i.qty * i.price) AS total_spend
  FROM ip6_m1_customers c
  LEFT JOIN ip6_m1_orders o ON o.customer_id = c.customer_id
  LEFT JOIN ip6_m1_items i ON i.order_id = o.order_id
  GROUP BY c.full_name
) t
WHERE t.total_spend > (
  SELECT AVG(total_spend) FROM (
    SELECT c2.customer_id, SUM(i2.qty * i2.price) AS total_spend
    FROM ip6_m1_customers c2
    LEFT JOIN ip6_m1_orders o2 ON o2.customer_id = c2.customer_id
    LEFT JOIN ip6_m1_items i2 ON i2.order_id = o2.order_id
    GROUP BY c2.customer_id
  ) u
)
ORDER BY t.total_spend DESC, t.full_name;
```

---

### M2) Top 2 Products per Category (CTE + Window)
Scenario: Return the top 2 products by revenue within each category.

Schema and sample data (≈14 rows)
```sql
DROP TABLE IF EXISTS ip6_m2_products;
CREATE TABLE ip6_m2_products (product_id INT PRIMARY KEY, category VARCHAR(40), name VARCHAR(60), price DECIMAL(7,2));
INSERT INTO ip6_m2_products VALUES
(1,'stationery','Notebook',4.99),(2,'stationery','Pen',2.50),(3,'kitchen','Mug',7.99),
(4,'home','Lamp',12.00),(5,'home','LED Strip',22.00),(6,'electronics','Keyboard',39.00);

DROP TABLE IF EXISTS ip6_m2_items;
CREATE TABLE ip6_m2_items (order_item_id INT PRIMARY KEY, product_id INT, qty INT);
INSERT INTO ip6_m2_items VALUES
(1,1,3),(2,2,5),(3,3,2),(4,4,1),(5,5,2),(6,1,1),(7,5,1),(8,6,1);
```
Requirements
- Return category, product, revenue, rank (1–2) using window functions.

Example output (abridged)
```
category   | product    | revenue | rnk
home       | LED Strip  | 66.00   | 1
home       | Lamp       | 12.00   | 2
```
Success criteria
- Correct aggregation then ranking per category.

Hints
- L1: SUM(qty*price) per product via join.
- L2: ROW_NUMBER or DENSE_RANK over category partition.
- L3: Filter to rnk <= 2.

Solution
```sql
WITH prod_rev AS (
  SELECT p.category, p.name AS product, SUM(i.qty * p.price) AS revenue
  FROM ip6_m2_items i
  JOIN ip6_m2_products p ON p.product_id = i.product_id
  GROUP BY p.category, p.name
)
SELECT category, product, revenue,
       ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS rnk
FROM prod_rev
WHERE revenue IS NOT NULL
QUALIFY rnk <= 2; -- MySQL doesn't support QUALIFY; use a wrapping SELECT instead
```
Alternative (MySQL-compliant)
```sql
WITH prod_rev AS (
  SELECT p.category, p.name AS product, SUM(i.qty * p.price) AS revenue
  FROM ip6_m2_items i
  JOIN ip6_m2_products p ON p.product_id = i.product_id
  GROUP BY p.category, p.name
), ranked AS (
  SELECT category, product, revenue,
         ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS rnk
  FROM prod_rev
)
SELECT *
FROM ranked
WHERE rnk <= 2
ORDER BY category, rnk, product;
```

---

### M3) NOT IN Trap (NULL-safe Anti-Join)
Scenario: List members who did not borrow any book, with NULLs present in loans.

Schema and sample data (≈12 rows)
```sql
DROP TABLE IF EXISTS ip6_m3_members;
CREATE TABLE ip6_m3_members (member_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO ip6_m3_members VALUES (1,'Ava'),(2,'Noah'),(3,'Mia'),(4,'Leo');

DROP TABLE IF EXISTS ip6_m3_loans;
CREATE TABLE ip6_m3_loans (loan_id INT PRIMARY KEY, member_id INT);
INSERT INTO ip6_m3_loans VALUES (100,1),(101,NULL);
```
Requirements
- Return member names with no loans using a NULL-safe approach.

Example output
```
name
Leo
Mia
Noah
```
Success criteria
- Use NOT EXISTS instead of NOT IN.

Hints
- L1: NOT IN fails if subquery yields NULL.
- L2: Match loans.member_id to members.member_id in a NOT EXISTS.
- L3: Order by name.

Solution
```sql
SELECT m.name
FROM ip6_m3_members m
WHERE NOT EXISTS (
  SELECT 1 FROM ip6_m3_loans l WHERE l.member_id = m.member_id
)
ORDER BY m.name;
```

---

## Challenge 🔴 (25–30 min)

### C1) Organization Chart Depth and Paths (Recursive CTE)
Scenario: HR needs the depth (level) of each employee and the reporting chain path from the CEO.

Schema and sample data (≈12 rows)
```sql
DROP TABLE IF EXISTS ip6_c1_employees;
CREATE TABLE ip6_c1_employees (emp_id INT PRIMARY KEY, name VARCHAR(60), manager_id INT);
INSERT INTO ip6_c1_employees VALUES
(1,'Alice',NULL),(2,'Bob',1),(3,'Cara',2),(4,'Drew',2),(5,'Evan',1),
(6,'Faye',5),(7,'Gina',5),(8,'Hank',6),(9,'Ivan',6),(10,'Jade',7),(11,'Kyle',7),(12,'Lia',11);
```
Requirements
- Return name, level (0 for CEO), and path 'Alice > Bob > ... > Name'.
- Order by level then name.

Example output (abridged)
```
name  | lvl | path
Alice | 0   | Alice
Bob   | 1   | Alice > Bob
...
```
Success criteria
- Correct recursive CTE with termination (manager_id IS NULL).
- Proper string concatenation per step.

Hints
- L1: Start with roots (manager_id IS NULL).
- L2: UNION ALL with join to previous level.
- L3: CONCAT(prior_path,' > ',name).

Solution
```sql
WITH RECURSIVE org AS (
  SELECT emp_id, name, manager_id, 0 AS lvl, CAST(name AS CHAR(255)) AS path
  FROM ip6_c1_employees
  WHERE manager_id IS NULL
  UNION ALL
  SELECT e.emp_id, e.name, e.manager_id, o.lvl + 1,
         CONCAT(o.path,' > ', e.name)
  FROM ip6_c1_employees e
  JOIN org o ON o.emp_id = e.manager_id
)
SELECT name, lvl, path
FROM org
ORDER BY lvl, name;
```

Alternatives
- Store a materialized path or closure table for complex hierarchies; compute deltas incrementally.
