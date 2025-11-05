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

**Data Consolidation**: Merging data from multiple sources or partitions
- *Example:* Combining customer data from acquired companies into one master list
- *Use:* UNION or UNION ALL

**Deduplication**: Using UNION to remove duplicates across tables
- *Example:* You have customer emails in 3 different systems—create one clean list
- *Use:* UNION (automatically removes duplicates)

**Finding Overlaps**: Finding common records between datasets
- *Example:* "Which customers bought from us both online AND in-store?"
- *Use:* INTERSECT or INNER JOIN

**Finding Exclusions**: Identifying records that exist in one table but not another
- *Example:* "Which products are in our catalog but have never been ordered?"
- *Use:* EXCEPT or LEFT JOIN...IS NULL

**Reporting**: Combining different query results into one report
- *Example:* Create a dashboard showing active users, inactive users, and banned users all in one view
- *Use:* UNION ALL with labels

**Historical Analysis**: Merging current and historical data
- *Example:* Combine last year's sales data with this year's for a trend report
- *Use:* UNION ALL (keep all records to see full history)

**Beginner Tip:** When planning your query, ask yourself: "Am I combining, finding overlaps, or finding differences?" This tells you which operation to use!

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

## Syntax Summary

```sql
-- Basic UNION
SELECT column1, column2 FROM table1
UNION
SELECT column1, column2 FROM table2;

-- Multiple set operations
SELECT id FROM table_a
UNION ALL
SELECT id FROM table_b
UNION
SELECT id FROM table_c;

-- With ORDER BY
SELECT name, dept FROM employees
UNION
SELECT name, dept FROM contractors
ORDER BY dept, name;
```

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
