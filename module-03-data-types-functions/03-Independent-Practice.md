# Independent Practice: Data Types & Functions

Seven exercises: 3 Easy 🟢, 3 Medium 🟡, 1 Challenge 🔴. Each includes schema+data, requirements, example output, success criteria, 3-level hints, and detailed solutions.

---

## Easy 🟢 (1): Tip Calculator Formatting (10–12 min)
Scenario: Display bill totals with rounded tips.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip_bills;
CREATE TABLE ip_bills (
  id INT PRIMARY KEY,
  subtotal DECIMAL(7,2)
);
INSERT INTO ip_bills VALUES
(1, 23.50), (2, 9.99), (3, 48.20);
```
Requirements
- Calculate 15% tip and total: `tip = ROUND(subtotal*0.15, 2)`, `total = ROUND(subtotal+tip,2)`.
- Show `id`, `tip`, `total`.

Example output
```
id | tip  | total
---+------+------
1  | 3.53 | 27.03
2  | 1.50 | 11.49
3  | 7.23 | 55.43
```
Success criteria
- Rounding to 2 dp; totals consistent with tip rounding.

Hints
1) Compute tip first; reuse the expression for total.
2) Use ROUND twice.
3) Aliases help readability.

Solution
```sql
SELECT 
  id,
  ROUND(subtotal * 0.15, 2) AS tip,
  ROUND(subtotal + ROUND(subtotal * 0.15, 2), 2) AS total
FROM ip_bills;
```

---

## Easy 🟢 (2): Proper-Case Names (10–12 min)
Scenario: Standardize customer names.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip_names;
CREATE TABLE ip_names (
  id INT PRIMARY KEY,
  first VARCHAR(40),
  last VARCHAR(40)
);
INSERT INTO ip_names VALUES
(1,'AVA','brown'),(2,' noah ','SMITH'),(3,NULL,'LEE');
```
Requirements
- Return `full_name` as `Last, First` with proper casing and trimmed.

Example output
```
full_name
-----------
Brown, Ava
Smith, Noah
Lee
```
Success criteria
- Missing first or last handled gracefully (no trailing commas/spaces).

Hints
1) Use TRIM and case functions.
2) Use CASE to handle NULLs.
3) Use NULLIF to avoid dangling ', '.

Solution
```sql
SELECT 
  NULLIF(
    CONCAT(
      CASE WHEN last IS NULL THEN '' ELSE CONCAT(UPPER(LEFT(TRIM(last),1)), LOWER(SUBSTRING(TRIM(last),2))) END,
      CASE WHEN first IS NULL THEN '' ELSE CONCAT(', ', CONCAT(UPPER(LEFT(TRIM(first),1)), LOWER(SUBSTRING(TRIM(first),2)))) END
    ),
    ''
  ) AS full_name
FROM ip_names;
```

---

## Easy 🟢 (3): Month and Weekday From Dates (10–12 min)
Scenario: Show friendly date parts for a schedule.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip_dates;
CREATE TABLE ip_dates (
  id INT PRIMARY KEY,
  dt DATE
);
INSERT INTO ip_dates VALUES
(1,'2025-02-01'),(2,'2025-03-15'),(3,'2025-04-30');
```
Requirements
- Return `id`, `DATE_FORMAT(dt, '%M')` as `month_name`, `DATE_FORMAT(dt, '%W')` as `weekday`.

Example output
```
id | month_name | weekday
---+------------+---------
1  | February   | Saturday
2  | March      | Saturday
3  | April      | Wednesday
```
Success criteria
- Correct month and weekday names.

Hints
1) Use DATE_FORMAT tokens.
2) Ensure the column is DATE type.

Solution
```sql
SELECT 
  id,
  DATE_FORMAT(dt, '%M') AS month_name,
  DATE_FORMAT(dt, '%W') AS weekday
FROM ip_dates;
```

---

## Medium 🟡 (1): Parse Messy Prices (12–15 min)
Scenario: Convert string prices with `$` and commas to DECIMAL.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip_messy_prices;
CREATE TABLE ip_messy_prices (
  id INT PRIMARY KEY,
  raw_price VARCHAR(20)
);
INSERT INTO ip_messy_prices VALUES
(1,'$1,299.95'),(2,' 799.5'),(3,'N/A'),(4,'$0'),(5,'');
```
Requirements
- Return `id`, parsed `DECIMAL(10,2)` as `price`, with NULL for non-numeric.

Example output
```
id | price
---+-------
1  | 1299.95
2  | 799.50
3  | NULL
4  | 0.00
5  | NULL
```
Success criteria
- Correct decimals and NULL handling.

Hints
1) REPLACE `$` and commas, TRIM spaces.
2) NULLIF empty string.
3) CAST to DECIMAL(10,2).

Solution
```sql
SELECT 
  id,
  CAST(NULLIF(REPLACE(REPLACE(TRIM(raw_price),'$',''),',',''), '') AS DECIMAL(10,2)) AS price
FROM ip_messy_prices;
```

---

## Medium 🟡 (2): Accurate Age in Years (15–18 min)
Scenario: Compute age in years as of today.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip_birthdays;
CREATE TABLE ip_birthdays (
  person_id INT PRIMARY KEY,
  birthdate DATE
);
INSERT INTO ip_birthdays VALUES
(1,'2000-10-30'),(2,'1990-03-01'),(3,'1992-12-31');
```
Requirements
- Return `person_id`, `age_years` using `TIMESTAMPDIFF(YEAR, birthdate, CURRENT_DATE)` adjusted for birthdays not yet occurred this year.

Example output (as of current date)
```
person_id | age_years
----------+----------
1         | 25
2         | 35
3         | 32
```
Success criteria
- Ages correct for today’s date.

Hints
1) TIMESTAMPDIFF(YEAR, ...) is generally correct for birthdays.
2) If extra precision needed, compare month/day.

Solution
```sql
SELECT 
  person_id,
  TIMESTAMPDIFF(YEAR, birthdate, CURRENT_DATE) AS age_years
FROM ip_birthdays;
```

---

## Medium 🟡 (3): Normalize Empty Strings to NULL (12–15 min)
Scenario: Downstream systems treat empty strings as NULL.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip_empty_strings;
CREATE TABLE ip_empty_strings (
  id INT PRIMARY KEY,
  note VARCHAR(40),
  phone VARCHAR(20)
);
INSERT INTO ip_empty_strings VALUES
(1,'','555-1001'),(2,'urgent',''),(3,NULL,NULL);
```
Requirements
- Return `id`, `note_norm`, `phone_norm` where empty strings -> NULL using `NULLIF(col,'')`.

Example output
```
id | note_norm | phone_norm
---+-----------+-----------
1  | NULL      | 555-1001
2  | urgent    | NULL
3  | NULL      | NULL
```
Success criteria
- Empty strings become NULL; existing NULL preserved.

Hints
1) Use NULLIF.
2) Apply per column.

Solution
```sql
SELECT 
  id,
  NULLIF(note, '') AS note_norm,
  NULLIF(phone, '') AS phone_norm
FROM ip_empty_strings;
```

---

## Challenge 🔴: Robust Conversion and Derived Metrics (20–25 min)
Scenario: Sales imports contain numeric fields as text with noise; compute revenue per unit safely.

Schema and sample data
```sql
DROP TABLE IF EXISTS ip_sales_import;
CREATE TABLE ip_sales_import (
  row_id INT PRIMARY KEY,
  qty_txt VARCHAR(10),
  price_txt VARCHAR(20),
  discount_pct_txt VARCHAR(10) -- like '10%'
);
INSERT INTO ip_sales_import VALUES
(1,'10',' $12.50 ','10%'),
(2,'0','9.99','0%'),
(3,'3','N/A','5%'),
(4,'five','$5.00','20%'),
(5,NULL,'$2.00',NULL);
```
Requirements
- Parse `qty` as INT (invalid or NULL -> NULL).
- Parse `price` as DECIMAL(10,2) from `$` strings.
- Parse `discount_pct` as DECIMAL (0–1), e.g., '10%' -> 0.10; NULL if not parsable.
- Compute `net_price = price * (1 - discount_pct)` with discount defaulting to 0 when NULL.
- Compute `revenue_per_unit = net_price` and `total_revenue = net_price * qty` with safe division/multiplication (NULL if qty NULL or 0).
- Sort by `row_id`.

Example output
```
row_id | qty  | price  | discount_pct | net_price | total_revenue
------+-----+--------+---------------+-----------+---------------
1     | 10  | 12.50  | 0.10          | 11.25     | 112.50
2     | 0   | 9.99   | 0.00          | 9.99      | 0.00
3     | 3   | NULL   | 0.05          | NULL      | NULL
4     | NULL| 5.00   | 0.20          | 4.00      | NULL
5     | NULL| 2.00   | NULL          | 2.00      | NULL
```
Success criteria
- Correct parsing; invalids to NULL; totals use defaults and NULLs appropriately.

Hints
1) Use REPLACE/TRIM for `$` and spaces; remove `%` then divide by 100.
2) Use CASE/REGEXP to detect digits.
3) Use COALESCE(discount,0), and NULLIF for zero-guard as needed.

Solution
```sql
SELECT 
  row_id,
  CASE WHEN qty_txt REGEXP '^[0-9]+$' THEN CAST(qty_txt AS UNSIGNED) END AS qty,
  CAST(NULLIF(REPLACE(REPLACE(TRIM(price_txt),'$',''),',',''), '') AS DECIMAL(10,2)) AS price,
  CASE 
    WHEN discount_pct_txt REGEXP '^[0-9]+%$' THEN CAST(REPLACE(discount_pct_txt,'%','') AS DECIMAL(5,2))/100
    ELSE NULL
  END AS discount_pct,
  CASE 
    WHEN CAST(NULLIF(REPLACE(REPLACE(TRIM(price_txt),'$',''),',',''), '') AS DECIMAL(10,2)) IS NULL THEN NULL
    ELSE CAST(NULLIF(REPLACE(REPLACE(TRIM(price_txt),'$',''),',',''), '') AS DECIMAL(10,2)) * (1 - COALESCE(CASE WHEN discount_pct_txt REGEXP '^[0-9]+%$' THEN CAST(REPLACE(discount_pct_txt,'%','') AS DECIMAL(5,2))/100 END, 0))
  END AS net_price,
  CASE 
    WHEN (CASE WHEN qty_txt REGEXP '^[0-9]+$' THEN CAST(qty_txt AS UNSIGNED) END) IS NULL OR 
         (CAST(NULLIF(REPLACE(REPLACE(TRIM(price_txt),'$',''),',',''), '') AS DECIMAL(10,2)) IS NULL) 
      THEN NULL
    ELSE (CASE WHEN qty_txt REGEXP '^[0-9]+$' THEN CAST(qty_txt AS UNSIGNED) END) *
         (CAST(NULLIF(REPLACE(REPLACE(TRIM(price_txt),'$',''),',',''), '') AS DECIMAL(10,2)) * (1 - COALESCE(CASE WHEN discount_pct_txt REGEXP '^[0-9]+%$' THEN CAST(REPLACE(discount_pct_txt,'%','') AS DECIMAL(5,2))/100 END, 0)))
  END AS total_revenue
FROM ip_sales_import
ORDER BY row_id;
```

Performance note: For production, consider staged cleanup in temporary columns or views to avoid repeating expressions, and add CHECK constraints where supported.
