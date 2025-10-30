# Real-World Project: Launch-Week Readiness Dashboard (45–60 min)

Company background
- BrightCart is a small e-commerce startup preparing a launch-week promo.
- The team needs clean, filterable exports: customer outreach list, spotlight products, and recent orders snapshot.

Business problem
- Create SELECT queries (MySQL) to produce three accurate lists without joins or aggregates—filtering, sorting, and shaping only. Edge cases include NULLs and duplicates.

Database (5 tables, 40+ total rows)
```sql
-- Customers
DROP TABLE IF EXISTS rwp_customers;
CREATE TABLE rwp_customers (
  customer_id INT PRIMARY KEY,
  full_name VARCHAR(60),
  email VARCHAR(80),
  city VARCHAR(40),
  created_at DATE
);
INSERT INTO rwp_customers VALUES
(1,'Ava Brown','ava@brightcart.com','Austin','2025-01-02'),
(2,'Noah Smith',NULL,'Dallas','2025-01-10'),
(3,'Mia Chen','mia@brightcart.com','Austin','2025-02-03'),
(4,'Liam Patel','liam@brightcart.com',NULL,'2025-02-10'),
(5,'Emma Davis','emma@brightcart.com','Seattle','2025-02-18'),
(6,'Olivia Johnson',NULL,'Seattle','2025-02-21'),
(7,'William Lee','will@brightcart.com','Miami','2025-02-28'),
(8,'James Kim','jkim@brightcart.com','Dallas','2025-03-02'),
(9,'Sophia Garcia',NULL,'Austin','2025-03-05'),
(10,'Benjamin Hall','ben@brightcart.com','Houston','2025-03-06');

-- Products
DROP TABLE IF EXISTS rwp_products;
CREATE TABLE rwp_products (
  product_id INT PRIMARY KEY,
  name VARCHAR(60),
  category VARCHAR(30),
  price DECIMAL(7,2),
  active TINYINT(1)
);
INSERT INTO rwp_products VALUES
(1,'Notebook','stationery',4.99,1),
(2,'Desk Lamp','home',12.00,1),
(3,'Yoga Mat','fitness',24.50,1),
(4,'Coffee Mug','kitchen',7.99,1),
(5,'Pen Set','stationery',3.75,1),
(6,'Throw Pillow','home',18.00,1),
(7,'Water Bottle','fitness',15.00,0),
(8,'Scented Candle','home',9.99,1),
(9,'Laptop Stand','electronics',29.99,1),
(10,'Cable Organizer','accessories',3.49,1),
(11,'Screen Cleaner','accessories',5.49,1),
(12,'Bluetooth Speaker','electronics',35.00,0);

-- Orders (status for filtering only)
DROP TABLE IF EXISTS rwp_orders;
CREATE TABLE rwp_orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  status VARCHAR(20),
  ship_city VARCHAR(40)
);
INSERT INTO rwp_orders VALUES
(101,1,'2025-02-25','shipped','Austin'),
(102,2,'2025-02-27','shipped','Dallas'),
(103,3,'2025-03-01','processing','Austin'),
(104,3,'2025-03-03','cancelled','Houston'),
(105,5,'2025-03-04','processing',NULL),
(106,6,'2025-03-05','shipped','Seattle'),
(107,7,'2025-03-06','processing','Miami'),
(108,8,'2025-03-07','processing','Dallas'),
(109,9,'2025-03-08','processing','Austin'),
(110,10,'2025-03-09','shipped','Houston');

-- Order items (not required for this module's deliverables)
DROP TABLE IF EXISTS rwp_order_items;
CREATE TABLE rwp_order_items (
  order_item_id INT PRIMARY KEY,
  order_id INT,
  product_id INT,
  quantity INT
);
INSERT INTO rwp_order_items VALUES
(1,101,1,2), (2,101,4,1), (3,102,2,1), (4,102,5,3),
(5,103,9,1), (6,104,3,1), (7,105,10,2), (8,106,6,2),
(9,106,8,1), (10,107,7,1), (11,108,11,2), (12,109,1,1),
(13,109,5,2), (14,109,4,1), (15,110,2,1), (16,110,9,1),
(17,103,10,1), (18,105,11,1), (19,108,1,1), (20,107,5,1);

-- Categories ( for convenience and filtering demos )
DROP TABLE IF EXISTS rwp_categories;
CREATE TABLE rwp_categories (
  code VARCHAR(30) PRIMARY KEY,
  display_name VARCHAR(40)
);
INSERT INTO rwp_categories VALUES
('stationery','Stationery'),('home','Home & Decor'),('fitness','Fitness'),
('kitchen','Kitchen'),('electronics','Electronics'),('accessories','Accessories');
```

Deliverables (create separate SELECT queries)
1) Outreach list: all customers created in Feb 2025 with `full_name`, `safe_email` (email or 'N/A'), `city_or_dash` ('-' if NULL), ordered by `city`, `full_name`.
   - Acceptance: Only dates 2025-02-01..2025-02-28 inclusive; NULLs handled; stable sort.
2) Active product spotlight: active products in categories `home`, `stationery`, or `accessories` priced <= 12.00, with columns `name`, `category`, `price` sorted by price asc then name.
   - Acceptance: No inactive items; only chosen categories; boundaries included.
3) Recent orders snapshot: orders in March 2025 with columns `order_id`, `order_date`, `status`, `ship_city_or_dash` and sort by date asc.
   - Acceptance: Only dates 2025-03-01..2025-03-31; NULL ship city shown as '-'.

Bonus objectives (optional)
- Use DISTINCT to list unique non-NULL cities from `rwp_customers` and `rwp_orders` separately.
- Normalize case for cities using LOWER() for comparison or display.

Evaluation rubric (0–3 each)
- Correctness (filters, outputs)
- Readability (clear aliases, formatting, comments)
- Robustness (handles NULLs, boundaries)
- Performance notes (mentions indexing, minimal columns)

Model solutions

1) Outreach list
```sql
SELECT 
  full_name,
  COALESCE(email, 'N/A') AS safe_email,
  COALESCE(city, '-') AS city_or_dash
FROM rwp_customers
WHERE created_at BETWEEN '2025-02-01' AND '2025-02-28'
ORDER BY city IS NULL, city, full_name;
```

2) Active product spotlight
```sql
SELECT name, category, price
FROM rwp_products
WHERE active = 1
  AND category IN ('home','stationery','accessories')
  AND price <= 12.00
ORDER BY price ASC, name ASC;
```

3) Recent orders snapshot
```sql
SELECT 
  order_id,
  order_date,
  status,
  COALESCE(ship_city, '-') AS ship_city_or_dash
FROM rwp_orders
WHERE order_date >= '2025-03-01'
  AND order_date <  '2025-04-01'
ORDER BY order_date ASC, order_id ASC;
```

Performance notes
- Add indexes on filter columns: `(created_at)`, `(active, category, price)`, `(order_date)`.
- Avoid functions on filtered columns for sargability.
- Only SELECT the columns you need to reduce I/O.

Encouragement: Keep queries tidy and commented—you’re building production habits.
