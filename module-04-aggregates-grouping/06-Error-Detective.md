# Error Detective: Aggregates & Grouping Bugs (5 challenges)

Each includes: scenario, sample data, broken query, error/symptom, expected output, guiding questions, and fixed solution.

**Beginner Tip:** GROUP BY errors are common when learning aggregates! The key rule: every non-aggregated column in SELECT must appear in GROUP BY. Run the broken queries and study the error messages—you'll quickly learn to spot and fix these patterns!

---

## Challenge 1: Non-aggregated Column in SELECT
Scenario: Count orders by status, but extra columns are selected.

Sample data
```sql
DROP TABLE IF EXISTS ed4_orders;
CREATE TABLE ed4_orders (
  id INT PRIMARY KEY,
  status VARCHAR(20),
  customer_id INT
);
INSERT INTO ed4_orders VALUES
(1,'processing',10),(2,'shipped',11),(3,'processing',12);
```
Broken query
```sql
SELECT status, customer_id, COUNT(*) AS cnt
FROM ed4_orders
GROUP BY status; -- BUG: ONLY_FULL_GROUP_BY will reject customer_id not in GROUP BY or aggregated
```
Error
- In ONLY_FULL_GROUP_BY mode: "is not in GROUP BY" error.

Fixed solution and explanation
```sql
SELECT status, COUNT(*) AS cnt
FROM ed4_orders
GROUP BY status;
```

---

## Challenge 2: HAVING vs WHERE Mix-up
Scenario: Keep only groups with total > 1.

Sample data
```sql
DROP TABLE IF EXISTS ed4_sales;
CREATE TABLE ed4_sales (
  category VARCHAR(30),
  qty INT
);
INSERT INTO ed4_sales VALUES
('A',1),('A',2),('B',1),('B',NULL);
```
Broken query
```sql
SELECT category, SUM(qty) AS total
FROM ed4_sales
WHERE SUM(qty) > 1 -- BUG: aggregate not allowed in WHERE
GROUP BY category;
```
Fixed solution and explanation
```sql
SELECT category, SUM(qty) AS total
FROM ed4_sales
GROUP BY category
HAVING SUM(qty) > 1;
```

---

## Challenge 3: COUNT(*) and NULL Misunderstanding
Scenario: Count items, expecting NULLs excluded.

Sample data
```sql
DROP TABLE IF EXISTS ed4_items;
CREATE TABLE ed4_items (
  id INT PRIMARY KEY,
  item VARCHAR(20)
);
INSERT INTO ed4_items VALUES
(1,NULL),(2,'Pen'),(3,'Notebook');
```
Broken query
```sql
SELECT COUNT(*) AS cnt FROM ed4_items; -- BUG: COUNT(*) counts NULL rows too
```
Expected output
```
cnt
---
2
```
Fixed solution and explanation
```sql
SELECT COUNT(item) AS cnt
FROM ed4_items; -- COUNT(column) ignores NULLs
```

---

## Challenge 4: GROUP_CONCAT Without ORDER
Scenario: Need deterministic order in concatenated list.

Sample data
```sql
DROP TABLE IF EXISTS ed4_concat;
CREATE TABLE ed4_concat (
  grp VARCHAR(10),
  val INT
);
INSERT INTO ed4_concat VALUES
('X',3),('X',1),('X',2);
```
Broken query
```sql
SELECT grp, GROUP_CONCAT(val) AS list
FROM ed4_concat
GROUP BY grp; -- BUG: order unspecified
```
Expected output
```
grp | list
----+-----
X   | 1,2,3
```
Fixed solution and explanation
```sql
SELECT grp, GROUP_CONCAT(val ORDER BY val SEPARATOR ',') AS list
FROM ed4_concat
GROUP BY grp;
```

---

## Challenge 5: Rounding After Averaging
Scenario: Show average price to 2 decimals, but rounding is off when ordering.

Sample data
```sql
DROP TABLE IF EXISTS ed4_avg;
CREATE TABLE ed4_avg (
  dept VARCHAR(10),
  price DECIMAL(7,2)
);
INSERT INTO ed4_avg VALUES
('A',10.00),('A',10.10),('B',10.05);
```
Broken query
```sql
SELECT dept, ROUND(AVG(price),2) AS avg_price
FROM ed4_avg
GROUP BY dept
ORDER BY avg_price DESC; -- BUG: ok but note ROUND affects displayed value only; ensure consistent tie-breaking
```
Expected output
```
dept | avg_price
-----+----------
A    | 10.05
B    | 10.05
```
Fixed solution and explanation
```sql
SELECT dept, ROUND(AVG(price),2) AS avg_price
FROM ed4_avg
GROUP BY dept
ORDER BY AVG(price) DESC, dept; -- Order by true aggregate then display rounded
```
