# Module 07 · Set Operations

Set operations combine result sets from multiple SELECT statements. They're useful for merging data sources, finding common records, and identifying differences between datasets.

## Topics Covered

### 1. UNION and UNION ALL
- **UNION**: Combines results and removes duplicates
- **UNION ALL**: Combines results and keeps all rows (including duplicates)
- Column count and types must match across all SELECT statements
- Column names from the first SELECT are used
- Performance: UNION ALL is faster (no duplicate elimination)

```sql
-- UNION removes duplicates
SELECT product_id FROM inventory_a
UNION
SELECT product_id FROM inventory_b;

-- UNION ALL keeps duplicates
SELECT product_id FROM inventory_a
UNION ALL
SELECT product_id FROM inventory_b;
```

### 2. INTERSECT (MySQL 8.0.31+)
- Returns only rows that appear in ALL result sets
- Removes duplicates by default
- Useful for finding common elements

```sql
-- Find products in both warehouses
SELECT product_id FROM warehouse_a
INTERSECT
SELECT product_id FROM warehouse_b;
```

**Alternative for older MySQL:**
```sql
-- Simulate INTERSECT with INNER JOIN
SELECT DISTINCT a.product_id
FROM warehouse_a a
INNER JOIN warehouse_b b ON a.product_id = b.product_id;
```

### 3. EXCEPT/MINUS (MySQL 8.0.31+)
- Returns rows from the first result set that don't appear in the second
- Removes duplicates
- Useful for finding differences

```sql
-- Find products only in warehouse A
SELECT product_id FROM warehouse_a
EXCEPT
SELECT product_id FROM warehouse_b;
```

**Alternative for older MySQL:**
```sql
-- Simulate EXCEPT with LEFT JOIN ... IS NULL
SELECT DISTINCT a.product_id
FROM warehouse_a a
LEFT JOIN warehouse_b b ON a.product_id = b.product_id
WHERE b.product_id IS NULL;
```

### 4. Key Rules and Best Practices
- All SELECT statements must have the same number of columns
- Corresponding columns must have compatible data types
- Column names come from the first SELECT
- Use ORDER BY only at the end (applies to the combined result)
- Use parentheses for complex combinations
- UNION ALL is faster when duplicates don't matter

```sql
-- Correct: ORDER BY at the end
SELECT name, 'active' AS status FROM active_users
UNION
SELECT name, 'inactive' AS status FROM inactive_users
ORDER BY name;

-- Use parentheses for complex operations
(SELECT id FROM set_a UNION SELECT id FROM set_b)
INTERSECT
(SELECT id FROM set_c UNION SELECT id FROM set_d);
```

### 5. Common Use Cases
- **Data consolidation**: Merging data from multiple sources or partitions
- **Deduplication**: Using UNION to remove duplicates across tables
- **Comparison**: Finding common or unique records between datasets
- **Reporting**: Combining different query results into one report
- **Archival**: Merging current and historical data

### 6. Performance Considerations
- UNION requires sorting/comparing to eliminate duplicates (expensive)
- UNION ALL is much faster when duplicates are acceptable
- For INTERSECT/EXCEPT alternatives, indexes on join columns help
- Consider pre-filtering data before set operations
- Use DISTINCT in alternatives only if needed

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

## Practice Strategy
1. Start with simple UNION and UNION ALL examples
2. Practice column alignment and type compatibility
3. Learn INTERSECT/EXCEPT and their alternatives
4. Combine set operations with WHERE, GROUP BY, and subqueries
5. Apply to real-world scenarios like data merging and comparison

**Remember:** Set operations are powerful for combining and comparing datasets. Master the basics before combining them with other advanced SQL features!
