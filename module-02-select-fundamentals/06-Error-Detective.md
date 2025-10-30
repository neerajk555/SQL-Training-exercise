# Error Detective: Fix Broken SELECTs (5 challenges)

Format per challenge: scenario, sample data, broken query, error message, expected output, guiding questions, and fixed solution with explanation.

---

## Challenge 1: NULL Comparison Gone Wrong
Scenario: Find customers without an email.

Sample data
```sql
DROP TABLE IF EXISTS ed_customers;
CREATE TABLE ed_customers (
  id INT PRIMARY KEY,
  name VARCHAR(60),
  email VARCHAR(80)
);
INSERT INTO ed_customers VALUES
(1,'Ava','ava@x.com'), (2,'Noah',NULL), (3,'Mia',NULL), (4,'Leo','leo@x.com');
```
Broken query
```sql
SELECT id, name
FROM ed_customers
WHERE email = NULL; -- BUG
```
Error message or symptom
- No error thrown, but returns 0 rows unexpectedly.

Expected output
```
id | name
---+-----
2  | Noah
3  | Mia
```
Guiding questions
- How do you test for NULL in SQL?
- What’s the difference between `= NULL` and `IS NULL`?

Fixed solution and explanation
```sql
SELECT id, name
FROM ed_customers
WHERE email IS NULL; -- Use IS NULL for NULL checks
```

---

## Challenge 2: Alias Misuse in WHERE
Scenario: Show products with a discounted price below $10 using an alias.

Sample data
```sql
DROP TABLE IF EXISTS ed_products;
CREATE TABLE ed_products (
  pid INT PRIMARY KEY,
  name VARCHAR(60),
  price DECIMAL(7,2)
);
INSERT INTO ed_products VALUES
(1,'Mug',7.99),(2,'Lamp',12.00),(3,'Cable',3.49),(4,'Mat',24.50);
```
Broken query
```sql
SELECT name, price*0.9 AS discounted
FROM ed_products
WHERE discounted < 10; -- BUG: WHERE cannot reference SELECT alias in MySQL
```
Error message
- Unknown column 'discounted' in 'where clause'

Expected output
```
name | discounted
-----+-----------
Mug  | 7.191
Cable| 3.141
```
Guiding questions
- When are column aliases visible?
- How can you reuse an expression in the WHERE?

Fixed solution and explanation
```sql
-- Option 1: Repeat the expression in WHERE
SELECT name, price*0.9 AS discounted
FROM ed_products
WHERE price*0.9 < 10;

-- Option 2 (alternative): Use a subquery or HAVING with alias (not needed here)
```

---

## Challenge 3: Quoting Identifiers vs Strings
Scenario: Find orders with status 'shipped'.

Sample data
```sql
DROP TABLE IF EXISTS ed_orders;
CREATE TABLE ed_orders (
  oid INT PRIMARY KEY,
  status VARCHAR(20)
);
INSERT INTO ed_orders VALUES
(101,'processing'),(102,'shipped'),(103,'cancelled');
```
Broken query
```sql
SELECT oid
FROM ed_orders
WHERE 'status' = 'shipped'; -- BUG: 'status' is a string literal, not a column
```
Error message or symptom
- Query runs but returns 0 rows.

Expected output
```
oid
---
102
```
Guiding questions
- How do you reference column names vs string literals?
- When do you need backticks in MySQL?

Fixed solution and explanation
```sql
SELECT oid
FROM ed_orders
WHERE status = 'shipped'; -- Column on left, string literal on right
```

---

## Challenge 4: DISTINCT With Extra Columns
Scenario: Get distinct cities from addresses, but an extra column ruins the de-duplication.

Sample data
```sql
DROP TABLE IF EXISTS ed_addresses;
CREATE TABLE ed_addresses (
  id INT PRIMARY KEY,
  city VARCHAR(40),
  country VARCHAR(40)
);
INSERT INTO ed_addresses VALUES
(1,'Austin','USA'),(2,'Austin','USA'),(3,'Dallas','USA'),(4,'Dallas','USA');
```
Broken query
```sql
SELECT DISTINCT city, country, id -- BUG: id forces all rows to be distinct
FROM ed_addresses;
```
Error message or symptom
- Returns all rows instead of de-duplicating by city.

Expected output
```
city
------
Austin
Dallas
```
Guiding questions
- How does DISTINCT decide duplicates?
- Which columns are required for the result?

Fixed solution and explanation
```sql
SELECT DISTINCT city
FROM ed_addresses; -- Only include columns that define distinctness
```

---

## Challenge 5: BETWEEN Off-by-One Date Error
Scenario: Report orders for February 2025 (inclusive) but March 1 shows up.

Sample data
```sql
DROP TABLE IF EXISTS ed_order_dates;
CREATE TABLE ed_order_dates (
  oid INT PRIMARY KEY,
  order_date DATE
);
INSERT INTO ed_order_dates VALUES
(1,'2025-01-31'),(2,'2025-02-01'),(3,'2025-02-28'),(4,'2025-03-01');
```
Broken query
```sql
SELECT oid, order_date
FROM ed_order_dates
WHERE order_date BETWEEN '2025-02-01' AND '2025-03-01'; -- BUG: includes March 1
```
Error message or symptom
- March 1 is incorrectly included.

Expected output
```
oid | order_date
----+-----------
2   | 2025-02-01
3   | 2025-02-28
```
Guiding questions
- Does BETWEEN include endpoints?
- What’s a safer way to express month windows?

Fixed solution and explanation
```sql
SELECT oid, order_date
FROM ed_order_dates
WHERE order_date >= '2025-02-01'
  AND order_date <  '2025-03-01'; -- Half-open interval excludes March 1
```
