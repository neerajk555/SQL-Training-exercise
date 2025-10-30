# Paired Programming: Store Snapshot Explorer (30 min)

Roles
- Driver: Types SQL, verbalizes approach.
- Navigator: Reviews logic, asks questions, checks requirements.
- Switch roles after each part (A → B → C).

Schema (2–4 tables; no joins required for this activity)
```sql
DROP TABLE IF EXISTS pp_customers;
CREATE TABLE pp_customers (
  customer_id INT PRIMARY KEY,
  full_name VARCHAR(60),
  email VARCHAR(80),
  city VARCHAR(40)
);
INSERT INTO pp_customers VALUES
(1,'Ava Brown','ava@shop.com','Austin'),
(2,'Noah Smith',NULL,'Dallas'),
(3,'Mia Chen','mia@shop.com','Austin'),
(4,'Leo Park','leo@shop.com',NULL),
(5,'Zoe Li',NULL,'Seattle');

DROP TABLE IF EXISTS pp_products;
CREATE TABLE pp_products (
  product_id INT PRIMARY KEY,
  name VARCHAR(60),
  category VARCHAR(30),
  price DECIMAL(7,2)
);
INSERT INTO pp_products VALUES
(1,'Notebook','stationery',4.99),
(2,'Desk Lamp','home',12.00),
(3,'Yoga Mat','fitness',24.50),
(4,'Coffee Mug','kitchen',7.99),
(5,'Pen Set','stationery',3.75);

DROP TABLE IF EXISTS pp_orders;
CREATE TABLE pp_orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  ship_city VARCHAR(40)
);
INSERT INTO pp_orders VALUES
(101,1,'2025-01-15','Austin'),
(102,2,'2025-01-16','Dallas'),
(103,3,'2025-02-01','Austin'),
(104,3,'2025-02-20','Houston'),
(105,5,'2025-03-01',NULL);
```

Part A (Driver 1): Customer Directory
- Task: List customers with `full_name`, `email_or_na` (email or 'N/A'), and `city` sorted by `city`, then `full_name`.
- Edge cases: NULL emails, NULL cities.
- Solution
```sql
SELECT 
  full_name,
  COALESCE(email, 'N/A') AS email_or_na,
  city
FROM pp_customers
ORDER BY city IS NULL, city, full_name;
```
Note: `city IS NULL` sorts NULLs last.

Part B (Driver 2): Product Spotlight
- Task: Show products priced between 4 and 10 inclusive, columns: `name`, `category`, `price`, sorted by `price` desc.
- Edge cases: boundary values.
- Solution
```sql
SELECT name, category, price
FROM pp_products
WHERE price BETWEEN 4 AND 10
ORDER BY price DESC;
```

Part C (Driver 1): Recent Orders Filter
- Task: Return orders in February 2025 only, columns: `order_id`, `order_date`, `ship_city_or_dash`.
- Edge cases: NULL ship_city.
- Solution
```sql
SELECT 
  order_id,
  order_date,
  COALESCE(ship_city, '-') AS ship_city_or_dash
FROM pp_orders
WHERE order_date >= '2025-02-01'
  AND order_date <  '2025-03-01'
ORDER BY order_date, order_id;
```

Role-switching points
- After each part, switch Driver/Navigator, briefly explain your solution and any alternative approaches.

Collaboration tips
- Navigator: Ask "What columns do we need? What filters? What order? Any NULLs?"
- Driver: Narrate: "I’ll SELECT columns, add WHERE, then ORDER BY."
- Both: Read errors aloud and fix iteratively.
