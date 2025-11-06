# Real-World Project: Weekly Ops Summary Reports (45–60 min)

## 📋 Before You Start

### Learning Objectives
By completing this real-world project, you will:
- Apply aggregates and GROUP BY to create business summary reports
- Practice using HAVING to filter aggregated results
- Work with realistic reporting scenarios (sales, inventory, customer metrics)
- Build multi-level summaries (by category, by date, by region)
- Develop analytical reporting skills

### Project Approach
**Time Allocation (45-60 minutes):**
- 📖 **10 min**: Read all deliverables, understand reporting goals
- 🔧 **5 min**: Run setup, explore data with sample aggregates
- 💻 **30-35 min**: Build reports one at a time, verify totals
- ✅ **5-10 min**: Review solutions, check for alternative approaches

**Work Process:**
1. **Identify grouping columns** (what to GROUP BY)
2. **Choose aggregate functions** (COUNT, SUM, AVG, MIN, MAX)
3. **Apply filters correctly** (WHERE before GROUP BY, HAVING after)
4. **Order results meaningfully** (highest sales first, etc.)
5. **Verify totals manually** for sample rows

**Success Tips:**
- ✅ Use WHERE to filter rows before aggregation
- ✅ Use HAVING to filter groups after aggregation
- ✅ All non-aggregated columns MUST be in GROUP BY
- ✅ Test with COUNT(*) first to verify grouping
- ✅ Check for NULLs in aggregate results

**Beginner Tip:** This project simulates a real reporting task! Work through deliverables systematically. Verify row counts and totals make sense. Test edge cases (NULLs, empty groups). Real analysts iterate—so try, check, refine. The rubric helps you self-assess. Take breaks if needed!

---

## Project Overview

Company background
- EduMart is an online retailer for education supplies.
- Operations and Marketing teams need weekly summaries: orders by status, revenue by category, and monthly trends.

Business problem
- Build SELECT queries using aggregates and grouping to produce clean summaries. Handle NULLs, duplicates, and date bucketing.

Database (5 tables, 40+ rows total)
```sql
-- Customers
DROP TABLE IF EXISTS rwp4_customers;
CREATE TABLE rwp4_customers (
  customer_id INT PRIMARY KEY,
  full_name VARCHAR(60),
  city VARCHAR(40)
);
INSERT INTO rwp4_customers VALUES
(1,'Ava Brown','Austin'),(2,'Noah Smith','Dallas'),(3,'Mia Chen','Austin'),(4,'Leo Park',NULL),
(5,'Zoe Li','Seattle'),(6,'Sam Wu','Seattle'),(7,'Kim Lee','Miami'),(8,'Ivy Ray','Dallas');

-- Products
DROP TABLE IF EXISTS rwp4_products;
CREATE TABLE rwp4_products (
  product_id INT PRIMARY KEY,
  name VARCHAR(60),
  category VARCHAR(30),
  price DECIMAL(7,2),
  active TINYINT(1)
);
INSERT INTO rwp4_products VALUES
(1,'Notebook','stationery',4.99,1),(2,'Desk Lamp','home',12.00,1),(3,'Yoga Mat','fitness',24.50,1),
(4,'Coffee Mug','kitchen',7.99,1),(5,'Pen Set','stationery',3.75,1),(6,'Throw Pillow','home',18.00,1),
(7,'Water Bottle','fitness',15.00,0),(8,'Candle','home',9.99,1),(9,'Laptop Stand','electronics',29.99,1),
(10,'Cable Organizer','accessories',3.49,1), (11,'Screen Cleaner','accessories',5.49,1), (12,'Binder','stationery',2.99,1);

-- Orders
DROP TABLE IF EXISTS rwp4_orders;
CREATE TABLE rwp4_orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  status VARCHAR(20)
);
INSERT INTO rwp4_orders VALUES
(101,1,'2025-03-01','shipped'),(102,2,'2025-03-02','shipped'),(103,3,'2025-03-02','processing'),
(104,3,'2025-03-03','cancelled'),(105,5,'2025-03-05','processing'),(106,6,'2025-03-06','shipped'),
(107,7,'2025-03-07','processing'),(108,8,'2025-03-08','processing'),(109,1,'2025-04-01','shipped'),
(110,2,'2025-04-03','processing'),(111,3,'2025-04-15','shipped'),(112,5,'2025-04-20','cancelled');

-- Order items
DROP TABLE IF EXISTS rwp4_order_items;
CREATE TABLE rwp4_order_items (
  order_item_id INT PRIMARY KEY,
  order_id INT,
  product_id INT,
  qty INT
);
INSERT INTO rwp4_order_items VALUES
(1,101,1,2),(2,101,4,1),(3,102,2,1),(4,102,5,3),(5,103,9,1),(6,104,3,1),
(7,105,10,2),(8,106,6,2),(9,106,8,1),(10,107,7,1),(11,108,11,2),(12,109,1,1),
(13,109,5,2),(14,109,4,1),(15,110,2,1),(16,110,9,1),(17,111,12,4),(18,112,3,1);

-- Categories (for display)
DROP TABLE IF EXISTS rwp4_categories;
CREATE TABLE rwp4_categories (
  code VARCHAR(30) PRIMARY KEY,
  display_name VARCHAR(40)
);
INSERT INTO rwp4_categories VALUES
('stationery','Stationery'),('home','Home & Decor'),('fitness','Fitness'),('kitchen','Kitchen'),
('electronics','Electronics'),('accessories','Accessories');
```

Deliverables
1) Orders by status (last 30 days window): `status`, `COUNT(*)` as `orders_cnt`, sorted by count desc.
   - Acceptance: Use a date window relative to latest order date for demo: `order_date >= DATE_SUB((SELECT MAX(order_date) FROM rwp4_orders), INTERVAL 30 DAY)`.
2) Product summary by category: For products table only, show `category`, count of active products as `product_cnt`, and average price as `avg_price`; sort by avg_price desc.
   - Acceptance: Include only non-discontinued products; handle NULL prices safely.
3) Monthly order trend: `month_label`, `orders_cnt`, and `sample_ids` (up to 3) via `GROUP_CONCAT`, sorted by month.
   - Acceptance: One row per month with proper ordering.

**Note:** Multi-table analysis with JOINs will be covered in Module 5 (next module). This project focuses on single-table and subquery aggregations.

Bonus objectives
- Distinct customers per city: `city_label`, `COUNT(DISTINCT customer_id)`.
- Top category by items sold: limit 1.

Evaluation rubric (0–3 each)
- Correctness (filters, math)
- Readability (aliases, comments)
- Robustness (NULL handling)
- Performance (prefiltering, minimal columns)

Model solutions

1) Orders by status (last 30 days)
```sql
SELECT status, COUNT(*) AS orders_cnt
FROM rwp4_orders
WHERE order_date >= DATE_SUB((SELECT MAX(order_date) FROM rwp4_orders), INTERVAL 30 DAY)
GROUP BY status
ORDER BY orders_cnt DESC, status;
```

2) Product summary by category
```sql
SELECT category,
       COUNT(*) AS product_cnt,
       ROUND(AVG(COALESCE(price, 0)), 2) AS avg_price
FROM rwp4_products
WHERE active = 1
GROUP BY category
ORDER BY avg_price DESC, category;
```

3) Monthly order trend with sample IDs
```sql
SELECT 
  DATE_FORMAT(order_date, '%M %Y') AS month_label,
  COUNT(*) AS orders_cnt,
  SUBSTRING_INDEX(GROUP_CONCAT(order_id ORDER BY order_id SEPARATOR ', '), ', ', 3) AS sample_ids,
  MIN(order_date) AS month_sort
FROM rwp4_orders
GROUP BY DATE_FORMAT(order_date, '%M %Y')
ORDER BY month_sort;
```

Performance notes
- Prefilter early in WHERE to shrink groups.
- Index typical filters and joins: `(order_date)`, `(product_id)`, and foreign keys.
- Avoid heavy expressions in join predicates; compute once and reuse via views if needed.

Encouragement: Great summaries come from clean inputs and focused questions—validate each metric.
