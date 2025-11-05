# Guided Step-by-Step — Subqueries & CTEs (15–20 min each)

Three guided activities to practice correlated subqueries, derived tables for top-N per group, and a non-recursive CTE pipeline. Each includes setup, checkpoints, common mistakes, full solutions with comments, and discussion questions.

## 📋 Before You Start

### Learning Objectives
Through these guided activities, you will:
- Write correlated subqueries that reference the outer query
- Use derived tables (subqueries in FROM) for complex calculations
- Build multi-step queries with CTEs for readability
- Implement top-N per group patterns
- Understand when to use subqueries vs joins

### Critical Subquery Concepts
**Correlated Subqueries:**
- Inner query references columns from outer query
- Executes once per outer row (can be slower)
- Example: Latest order date per customer
- Pattern: `SELECT (SELECT MAX(...) FROM table2 WHERE table2.id = table1.id)`

**Derived Tables:**
- Subquery in FROM clause creates a temporary result set
- Must have an alias
- Good for pre-aggregation before joining
- Example: `FROM (SELECT category, SUM(sales) ... GROUP BY category) AS t`

**CTEs (WITH clause):**
- Named temporary result sets
- More readable than nested subqueries
- Can reference multiple CTEs in sequence
- Great for multi-step transformations

### Execution Process
1. **Run complete setup** for the activity
2. **Test subqueries independently** before embedding them
3. **Follow each step** and verify checkpoints
4. **Review common mistakes** specific to subqueries
5. **Study the solution** with detailed annotations
6. **Answer discussion questions** about performance and alternatives

**Performance Note:** Correlated subqueries can be slow on large tables. Consider JOINs or window functions as alternatives when performance matters.

**Beginner Tip:** Subqueries and CTEs make complex queries manageable. Build them piece by piece—test the inner query first, then wrap it. CTEs especially help you think clearly about multi-step logic!

---

## Activity 1: Latest Order Per Customer (Correlated Subquery)
Business context: Support needs the most recent order date per customer to prioritize callbacks.

Database setup
```sql
DROP TABLE IF EXISTS gs6_customers;
CREATE TABLE gs6_customers (
  customer_id INT PRIMARY KEY,
  full_name VARCHAR(60)
);
INSERT INTO gs6_customers VALUES
(1,'Ava Brown'),(2,'Noah Smith'),(3,'Mia Chen'),(4,'Leo Park');

DROP TABLE IF EXISTS gs6_orders;
CREATE TABLE gs6_orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE
);
INSERT INTO gs6_orders VALUES
(1001,1,'2025-02-01'),(1002,1,'2025-03-05'),(1003,2,'2025-03-01'),(1004,3,'2024-12-30');
```
Final goal: One row per customer with `latest_order_date` (NULL if none).

Steps with checkpoints
1) Select all customers; confirm 4 rows.
2) Add a correlated subquery in SELECT to fetch MAX(order_date) for each customer.
3) Alias the column as latest_order_date and order by customer name.
4) Verify that customers without orders show NULL.

Common mistakes
- Forgetting the correlation (WHERE o.customer_id = c.customer_id) causing the same MAX for all rows.
- Using WHERE on orders that turns NULL into an empty result; keep it in the subquery.

Solution
```sql
SELECT c.full_name,
  (
    SELECT MAX(o.order_date)
    FROM gs6_orders o
    WHERE o.customer_id = c.customer_id
  ) AS latest_order_date
FROM gs6_customers c
ORDER BY c.full_name;
```

**Detailed Explanation:**
This is a **correlated subquery** because the inner query references `c.customer_id` from the outer query. Here's what happens:

1. **For each customer** (outer query loops through all 4 customers)
2. **The subquery executes** with that customer's ID
3. **MAX(order_date)** finds the most recent order for THAT specific customer
4. **If no orders exist**, MAX returns NULL (see Leo with NULL)

**Execution Flow:**
```
Customer: Ava (ID=1)
  → Subquery: MAX(order_date) WHERE customer_id=1
  → Found: 2025-03-05 ✓

Customer: Leo (ID=4)  
  → Subquery: MAX(order_date) WHERE customer_id=4
  → Found: NULL (no orders) ✗

Customer: Mia (ID=3)
  → Subquery: MAX(order_date) WHERE customer_id=3
  → Found: 2024-12-30 ✓

Customer: Noah (ID=2)
  → Subquery: MAX(order_date) WHERE customer_id=2
  → Found: 2025-03-01 ✓
```

Discussion
- **When does a correlated subquery outperform a JOIN + GROUP BY?** 
  - When you need just ONE value per row and the subquery can use an index
  - When most outer rows won't have matches (subquery stops early)
  - Small outer table × large inner table
  
- **When is JOIN + GROUP BY better?**
  - When you need MULTIPLE aggregates (COUNT, SUM, AVG together)
  - Large result sets where batch processing is more efficient
  - Modern optimizers often convert correlated subqueries to joins anyway!

- **How would you filter to only customers with a 2025 latest order?**
  ```sql
  SELECT c.full_name,
    (SELECT MAX(o.order_date) FROM gs6_orders o 
     WHERE o.customer_id = c.customer_id) AS latest_order_date
  FROM gs6_customers c
  WHERE (SELECT MAX(o.order_date) FROM gs6_orders o 
         WHERE o.customer_id = c.customer_id) >= '2025-01-01'
  ORDER BY c.full_name;
  ```
  Note: The subquery runs twice! With a CTE or JOIN, it would run once.

---

## Activity 2: Top Product per Category (Derived Table + Window)
Business context: Merchandising wants the best-selling product by revenue within each category.

Database setup
```sql
DROP TABLE IF EXISTS gs6_products;
CREATE TABLE gs6_products (
  product_id INT PRIMARY KEY,
  category VARCHAR(40),
  name VARCHAR(60),
  price DECIMAL(7,2)
);
INSERT INTO gs6_products VALUES
(1,'stationery','Notebook',4.99),(2,'stationery','Pen',2.50),
(3,'home','Lamp',12.00),(4,'home','LED Strip',22.00),
(5,'kitchen','Mug',7.99);

DROP TABLE IF EXISTS gs6_order_items;
CREATE TABLE gs6_order_items (
  order_item_id INT PRIMARY KEY,
  product_id INT,
  qty INT
);
INSERT INTO gs6_order_items VALUES
(1,1,2),(2,2,3),(3,3,1),(4,4,1),(5,5,2),(6,1,1),(7,4,2);
```
Final goal: For each category, return the single top product by revenue (qty*price). Include ties using DENSE_RANK.

Steps with checkpoints
1) In a derived table t, join items→products and compute revenue per product.
2) In an outer query, apply a window function DENSE_RANK() over (PARTITION BY category ORDER BY revenue DESC).
3) Filter to rnk = 1 and order by category.

Common mistakes
- Summing price without multiplying qty.
- Ranking before aggregating per product (row-level ranking is wrong).

Solution
```sql
SELECT category, name AS product, revenue
FROM (
  SELECT p.category, p.name,
         SUM(oi.qty * p.price) AS revenue,
         DENSE_RANK() OVER (PARTITION BY p.category ORDER BY SUM(oi.qty * p.price) DESC) AS rnk
  FROM gs6_order_items oi
  JOIN gs6_products p ON p.product_id = oi.product_id
  GROUP BY p.category, p.name
) t
WHERE rnk = 1
ORDER BY category, product;
```

**Detailed Explanation:**
This solution combines **aggregation**, **window functions**, and **filtering** in a multi-step process:

**Step 1: Inner Query (Derived Table)**
```sql
-- Join items to products and calculate revenue per product
SELECT p.category, p.name,
       SUM(oi.qty * p.price) AS revenue,  ← Total revenue per product
       DENSE_RANK() OVER (                ← Rank within each category
         PARTITION BY p.category           ← Separate rankings per category
         ORDER BY SUM(...) DESC            ← Highest revenue = rank 1
       ) AS rnk
FROM gs6_order_items oi
JOIN gs6_products p ON p.product_id = oi.product_id
GROUP BY p.category, p.name              ← One row per product
```

**What This Produces:**
| category   | name      | revenue | rnk |
|------------|-----------|---------|-----|
| home       | LED Strip | 66.00   | 1   |
| home       | Lamp      | 12.00   | 2   |
| kitchen    | Mug       | 15.98   | 1   |
| stationery | Notebook  | 19.96   | 1   |
| stationery | Pen       | 7.50    | 2   |

**Step 2: Outer Query (Filter)**
```sql
SELECT category, name, revenue
FROM (...) t
WHERE rnk = 1  ← Keep only the top product per category
```

**Why DENSE_RANK vs ROW_NUMBER?**
- `DENSE_RANK()`: Ties get the same rank (1,1,2,3...)
  - Use when you want ALL winners if there's a tie
- `ROW_NUMBER()`: No ties, arbitrary ordering (1,2,3,4...)
  - Use when you want EXACTLY one winner per group

**Example of Tie Handling:**
If two products had $20 revenue in the same category:
```
DENSE_RANK: Product A (rank 1), Product B (rank 1) → Both appear!
ROW_NUMBER: Product A (rank 1), Product B (rank 2) → Only A appears
```

**Execution Order (Inside → Outside):**
1. JOIN items to products
2. GROUP BY to sum revenue per product
3. DENSE_RANK() assigns ranks within each category
4. WHERE filters to rank 1 only
5. ORDER BY sorts the final results

Discussion
- **When should you pre-aggregate in a derived table before ranking?**
  - ALWAYS when working with detail-level data (order items)
  - Prevents ranking individual line items (which would be wrong!)
  - GROUP BY first → then rank the aggregated results
  
- **How would you return the top 2 products per category?**
  ```sql
  -- Just change the WHERE clause:
  WHERE rnk <= 2  ← Top 2 instead of top 1
  ```

**Alternative: Using CTE (More Readable)**
```sql
WITH product_revenue AS (
  SELECT p.category, p.name,
         SUM(oi.qty * p.price) AS revenue
  FROM gs6_order_items oi
  JOIN gs6_products p ON p.product_id = oi.product_id
  GROUP BY p.category, p.name
),
ranked_products AS (
  SELECT *,
         DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rnk
  FROM product_revenue
)
SELECT category, name, revenue
FROM ranked_products
WHERE rnk = 1;
```
This CTE version breaks down the logic into clearer steps!

---

## Activity 3: KPI Pipeline with CTE (Non-recursive)
Business context: Analytics wants a clean pipeline to compute revenue per active customer for March 2025.

Database setup
```sql
DROP TABLE IF EXISTS gs6_users;
CREATE TABLE gs6_users (user_id INT PRIMARY KEY, name VARCHAR(60), active TINYINT);
INSERT INTO gs6_users VALUES (1,'Ava',1),(2,'Noah',1),(3,'Mia',0),(4,'Leo',1);

DROP TABLE IF EXISTS gs6_orders2;
CREATE TABLE gs6_orders2 (order_id INT PRIMARY KEY, user_id INT, order_date DATE);
INSERT INTO gs6_orders2 VALUES
(2001,1,'2025-03-01'),(2002,1,'2025-03-10'),(2003,2,'2025-02-28'),(2004,4,'2025-03-05');

DROP TABLE IF EXISTS gs6_order_items2;
CREATE TABLE gs6_order_items2 (order_item_id INT PRIMARY KEY, order_id INT, price DECIMAL(7,2), qty INT);
INSERT INTO gs6_order_items2 VALUES
(1,2001,4.99,2),(2,2001,7.99,1),(3,2002,2.50,3),(4,2004,12.00,1);
```
Final goal: For active users, return March-2025 revenue per user, including users with 0 revenue.

Steps with checkpoints
1) CTE active_users: select active=1 users.
2) CTE march_orders: select orders in '2025-03-01' to '2025-03-31'.
3) CTE order_revenue: per order, sum qty*price.
4) Final select: left join active_users to (march_orders→order_revenue) and sum per user.

Common mistakes
- Filtering March after joining (ok but less clear); stage early in CTE.
- Forgetting to include users with 0 revenue (use LEFT JOIN + COALESCE).

Solution
```sql
WITH active_users AS (
  SELECT user_id, name FROM gs6_users WHERE active = 1
),
march_orders AS (
  SELECT order_id, user_id FROM gs6_orders2
  WHERE order_date >= '2025-03-01' AND order_date < '2025-04-01'
),
order_revenue AS (
  SELECT oi.order_id, SUM(oi.qty * oi.price) AS order_total
  FROM gs6_order_items2 oi
  GROUP BY oi.order_id
)
SELECT au.name, COALESCE(SUM(orv.order_total),0) AS march_revenue
FROM active_users au
LEFT JOIN march_orders mo ON mo.user_id = au.user_id
LEFT JOIN order_revenue orv ON orv.order_id = mo.order_id
GROUP BY au.name
ORDER BY march_revenue DESC, au.name;
```

**Detailed Explanation:**
This query uses **multiple CTEs** to create a clean data pipeline. Each CTE handles one logical step!

**CTE 1: active_users**
```sql
-- Filter to only active users upfront
SELECT user_id, name FROM gs6_users WHERE active = 1
-- Result: (1,'Ava'), (2,'Noah'), (4,'Leo')  ← Mia excluded (inactive)
```

**CTE 2: march_orders**
```sql
-- Get only March 2025 orders
WHERE order_date >= '2025-03-01' AND order_date < '2025-04-01'
-- Result: (2001,1), (2002,1), (2004,4)  ← Noah's order excluded (Feb 28)
```

**CTE 3: order_revenue**
```sql
-- Calculate total for each order (sum up all items in that order)
SUM(qty * price) ... GROUP BY order_id
-- Result: (2001, 17.97), (2002, 7.50), (2004, 12.00)
```

**Main Query: Combine Everything**
```sql
FROM active_users au              ← Start with ALL active users
LEFT JOIN march_orders mo ...     ← Add their March orders (NULL if none)
LEFT JOIN order_revenue orv ...   ← Add revenue for those orders
GROUP BY au.name                  ← Sum revenue per user
```

**Why Multiple LEFT JOINs?**
- **First LEFT JOIN**: Keeps users with NO March orders (Leo gets included with NULL)
- **Second LEFT JOIN**: Connects orders to their revenue
- **COALESCE**: Converts NULL to 0 for users with no revenue

**Data Flow Example - Following Ava:**
1. **CTE 1**: Ava is active → included ✓
2. **CTE 2**: Ava has orders 2001, 2002 in March → both included ✓
3. **CTE 3**: Order 2001 = $17.97, Order 2002 = $7.50
4. **Main query**: SUM(17.97 + 7.50) = $25.47 for Ava

**Data Flow Example - Following Leo:**
1. **CTE 1**: Leo is active → included ✓
2. **CTE 2**: Leo has order 2004 in March → included ✓
3. **CTE 3**: Order 2004 = $12.00
4. **Main query**: SUM(12.00) = $12.00 for Leo

**Data Flow Example - Following Mia:**
1. **CTE 1**: Mia is inactive (active=0) → EXCLUDED completely ✗
2. Never appears in results

**Pipeline Visualization:**
```
Step 1: [All Users] → Filter → [Active Users Only]
Step 2: [All Orders] → Filter → [March Orders Only]
Step 3: [Order Items] → Aggregate → [Revenue per Order]
Step 4: Join all together → Sum per user → Final results
```

Discussion
- **What are the trade-offs of staging steps in CTEs vs nesting subqueries?**
  
  **CTEs (Better!):**
  ✅ Easy to read and understand (top-to-bottom flow)
  ✅ Can test each step independently
  ✅ Easy to modify one step without touching others
  ✅ Reusable within the same query
  ✅ Self-documenting with meaningful names
  
  **Nested Subqueries (Harder):**
  ❌ Inside-out reading (counterintuitive)
  ❌ Hard to debug (can't easily test intermediate steps)
  ❌ Difficult to maintain (changing one part affects everything)
  ❌ No reusability
  
  Example of nested nightmare:
  ```sql
  SELECT name, COALESCE(SUM(total),0)
  FROM (SELECT ... FROM (SELECT ... FROM (SELECT ... ))) ← Hard to read!
  ```

- **How would you extend this to compute average order value per active user for March?**
  ```sql
  -- Add this to the final SELECT:
  SELECT au.name, 
         COALESCE(SUM(orv.order_total),0) AS march_revenue,
         COALESCE(AVG(orv.order_total),0) AS avg_order_value,
         COUNT(mo.order_id) AS order_count
  FROM active_users au
  LEFT JOIN march_orders mo ON mo.user_id = au.user_id
  LEFT JOIN order_revenue orv ON orv.order_id = mo.order_id
  GROUP BY au.name;
  ```
  
**Pro Tip:** When building complex queries, always start with CTEs! Write and test each CTE separately, then combine them in the main query. This makes debugging SO much easier!
