# Quick Warm-Ups (Aggregates & Grouping)

Each exercise: 5–10 minutes. Copy sample data first.

##  Before You Start

### Learning Objectives
By completing these warm-ups, you will:
- Use aggregate functions (COUNT, SUM, AVG, MAX, MIN)
- Group data with GROUP BY for summary reports
- Filter aggregated results with HAVING
- Understand NULL behavior in aggregates
- Master the WHERE vs HAVING distinction

### Key Concepts for Beginners
**Aggregate Functions:**
- `COUNT(*)` counts all rows (including NULLs)
- `COUNT(column)` counts non-NULL values only
- `SUM`, `AVG`, `MIN`, `MAX` ignore NULL values
- Aggregates reduce multiple rows to a single summary value

**GROUP BY:**
- Groups rows with the same values together
- Each selected non-aggregated column MUST be in GROUP BY
- Use with aggregates to get summaries per group

**HAVING vs WHERE:**
- `WHERE` filters rows BEFORE grouping (use for non-aggregated conditions)
- `HAVING` filters groups AFTER aggregation (use for aggregated conditions)

### Execution Tips
1. **Run the setup** for each exercise (DROP + CREATE + INSERT)
2. **Try solving** before checking the solution
3. **Verify row counts** match expected output
4. **Experiment** by changing GROUP BY columns to see the effect

**Beginner Tip:** Aggregates (COUNT, SUM, AVG, MAX, MIN) help you summarize data. GROUP BY groups rows together before summarizing. HAVING filters groups after aggregation. These are powerful tools for reporting and analysis!

---

## 1) Count Orders
- Scenario: Get a quick order count.
- Sample data
```sql
DROP TABLE IF EXISTS qwu4_orders;
CREATE TABLE qwu4_orders (
  order_id INT PRIMARY KEY,
  status VARCHAR(20)
);
INSERT INTO qwu4_orders VALUES
(101,'processing'),(102,'shipped'),(103,'processing'),(104,'cancelled');
```
- Task: Count total orders.
- Expected output
```
order_count
-----------
4
```
- Time: 5 min
- Solution
```sql
SELECT COUNT(*) AS order_count
FROM qwu4_orders;
```

---

## 2) Average Price by Category
- Scenario: Estimate average price per category.
- Sample data
```sql
DROP TABLE IF EXISTS qwu4_products;
CREATE TABLE qwu4_products (
  product_id INT PRIMARY KEY,
  category VARCHAR(30),
  price DECIMAL(7,2)
);
INSERT INTO qwu4_products VALUES
(1,'home',12.00),(2,'home',18.00),(3,'stationery',4.99),(4,'stationery',3.75);
```
- Task: Return `category`, `AVG(price)` as `avg_price`, sorted by `avg_price` desc.
- Expected output
```
category   | avg_price
-----------+---------
home       | 15.00
stationery | 4.37
```
- Time: 5–7 min
- Solution
```sql
SELECT category, ROUND(AVG(price),2) AS avg_price
FROM qwu4_products
GROUP BY category
ORDER BY avg_price DESC;
```

---

## 3) Count by Status With HAVING
- Scenario: See only statuses with at least 2 orders.
- Sample data: Use `qwu4_orders`.
- Task: Show `status`, `COUNT(*)` as `cnt` for groups where cnt >= 2.
- Expected output
```
status     | cnt
-----------+----
processing | 2
```
- Time: 5–7 min
- Solution
```sql
SELECT status, COUNT(*) AS cnt
FROM qwu4_orders
GROUP BY status
HAVING COUNT(*) >= 2;
```

---

## 4) SUM With NULLs
- Scenario: Sum donations where some rows have NULL amounts.
- Sample data
```sql
DROP TABLE IF EXISTS qwu4_donations;
CREATE TABLE qwu4_donations (
  donor VARCHAR(40),
  amount DECIMAL(8,2)
);
INSERT INTO qwu4_donations VALUES
('Ava', 10.00), ('Ben', NULL), ('Ava', 15.50);
```
- Task: Sum per donor; NULLs should be ignored by SUM.
- Expected output
```
donor | total
------+------
Ava   | 25.50
Ben   | 0.00
```
- Time: 7–10 min
- Solution
```sql
SELECT donor, COALESCE(SUM(amount),0) AS total
FROM qwu4_donations
GROUP BY donor
ORDER BY donor;
```

---

## 5) COUNT(DISTINCT) Emails
- Scenario: How many unique emails are present?
- Sample data
```sql
DROP TABLE IF EXISTS qwu4_emails;
CREATE TABLE qwu4_emails (
  id INT PRIMARY KEY,
  email VARCHAR(80)
);
INSERT INTO qwu4_emails VALUES
(1,'a@x.com'),(2,'A@x.com'),(3,NULL),(4,'b@x.com');
```
- Task: Return `COUNT(DISTINCT LOWER(email))` as `unique_emails`, ignoring NULL.
- Expected output
```
unique_emails
-------------
2
```
- Time: 7–10 min
- Solution
```sql
SELECT COUNT(DISTINCT LOWER(email)) AS unique_emails
FROM qwu4_emails
WHERE email IS NOT NULL;
```

Performance note: On large tables, compute/store normalized email in a generated column and index it for faster distinct counts.
