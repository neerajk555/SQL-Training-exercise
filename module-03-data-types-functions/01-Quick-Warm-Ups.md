# Quick Warm-Ups (Data Types & Functions)

Each exercise: 5–10 minutes. Focus on conversions and core functions. Copy sample data to a scratch DB first.

##  Before You Start

### Learning Objectives
By completing these warm-ups, you will:
- Master type conversions with CAST and CONVERT
- Clean messy data with TRIM, LOWER, and UPPER
- Work with date functions for parsing and arithmetic
- Handle NULL values in function calls
- Use CASE statements for conditional logic

### Environment Setup & Execution
1. **Connect to MySQL** and choose/create a practice database
2. **Copy each exercise setup** (DROP + CREATE + INSERT)
3. **Run the setup** to create sample data
4. **Try solving** before looking at the solution
5. **Compare your output** with expected results

**Beginner Tip:** These exercises help you practice cleaning and transforming data—essential skills for real-world SQL work. Take your time, read error messages carefully, and try variations to deepen your understanding.

**Common Function Pitfalls:**
- ❌ String functions return NULL if input is NULL (use COALESCE to handle)
- ❌ Date parsing fails with wrong format—match STR_TO_DATE pattern exactly
- ❌ CAST to numeric types may truncate unexpectedly—check your precision
- ✅ Test with edge cases (NULL, empty string, zero) to build robust queries

---

## 1) Round and Cast Prices
- Scenario: Show friendly prices for display.
- Sample data
```sql
DROP TABLE IF EXISTS qwu_prices;
CREATE TABLE qwu_prices (
  id INT PRIMARY KEY,
  name VARCHAR(40),
  price DECIMAL(7,3)
);
INSERT INTO qwu_prices VALUES
(1,'Notebook',4.995),
(2,'Mug',7.499),
(3,'Lamp',12.000);
```
- Task: Return `name`, `ROUND(price,2)` as `price_2dp`, and `CAST(price AS UNSIGNED)` as `price_whole`.
- Expected output
```
name     | price_2dp | price_whole
---------+-----------+------------
Notebook | 5.00      | 4
Mug      | 7.50      | 7
Lamp     | 12.00     | 12
```
- Solution
```sql
SELECT 
  name,
  ROUND(price, 2) AS price_2dp,
  CAST(price AS UNSIGNED) AS price_whole
FROM qwu_prices;
```

---

## 2) Trim and Lowercase Emails
- Scenario: Clean up email inputs with extra spaces/casing.
- Sample data
```sql
DROP TABLE IF EXISTS qwu_emails;
CREATE TABLE qwu_emails (
  id INT PRIMARY KEY,
  raw_email VARCHAR(80)
);
INSERT INTO qwu_emails VALUES
(1,'  Ava@Example.com '),
(2,'NOAH@EXAMPLE.COM'),
(3,' mia@example.com'),
(4,NULL);
```
- Task: Return `id`, `TRIM(raw_email)` as `trimmed`, and `LOWER(TRIM(raw_email))` as `normalized`.
- Expected output
```
id | trimmed            | normalized
---+--------------------+-------------------
1  | Ava@Example.com    | ava@example.com
2  | NOAH@EXAMPLE.COM   | noah@example.com
3  | mia@example.com    | mia@example.com
4  | NULL               | NULL
```
- Solution
```sql
SELECT 
  id,
  TRIM(raw_email) AS trimmed,
  LOWER(TRIM(raw_email)) AS normalized
FROM qwu_emails;
```

---

## 3) Parse Dates From Strings
- Scenario: Convert mixed-formatted dates to proper DATEs.
- Sample data
```sql
DROP TABLE IF EXISTS qwu_dates;
CREATE TABLE qwu_dates (
  id INT PRIMARY KEY,
  date_txt VARCHAR(20)
);
INSERT INTO qwu_dates VALUES
(1,'2025-04-01'),
(2,'04/15/2025'),
(3,'2025.04.30');
```
- Task: Return `id`, and parsed dates using `COALESCE(STR_TO_DATE(...))` with patterns '%Y-%m-%d', '%m/%d/%Y', '%Y.%m.%d' as `parsed_date`.
- Expected output
```
id | parsed_date
---+------------
1  | 2025-04-01
2  | 2025-04-15
3  | 2025-04-30
```
- Solution
```sql
SELECT 
  id,
  COALESCE(
    STR_TO_DATE(date_txt, '%Y-%m-%d'),
    STR_TO_DATE(date_txt, '%m/%d/%Y'),
    STR_TO_DATE(date_txt, '%Y.%m.%d')
  ) AS parsed_date
FROM qwu_dates;
```

---

## 4) Safe Division for Unit Price
- Scenario: Compute `total/qty` with guards against zero or NULL.
- Sample data
```sql
DROP TABLE IF EXISTS qwu_orders;
CREATE TABLE qwu_orders (
  id INT PRIMARY KEY,
  total DECIMAL(8,2),
  qty INT
);
INSERT INTO qwu_orders VALUES
(1, 50.00, 5),
(2, 20.00, 0),
(3, 10.00, NULL);
```
- Task: Return `id`, `ROUND(total / NULLIF(qty,0), 2)` as `unit_price` (NULL when qty is 0/NULL).
- Expected output
```
id | unit_price
---+-----------
1  | 10.00
2  | NULL
3  | NULL
```
- Solution
```sql
SELECT 
  id,
  ROUND(total / NULLIF(qty, 0), 2) AS unit_price
FROM qwu_orders;
```

---

## 5) Extract Email Domain
- Scenario: List the email domain for each row.
- Sample data
```sql
DROP TABLE IF EXISTS qwu_domains;
CREATE TABLE qwu_domains (
  id INT PRIMARY KEY,
  email VARCHAR(80)
);
INSERT INTO qwu_domains VALUES
(1,'ava@shop.com'),
(2,'noah@EXAMPLE.org'),
(3,NULL);
```
- Task: Return `id`, lowercased domain using `LOWER(SUBSTRING_INDEX(email,'@',-1))` as `domain`.
- Expected output
```
id | domain
---+-------------
1  | shop.com
2  | example.org
3  | NULL
```
- Solution
```sql
SELECT 
  id,
  LOWER(SUBSTRING_INDEX(email, '@', -1)) AS domain
FROM qwu_domains;
```

Performance note: For large datasets, consider a generated column for normalized values (e.g., lowercased email/domain) and index that column.
