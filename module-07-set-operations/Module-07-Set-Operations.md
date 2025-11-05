# Module 07 · Set Operations

## What Are Set Operations?

**Simple Explanation:** Set operations let you combine, compare, or filter results from multiple queries. Think of them like working with circles in a Venn diagram—you can combine them (UNION), find overlaps (INTERSECT), or find what's unique to one side (EXCEPT).

**Real-World Analogy:** Imagine you have two customer lists—one from your online store and one from your physical store. Set operations help you:
- Combine both lists into one (UNION)
- Find customers who shop both online AND in-store (INTERSECT)  
- Find customers who ONLY shop online (EXCEPT)

Set operations combine result sets from multiple SELECT statements. They're useful for merging data sources, finding common records, and identifying differences between datasets.

### When Would You Use Set Operations?
- Merging data from different tables (like combining regional sales reports)
- Finding duplicates or overlaps between datasets
- Identifying records that exist in one table but not another
- Creating reports that pull from multiple sources
- Data cleanup and reconciliation tasks

## Topics Covered

### 1. UNION and UNION ALL

**The Difference Explained:**
- **UNION**: Combines results and removes duplicate rows (like merging two lists and crossing out repeats)
- **UNION ALL**: Combines results and keeps ALL rows, even if repeated (like stacking two lists together as-is)

**Think of it this way:**
- `UNION` = "Give me everything from both lists, but only list each unique item once"
- `UNION ALL` = "Give me everything from both lists, exactly as they are"

**Important Rules:**
- Column count must match: If query A returns 3 columns, query B must also return 3 columns
- Column types must be compatible: Can't combine a name (text) with a price (number) in the same position
- Column names from the first SELECT are used in the final result
- Performance tip: UNION ALL is faster because it doesn't need to check for and remove duplicates

```sql
-- UNION removes duplicates
-- If product_id 5 exists in BOTH tables, you'll see it only ONCE
SELECT product_id FROM inventory_a
UNION
SELECT product_id FROM inventory_b;

-- UNION ALL keeps duplicates  
-- If product_id 5 exists in BOTH tables, you'll see it TWICE
SELECT product_id FROM inventory_a
UNION ALL
SELECT product_id FROM inventory_b;
```

**When to use which?**
- Use `UNION` when you need a unique list (e.g., "show me all unique customers")
- Use `UNION ALL` when you need the total count or all records (e.g., "show me all transactions, even if someone made multiple purchases")

### 2. INTERSECT (MySQL 8.0.31+)

**What It Does:** Returns only the rows that appear in BOTH result sets—the overlap in the Venn diagram.

**Real-World Example:** "Show me products that are stocked in BOTH our east AND west warehouses" (the intersection of two inventories).

**Think of it as:** The AND operation—only items that satisfy BOTH conditions make it through.

- Returns only rows that appear in ALL result sets
- Removes duplicates by default  
- Perfect for finding commonalities

```sql
-- Find products in both warehouses
-- Only returns product_ids that exist in BOTH warehouse_a AND warehouse_b
SELECT product_id FROM warehouse_a
INTERSECT
SELECT product_id FROM warehouse_b;
```

**Alternative for older MySQL versions:**
If you're using MySQL before 8.0.31, INTERSECT isn't available. But you can achieve the same result with an INNER JOIN:

```sql
-- Simulate INTERSECT with INNER JOIN
-- INNER JOIN only keeps rows where there's a match in BOTH tables
SELECT DISTINCT a.product_id
FROM warehouse_a a
INNER JOIN warehouse_b b ON a.product_id = b.product_id;

-- Why this works: INNER JOIN returns only matching rows
-- DISTINCT removes any duplicates that might exist within the tables themselves
```

**Beginner Tip:** If you see "find items in both" or "common to all", think INTERSECT (or INNER JOIN for older MySQL).

### 3. EXCEPT/MINUS (MySQL 8.0.31+)

**What It Does:** Returns rows from the first result set that DON'T appear in the second—finding what's unique to the first set.

**Real-World Example:** "Show me products in warehouse A that are NOT in warehouse B" (items exclusive to one location).

**Think of it as:** The SUBTRACTION operation—take the first set and remove anything that also appears in the second set.

- Returns rows from the first result set that don't appear in the second
- Order matters: `A EXCEPT B` is different from `B EXCEPT A`
- Removes duplicates
- Perfect for finding differences or exclusions

```sql
-- Find products only in warehouse A (not in B)
-- Returns product_ids that exist in warehouse_a but NOT in warehouse_b
SELECT product_id FROM warehouse_a
EXCEPT
SELECT product_id FROM warehouse_b;
```

**Alternative for older MySQL versions:**
If you're using MySQL before 8.0.31, use this LEFT JOIN pattern:

```sql
-- Simulate EXCEPT with LEFT JOIN ... IS NULL
SELECT DISTINCT a.product_id
FROM warehouse_a a
LEFT JOIN warehouse_b b ON a.product_id = b.product_id
WHERE b.product_id IS NULL;

-- Why this works:
-- 1. LEFT JOIN keeps ALL rows from warehouse_a
-- 2. For rows without a match in warehouse_b, the b columns are NULL
-- 3. WHERE b.product_id IS NULL filters to ONLY the non-matching rows
-- 4. This gives us items in A but not in B
```

**Beginner Tip:** If you see "only in A" or "not in B" or "exclusive to", think EXCEPT (or LEFT JOIN...IS NULL for older MySQL).

### 4. Key Rules and Best Practices

**The Golden Rules (Memorize These!):**

1. **Same Column Count**: All SELECT statements must return the same number of columns
   - Wrong: `SELECT id, name` UNION `SELECT id` (2 columns vs 1 column ❌)
   - Right: `SELECT id, name` UNION `SELECT id, name` (2 columns vs 2 columns ✅)

2. **Compatible Data Types**: Columns in the same position must have compatible types
   - Wrong: `SELECT name` (text) UNION `SELECT price` (number) in same position ❌
   - Right: `SELECT name, price` UNION `SELECT name, price` (text with text, number with number ✅)

3. **Column Names from First Query**: The column names in your final result come from the FIRST SELECT
   - Even if later queries use different column names, the first one wins

4. **ORDER BY Goes at the End**: You can only sort the final combined result
   - Wrong: `SELECT * FROM a ORDER BY id UNION SELECT * FROM b` ❌
   - Right: `SELECT * FROM a UNION SELECT * FROM b ORDER BY id` ✅

5. **Use Parentheses for Clarity**: When combining multiple operations, use parentheses to show what happens first

6. **Performance Tip**: UNION ALL is much faster than UNION—only use UNION when you specifically need to remove duplicates

```sql
-- Correct: ORDER BY at the end, applies to entire result
SELECT name, 'active' AS status FROM active_users
UNION
SELECT name, 'inactive' AS status FROM inactive_users
ORDER BY name;  -- Sorts the combined result

-- Use parentheses for complex operations (easier to read and understand)
(SELECT id FROM set_a UNION SELECT id FROM set_b)
INTERSECT
(SELECT id FROM set_c UNION SELECT id FROM set_d);
```

**Common Beginner Mistakes:**
- ❌ Forgetting to match column counts
- ❌ Putting ORDER BY in the middle of a UNION
- ❌ Using UNION when UNION ALL would work (slower for no reason)
- ❌ Assuming column names from the second query will be used
- ✅ Test each SELECT separately before combining them!

### 5. Common Use Cases (When You'd Use This in Real Life)

**Understanding Through Real Examples:**

**1. Data Consolidation** - Merging data from multiple sources or partitions
- **Real-World Scenario:** Your company just acquired two competitors. You need to merge all three customer databases into one master list for your CRM system.
- **Why It Matters:** Without consolidation, your sales team doesn't know if they're calling the same customer multiple times!
- **Which Operation:** UNION (if you want one entry per unique customer) or UNION ALL (if you need to see all records including duplicates for auditing)
- **MySQL Example:**
  ```sql
  -- Combine customers from three companies
  SELECT customer_id, email, 'Company A' AS source FROM company_a_customers
  UNION ALL
  SELECT customer_id, email, 'Company B' AS source FROM company_b_customers
  UNION ALL
  SELECT customer_id, email, 'Company C' AS source FROM company_c_customers
  ORDER BY email;
  -- UNION ALL keeps all records with source tracking
  ```

**2. Deduplication** - Using UNION to automatically remove duplicates across tables
- **Real-World Scenario:** You have customer emails scattered across your marketing system, sales CRM, and support ticketing system. You need one clean mailing list for a company-wide announcement.
- **Why It Matters:** Sending 3 copies of the same email to one customer is annoying and unprofessional!
- **Which Operation:** UNION (automatically removes duplicate email addresses)
- **MySQL Example:**
  ```sql
  -- Create unified email list (no duplicates)
  SELECT email FROM marketing_contacts
  UNION
  SELECT email FROM sales_contacts
  UNION
  SELECT email FROM support_contacts
  ORDER BY email;
  -- If alice@example.com exists in all 3 tables, UNION keeps only 1 copy
  ```

**3. Finding Overlaps** - Identifying common records between datasets
- **Real-World Scenario:** You run both a physical store and an online store. Management wants to know: "How many customers shop with us BOTH ways?" These are your most loyal customers who deserve VIP treatment!
- **Why It Matters:** Multi-channel customers are usually more valuable—they buy more and stay longer.
- **Which Operation:** INTERSECT (MySQL 8.0.31+) or INNER JOIN (all versions)
- **MySQL Example (Compatible with all versions):**
  ```sql
  -- Find customers who bought both online AND in-store
  SELECT DISTINCT o.customer_id, o.customer_name
  FROM online_customers o
  INNER JOIN store_customers s ON o.customer_id = s.customer_id
  ORDER BY o.customer_id;
  -- INNER JOIN keeps only customer_ids that exist in BOTH tables
  -- These are your cross-channel shoppers!
  ```
- **Alternative with INTERSECT (MySQL 8.0.31+):**
  ```sql
  SELECT customer_id FROM online_customers
  INTERSECT
  SELECT customer_id FROM store_customers;
  ```

**4. Finding Exclusions** - Identifying records that exist in one place but not another
- **Real-World Scenario:** Your catalog has 500 products, but some have NEVER been ordered. These slow-moving items are tying up warehouse space and capital. Which products should you consider discontinuing?
- **Why It Matters:** Identifying dead inventory frees up cash and space for products that actually sell!
- **Which Operation:** EXCEPT (MySQL 8.0.31+) or LEFT JOIN...IS NULL (all versions)
- **MySQL Example (Compatible with all versions):**
  ```sql
  -- Find products in catalog but never ordered
  SELECT c.product_id, c.product_name, c.category
  FROM product_catalog c
  LEFT JOIN order_items o ON c.product_id = o.product_id
  WHERE o.product_id IS NULL
  ORDER BY c.category, c.product_name;
  -- LEFT JOIN keeps ALL products from catalog
  -- WHERE o.product_id IS NULL filters to only products with NO orders
  -- These are candidates for discontinuation!
  ```
- **Alternative with EXCEPT (MySQL 8.0.31+):**
  ```sql
  SELECT product_id FROM product_catalog
  EXCEPT
  SELECT product_id FROM order_items;
  ```

**5. Reporting** - Combining different query results into one unified report
- **Real-World Scenario:** Your boss wants a user status report showing: active users (logged in last 30 days), inactive users (31-90 days), and dormant users (90+ days) all in one view with clear labels.
- **Why It Matters:** Different user segments need different re-engagement strategies. This report helps prioritize outreach efforts.
- **Which Operation:** UNION ALL with status labels
- **MySQL Example:**
  ```sql
  -- User activity status report
  SELECT 
    user_id, 
    username, 
    last_login,
    'Active' AS status
  FROM users
  WHERE last_login >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
  
  UNION ALL
  
  SELECT 
    user_id, 
    username, 
    last_login,
    'Inactive' AS status
  FROM users
  WHERE last_login BETWEEN DATE_SUB(CURDATE(), INTERVAL 90 DAY) 
                      AND DATE_SUB(CURDATE(), INTERVAL 31 DAY)
  
  UNION ALL
  
  SELECT 
    user_id, 
    username, 
    last_login,
    'Dormant' AS status
  FROM users
  WHERE last_login < DATE_SUB(CURDATE(), INTERVAL 90 DAY)
  
  ORDER BY status, last_login DESC;
  -- UNION ALL keeps all users, status label shows which segment they're in
  ```

**6. Historical Analysis** - Merging current and historical data for trend analysis
- **Real-World Scenario:** Your sales data for this year is in the `sales_2025` table, but last year's is archived in `sales_2024`. You need to create a year-over-year comparison report showing sales trends.
- **Why It Matters:** Understanding trends helps predict future demand and plan inventory.
- **Which Operation:** UNION ALL (keep all records to see complete history)
- **MySQL Example:**
  ```sql
  -- Two-year sales history for trend analysis
  SELECT 
    sale_date,
    product_id,
    quantity,
    amount,
    2024 AS year
  FROM sales_2024
  
  UNION ALL
  
  SELECT 
    sale_date,
    product_id,
    quantity,
    amount,
    2025 AS year
  FROM sales_2025
  
  ORDER BY sale_date;
  -- UNION ALL combines both years' data
  -- Adding a 'year' column makes it easy to filter and group by year
  ```

**Beginner's Decision Tree:**

```
Question: What do I need to do?
│
├─ "Combine data from multiple tables into one list"
│  ├─ Need unique rows only? → Use UNION
│  └─ Need all rows including duplicates? → Use UNION ALL
│
├─ "Find items that exist in BOTH datasets"
│  └─ Use INTERSECT (MySQL 8.0.31+) or INNER JOIN (all versions)
│
├─ "Find items in A but NOT in B"
│  └─ Use EXCEPT (MySQL 8.0.31+) or LEFT JOIN...IS NULL (all versions)
│
└─ "Compare multiple datasets"
   └─ Combine operations: Use UNION/INTERSECT/EXCEPT together
```

**Pro Tip for Beginners:** When planning your query, always ask yourself: "Am I **combining**, **finding overlaps**, or **finding differences**?" This question tells you exactly which operation to use!

### 6. Performance Considerations (Making Your Queries Fast)

**Understanding Performance:**

**UNION vs UNION ALL Speed:**
- `UNION` is SLOW on large datasets—it must compare every row to find duplicates (like checking every item in two shopping carts to remove duplicates)
- `UNION ALL` is FAST—it just stacks the results together without any checking
- **Rule of thumb:** If you don't need duplicate removal, ALWAYS use UNION ALL

**Making Joins Faster (for INTERSECT/EXCEPT alternatives):**
- Create indexes on the columns you're joining on
- *Example:* If joining on `product_id`, make sure there's an index on `product_id` in both tables
- This helps the database quickly find matching rows

**Filter Early:**
- Add WHERE clauses to each SELECT statement to reduce data BEFORE combining
- Better: Filter to 1000 rows then combine, than combine 1 million rows then filter

```sql
-- SLOW: Combines everything, then filters
SELECT * FROM large_table_a
UNION ALL
SELECT * FROM large_table_b
WHERE status = 'active';  -- ❌ Wrong placement!

-- FAST: Filters first, then combines smaller result sets
SELECT * FROM large_table_a WHERE status = 'active'
UNION ALL
SELECT * FROM large_table_b WHERE status = 'active';  -- ✅ Filter early!
```

**Using DISTINCT Wisely:**
- Only use DISTINCT in JOIN alternatives when you actually have duplicates within a single table
- DISTINCT is expensive—it sorts and compares all rows
- If you know your data doesn't have duplicates, skip DISTINCT

**Beginner Tip:** Start with functionality (get it working), then optimize for performance. Don't guess—test with realistic data sizes!

## Visual Comparison: Set Operations Explained

**Think of Set Operations Like Venn Diagrams:**

```
Table A: {1, 2, 3}        Table B: {2, 3, 4}

UNION (Remove Duplicates):
Result: {1, 2, 3, 4} ← Only unique values
Explanation: Combines both sets, 2 and 3 appear only once

UNION ALL (Keep Everything):
Result: {1, 2, 3, 2, 3, 4} ← All values including duplicates
Explanation: Stacks both sets together as-is

INTERSECT (Only Common Items):
Result: {2, 3} ← Only items in BOTH sets
Explanation: The overlap in the Venn diagram

EXCEPT (A minus B):
Result: {1} ← Only items in A that aren't in B
Explanation: Items unique to set A
```

**Practical Example with Real Data:**

```
Online Store Customers: Alice, Bob, Carol
Physical Store Customers: Bob, Carol, Dave

UNION (Unique Customers Across All Channels):
→ Alice, Bob, Carol, Dave (4 unique customers)

UNION ALL (Total Customer Entries):
→ Alice, Bob, Carol, Bob, Carol, Dave (6 entries total)

INTERSECT (Customers Who Shop Both Ways):
→ Bob, Carol (cross-channel shoppers - your VIPs!)

EXCEPT (Online-Only Customers):
→ Alice (never visited physical store - send them a coupon!)
```

## Syntax Summary

```sql
-- Basic UNION (removes duplicates)
SELECT column1, column2 FROM table1
UNION
SELECT column1, column2 FROM table2;

-- UNION ALL (keeps all rows - faster!)
SELECT column1, column2 FROM table1
UNION ALL
SELECT column1, column2 FROM table2;

-- Multiple set operations (chain them together)
SELECT id FROM table_a
UNION ALL
SELECT id FROM table_b
UNION
SELECT id FROM table_c;  -- This UNION removes dupes from combined result

-- With ORDER BY (always at the end!)
SELECT name, dept FROM employees
UNION
SELECT name, dept FROM contractors
ORDER BY dept, name;  -- Sorts the final combined result

-- INTERSECT (MySQL 8.0.31+)
SELECT product_id FROM warehouse_a
INTERSECT
SELECT product_id FROM warehouse_b;

-- INTERSECT Alternative (All MySQL versions)
SELECT DISTINCT a.product_id
FROM warehouse_a a
INNER JOIN warehouse_b b ON a.product_id = b.product_id;

-- EXCEPT (MySQL 8.0.31+)
SELECT customer_id FROM all_customers
EXCEPT
SELECT customer_id FROM unsubscribed;

-- EXCEPT Alternative (All MySQL versions)
SELECT a.customer_id
FROM all_customers a
LEFT JOIN unsubscribed u ON a.customer_id = u.customer_id
WHERE u.customer_id IS NULL;
```

**MySQL Compatibility Quick Reference:**

| Operation | MySQL 5.7 | MySQL 8.0.0-8.0.30 | MySQL 8.0.31+ |
|-----------|-----------|---------------------|---------------|
| UNION | ✅ Yes | ✅ Yes | ✅ Yes |
| UNION ALL | ✅ Yes | ✅ Yes | ✅ Yes |
| INTERSECT | ❌ Use INNER JOIN | ❌ Use INNER JOIN | ✅ Yes |
| EXCEPT | ❌ Use LEFT JOIN | ❌ Use LEFT JOIN | ✅ Yes |

**Beginner's Syntax Checklist:**
- ✅ Same number of columns in all SELECTs
- ✅ Compatible data types in same positions
- ✅ ORDER BY at the very end (not in the middle)
- ✅ Parentheses optional but helpful for readability
- ✅ Column names from first SELECT are used in result

## Practice Strategy (Your Learning Path)

**Level 1: Foundation (Start Here)**
1. Practice simple UNION and UNION ALL with 2 tables
2. Get comfortable matching column counts and types
3. Understand when to use UNION vs UNION ALL

**Level 2: Comparisons**
3. Learn INTERSECT patterns (finding overlaps)
4. Master EXCEPT patterns (finding differences)
5. Practice the JOIN alternatives for older MySQL

**Level 3: Integration**
6. Combine set operations with WHERE clauses (filter before combining)
7. Add GROUP BY and aggregate functions
8. Use set operations within subqueries

**Level 4: Real-World Application**
9. Solve data consolidation problems
10. Practice data reconciliation scenarios
11. Build complex reports combining multiple sources

**Remember:** Set operations are powerful for combining and comparing datasets. Master the basics before combining them with other advanced SQL features!

## Quick Reference Card

```
UNION           → Combine + Remove Duplicates (slower)
UNION ALL       → Combine + Keep All Rows (faster)
INTERSECT       → Only Common Rows (overlap)
EXCEPT          → Rows in A but NOT in B (difference)

Rules: Same column count, compatible types, ORDER BY at end
```

**Next Steps:** Start with the Quick Warm-Ups to practice each operation, then progress through Guided exercises for real scenarios!
