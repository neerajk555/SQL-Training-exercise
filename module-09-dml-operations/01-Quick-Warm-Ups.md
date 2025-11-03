# Quick Warm-Ups — DML Operations

## 1) Insert New Product — 6 min
```sql
DROP TABLE IF EXISTS wu9_products;
CREATE TABLE wu9_products (product_id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(60), price DECIMAL(8,2));
-- Task: Insert 3 products in one statement
INSERT INTO wu9_products (name, price) VALUES ('Laptop', 1200), ('Mouse', 25), ('Keyboard', 75);
SELECT * FROM wu9_products;
```

## 2) Update Prices — 7 min
```sql
-- Task: Increase all prices by 10%
UPDATE wu9_products SET price = price * 1.10;
SELECT * FROM wu9_products;
```

## 3) Conditional Update — 8 min
```sql
-- Task: Set price to 20 for products cheaper than 30
UPDATE wu9_products SET price = 20 WHERE price < 30;
```

## 4) Delete Expired Records — 7 min
```sql
DROP TABLE IF EXISTS wu9_sessions;
CREATE TABLE wu9_sessions (session_id INT, expires_at DATETIME);
INSERT INTO wu9_sessions VALUES (1, '2025-01-01'), (2, '2025-12-31');
-- Task: Delete expired sessions
DELETE FROM wu9_sessions WHERE expires_at < CURDATE();
```

## 5) Upsert Pattern — 9 min
```sql
DROP TABLE IF EXISTS wu9_user_stats;
CREATE TABLE wu9_user_stats (user_id INT PRIMARY KEY, login_count INT DEFAULT 0);
-- Task: Increment login_count, insert if not exists
INSERT INTO wu9_user_stats (user_id, login_count) VALUES (1, 1)
ON DUPLICATE KEY UPDATE login_count = login_count + 1;
```
