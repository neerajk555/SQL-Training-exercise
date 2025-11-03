# Module 15 · Advanced MySQL Concepts

Explore advanced features: JSON, full-text search, recursive queries, and more.

## Key Topics:
### JSON Handling
```sql
-- Store and query JSON
CREATE TABLE users (id INT, profile JSON);
INSERT INTO users VALUES (1, '{"name":"Alice","age":30,"skills":["SQL","Python"]}');
SELECT JSON_EXTRACT(profile, '$.name') AS name FROM users;
SELECT * FROM users WHERE JSON_EXTRACT(profile, '$.age') > 25;
```

### Full-Text Search
```sql
CREATE FULLTEXT INDEX ft_content ON articles(title, body);
SELECT * FROM articles WHERE MATCH(title, body) AGAINST ('database optimization' IN NATURAL LANGUAGE MODE);
```

### Recursive CTEs
```sql
WITH RECURSIVE employee_hierarchy AS (
  SELECT emp_id, name, manager_id, 1 AS level FROM employees WHERE manager_id IS NULL
  UNION ALL
  SELECT e.emp_id, e.name, e.manager_id, h.level + 1
  FROM employees e JOIN employee_hierarchy h ON e.manager_id = h.emp_id
)
SELECT * FROM employee_hierarchy ORDER BY level, name;
```

## Modern Features:
- Generated (computed) columns
- CHECK constraints (MySQL 8.0.16+)
- Window functions (covered in Module 8)
- CTEs and recursive queries (Module 6)
