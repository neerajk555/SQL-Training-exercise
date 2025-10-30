# Guided Step-by-Step — Subqueries & CTEs (15–20 min each)

Three guided activities to practice correlated subqueries, derived tables for top-N per group, and a non-recursive CTE pipeline. Each includes setup, checkpoints, common mistakes, full solutions with comments, and discussion questions.

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

Discussion
- When does a correlated subquery outperform a JOIN + GROUP BY? When is the reverse true?
- How would you filter to only customers with a 2025 latest order using the correlated value?

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

Discussion
- When should you pre-aggregate in a derived table before ranking?
- How would you return the top 2 products per category?

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

Discussion
- What are the trade-offs of staging steps in CTEs vs nesting subqueries?
- How would you extend this to compute average order value per active user for March?
