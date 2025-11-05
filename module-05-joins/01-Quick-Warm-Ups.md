# Quick Warm-Ups — Joins (5–10 min each)

Each exercise includes a tiny setup, a task, the expected output, and an answer. Run each in its own session.

## 📋 Before You Start

### Learning Objectives
By completing these warm-ups, you will:
- Use INNER JOIN to combine matching rows from two tables
- Apply LEFT JOIN to preserve all rows from the left table
- Implement self-joins to relate a table to itself
- Combine joins with aggregation
- Understand anti-joins (LEFT JOIN ... IS NULL pattern)

### Key Join Concepts for Beginners
**INNER JOIN:**
- Returns only rows that have matches in BOTH tables
- Use when you only want records that exist in both tables
- Example: Orders WITH customer information (excludes invalid customer_ids)

**LEFT JOIN (LEFT OUTER JOIN):**
- Returns ALL rows from the left table
- Includes matches from right table, or NULL if no match
- Use when you want ALL left records, even without matches
- Example: ALL customers, showing orders if they exist

**Self-Join:**
- Joins a table to itself (using different aliases)
- Use for hierarchical data (employee-manager relationships)
- Example: Employees table referencing itself for manager names

**Anti-Join Pattern:**
- LEFT JOIN ... WHERE right_table.key IS NULL
- Finds rows in left table with NO match in right table
- Example: Customers who have never placed an order

### Execution Tips
1. **Run setup code** for each exercise (DROP + CREATE + INSERT)
2. **Note the table relationships** (which columns link tables)
3. **Try solving** before checking the solution
4. **Verify row counts** match expected output
5. **Experiment** with different join types to see the difference

**Beginner Tip:** Joins combine data from multiple tables. INNER JOIN keeps only matching rows, LEFT JOIN keeps all left table rows (even if no match), and SELF JOIN joins a table to itself. Start simple and build up!

---

## 1) Orders with Customer Names (INNER JOIN) — 7 min
Scenario: Show each order’s id, date, and customer name.

Sample data
```sql
DROP TABLE IF EXISTS wu5_customers;
CREATE TABLE wu5_customers (customer_id INT PRIMARY KEY, full_name VARCHAR(60));
INSERT INTO wu5_customers VALUES (1,'Ava Brown'),(2,'Noah Smith'),(3,'Mia Chen');

DROP TABLE IF EXISTS wu5_orders;
CREATE TABLE wu5_orders (order_id INT PRIMARY KEY, customer_id INT, order_date DATE);
INSERT INTO wu5_orders VALUES (101,1,'2025-03-01'),(102,2,'2025-03-02'),(103,1,'2025-03-04');
```
Task: Return order_id, order_date, full_name.

Expected output
```
order_id | order_date  | full_name
101      | 2025-03-01  | Ava Brown
102      | 2025-03-02  | Noah Smith
103      | 2025-03-04  | Ava Brown
```

Solution
```sql
SELECT o.order_id, o.order_date, c.full_name
FROM wu5_orders o
JOIN wu5_customers c ON c.customer_id = o.customer_id
ORDER BY o.order_id;
```

---

## 2) Customers without Orders (LEFT JOIN anti-join) — 8 min
Scenario: List customers who have no orders.

Sample data
```sql
-- re-use wu5_customers and wu5_orders from above
```
Task: Return full_name of customers with zero orders.

Expected output
```
full_name
Mia Chen
```

Solution
```sql
SELECT c.full_name
FROM wu5_customers c
LEFT JOIN wu5_orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL
ORDER BY c.full_name;
```

---

## 3) Items per Order (JOIN + aggregate) — 7 min
Scenario: Count items per order.

Sample data
```sql
DROP TABLE IF EXISTS wu5_order_items;
CREATE TABLE wu5_order_items (order_item_id INT PRIMARY KEY, order_id INT, qty INT);
INSERT INTO wu5_order_items VALUES
(1,101,2),(2,101,1),(3,102,3),(4,103,1);
```
Task: For each order, return order_id and SUM(qty).

Expected output
```
order_id | total_items
101      | 3
102      | 3
103      | 1
```

Solution
```sql
SELECT oi.order_id, SUM(oi.qty) AS total_items
FROM wu5_order_items oi
GROUP BY oi.order_id
ORDER BY oi.order_id;
```

---

## 4) Employees and Managers (SELF JOIN) — 9 min
Scenario: Show each employee’s manager name.

Sample data
```sql
DROP TABLE IF EXISTS wu5_employees;
CREATE TABLE wu5_employees (
  emp_id INT PRIMARY KEY,
  full_name VARCHAR(60),
  manager_id INT
);
INSERT INTO wu5_employees VALUES
(1,'Alice CEO',NULL),(2,'Bob Lead',1),(3,'Cara Dev',2),(4,'Drew Dev',2);
```
Task: Return employee, manager (NULL as 'None').

Expected output
```
full_name | manager
Alice CEO | None
Bob Lead  | Alice CEO
Cara Dev  | Bob Lead
Drew Dev  | Bob Lead
```

Solution
```sql
SELECT e.full_name,
       COALESCE(m.full_name,'None') AS manager
FROM wu5_employees e
LEFT JOIN wu5_employees m ON m.emp_id = e.manager_id
ORDER BY e.emp_id;
```

---

## 5) Products Never Sold (LEFT anti-join) — 9 min
Scenario: Find products with no order items.

Sample data
```sql
DROP TABLE IF EXISTS wu5_products;
CREATE TABLE wu5_products (product_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO wu5_products VALUES (1,'Notebook'),(2,'Lamp'),(3,'Mug');

DROP TABLE IF EXISTS wu5_order_items;
CREATE TABLE wu5_order_items (order_item_id INT PRIMARY KEY, order_id INT, product_id INT, qty INT);
INSERT INTO wu5_order_items VALUES
(1,101,1,2),(2,101,2,1),(3,102,1,3),(4,103,2,1);
```
Task: Return product names that never appear in wu5_order_items.

Expected output
```
name
Mug
```

Solution
```sql
SELECT p.name
FROM wu5_products p
LEFT JOIN wu5_order_items oi ON oi.product_id = p.product_id
WHERE oi.order_item_id IS NULL
ORDER BY p.name;
```
