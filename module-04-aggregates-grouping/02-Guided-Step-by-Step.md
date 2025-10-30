# Guided Step-by-Step (Aggregates & Grouping)

Three 15–20 minute activities to practice GROUP BY, HAVING, and date bucketing.

---

## Activity 1: Category Revenue Snapshot
- Business context: Merchandising wants total and average price per category for active products only.
- Database setup
```sql
DROP TABLE IF EXISTS gss4_products;
CREATE TABLE gss4_products (
  product_id INT PRIMARY KEY,
  category VARCHAR(30),
  price DECIMAL(7,2),
  active TINYINT(1)
);
INSERT INTO gss4_products VALUES
(1,'home',12.00,1),(2,'home',18.00,1),(3,'stationery',4.99,1),
(4,'stationery',3.75,0),(5,'fitness',24.50,1),(6,'fitness',15.00,0);
```
- Final goal: For active products only, return `category`, `COUNT(*)` as `cnt`, `SUM(price)` as `total_price`, and `AVG(price)` as `avg_price`, ordered by `total_price` desc.

Step-by-step with checkpoints
1) Filter to active=1 in WHERE.
   - Checkpoint: Only active rows remain.
2) Group by `category` and compute COUNT, SUM, AVG.
   - Checkpoint: One row per category.
3) Round averages to 2 decimals for readability.
   - Checkpoint: `avg_price` shows two decimals.
4) Order by `total_price` desc.
   - Checkpoint: Highest total first.

Common mistakes
- Using HAVING instead of WHERE for non-aggregated filter `active=1`.
- Forgetting to round AVG.

Complete solution (with comments)
```sql
SELECT 
  category,
  COUNT(*) AS cnt,
  SUM(price) AS total_price,
  ROUND(AVG(price),2) AS avg_price
FROM gss4_products
WHERE active = 1
GROUP BY category
ORDER BY total_price DESC;
```

Discussion questions
- Why is filtering early in WHERE better for performance?
- When might inactive rows still be included in totals?

---

## Activity 2: Orders by Status With Threshold
- Business context: Ops wants to see statuses that have at least 2 orders.
- Database setup
```sql
DROP TABLE IF EXISTS gss4_orders;
CREATE TABLE gss4_orders (
  order_id INT PRIMARY KEY,
  status VARCHAR(20)
);
INSERT INTO gss4_orders VALUES
(101,'processing'),(102,'shipped'),(103,'processing'),(104,'cancelled'),(105,'shipped');
```
- Final goal: Return `status`, `COUNT(*)` as `cnt` but only include rows where cnt >= 2.

Step-by-step with checkpoints
1) Group by `status` and count rows.
   - Checkpoint: One row per status.
2) Apply `HAVING COUNT(*) >= 2`.
   - Checkpoint: Only groups meeting threshold remain.
3) Sort by `cnt` desc then `status`.

Common mistakes
- Using WHERE COUNT(*) >= 2 (invalid; WHERE runs before grouping).
- Selecting non-grouped columns.

Complete solution (with comments)
```sql
SELECT status, COUNT(*) AS cnt
FROM gss4_orders
GROUP BY status
HAVING COUNT(*) >= 2
ORDER BY cnt DESC, status ASC;
```

Discussion questions
- When do you use HAVING vs WHERE?
- What happens if two statuses tie on counts?

---

## Activity 3: Monthly Orders with GROUP_CONCAT
- Business context: Marketing wants a month-view count of orders and a sample list of order IDs for reporting.
- Database setup
```sql
DROP TABLE IF EXISTS gss4_orders_dates;
CREATE TABLE gss4_orders_dates (
  order_id INT PRIMARY KEY,
  order_date DATE,
  status VARCHAR(20)
);
INSERT INTO gss4_orders_dates VALUES
(201,'2025-03-01','shipped'),(202,'2025-03-02','processing'),(203,'2025-03-15','processing'),
(204,'2025-04-01','shipped'),(205,'2025-04-03','cancelled'),(206,'2025-04-15','shipped');
```
- Final goal: Return `month_label` (e.g., 'March 2025'), `orders_cnt`, and a comma-separated `sample_ids` using `GROUP_CONCAT` of up to 3 order IDs per month.

Step-by-step with checkpoints
1) Build `month_label` using `DATE_FORMAT(order_date, '%M %Y')`.
   - Checkpoint: Labels like 'March 2025'.
2) Group by `month_label` and count orders.
   - Checkpoint: One row per month.
3) Use `GROUP_CONCAT(order_id ORDER BY order_id SEPARATOR ', ')` and limit to 3 items with `SUBSTRING_INDEX`.
   - Checkpoint: At most 3 IDs listed.
4) Order results by the actual month (use `MIN(order_date)` for ordering).

Common mistakes
- Ordering by `month_label` lexicographically.
- Not limiting GROUP_CONCAT length when needed.

Complete solution (with comments)
```sql
SELECT 
  DATE_FORMAT(order_date, '%M %Y') AS month_label,
  COUNT(*) AS orders_cnt,
  SUBSTRING_INDEX(GROUP_CONCAT(order_id ORDER BY order_id SEPARATOR ', '), ', ', 3) AS sample_ids,
  MIN(order_date) AS month_sort
FROM gss4_orders_dates
GROUP BY DATE_FORMAT(order_date, '%M %Y')
ORDER BY month_sort;
```

Discussion questions
- What are pros/cons of using GROUP_CONCAT in exports?
- How would you handle very large groups (truncate, limit, or separate query)?
