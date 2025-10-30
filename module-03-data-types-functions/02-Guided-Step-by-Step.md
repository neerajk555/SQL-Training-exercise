# Guided Step-by-Step (Data Types & Functions)

Three 15–20 minute activities. Practice cleansing and transforming data with MySQL functions.

---

## Activity 1: Clean Messy Prices for Display
- Business context: The catalog team has prices stored with symbols and commas. Produce clean numeric prices and a display-friendly format.
- Database setup
```sql
DROP TABLE IF EXISTS gss_price_clean;
CREATE TABLE gss_price_clean (
  sku VARCHAR(10) PRIMARY KEY,
  raw_price VARCHAR(20)
);
INSERT INTO gss_price_clean VALUES
('A1','$1,299.95'),
('A2',' 799.5 '),
('A3','N/A'),
('A4','$12'),
('A5','0');
```
- Final goal: Return `sku`, `numeric_price` (DECIMAL(10,2)) parsed from `raw_price`, and `display_price` rounded to 2 dp. Non-parsable values become NULL.

Step-by-step with checkpoints
1) Strip `$` and commas using REPLACE; trim spaces.
   - Checkpoint: `'$1,299.95'` becomes `1299.95`.
2) Guard against 'N/A' or empty string using NULLIF and a whitelist REGEXP.
   - Checkpoint: Non-numeric strings convert to NULL.
3) CAST cleaned string to DECIMAL(10,2).
   - Checkpoint: Numeric precision is 2 decimals.
4) Create a display alias rounded to 2 dp.
   - Checkpoint: Display shows 799.50 not 799.5.

Common mistakes
- Casting directly from `raw_price` (fails or coerces unexpectedly).
- Forgetting to NULLIF empty strings or 'N/A'.
- Using `ROUND()` after casting to INT (loses decimals).

Complete solution (with comments)
```sql
SELECT 
  sku,
  -- 1) Remove symbols/commas and trim
  CAST(
    NULLIF(
      -- 2) Replace currency symbols and commas
      REPLACE(REPLACE(TRIM(raw_price), '$', ''), ',', ''),
      ''
    ) AS DECIMAL(10,2)
  ) AS numeric_price,
  -- 4) Display rounded price (note: numeric_price already 2 dp)
  ROUND(
    CAST(
      NULLIF(REPLACE(REPLACE(TRIM(raw_price),'$',''),',',''), '') AS DECIMAL(10,2)
    ), 2
  ) AS display_price
FROM gss_price_clean
-- Optional: turn 'N/A' into NULLs before REPLACE with CASE/NULLIF
;
```

Discussion questions
- When might you choose `DECIMAL(10,2)` over `DOUBLE`?
- How would you handle different currency symbols/locales?

---

## Activity 2: Normalize Names and Emails
- Business context: Support wants standardized names and emails for outbound messages.
- Database setup
```sql
DROP TABLE IF EXISTS gss_contacts;
CREATE TABLE gss_contacts (
  id INT PRIMARY KEY,
  first_name VARCHAR(40),
  last_name VARCHAR(40),
  email VARCHAR(80)
);
INSERT INTO gss_contacts VALUES
(1,'  ava ','BROWN',' Ava.Brown@Example.com '),
(2,'NOAH','smith','Noah@Example.com'),
(3,'Mia',NULL,'  '),
(4,NULL,'Park','park@example.com');
```
- Final goal: Return `full_name` in "Last, First" with proper casing, and `normalized_email` as lower-trimmed or 'N/A' if blank/NULL.

Step-by-step with checkpoints
1) Trim name and email fields.
   - Checkpoint: Leading/trailing spaces removed.
2) Proper-case names with `CONCAT(UPPER(LEFT(..,1)), LOWER(SUBSTRING(..,2)))` handling NULL safely with COALESCE('').
   - Checkpoint: "BROWN" → "Brown".
3) Build `full_name` as `last, first` and collapse blanks to NULL using NULLIF.
   - Checkpoint: Rows with missing names don’t produce dangling commas.
4) Normalize email: `LOWER(TRIM(email))`, then NULLIF to '', and COALESCE to 'N/A'.
   - Checkpoint: Empty/NULL become 'N/A'.

Common mistakes
- Using `= ''` on NULLs.
- Not handling NULL before string functions (returns NULL entire expression).

Complete solution (with comments)
```sql
SELECT 
  -- Proper-case helper
  CONCAT(
    NULLIF(
      CONCAT(
        CASE WHEN last_name IS NULL THEN '' ELSE CONCAT(UPPER(LEFT(TRIM(last_name),1)), LOWER(SUBSTRING(TRIM(last_name),2))) END,
        ', ',
        CASE WHEN first_name IS NULL THEN '' ELSE CONCAT(UPPER(LEFT(TRIM(first_name),1)), LOWER(SUBSTRING(TRIM(first_name),2))) END
      ),
      ', '
    )
  ) AS full_name,
  COALESCE(NULLIF(LOWER(TRIM(email)), ''), 'N/A') AS normalized_email
FROM gss_contacts;
```

Discussion questions
- Would you store normalized values or compute on read?
- How might diacritics or non-Latin scripts affect casing logic?

---

## Activity 3: Appointment Durations and Buckets
- Business context: A clinic wants to estimate time slots and categorize duration.
- Database setup
```sql
DROP TABLE IF EXISTS gss_appt_time;
CREATE TABLE gss_appt_time (
  appt_id INT PRIMARY KEY,
  start_dt DATETIME,
  end_dt DATETIME
);
INSERT INTO gss_appt_time VALUES
(1,'2025-03-01 09:00:00','2025-03-01 09:30:00'),
(2,'2025-03-01 10:00:00','2025-03-01 11:15:00'),
(3,'2025-03-01 13:00:00',NULL);
```
- Final goal: Return `appt_id`, minutes duration using `TIMESTAMPDIFF(MINUTE, start_dt, end_dt)` as `mins`, and a bucket `short` (<=30), `standard` (31–60), `long` (>60), with '-' when end_dt is NULL.

Step-by-step with checkpoints
1) Compute duration minutes with TIMESTAMPDIFF; end_dt NULL yields NULL.
   - Checkpoint: Row 3 shows NULL.
2) Build CASE for buckets based on minutes.
   - Checkpoint: 30 → short; 75 → long.
3) COALESCE bucket to '-' when duration is NULL.
   - Checkpoint: Row 3 shows '-'.
4) Order by start_dt.

Common mistakes
- Using DATEDIFF for minutes (returns days, not minutes).
- Not handling NULL end_dt.

Complete solution (with comments)
```sql
SELECT 
  appt_id,
  TIMESTAMPDIFF(MINUTE, start_dt, end_dt) AS mins,
  COALESCE(
    CASE 
      WHEN TIMESTAMPDIFF(MINUTE, start_dt, end_dt) <= 30 THEN 'short'
      WHEN TIMESTAMPDIFF(MINUTE, start_dt, end_dt) <= 60 THEN 'standard'
      WHEN TIMESTAMPDIFF(MINUTE, start_dt, end_dt)  > 60 THEN 'long'
    END, '-'
  ) AS duration_bucket
FROM gss_appt_time
ORDER BY start_dt;
```

Discussion questions
- How would time zones affect these calculations?
- Would storing duration as an INT column be helpful for reporting?
