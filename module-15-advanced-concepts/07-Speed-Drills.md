# Speed Drills — Advanced Concepts

## Drill 1: JSON Query (30 seconds)
Extract the "status" field from JSON column.
```sql
SELECT JSON_EXTRACT(data, '$.status') FROM orders;
```

## Drill 2: Full-Text Search (30 seconds)
Find articles containing "database".
```sql
SELECT * FROM articles WHERE MATCH(content) AGAINST('database');
```

## Drill 3: Recursive CTE for Depth (45 seconds)
Write a recursive query to find max hierarchy depth.
```sql
WITH RECURSIVE depth AS (
  SELECT id, 0 AS lvl FROM t WHERE parent_id IS NULL
  UNION ALL
  SELECT t.id, d.lvl+1 FROM t JOIN depth d ON t.parent_id=d.id
)
SELECT MAX(lvl) FROM depth;
```

## Drill 4: JSON Update (45 seconds)
Add a field "verified":true to existing JSON.
```sql
UPDATE users SET data = JSON_SET(data, '$.verified', true);
```

## Drill 5: Full-Text Boolean Mode (60 seconds)
Find articles with "mysql" but not "oracle".
```sql
SELECT * FROM articles WHERE MATCH(content) AGAINST('+mysql -oracle' IN BOOLEAN MODE);
```

