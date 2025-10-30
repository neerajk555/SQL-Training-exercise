# Error Detective: Functions & Conversion Bugs (5 challenges)

Each includes: scenario, sample data, broken query, error/symptom, expected output, guiding questions, and a fixed solution with explanation.

**Beginner Tip:** Debugging is a key SQL skill! Read error messages carefully—they often point to the exact problem. Try the broken query first, observe what happens, then work through the guiding questions. You'll learn more by fixing bugs than writing perfect code the first time!

---

## Challenge 1: Wrong NULL Check in COALESCE Context
Scenario: Show email or 'N/A' for missing values.

Sample data
```sql
DROP TABLE IF EXISTS ed3_emails;
CREATE TABLE ed3_emails (
  id INT PRIMARY KEY,
  email VARCHAR(80)
);
INSERT INTO ed3_emails VALUES
(1,'ava@x.com'),(2,NULL),(3,'');
```
Broken query
```sql
SELECT id, COALESCE(email, 'N/A') AS safe_email
FROM ed3_emails
WHERE email = NULL; -- BUG
```
Symptom
- Returns 0 rows instead of IDs 2 and (possibly) 3 depending on intent.

Expected output
```
id | safe_email
---+-----------
2  | N/A
3  | N/A
```
Guiding questions
- How to test for NULL vs empty strings?
- Should empty strings be treated as NULLs here?

Fixed solution and explanation
```sql
SELECT id, COALESCE(NULLIF(email,''), 'N/A') AS safe_email
FROM ed3_emails
WHERE email IS NULL OR email = '';
```

---

## Challenge 2: DATE_ADD Syntax Misuse
Scenario: List orders within 7 days after a given date.

Sample data
```sql
DROP TABLE IF EXISTS ed3_orders;
CREATE TABLE ed3_orders (
  id INT PRIMARY KEY,
  order_date DATE
);
INSERT INTO ed3_orders VALUES
(1,'2025-03-01'),(2,'2025-03-05'),(3,'2025-03-08');
```
Broken query
```sql
SELECT *
FROM ed3_orders
WHERE order_date <= DATE_ADD('2025-03-01', 7 DAY); -- BUG
```
Error
- You have an error in your SQL syntax near '7 DAY'.

Fixed solution and explanation
```sql
SELECT *
FROM ed3_orders
WHERE order_date <= DATE_ADD('2025-03-01', INTERVAL 7 DAY);
```

---

## Challenge 3: Integer vs Decimal Casting
Scenario: Convert a numeric string to a number for math.

Sample data
```sql
DROP TABLE IF EXISTS ed3_nums;
CREATE TABLE ed3_nums (
  id INT PRIMARY KEY,
  val_txt VARCHAR(10)
);
INSERT INTO ed3_nums VALUES
(1,'12.75'),(2,'9'),(3,'N/A');
```
Broken query
```sql
SELECT id, CAST(val_txt AS UNSIGNED) * 2 AS doubled
FROM ed3_nums; -- BUG: 12.75 becomes 12 (truncation)
```
Expected output
```
id | doubled
---+--------
1  | 25.50
2  | 18.00
3  | NULL
```
Fixed solution and explanation
```sql
SELECT 
  id,
  CASE 
    WHEN val_txt REGEXP '^[0-9]+(\.[0-9]+)?$' 
      THEN CAST(val_txt AS DECIMAL(10,2)) * 2
  END AS doubled
FROM ed3_nums;
```

---

## Challenge 4: Misplaced Alias in WHERE
Scenario: Filter on a computed discount.

Sample data
```sql
DROP TABLE IF EXISTS ed3_discounts;
CREATE TABLE ed3_discounts (
  id INT PRIMARY KEY,
  price DECIMAL(7,2),
  pct INT
);
INSERT INTO ed3_discounts VALUES
(1,100.00,10),(2,40.00,50),(3,20.00,0);
```
Broken query
```sql
SELECT id, price * (1 - pct/100) AS net
FROM ed3_discounts
WHERE net < 50; -- BUG
```
Error
- Unknown column 'net' in 'where clause'

Fixed solution and explanation
```sql
SELECT id, price * (1 - pct/100) AS net
FROM ed3_discounts
WHERE price * (1 - pct/100) < 50;
```

---

## Challenge 5: STR_TO_DATE Format Mismatch
Scenario: Parse various date strings.

Sample data
```sql
DROP TABLE IF EXISTS ed3_date_parse;
CREATE TABLE ed3_date_parse (
  id INT PRIMARY KEY,
  dt_txt VARCHAR(20)
);
INSERT INTO ed3_date_parse VALUES
(1,'2025-03-01'),(2,'03/02/2025'),(3,'03-03-2025');
```
Broken query
```sql
SELECT id, STR_TO_DATE(dt_txt, '%Y/%m/%d') AS dt
FROM ed3_date_parse; -- BUG: mismatched format tokens
```
Expected output
```
id | dt
---+------------
1  | 2025-03-01
2  | 2025-03-02
3  | 2025-03-03
```
Fixed solution and explanation
```sql
SELECT 
  id,
  COALESCE(
    STR_TO_DATE(dt_txt, '%Y-%m-%d'),
    STR_TO_DATE(dt_txt, '%m/%d/%Y'),
    STR_TO_DATE(dt_txt, '%m-%d-%Y')
  ) AS dt
FROM ed3_date_parse;
```
