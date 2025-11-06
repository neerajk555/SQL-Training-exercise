# Quick Warm-Ups — Subqueries & CTEs (5–10 min each)

Each exercise includes a tiny setup, a task, expected output, and an answer. Run each in its own session.

##  Before You Start

### Learning Objectives
By completing these warm-ups, you will:
- Write scalar subqueries (return one value)
- Use EXISTS for semi-joins (check if related rows exist)
- Handle NOT IN vs NOT EXISTS with NULL safety
- Create CTEs with WITH clause for readable multi-step queries
- Understand correlated vs non-correlated subqueries

### Key Subquery Concepts for Beginners
**Types of Subqueries:**
1. **Scalar subquery**: Returns exactly one value (one row, one column)
   - Used in SELECT, WHERE, or HAVING
   - Example: `(SELECT AVG(price) FROM products)`

2. **Row subquery**: Returns one row with multiple columns
   - Example: `(SELECT MIN(price), MAX(price) FROM products)`

3. **Table subquery**: Returns multiple rows and columns
   - Used in FROM (derived table) or with IN/EXISTS
   - Example: `(SELECT category, AVG(price) FROM products GROUP BY category)`

**EXISTS vs IN:**
- `EXISTS`: Checks if any row exists (stops at first match—efficient!)
- `IN`: Checks if value matches any in a list
- `NOT IN` with NULLs: Returns no results! (Use NOT EXISTS instead)

**CTEs (Common Table Expressions):**
- Defined with WITH clause before main query
- Makes complex queries readable and testable
- Can reference earlier CTEs in the same WITH clause
- Syntax: `WITH cte_name AS (SELECT ...) SELECT ... FROM cte_name`

### Execution Tips
1. **Test inner queries first**: Run subquery separately to verify results
2. **Check for NULLs**: Use NOT EXISTS instead of NOT IN when NULLs possible
3. **CTEs for clarity**: Use WITH when query has multiple steps
4. **Correlated subqueries**: Reference outer table in inner query

**Beginner Tip:** Subqueries are queries inside queries. CTEs (WITH clause) make complex queries easier to read. EXISTS checks if a related row exists. These patterns help you break down complex problems into manageable pieces!

---

## 1) Scalar Subquery in SELECT — 7 min
Scenario: Show each product with its category name via scalar subquery.

**What You're Learning:**
A **scalar subquery** returns exactly ONE value (one row, one column). In this exercise, for each product row, we'll look up its category name by running a mini-query inside the SELECT clause.

**Why Use This Pattern:**
- When you need to fetch a related value without doing a JOIN
- Perfect for one-to-one or many-to-one relationships
- Makes the query more readable when you only need one related field

Sample data
```sql
DROP TABLE IF EXISTS wu6_categories;
CREATE TABLE wu6_categories (category_id INT PRIMARY KEY, name VARCHAR(40));
INSERT INTO wu6_categories VALUES (1,'stationery'),(2,'home');

DROP TABLE IF EXISTS wu6_products;
CREATE TABLE wu6_products (product_id INT PRIMARY KEY, category_id INT, name VARCHAR(60));
INSERT INTO wu6_products VALUES (10,1,'Notebook'),(11,2,'Lamp');
```
Task: Return product name and category (via subquery in SELECT).

Expected output
```
name     | category
Notebook | stationery
Lamp     | home
```

Solution
```sql
SELECT p.name,
  (SELECT c.name FROM wu6_categories c WHERE c.category_id = p.category_id) AS category
FROM wu6_products p
ORDER BY p.name;
```

**How It Works (Step-by-Step):**
1. For EACH product row in `wu6_products`, the outer query runs
2. The subquery `(SELECT c.name FROM wu6_categories c WHERE c.category_id = p.category_id)` executes
3. Notice `p.category_id` in the subquery - this references the outer query's current product row!
4. The subquery finds the matching category and returns just the category name
5. This single value becomes the "category" column in our result

**Alternative Approach:**
You could also use a JOIN: `SELECT p.name, c.name AS category FROM wu6_products p JOIN wu6_categories c ON c.category_id = p.category_id`
Both work! Use subqueries when you want to emphasize the "lookup one value" pattern.

---

## 2) EXISTS (semi-join) — 6 min
Scenario: List customers who have at least one order.

**What You're Learning:**
The **EXISTS** operator checks "does a related row exist?" It returns TRUE or FALSE, not actual data. It's super efficient because it stops searching as soon as it finds ONE matching row!

**Why Use EXISTS:**
- **Performance**: Stops at first match (doesn't count all matches like COUNT would)
- **Clarity**: "Give me customers WHO HAVE orders" is clear intent
- **NULL-safe**: Unlike IN, EXISTS handles NULL values correctly
- **No duplicates**: Returns each customer once, even if they have multiple orders

Sample data
```sql
DROP TABLE IF EXISTS wu6_customers;
CREATE TABLE wu6_customers (customer_id INT PRIMARY KEY, full_name VARCHAR(60));
INSERT INTO wu6_customers VALUES (1,'Ava'),(2,'Noah'),(3,'Mia');

DROP TABLE IF EXISTS wu6_orders;
CREATE TABLE wu6_orders (order_id INT PRIMARY KEY, customer_id INT);
INSERT INTO wu6_orders VALUES (100,1),(101,1),(102,2);
```
Task: Return full_name for customers with an order.

Expected output
```
full_name
Ava
Noah
```

Solution
```sql
SELECT c.full_name
FROM wu6_customers c
WHERE EXISTS (
  SELECT 1 FROM wu6_orders o WHERE o.customer_id = c.customer_id
)
ORDER BY c.full_name;
```

**How It Works (Step-by-Step):**
1. For EACH customer (Ava, Noah, Mia), check the WHERE EXISTS condition
2. The subquery looks for ANY order with matching customer_id
3. **For Ava**: Found order 100 → EXISTS returns TRUE → Include Ava ✓
4. **For Noah**: Found order 102 → EXISTS returns TRUE → Include Noah ✓
5. **For Mia**: No orders found → EXISTS returns FALSE → Exclude Mia ✗

**Why "SELECT 1"?**
We write `SELECT 1` because we don't care WHAT data exists, only IF it exists. The "1" is just a placeholder. You could write `SELECT *` or `SELECT order_id` - it makes no difference! EXISTS only checks if any rows match.

**Pattern Recognition:**
This is called a "semi-join" - we're filtering the customers table based on the existence of related rows in another table, without actually joining the tables together.

---

## 3) NOT IN vs NOT EXISTS with NULLs — 9 min
Scenario: Find products not ordered; ensure NULL-safety.

**What You're Learning:**
This is a **critical SQL gotcha!** The `NOT IN` operator has a dangerous trap with NULL values that can make your entire query return ZERO rows. `NOT EXISTS` is the safe alternative.

**The NULL Trap Explained:**
```sql
-- ❌ DANGEROUS: NOT IN with NULLs
WHERE product_id NOT IN (1, NULL)
-- This means: WHERE product_id != 1 AND product_id != NULL
-- But nothing equals NULL (not even NULL = NULL!)
-- So this ALWAYS returns FALSE → NO ROWS RETURNED!
```

**Why This Matters:**
In real databases, NULL values sneak in from:
- Optional foreign keys (not every order item links to a product)
- Data quality issues
- LEFT JOINs that didn't match
- If even ONE NULL exists in your NOT IN list, the whole query breaks!

Sample data
```sql
DROP TABLE IF EXISTS wu6_p;
CREATE TABLE wu6_p (product_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO wu6_p VALUES (1,'Notebook'),(2,'Lamp'),(3,'Mug');

DROP TABLE IF EXISTS wu6_oi;
CREATE TABLE wu6_oi (order_item_id INT PRIMARY KEY, product_id INT);
INSERT INTO wu6_oi VALUES (1,1),(2,NULL); -- note NULL product_id
```
Task: Return product names never appearing in order items.

Expected output
```
name
Lamp
Mug
```

Solution (prefer NOT EXISTS)
```sql
SELECT p.name
FROM wu6_p p
WHERE NOT EXISTS (
  SELECT 1 FROM wu6_oi oi WHERE oi.product_id = p.product_id
)
ORDER BY p.name;
-- Avoid NOT IN (SELECT product_id ... ) when subquery may return NULL.
```

**How It Works (Step-by-Step):**
1. **For Notebook (ID=1)**: Check if any order_item has product_id=1 → YES (row 1) → NOT EXISTS = FALSE → Exclude
2. **For Lamp (ID=2)**: Check if any order_item has product_id=2 → NO → NOT EXISTS = TRUE → Include ✓
3. **For Mug (ID=3)**: Check if any order_item has product_id=3 → NO → NOT EXISTS = TRUE → Include ✓
4. The NULL in order_items is safely ignored (NULL != 2 and NULL != 3)

**What Happens With NOT IN (WRONG!):**
```sql
-- ❌ THIS RETURNS ZERO ROWS!
SELECT p.name FROM wu6_p p
WHERE p.product_id NOT IN (SELECT product_id FROM wu6_oi);
-- Subquery returns (1, NULL)
-- "WHERE 2 NOT IN (1, NULL)" becomes "WHERE 2 != 1 AND 2 != NULL"
-- Since "2 != NULL" is UNKNOWN (not TRUE), the whole condition fails
```

**Golden Rule:**
🌟 **Always use NOT EXISTS for "anti-joins" (finding rows that DON'T have a match)**
🌟 **Only use NOT IN when you're 100% certain there are no NULLs**

---

## 4) Derived Table (FROM subquery) — 7 min
Scenario: Count orders per customer using a subquery in FROM.

**What You're Learning:**
A **derived table** is a subquery in the FROM clause that creates a temporary result set. Think of it as creating a "virtual table on the fly" that you can join to other tables!

**Why Use Derived Tables:**
- **Pre-aggregate before joining**: Calculate summaries first, then join
- **Avoid row explosion**: GROUP BY in subquery prevents duplicate rows
- **Multi-step logic**: Break complex queries into manageable pieces
- **Must have an alias**: The `t` in `AS t` is required in MySQL!

Sample data
```sql
-- reuse wu6_customers and wu6_orders from #2
```
Task: Return customer name and order_count using a derived table alias t.

Expected output
```
full_name | order_count
Ava       | 2
Mia       | 0
Noah      | 1
```

Solution
```sql
SELECT c.full_name, COALESCE(t.order_count,0) AS order_count
FROM wu6_customers c
LEFT JOIN (
  SELECT o.customer_id, COUNT(*) AS order_count
  FROM wu6_orders o
  GROUP BY o.customer_id
) t ON t.customer_id = c.customer_id
ORDER BY c.full_name;
```

**How It Works (Step-by-Step):**
1. **Inner subquery runs FIRST**: 
   ```sql
   SELECT customer_id, COUNT(*) FROM wu6_orders GROUP BY customer_id
   -- Results: (1, 2), (2, 1)  ← This becomes our "table t"
   ```
2. **LEFT JOIN to customers**: Now we join this summarized data to customers
3. **COALESCE handles NULLs**: Mia has no orders, so t.order_count is NULL → convert to 0

**Why LEFT JOIN?**
- `LEFT JOIN` keeps ALL customers, even those with no orders
- If we used `INNER JOIN`, Mia would disappear from results
- For customers with no orders, the joined columns are NULL

**Breaking Down the Derived Table:**
```sql
(
  SELECT o.customer_id, COUNT(*) AS order_count  ← What to calculate
  FROM wu6_orders o                               ← Source data
  GROUP BY o.customer_id                          ← Summarize per customer
) t                                                ← REQUIRED alias!
```

**Common Mistake:**
```sql
-- ❌ ERROR: Derived table must have alias
LEFT JOIN (SELECT ...) ON ...

-- ✓ CORRECT: Must add alias "t"
LEFT JOIN (SELECT ...) t ON ...
```

---

## 5) Simple CTE for Staging — 8 min
Scenario: Stage active students, then count enrollments.

**What You're Learning:**
A **CTE (Common Table Expression)** is like giving a name to a subquery using the `WITH` clause. It makes your query more readable by breaking it into logical steps!

**Why Use CTEs:**
- **Readability**: Named steps are easier to understand than nested subqueries
- **Reusability**: Reference the same CTE multiple times in one query
- **Testing**: Run just the CTE part to verify intermediate results
- **Maintainability**: Easier to modify and debug complex queries

**CTE vs Derived Table:**
```sql
-- Derived table (harder to read)
SELECT ... FROM table1 JOIN (SELECT ...) t ON ...

-- CTE (clearer intent)
WITH my_summary AS (SELECT ...)
SELECT ... FROM table1 JOIN my_summary ON ...
```

Sample data
```sql
DROP TABLE IF EXISTS wu6_students;
CREATE TABLE wu6_students (student_id INT PRIMARY KEY, name VARCHAR(60), active TINYINT);
INSERT INTO wu6_students VALUES (1,'Ava',1),(2,'Noah',0),(3,'Mia',1);

DROP TABLE IF EXISTS wu6_enrollments;
CREATE TABLE wu6_enrollments (student_id INT, course_code VARCHAR(10));
INSERT INTO wu6_enrollments VALUES (1,'CS101'),(3,'DS201'),(3,'CS101');
```
Task: Using a CTE `active_students`, return name and enrollment_count for active students only.

Expected output
```
name | enrollment_count
Ava  | 1
Mia  | 2
```

Solution
```sql
WITH active_students AS (
  SELECT student_id, name FROM wu6_students WHERE active = 1
)
SELECT a.name, COUNT(e.course_code) AS enrollment_count
FROM active_students a
LEFT JOIN wu6_enrollments e ON e.student_id = a.student_id
GROUP BY a.name
ORDER BY a.name;
```

**How It Works (Step-by-Step):**
1. **WITH clause defines the CTE**: 
   ```sql
   WITH active_students AS (...)  ← Create a named temporary result set
   ```
2. **CTE filters active students**: Only students with active=1 (Ava and Mia)
3. **Main query uses the CTE**: Like it's a regular table - `FROM active_students a`
4. **LEFT JOIN counts enrollments**: Count courses for each active student
5. **Noah is excluded**: He's not active, so never makes it into the CTE

**Breaking Down the Query:**
```sql
WITH active_students AS (         ← Step 1: Define what "active students" means
  SELECT student_id, name 
  FROM wu6_students 
  WHERE active = 1
)                                 ← CTE ends here
SELECT a.name,                    ← Step 2: Use the CTE in main query
       COUNT(e.course_code) 
FROM active_students a            ← Reference CTE by name!
LEFT JOIN wu6_enrollments e ...
```

**Why COUNT(e.course_code) instead of COUNT(*):**
- `COUNT(e.course_code)` counts non-NULL enrollment records
- `COUNT(*)` would count the row even if there's no enrollment
- With LEFT JOIN, students with no enrollments still appear but e.course_code is NULL
- `COUNT(NULL)` = 0, which is what we want!

**Testing Your CTE:**
```sql
-- You can run just the CTE to see intermediate results:
WITH active_students AS (
  SELECT student_id, name FROM wu6_students WHERE active = 1
)
SELECT * FROM active_students;
-- Shows: (1, 'Ava'), (3, 'Mia')
```
