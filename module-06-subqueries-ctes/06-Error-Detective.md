# Error Detective — Subqueries & CTEs (5 challenges)

Each challenge includes scenario, broken query, error or wrong result, sample data, expected output, guiding questions, and a fix explanation.

---

## ED1) NOT IN with NULL nukes your results
Scenario: Find products never ordered; subquery may return NULLs.

Sample data
```sql
DROP TABLE IF EXISTS ed6_1_products;
CREATE TABLE ed6_1_products (product_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO ed6_1_products VALUES (1,'Notebook'),(2,'Lamp'),(3,'Mug');

DROP TABLE IF EXISTS ed6_1_items;
CREATE TABLE ed6_1_items (order_item_id INT PRIMARY KEY, product_id INT);
INSERT INTO ed6_1_items VALUES (1,1),(2,NULL);
```
Broken query and symptom
```sql
SELECT name FROM ed6_1_products
WHERE product_id NOT IN (SELECT product_id FROM ed6_1_items);
-- Returns 0 rows because subquery yields NULL
```
Expected output
```
name
Lamp
Mug
```
Fix and explanation
```sql
SELECT p.name
FROM ed6_1_products p
WHERE NOT EXISTS (
  SELECT 1 FROM ed6_1_items i WHERE i.product_id = p.product_id
);
-- NOT EXISTS is NULL-safe; NOT IN is unsafe if the subquery can return NULLs.
```

---

## ED2) Uncorrelated "correlated" subquery
Scenario: Latest order date per customer, but the subquery forgot to correlate on customer_id.

Sample data
```sql
DROP TABLE IF EXISTS ed6_2_customers;
CREATE TABLE ed6_2_customers (customer_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO ed6_2_customers VALUES (1,'Ava'),(2,'Noah');

DROP TABLE IF EXISTS ed6_2_orders;
CREATE TABLE ed6_2_orders (order_id INT PRIMARY KEY, customer_id INT, order_date DATE);
INSERT INTO ed6_2_orders VALUES (10,1,'2025-03-01'),(11,2,'2025-03-02');
```
Broken query
```sql
SELECT c.name,
  (SELECT MAX(order_date) FROM ed6_2_orders) AS latest -- same value for all
FROM ed6_2_customers c;
```
Expected output
```
name | latest
Ava  | 2025-03-01
Noah | 2025-03-02
```
Fix and explanation
```sql
SELECT c.name,
  (SELECT MAX(o.order_date) FROM ed6_2_orders o WHERE o.customer_id = c.customer_id) AS latest
FROM ed6_2_customers c;
-- Add correlation predicate to compute per-customer values.
```

---

## ED3) Aggregate in WHERE instead of HAVING (over derived)
Scenario: We want products with revenue > 20 but put SUM in WHERE.

Sample data
```sql
DROP TABLE IF EXISTS ed6_3_products;
CREATE TABLE ed6_3_products (product_id INT PRIMARY KEY, name VARCHAR(60), price DECIMAL(7,2));
INSERT INTO ed6_3_products VALUES (1,'Notebook',4.99),(2,'Lamp',12.00),(3,'Mug',7.99);

DROP TABLE IF EXISTS ed6_3_items;
CREATE TABLE ed6_3_items (order_item_id INT PRIMARY KEY, product_id INT, qty INT);
INSERT INTO ed6_3_items VALUES (1,1,2),(2,2,1),(3,3,2),(4,2,1);
```
Broken query
```sql
SELECT p.name, SUM(i.qty * p.price) AS revenue
FROM ed6_3_items i JOIN ed6_3_products p ON p.product_id = i.product_id
WHERE SUM(i.qty * p.price) > 20 -- invalid
GROUP BY p.name;
```
Expected output
```
name   | revenue
Lamp   | 24.00
Mug    | 15.98 -- should be excluded
Notebook | 9.98 -- should be excluded
```
Fix and explanation
```sql
SELECT p.name, SUM(i.qty * p.price) AS revenue
FROM ed6_3_items i JOIN ed6_3_products p ON p.product_id = i.product_id
GROUP BY p.name
HAVING SUM(i.qty * p.price) > 20;
-- Aggregates belong in HAVING (or filter in an outer query/derived table).
```

---

## ED4) CTE column list mismatch
Scenario: CTE defines two columns but SELECT returns three.

Broken query
```sql
WITH bad(cte_col1, cte_col2) AS (
  SELECT 1 AS a, 2 AS b, 3 AS c
)
SELECT * FROM bad;
-- Error: Number of columns in result set of a CTE does not match column list
```
Fix and explanation
```sql
WITH good(cte_col1, cte_col2, cte_col3) AS (
  SELECT 1, 2, 3
)
SELECT * FROM good;
-- CTE column list must match the number of columns returned.
```

---

## ED5) Recursive CTE without termination
Scenario: Calendar CTE forgets to stop; leads to infinite recursion or max recursion reached.

Broken query
```sql
WITH RECURSIVE badcal AS (
  SELECT DATE('2025-03-01') AS d
  UNION ALL
  SELECT DATE_ADD(d, INTERVAL 1 DAY)
  FROM badcal
  -- missing WHERE to stop at '2025-03-31'
)
SELECT * FROM badcal;
```
Fix and explanation
```sql
WITH RECURSIVE goodcal AS (
  SELECT DATE('2025-03-01') AS d
  UNION ALL
  SELECT DATE_ADD(d, INTERVAL 1 DAY)
  FROM goodcal
  WHERE d < '2025-03-31'
)
SELECT * FROM goodcal;
-- Always include a termination predicate in the recursive branch.
```
