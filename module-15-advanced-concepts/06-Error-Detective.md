# Error Detective — Advanced Concepts

## Error 1: Invalid JSON Syntax
```sql
INSERT INTO t VALUES ('{"name": "Alice" "age": 30}');  -- Missing comma!
```
**Fix:** Validate JSON: `{"name": "Alice", "age": 30}`

## Error 2: Wrong JSON Path
```sql
SELECT JSON_EXTRACT(data, 'name') FROM t;  -- Missing $
```
**Fix:** Use `JSON_EXTRACT(data, '$.name')`

## Error 3: Full-Text Without Index
```sql
SELECT * FROM articles WHERE MATCH(content) AGAINST('search');
-- Error: No FULLTEXT index!
```
**Fix:** Create FULLTEXT index first.

## Error 4: Recursive CTE Without Base Case
```sql
WITH RECURSIVE cte AS (
  SELECT * FROM t WHERE id = parent_id  -- Infinite loop!
)
```
**Fix:** Proper base case and termination condition.

## Error 5: Generated Column with Non-Deterministic Function
```sql
CREATE TABLE t (
  id INT,
  created TIMESTAMP GENERATED ALWAYS AS (NOW())  -- Error!
);
```
**Fix:** Generated columns must be deterministic.

