# Paired Programming: Data Cleanup Lab (30 min)

**Beginner Tip:** Pair programming helps you learn from each other! The driver explains their thinking out loud (this solidifies learning). The navigator catches mistakes early. Switch roles so both people practice each skill. Be supportive and curious!

Roles
- Driver: Types SQL, narrates approach.
- Navigator: Reviews logic, checks edge cases, and asks clarifying questions.
- Switch roles after each part (A → B → C).

Schema (3 tables)
```sql
DROP TABLE IF EXISTS pp_users;
CREATE TABLE pp_users (
  user_id INT PRIMARY KEY,
  first_name VARCHAR(40),
  last_name VARCHAR(40),
  email VARCHAR(80),
  created_at DATE
);
INSERT INTO pp_users VALUES
(1,' ava ','BROWN',' Ava.Brown@Example.com ','2025-02-01'),
(2,'NOAH','smith','Noah@Example.com','2025-02-10'),
(3,'Mia',NULL,'  ','2025-03-05');

DROP TABLE IF EXISTS pp_items;
CREATE TABLE pp_items (
  sku VARCHAR(10) PRIMARY KEY,
  name VARCHAR(60),
  price_txt VARCHAR(20)
);
INSERT INTO pp_items VALUES
('A1','Notebook','$4.99'),
('A2','Lamp','12.0'),
('A3','Mug','N/A');

DROP TABLE IF EXISTS pp_orders;
CREATE TABLE pp_orders (
  order_id INT PRIMARY KEY,
  user_id INT,
  order_date DATE,
  qty INT
);
INSERT INTO pp_orders VALUES
(101,1,'2025-03-01',2),
(102,1,'2025-03-02',0),
(103,2,'2025-03-05',3),
(104,3,'2025-03-06',NULL);
```

Part A (Driver 1): Normalize Users
- Task: Return `user_id`, `full_name` ("Last, First" proper case) and `normalized_email` (lower-trimmed or 'N/A').
- Edge cases: NULLs, blanks.
- Solution
```sql
SELECT 
  user_id,
  NULLIF(
    CONCAT(
      CASE WHEN last_name IS NULL THEN '' ELSE CONCAT(UPPER(LEFT(TRIM(last_name),1)), LOWER(SUBSTRING(TRIM(last_name),2))) END,
      CASE WHEN first_name IS NULL THEN '' ELSE CONCAT(', ', CONCAT(UPPER(LEFT(TRIM(first_name),1)), LOWER(SUBSTRING(TRIM(first_name),2)))) END
    ), ''
  ) AS full_name,
  COALESCE(NULLIF(LOWER(TRIM(email)), ''), 'N/A') AS normalized_email
FROM pp_users
ORDER BY user_id;
```

Part B (Driver 2): Clean Prices
- Task: Return `sku`, `name`, and `price` as DECIMAL(10,2) parsed from `price_txt` ('$' or 'N/A').
- Edge cases: symbols, missing.
- Solution
```sql
SELECT 
  sku,
  name,
  CAST(NULLIF(REPLACE(REPLACE(TRIM(price_txt),'$',''),',',''), '') AS DECIMAL(10,2)) AS price
FROM pp_items
ORDER BY sku;
```

Part C (Driver 1): Safe Quantity Buckets
- Task: Return orders with `order_id`, `qty`, and a `qty_bucket` using CASE: 'none' (0 or NULL), 'small'(1–2), 'bulk'(>=3).
- Edge cases: NULL qty.
- Solution
```sql
SELECT 
  order_id,
  qty,
  CASE 
    WHEN qty IS NULL OR qty = 0 THEN 'none'
    WHEN qty BETWEEN 1 AND 2 THEN 'small'
    ELSE 'bulk'
  END AS qty_bucket
FROM pp_orders
ORDER BY order_id;
```

Role-switching points
- Switch roles after each part; Navigator summarizes what changed and why.

Collaboration tips
- Navigator: Ask "What functions do we need? Any NULL/empty cases?"
- Driver: Narrate: "Normalize strings, convert types, then CASE for categories."
