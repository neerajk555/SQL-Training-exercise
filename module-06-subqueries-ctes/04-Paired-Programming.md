# Paired Programming — Subqueries & CTEs (30 min)

**Beginner Tip:** Complex queries benefit from two minds! Driver explains the nested logic step-by-step. Navigator ensures each subquery/CTE is tested before combining. Take turns—both roles develop different problem-solving muscles. Help each other succeed!

Roles
- Driver: types queries and explains each clause.
- Navigator: challenges assumptions, checks edge cases, and suggests quick validations.

Collaboration tips
- Switch roles after each part.
- Validate logic with tiny probes (COUNT(*), LIMIT 5) before final queries.

Schema (Employee hierarchy and projects)
```sql
DROP TABLE IF EXISTS pp6_employees;
CREATE TABLE pp6_employees (emp_id INT PRIMARY KEY, name VARCHAR(60), manager_id INT);
INSERT INTO pp6_employees VALUES
(1,'Alice',NULL),(2,'Bob',1),(3,'Cara',2),(4,'Drew',2),(5,'Evan',1);

DROP TABLE IF EXISTS pp6_projects;
CREATE TABLE pp6_projects (project_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO pp6_projects VALUES (10,'Apollo'),(20,'Zephyr');

DROP TABLE IF EXISTS pp6_assignments;
CREATE TABLE pp6_assignments (emp_id INT, project_id INT);
INSERT INTO pp6_assignments VALUES (2,10),(3,10),(5,20);
```

Parts
A) Semi-join: Employees assigned to any project (using EXISTS).
B) Scalar subquery: For each employee, show their manager name (or 'None').
C) Recursive CTE: For each employee, compute level in the org (root=0).

Role-switching points
- Switch after finishing Part A and again after Part B.

Solutions
```sql
-- A) Employees with a project (EXISTS)
SELECT e.name
FROM pp6_employees e
WHERE EXISTS (
  SELECT 1 FROM pp6_assignments a WHERE a.emp_id = e.emp_id
)
ORDER BY e.name;

-- B) Manager name via scalar subquery
SELECT e.name,
  COALESCE((SELECT m.name FROM pp6_employees m WHERE m.emp_id = e.manager_id),'None') AS manager
FROM pp6_employees e
ORDER BY e.emp_id;

-- C) Org levels via recursive CTE
WITH RECURSIVE org AS (
  SELECT emp_id, name, manager_id, 0 AS lvl
  FROM pp6_employees
  WHERE manager_id IS NULL
  UNION ALL
  SELECT e.emp_id, e.name, e.manager_id, o.lvl + 1
  FROM pp6_employees e
  JOIN org o ON o.emp_id = e.manager_id
)
SELECT name, lvl
FROM org
ORDER BY lvl, name;
```
