# Take-Home Challenges (Advanced, Data Types & Functions)

Three multi-part exercises using MySQL functions for robust cleaning and transformation. Each has an open-ended component and detailed solutions with trade-offs.

**Beginner Tip:** These are advanced! Take your time—it's okay to spend multiple sessions on one challenge. Break each part into smaller steps. Test your queries incrementally. These exercises mimic real-world data work, so struggle is part of learning!

---

## Challenge 1: Marketing Contacts Normalization (40–50 min)
Scenario: Build a clean contacts export from messy inputs.

Schema and sample data
```sql
DROP TABLE IF EXISTS thc3_contacts;
CREATE TABLE thc3_contacts (
  id INT PRIMARY KEY,
  first VARCHAR(40),
  last VARCHAR(40),
  email VARCHAR(80),
  phone VARCHAR(30)
);
INSERT INTO thc3_contacts VALUES
(1,' ava ','BROWN',' Ava.Brown@Example.com ','(555) 100-2000 '),
(2,'NOAH','smith','Noah@Example.com','+1-555-300-4444'),
(3,'Mia',NULL,'  ','555.000.9999'),
(4,NULL,'Park','park@example.com',NULL);
```
Parts
A) Normalize names to proper case; build `full_name` as `Last, First` without dangling commas.
B) Normalize email to lower-trimmed or 'N/A' when blank/NULL.
C) Normalize phone to digits-only (keep leading `+` if present). Output `phone_norm`.
D) Open-ended: Propose validation (e.g., min length) and show how you’d mark invalid phones as NULL.

Solutions and notes
```sql
-- A + B
SELECT 
  id,
  NULLIF(
    CONCAT(
      CASE WHEN last IS NULL THEN '' ELSE CONCAT(UPPER(LEFT(TRIM(last),1)), LOWER(SUBSTRING(TRIM(last),2))) END,
      CASE WHEN first IS NULL THEN '' ELSE CONCAT(', ', CONCAT(UPPER(LEFT(TRIM(first),1)), LOWER(SUBSTRING(TRIM(first),2)))) END
    ), ''
  ) AS full_name,
  COALESCE(NULLIF(LOWER(TRIM(email)), ''), 'N/A') AS email_norm
FROM thc3_contacts;

-- C (MySQL 8.0+ REGEXP_REPLACE; fallback: nested REPLACE)
SELECT 
  id,
  CASE 
    WHEN phone LIKE '+%' THEN CONCAT('+', REGEXP_REPLACE(SUBSTRING(phone,2),'[^0-9]',''))
    WHEN phone IS NULL THEN NULL
    ELSE REGEXP_REPLACE(phone,'[^0-9]','')
  END AS phone_norm
FROM thc3_contacts;

-- D (validate: length >= 10 digits after removing non-digits)
SELECT 
  id,
  CASE 
    WHEN phone IS NULL THEN NULL
    ELSE CASE 
      WHEN LENGTH(REGEXP_REPLACE(phone,'[^0-9]','')) < 10 THEN NULL
      ELSE REGEXP_REPLACE(phone,'[^0-9]','')
    END
  END AS phone_validated
FROM thc3_contacts;
```
Trade-offs
- REGEXP_REPLACE requires MySQL 8.0+; earlier versions need nested REPLACE calls.
- Validation rules vary by country; consider library support upstream.

---

## Challenge 2: Product Pricing and Promotions (45–55 min)
Scenario: Parse prices, apply percentage discounts from text, and present display strings.

Schema and sample data
```sql
DROP TABLE IF EXISTS thc3_pricing;
CREATE TABLE thc3_pricing (
  sku VARCHAR(10) PRIMARY KEY,
  name VARCHAR(60),
  price_txt VARCHAR(20),
  promo_txt VARCHAR(10) -- like '10%'
);
INSERT INTO thc3_pricing VALUES
('A1','Notebook','$4.99','10%'),
('A2','Lamp',' 12.00 ','0%'),
('A3','Mug','N/A',NULL),
('A4','Mat','$24.50','5%');
```
Parts
A) Parse `price` from `price_txt` to DECIMAL(10,2), NULL when invalid.
B) Parse `promo_pct` from `promo_txt` as decimal 0..1.
C) Compute `net_price = price * (1 - COALESCE(promo_pct,0))` and a `display_price` as a formatted string like `$4.49` using CONCAT and FORMAT/ROUND.
D) Open-ended: Propose how rounding should be handled for financial reporting vs display.

Solutions and notes
```sql
-- A + B + C
SELECT 
  sku, name,
  CAST(NULLIF(REPLACE(REPLACE(TRIM(price_txt),'$',''),',',''), '') AS DECIMAL(10,2)) AS price,
  CASE WHEN promo_txt REGEXP '^[0-9]+%$' THEN CAST(REPLACE(promo_txt,'%','') AS DECIMAL(5,2))/100 END AS promo_pct,
  ROUND(
    CAST(NULLIF(REPLACE(REPLACE(TRIM(price_txt),'$',''),',',''), '') AS DECIMAL(10,2)) * (1 - COALESCE(CASE WHEN promo_txt REGEXP '^[0-9]+%$' THEN CAST(REPLACE(promo_txt,'%','') AS DECIMAL(5,2))/100 END, 0)),
    2
  ) AS net_price,
  CONCAT('$', FORMAT(
    CAST(NULLIF(REPLACE(REPLACE(TRIM(price_txt),'$',''),',',''), '') AS DECIMAL(10,2)) * (1 - COALESCE(CASE WHEN promo_txt REGEXP '^[0-9]+%$' THEN CAST(REPLACE(promo_txt,'%','') AS DECIMAL(5,2))/100 END, 0)),
    2
  )) AS display_price
FROM thc3_pricing;
```
Trade-offs
- FORMAT adds thousand separators and returns string; use ROUND for numeric precision.
- Consider using DECIMAL everywhere for money to avoid floating-point rounding issues.

---

## Challenge 3: Order Windowing and Labels (50–60 min)
Scenario: Parse mixed date formats, filter by quarter, and label orders.

Schema and sample data
```sql
DROP TABLE IF EXISTS thc3_orders;
CREATE TABLE thc3_orders (
  id INT PRIMARY KEY,
  order_dt_txt VARCHAR(20),
  status VARCHAR(20)
);
INSERT INTO thc3_orders VALUES
(1,'2025-04-01','processing'),
(2,'04/15/2025','shipped'),
(3,'2025.05.10','cancelled'),
(4,'05-20-2025','processing'),
(5,'2025-06-30','shipped');
```
Parts
A) Parse `order_dt` from `order_dt_txt` with multiple `STR_TO_DATE` patterns.
B) Filter to Q2 2025 (April–June inclusive).
C) Derive `month_label` using `DATE_FORMAT(order_dt, '%M %Y')` and `status_label` via CASE mapping 'processing' → 'in-progress', others unchanged.
D) Open-ended: Suggest how to persist parsed dates for reuse in later modules (CTEs, views, generated columns).

Solutions and notes
```sql
-- A + B + C
SELECT 
  id,
  COALESCE(
    STR_TO_DATE(order_dt_txt, '%Y-%m-%d'),
    STR_TO_DATE(order_dt_txt, '%m/%d/%Y'),
    STR_TO_DATE(order_dt_txt, '%Y.%m.%d'),
    STR_TO_DATE(order_dt_txt, '%m-%d-%Y')
  ) AS order_dt,
  DATE_FORMAT(
    COALESCE(
      STR_TO_DATE(order_dt_txt, '%Y-%m-%d'),
      STR_TO_DATE(order_dt_txt, '%m/%d/%Y'),
      STR_TO_DATE(order_dt_txt, '%Y.%m.%d'),
      STR_TO_DATE(order_dt_txt, '%m-%d-%Y')
    ), '%M %Y'
  ) AS month_label,
  CASE WHEN status = 'processing' THEN 'in-progress' ELSE status END AS status_label
FROM thc3_orders
WHERE COALESCE(
        STR_TO_DATE(order_dt_txt, '%Y-%m-%d'),
        STR_TO_DATE(order_dt_txt, '%m/%d/%Y'),
        STR_TO_DATE(order_dt_txt, '%Y.%m.%d'),
        STR_TO_DATE(order_dt_txt, '%m-%d-%Y')
      ) BETWEEN '2025-04-01' AND '2025-06-30'
ORDER BY order_dt;
```
Trade-offs
- Repeating parsing logic is verbose; prefer views or generated columns for reuse.
- Ensure all expected formats are covered; otherwise NULLs drop out in filters.
