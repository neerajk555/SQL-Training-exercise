# Error Detective — Set Operations (5 challenges)

## 📋 Before You Start

### Learning Objectives
By completing these error detective challenges, you will:
- Develop debugging skills for UNION, INTERSECT, EXCEPT queries
- Practice identifying column count mismatches and type incompatibilities
- Learn to recognize ORDER BY placement errors
- Build troubleshooting skills for set operations
- Understand common set operation pitfalls

### How to Approach Each Challenge
1. **Read scenario** - understand what sets need combining/comparing
2. **Run broken query** - observe error message
3. **Check column counts** - ensure all SELECTs have same number
4. **Verify data types** - ensure corresponding columns are compatible
5. **Check ORDER BY** - must be at the very end

**Detective Tip:** Read error messages carefully. Check column counts, data types, operator choice, and ORDER BY placement. Set operations are strict about structure!

---

## 🔍 Systematic Debugging Approach

When a set operation query fails, check in this order:

1. **Column Count**: Do all SELECTs return the same number of columns?
2. **Column Types**: Are column types compatible in the same positions?
3. **Operation Choice**: Did you use the right operation (UNION vs INTERSECT vs EXCEPT)?
4. **ORDER BY Placement**: Is ORDER BY at the very end (not in the middle)?
5. **Duplicate Handling**: Do you want UNION (remove dups) or UNION ALL (keep all)?

**Beginner Strategy:** When you see an error, don't panic! Read the error message—MySQL tells you exactly what's wrong. Then work through the checklist above.

---

## Challenge 1: The Missing Column Mystery

### Scenario
Combining product lists from two warehouses to create a unified inventory report.

### Sample Data
```sql
DROP TABLE IF EXISTS ed7_warehouse_east;
CREATE TABLE ed7_warehouse_east (product_id INT, product_name VARCHAR(60), quantity INT);
INSERT INTO ed7_warehouse_east VALUES (1,'Laptop',10),(2,'Mouse',50);

DROP TABLE IF EXISTS ed7_warehouse_west;
CREATE TABLE ed7_warehouse_west (product_id INT, product_name VARCHAR(60), quantity INT, location VARCHAR(20));
INSERT INTO ed7_warehouse_west VALUES (1,'Laptop',15,'WW-A'),(3,'Keyboard',30,'WW-B');
```

### Broken Query
```sql
SELECT product_id, product_name, quantity FROM ed7_warehouse_east
UNION
SELECT product_id, product_name, quantity, location FROM ed7_warehouse_west;
```

### Error Message
```
ERROR 1222 (21000): The used SELECT statements have a different number of columns
```

### Expected Output
```
product_id | product_name | quantity
1          | Laptop       | 10
1          | Laptop       | 15
2          | Mouse        | 50
3          | Keyboard     | 30
```

### Guiding Questions
1. How many columns does the first SELECT return? *(Count them: product_id, product_name, quantity = 3)*
2. How many columns does the second SELECT return? *(Count them: product_id, product_name, quantity, location = 4)*
3. What's the UNION rule about column counts? *(ALL SELECTs must return the SAME number of columns)*
4. What are your options to fix this? *(Either add a column to the first, or remove one from the second)*

### Solution
```sql
-- Fix: Match column counts by removing location from second SELECT
SELECT product_id, product_name, quantity 
FROM ed7_warehouse_east
UNION
SELECT product_id, product_name, quantity 
FROM ed7_warehouse_west;

-- Alternative: Add NULL placeholder for location in first SELECT
SELECT product_id, product_name, quantity, NULL AS location 
FROM ed7_warehouse_east
UNION
SELECT product_id, product_name, quantity, location 
FROM ed7_warehouse_west;
```

**Explanation:** 
UNION requires all SELECT statements to have the SAME number of columns. The first query has 3 columns, the second has 4. MySQL can't combine them because it doesn't know what to do with that extra column.

**Two Fixes:**
1. **Remove the extra column** from warehouse_west (if you don't need location)
2. **Add a placeholder column** to warehouse_east (if you want to keep location data)

**Which to choose?** 
- If location doesn't matter for your report → Remove it (Option 1)
- If you want location for west but east doesn't have it → Add NULL placeholder (Option 2)

**Learning Point:** Always ensure structural compatibility BEFORE combining with set operations!

---

## Challenge 2: The Disappearing Duplicates

### Scenario
Counting total customer contacts across email and phone campaigns for volume reporting.

### Sample Data
```sql
DROP TABLE IF EXISTS ed7_email_contacts;
CREATE TABLE ed7_email_contacts (customer_id INT, contact_date DATE);
INSERT INTO ed7_email_contacts VALUES (1,'2025-03-01'),(2,'2025-03-02'),(3,'2025-03-03');

DROP TABLE IF EXISTS ed7_phone_contacts;
CREATE TABLE ed7_phone_contacts (customer_id INT, contact_date DATE);
INSERT INTO ed7_phone_contacts VALUES (2,'2025-03-02'),(3,'2025-03-03'),(4,'2025-03-04');
```

### Broken Query
```sql
SELECT COUNT(*) AS total_contacts
FROM (
  SELECT customer_id, contact_date FROM ed7_email_contacts
  UNION
  SELECT customer_id, contact_date FROM ed7_phone_contacts
) AS all_contacts;
```

### Wrong Output
```
total_contacts
5
```

### Expected Output
```
total_contacts
7
```
(3 email + 4 phone = 7 total contact events, including duplicates)

### Guiding Questions
1. What's the difference between UNION and UNION ALL? *(UNION removes duplicates, UNION ALL keeps everything)*
2. Do we want to count duplicates here for "total contacts"? *(Yes! Each contact event matters, even if it's the same customer on the same date via different channels)*
3. Which operator removes duplicates? *(UNION removes them, which is why we're getting 5 instead of 7)*
4. Look at the data: Which customer-date pairs appear in BOTH tables? *(Customers 2 and 3 on their respective dates exist in both email and phone)*

### Solution
```sql
-- Fix: Use UNION ALL to keep all contacts including duplicates
SELECT COUNT(*) AS total_contacts
FROM (
  SELECT customer_id, contact_date FROM ed7_email_contacts
  UNION ALL
  SELECT customer_id, contact_date FROM ed7_phone_contacts
) AS all_contacts;
-- Result: 7 (3 + 4, duplicates kept)
```

**Explanation:** 
UNION automatically removes duplicate rows. When it sees the same customer_id AND contact_date from both tables, it treats them as duplicates and keeps only one.

**The Bug:**
- Email contacts: (1, 2025-03-01), (2, 2025-03-02), (3, 2025-03-03) = 3 rows
- Phone contacts: (2, 2025-03-02), (3, 2025-03-03), (4, 2025-03-04) = 4 rows
- Customer 2 on 2025-03-02 appears in BOTH → UNION keeps only 1 copy
- Customer 3 on 2025-03-03 appears in BOTH → UNION keeps only 1 copy
- Result: 1 + 2 + 3 + 4 = 5 unique customer-date combinations

**The Fix:**
Use UNION ALL to keep ALL contact events, treating each channel as a separate touchpoint.
- 3 email contacts + 4 phone contacts = 7 total contact events

**When to Use Each:**
- UNION → "How many unique customers were contacted?"
- UNION ALL → "How many total contact attempts were made?"

---

## Challenge 3: The ORDER BY Placement Problem

### Scenario
Listing all employees from two departments sorted by name.

### Sample Data
```sql
DROP TABLE IF EXISTS ed7_sales_dept;
CREATE TABLE ed7_sales_dept (emp_id INT, emp_name VARCHAR(60));
INSERT INTO ed7_sales_dept VALUES (1,'Alice'),(2,'Charlie');

DROP TABLE IF EXISTS ed7_marketing_dept;
CREATE TABLE ed7_marketing_dept (emp_id INT, emp_name VARCHAR(60));
INSERT INTO ed7_marketing_dept VALUES (3,'Bob'),(4,'Diana');
```

### Broken Query
```sql
(SELECT emp_id, emp_name FROM ed7_sales_dept ORDER BY emp_name)
UNION
(SELECT emp_id, emp_name FROM ed7_marketing_dept ORDER BY emp_name);
```

### Error Message
```
ERROR 1221 (HY000): Incorrect usage of UNION and ORDER BY
```

### Expected Output
```
emp_id | emp_name
1      | Alice
3      | Bob
2      | Charlie
4      | Diana
```

### Guiding Questions
1. Where should ORDER BY be placed with UNION?
2. Does ORDER BY inside parentheses apply to the combined result?
3. Can you sort each SELECT independently before combining?

### Solution
```sql
-- Fix: Move ORDER BY to the end (applies to combined result)
SELECT emp_id, emp_name FROM ed7_sales_dept
UNION
SELECT emp_id, emp_name FROM ed7_marketing_dept
ORDER BY emp_name;
```

**Explanation:** ORDER BY cannot be used inside individual SELECT statements when combined with UNION. It must be placed at the end and applies to the entire combined result set. Each individual SELECT doesn't need ordering—only the final result.

---

## Challenge 4: The Type Mismatch Trap

### Scenario
Combining customer IDs from two systems for reconciliation.

### Sample Data
```sql
DROP TABLE IF EXISTS ed7_system_a;
CREATE TABLE ed7_system_a (customer_id VARCHAR(10));
INSERT INTO ed7_system_a VALUES ('C001'),('C002'),('C003');

DROP TABLE IF EXISTS ed7_system_b;
CREATE TABLE ed7_system_b (customer_id INT);
INSERT INTO ed7_system_b VALUES (1001),(1002),(1003);
```

### Broken Query
```sql
SELECT customer_id FROM ed7_system_a
UNION
SELECT customer_id FROM ed7_system_b;
```

### Error/Warning
Query runs but results may be unexpected due to implicit type conversion. System B's integers are converted to strings.

### Current Output (MySQL does implicit conversion)
```
customer_id
1001
1002
1003
C001
C002
C003
```

### Better Approach
Explicitly handle type differences and label sources.

### Guiding Questions
1. Are the customer_id types the same in both tables?
2. Should they be combined as-is or standardized?
3. How can you identify which system each ID came from?

### Solution
```sql
-- Fix: Explicitly cast and add source labels
SELECT 
  customer_id,
  'System A' AS source
FROM ed7_system_a
UNION ALL
SELECT 
  CAST(customer_id AS CHAR) AS customer_id,
  'System B' AS source
FROM ed7_system_b
ORDER BY source, customer_id;

-- Alternative: Keep types separate and use UNION ALL with labels
SELECT 
  customer_id AS id,
  'System A (String)' AS source
FROM ed7_system_a
UNION ALL
SELECT 
  CONCAT('ID:', customer_id) AS id,
  'System B (Int)' AS source
FROM ed7_system_b;
```

**Explanation:** Combining different data types can lead to implicit conversions and confusing results. Best practice: explicitly cast to a common type (usually VARCHAR for IDs) and add source labels to track data origin. This prevents silent errors and makes results clearer.

---

## Challenge 5: The INTERSECT Alternative Mistake

### Scenario
Finding common products between two warehouses (MySQL 8.0.30 or earlier without native INTERSECT).

### Sample Data
```sql
DROP TABLE IF EXISTS ed7_wh_north;
CREATE TABLE ed7_wh_north (product_code VARCHAR(10), quantity INT);
INSERT INTO ed7_wh_north VALUES ('P001',10),('P002',20),('P002',15),('P003',5);

DROP TABLE IF EXISTS ed7_wh_south;
CREATE TABLE ed7_wh_south (product_code VARCHAR(10), quantity INT);
INSERT INTO ed7_wh_south VALUES ('P002',30),('P003',8),('P004',12);
```

### Broken Query (Attempting to simulate INTERSECT)
```sql
SELECT product_code FROM ed7_wh_north
INNER JOIN ed7_wh_south USING (product_code);
```

### Wrong Output
```
product_code
P002
P002
P002
P002
P003
```
(Duplicates due to cartesian product of matching rows)

### Expected Output
```
product_code
P002
P003
```

### Guiding Questions
1. Why are there duplicate results?
2. What happens when you JOIN tables with duplicate values?
3. How does INTERSECT handle duplicates?

### Solution
```sql
-- Fix 1: Add DISTINCT to eliminate duplicates
SELECT DISTINCT product_code 
FROM ed7_wh_north
INNER JOIN ed7_wh_south USING (product_code);
-- Result: P002, P003

-- Fix 2: Use IN subquery (also eliminates duplicates naturally)
SELECT DISTINCT product_code 
FROM ed7_wh_north
WHERE product_code IN (SELECT product_code FROM ed7_wh_south);

-- Fix 3: Use EXISTS (best for large tables)
SELECT DISTINCT product_code
FROM ed7_wh_north n
WHERE EXISTS (
  SELECT 1 FROM ed7_wh_south s 
  WHERE s.product_code = n.product_code
);

-- Note: MySQL 8.0.31+ supports native INTERSECT
-- SELECT product_code FROM ed7_wh_north
-- INTERSECT
-- SELECT product_code FROM ed7_wh_south;
```

**Explanation:** INNER JOIN produces a cartesian product of matching rows. If P002 appears twice in wh_north and once in wh_south, you get 2×1=2 result rows. If it appears twice in both, you get 2×2=4 rows. INTERSECT returns distinct values, so when simulating with JOIN, always add DISTINCT. EXISTS is often most efficient as it stops searching after finding the first match.

---

**Debugging Complete!** You've mastered common set operation pitfalls: column mismatches, UNION vs UNION ALL, ORDER BY placement, type compatibility, and INTERSECT simulation.

**Next Step:** Move to `07-Speed-Drills.md` for rapid-fire practice questions.
