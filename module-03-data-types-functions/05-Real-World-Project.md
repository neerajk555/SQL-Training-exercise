# Real-World Project: Clean Data Export Suite (45–60 min)

Company background
- CareCart is a small retailer expanding its online presence.
- Operations needs clean exports for email campaigns, product listings, and order summaries.

Business problem
- Data arrives with mixed types (strings for numbers, inconsistent casing/spaces, dates in various formats). Build SELECT queries using MySQL functions to normalize and export without changing source tables.

Database (5 tables, 40+ rows total)
```sql
-- Customers
DROP TABLE IF EXISTS rwp3_customers;
CREATE TABLE rwp3_customers (
  customer_id INT PRIMARY KEY,
  first_name VARCHAR(40),
  last_name VARCHAR(40),
  email VARCHAR(80),
  city VARCHAR(40),
  created_at VARCHAR(20) -- intentionally as string, e.g., '2025-03-05' or '03/06/2025'
);
INSERT INTO rwp3_customers VALUES
(1,' ava ','BROWN',' Ava.Brown@Example.com ','Austin','2025-02-01'),
(2,'NOAH','smith','Noah@Example.com','Dallas','02/10/2025'),
(3,'Mia',NULL,'  ','Austin','2025.03.05'),
(4,'Liam','Patel','liam@carecart.com',NULL,'2025-03-07'),
(5,'Emma','Davis','emma@carecart.com','Seattle','2025-03-10'),
(6,'Olivia','Johnson',NULL,'Seattle','2025-03-15'),
(7,'William','Lee','will@carecart.com','Miami','2025-03-20'),
(8,'James','Kim','jkim@carecart.com','Dallas','2025-03-22');

-- Products
DROP TABLE IF EXISTS rwp3_products;
CREATE TABLE rwp3_products (
  product_id INT PRIMARY KEY,
  name VARCHAR(60),
  category VARCHAR(30),
  price_txt VARCHAR(20),
  active TINYINT(1)
);
INSERT INTO rwp3_products VALUES
(1,'Notebook','stationery','$4.99',1),
(2,'Desk Lamp','home','12.00',1),
(3,'Yoga Mat','fitness','24.50',1),
(4,'Coffee Mug','kitchen','7.99',1),
(5,'Pen Set','stationery','3.75',1),
(6,'Throw Pillow','home','18.00',1),
(7,'Water Bottle','fitness','15.00',0),
(8,'Scented Candle','home','9.99',1),
(9,'Laptop Stand','electronics','29.99',1),
(10,'Cable Organizer','accessories','$3.49',1),
(11,'Screen Cleaner','accessories','5.49',1),
(12,'Bluetooth Speaker','electronics','35.00',0);

-- Orders
DROP TABLE IF EXISTS rwp3_orders;
CREATE TABLE rwp3_orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date VARCHAR(20), -- mixed format
  status VARCHAR(20),
  ship_city VARCHAR(40)
);
INSERT INTO rwp3_orders VALUES
(101,1,'2025-03-01','shipped','Austin'),
(102,2,'2025/03/02','shipped','Dallas'),
(103,3,'03-03-2025','processing','Austin'),
(104,3,'2025-03-04','cancelled','Houston'),
(105,5,'03/05/2025','processing',NULL),
(106,6,'2025.03.06','shipped','Seattle'),
(107,7,'2025-03-07','processing','Miami'),
(108,8,'2025-03-08','processing','Dallas');

-- Order items (not needed for joins here; used to show numeric parsing)
DROP TABLE IF EXISTS rwp3_order_items;
CREATE TABLE rwp3_order_items (
  order_item_id INT PRIMARY KEY,
  order_id INT,
  product_id INT,
  qty_txt VARCHAR(10)
);
INSERT INTO rwp3_order_items VALUES
(1,101,1,'2'),(2,101,4,'1'),(3,102,2,'1'),(4,102,5,'3'),
(5,103,9,'1'),(6,104,3,'1'),(7,105,10,'2'),(8,106,6,'2'),
(9,106,8,'1'),(10,107,7,'1'),(11,108,11,'2'),(12,108,1,'1');

-- Categories (for display names only)
DROP TABLE IF EXISTS rwp3_categories;
CREATE TABLE rwp3_categories (
  code VARCHAR(30) PRIMARY KEY,
  display_name VARCHAR(40)
);
INSERT INTO rwp3_categories VALUES
('stationery','Stationery'),('home','Home & Decor'),('fitness','Fitness'),
('kitchen','Kitchen'),('electronics','Electronics'),('accessories','Accessories');
```

Deliverables
1) Clean customers export: `full_name` (Last, First proper-case), `email_norm` (lower-trimmed or 'N/A'), `city_or_dash`, and `created_date` parsed to DATE from mixed `created_at` values. Sort by `created_date`, then `full_name`.
   - Acceptance: All dates parsed where possible; blanks to 'N/A' or '-' appropriately.
2) Product price normalization: active products only, parse `price_txt` to `DECIMAL(10,2)` as `price`, return `name`, `category`, `price` sorted by `category`, then `price` asc.
   - Acceptance: `$` removed; invalid/missing become NULL (excluded using `price IS NOT NULL`).
3) Orders snapshot with parsed dates: March 2025 orders only; columns `order_id`, `order_date` (DATE), `status`, `ship_city_or_dash`. Sort by `order_date`.
   - Acceptance: Date parsing across multiple formats; NULL ships become '-'.

Bonus objectives
- Derive a `qty_int` from `rwp3_order_items.qty_txt` using a REGEXP guard and cast.
- Produce a human-readable month label using `DATE_FORMAT(order_date, '%M %Y')`.

Evaluation rubric (0–3 each)
- Correctness (parsing and transformations)
- Readability (clear aliases, comments)
- Robustness (handles NULLs, bad formats)
- Performance (avoid repeated expressions; consider indexing if persisted)

Model solutions

1) Clean customers export
```sql
SELECT 
  NULLIF(
    CONCAT(
      CASE WHEN last_name IS NULL THEN '' ELSE CONCAT(UPPER(LEFT(TRIM(last_name),1)), LOWER(SUBSTRING(TRIM(last_name),2))) END,
      CASE WHEN first_name IS NULL THEN '' ELSE CONCAT(', ', CONCAT(UPPER(LEFT(TRIM(first_name),1)), LOWER(SUBSTRING(TRIM(first_name),2)))) END
    ), ''
  ) AS full_name,
  COALESCE(NULLIF(LOWER(TRIM(email)), ''), 'N/A') AS email_norm,
  COALESCE(city, '-') AS city_or_dash,
  COALESCE(
    STR_TO_DATE(created_at, '%Y-%m-%d'),
    STR_TO_DATE(created_at, '%m/%d/%Y'),
    STR_TO_DATE(created_at, '%Y.%m.%d'),
    STR_TO_DATE(created_at, '%m-%d-%Y')
  ) AS created_date
FROM rwp3_customers
ORDER BY created_date, full_name;
```

2) Product price normalization
```sql
SELECT name, category,
       CAST(NULLIF(REPLACE(REPLACE(TRIM(price_txt),'$',''),',',''), '') AS DECIMAL(10,2)) AS price
FROM rwp3_products
WHERE active = 1
  AND CAST(NULLIF(REPLACE(REPLACE(TRIM(price_txt),'$',''),',',''), '') AS DECIMAL(10,2)) IS NOT NULL
ORDER BY category, price, name;
```

3) Orders snapshot with parsed dates (March 2025)
```sql
SELECT 
  order_id,
  COALESCE(
    STR_TO_DATE(order_date, '%Y-%m-%d'),
    STR_TO_DATE(order_date, '%Y/%m/%d'),
    STR_TO_DATE(order_date, '%m-%d-%Y'),
    STR_TO_DATE(order_date, '%m/%d/%Y'),
    STR_TO_DATE(order_date, '%Y.%m.%d')
  ) AS order_date,
  status,
  COALESCE(ship_city, '-') AS ship_city_or_dash
FROM rwp3_orders
WHERE COALESCE(
        STR_TO_DATE(order_date, '%Y-%m-%d'),
        STR_TO_DATE(order_date, '%Y/%m/%d'),
        STR_TO_DATE(order_date, '%m-%d-%Y'),
        STR_TO_DATE(order_date, '%m/%d/%Y'),
        STR_TO_DATE(order_date, '%Y.%m.%d')
      ) BETWEEN '2025-03-01' AND '2025-03-31'
ORDER BY order_date, order_id;
```

Performance notes
- Consider computed/generated columns for parsed dates and normalized emails if this logic is reused.
- Avoid repeating heavy expressions by wrapping in views or CTEs (Module 6).
- Index persisted normalized columns if filtered frequently.

Encouragement: You’re building robust exports—clean inputs, clear outputs, and thoughtful defaults.
