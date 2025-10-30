# Independent Practice (Aggregates & Grouping)

Seven exercises: 3 Easy 🟢, 3 Medium 🟡, 1 Challenge 🔴. Each includes schema+data, requirements, example output, success criteria, 3-level hints, and detailed solutions with alternatives.

**Beginner Tip:** Work through exercises in order—they build on each other. If you get an unexpected count or sum, double-check your WHERE filter and GROUP BY columns. Use the hints when needed; they're designed to guide without giving everything away!

---

## Easy 🟢 (1): Items per Category (10–12 min)
Scenario: Count items in each category.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip4_products;
CREATE TABLE ip4_products (
  id INT PRIMARY KEY,
  name VARCHAR(60),
  category VARCHAR(30)
);
INSERT INTO ip4_products VALUES
(1,'Notebook','stationery'),(2,'Lamp','home'),(3,'Mug','kitchen'),
(4,'Pen','stationery'),(5,'Pillow','home'),(6,'Cable','electronics');
```
Requirements
- Return `category`, `COUNT(*)` as `item_count` sorted by `item_count` desc.

Example output
```
category   | item_count
-----------+-----------
home       | 2
stationery | 2
electronics| 1
kitchen    | 1
```
Success criteria
- One row per category; correct counts, sorted by count desc then category.

Hints
1) GROUP BY category.
2) ORDER BY 2 DESC, 1.
3) COUNT(*) counts rows regardless of NULLs.

Solution
```sql
SELECT category, COUNT(*) AS item_count
FROM ip4_products
GROUP BY category
ORDER BY item_count DESC, category;
```

---

## Easy 🟢 (2): Average Price With Rounding (10–12 min)
Scenario: Compute average price per department.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip4_prices;
CREATE TABLE ip4_prices (
  id INT PRIMARY KEY,
  dept VARCHAR(30),
  price DECIMAL(7,2)
);
INSERT INTO ip4_prices VALUES
(1,'A',10.00),(2,'A',15.00),(3,'B',3.75),(4,'B',4.99),(5,'B',NULL);
```
Requirements
- Return `dept`, `ROUND(AVG(price),2)` as `avg_price`.
- Sort by `dept`.

Example output
```
dept | avg_price
-----+----------
A    | 12.50
B    | 4.37
```
Success criteria
- AVG ignores NULLs; rounded 2 dp.

Hints
1) AVG ignores NULL by default.
2) Use ROUND for display.

Solution
```sql
SELECT dept, ROUND(AVG(price),2) AS avg_price
FROM ip4_prices
GROUP BY dept
ORDER BY dept;
```

---

## Easy 🟢 (3): Count Distinct Cities (10–12 min)
Scenario: Count unique cities, case-insensitive.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip4_cities;
CREATE TABLE ip4_cities (
  id INT PRIMARY KEY,
  city VARCHAR(40)
);
INSERT INTO ip4_cities VALUES
(1,'Austin'),(2,'austin'),(3,'Dallas'),(4,NULL),(5,'Dallas');
```
Requirements
- Return `COUNT(DISTINCT LOWER(city))` as `uniq_cities`, exclude NULL.

Example output
```
uniq_cities
-----------
2
```
Success criteria
- Count equals 2 (austin, dallas).

Hints
1) Filter `city IS NOT NULL` in WHERE.
2) Apply LOWER inside DISTINCT.

Solution
```sql
SELECT COUNT(DISTINCT LOWER(city)) AS uniq_cities
FROM ip4_cities
WHERE city IS NOT NULL;
```

---

## Medium 🟡 (1): Orders Per Day (12–15 min)
Scenario: Show count of orders per date.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip4_orders;
CREATE TABLE ip4_orders (
  order_id INT PRIMARY KEY,
  order_date DATE,
  status VARCHAR(20)
);
INSERT INTO ip4_orders VALUES
(101,'2025-03-01','shipped'),(102,'2025-03-01','processing'),(103,'2025-03-02','cancelled'),
(104,'2025-03-02','shipped'),(105,'2025-03-03','processing');
```
Requirements
- Return `order_date`, `COUNT(*)` as `orders_cnt`, sorted by date.

Example output
```
order_date | orders_cnt
-----------+-----------
2025-03-01 | 2
2025-03-02 | 2
2025-03-03 | 1
```
Success criteria
- One row per date; accurate counts.

Hints
1) GROUP BY order_date.
2) ORDER BY order_date asc.

Solution
```sql
SELECT order_date, COUNT(*) AS orders_cnt
FROM ip4_orders
GROUP BY order_date
ORDER BY order_date;
```

---

## Medium 🟡 (2): HAVING With SUM (12–15 min)
Scenario: Find donors whose total donations exceed $20.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip4_donations;
CREATE TABLE ip4_donations (
  donor VARCHAR(40),
  amount DECIMAL(8,2)
);
INSERT INTO ip4_donations VALUES
('Ava', 10.00),('Ben', 15.50),('Ava', 15.50),('Ben', NULL);
```
Requirements
- Return `donor`, `SUM(amount)` as `total` where total > 20.

Example output
```
donor | total
------+------
Ava   | 25.50
```
Success criteria
- SUM ignores NULL; HAVING filters on aggregated total.

Hints
1) Use HAVING to filter on SUM.
2) Don’t COALESCE inside SUM unless needed.

Solution
```sql
SELECT donor, SUM(amount) AS total
FROM ip4_donations
GROUP BY donor
HAVING SUM(amount) > 20
ORDER BY total DESC;
```

---

## Medium 🟡 (3): Top Status by Count (15–18 min)
Scenario: Find which status has the most orders.

Schema and sample data: reuse `ip4_orders`.

Requirements
- Return `status`, `COUNT(*)` as `cnt` ordered desc; limit 1.

Example output
```
status     | cnt
-----------+----
processing | 2
```
Success criteria
- Highest count only.

Hints
1) ORDER BY cnt desc.
2) LIMIT 1.

Solution
```sql
SELECT status, COUNT(*) AS cnt
FROM ip4_orders
GROUP BY status
ORDER BY cnt DESC, status
LIMIT 1;
```

---

## Challenge 🔴: Category Performance Report (20–25 min)
Scenario: Build a comprehensive summary with multiple metrics and filters.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip4_sales;
CREATE TABLE ip4_sales (
  sale_id INT PRIMARY KEY,
  category VARCHAR(30),
  qty INT,
  price DECIMAL(7,2),
  status VARCHAR(20)
);
INSERT INTO ip4_sales VALUES
(1,'home',2,12.00,'shipped'),(2,'home',1,18.00,'cancelled'),
(3,'stationery',3,4.99,'shipped'),(4,'stationery',2,3.75,'shipped'),
(5,'fitness',NULL,24.50,'processing'),(6,'fitness',1,15.00,'shipped');
```
Requirements
- Include only status in ('shipped','processing').
- For each category, compute: `order_cnt`, `items_sold = SUM(qty)` (NULL-safe), `revenue = SUM(qty*price)` (guard qty), `avg_order_value = AVG(qty*price)` ignoring NULL, `max_line_value = MAX(qty*price)`.
- Only include categories with `items_sold >= 3` using HAVING.
- Sort by `revenue` desc.

Example output
```
category   | order_cnt | items_sold | revenue | avg_order_value | max_line_value
-----------+-----------+------------+---------+-----------------+----------------
home       | 2         | 3          | 42.00   | 21.00           | 24.00
stationery | 2         | 5          | 23.47   | 11.74           | 14.97
```
Success criteria
- Correct NULL handling; HAVING filter applied; accurate math.

Hints
1) Prefilter status in WHERE.
2) Use SUM(COALESCE(qty,0)) for items; for revenue, multiply with COALESCE.
3) HAVING applies to aggregated results.

Solution
```sql
SELECT 
  category,
  COUNT(*) AS order_cnt,
  SUM(COALESCE(qty,0)) AS items_sold,
  SUM(COALESCE(qty,0) * price) AS revenue,
  AVG(CASE WHEN qty IS NULL THEN NULL ELSE qty*price END) AS avg_order_value,
  MAX(CASE WHEN qty IS NULL THEN NULL ELSE qty*price END) AS max_line_value
FROM ip4_sales
WHERE status IN ('shipped','processing')
GROUP BY category
HAVING SUM(COALESCE(qty,0)) >= 3
ORDER BY revenue DESC;
```

Performance note: For very large tables, pre-aggregate or use covering indexes on `(status, category)`; avoid expressions in WHERE that prevent index use.
