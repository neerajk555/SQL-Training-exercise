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

**Part A) Employees with a project (EXISTS)**
```sql
SELECT e.name
FROM pp6_employees e
WHERE EXISTS (
  SELECT 1 FROM pp6_assignments a WHERE a.emp_id = e.emp_id
)
ORDER BY e.name;
```

**Explanation:**
- **Pattern**: Semi-join using EXISTS
- **Logic**: "Show me employees WHO HAVE at least one project assignment"
- **Why EXISTS?** Efficient (stops at first match), no duplicates, NULL-safe
- **Result**: Bob, Cara, Evan have assignments → they appear
- **Alice and Drew** have no assignments → excluded

**Collaboration Checkpoint:**
- Navigator: "Can you explain why Alice doesn't appear in results?"
- Driver: "Because EXISTS checks assignments table and finds no row with emp_id=1"
- Navigator: "What if we used JOIN instead?"
- Driver: "We'd need DISTINCT to avoid duplicate rows if someone has multiple projects"

---

**Part B) Manager name via scalar subquery**
```sql
SELECT e.name,
  COALESCE((SELECT m.name FROM pp6_employees m WHERE m.emp_id = e.manager_id),'None') AS manager
FROM pp6_employees e
ORDER BY e.emp_id;
```

**Explanation:**
- **Pattern**: Correlated scalar subquery (returns ONE value per row)
- **Logic**: For EACH employee, look up their manager's name by joining on manager_id
- **Self-join**: The employees table references itself! (e = employee, m = manager)
- **COALESCE**: Handles Alice (CEO with no manager) → converts NULL to 'None'

**Step-by-Step Example:**
```
For Alice (emp_id=1, manager_id=NULL):
  → Subquery: SELECT name WHERE emp_id = NULL → No match → NULL
  → COALESCE(NULL, 'None') → 'None' ✓

For Bob (emp_id=2, manager_id=1):
  → Subquery: SELECT name WHERE emp_id = 1 → Found Alice
  → Result: 'Alice' ✓

For Cara (emp_id=3, manager_id=2):
  → Subquery: SELECT name WHERE emp_id = 2 → Found Bob
  → Result: 'Bob' ✓
```

**Collaboration Checkpoint:**
- Navigator: "Why do we need COALESCE?"
- Driver: "Because Alice has manager_id=NULL, and the subquery returns NULL"
- Navigator: "Could we use a LEFT JOIN instead?"
- Driver: "Yes! `LEFT JOIN pp6_employees m ON m.emp_id = e.manager_id` would work too"

---

**Part C) Org levels via recursive CTE**
```sql
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

**Explanation:**
- **Pattern**: Recursive CTE (WITH RECURSIVE) for hierarchies
- **Two parts**: Anchor (starting point) + Recursive (keep going)

**How Recursion Works:**

**Iteration 0 (Anchor):**
```sql
WHERE manager_id IS NULL  → Find the CEO (root of tree)
Result: Alice | lvl=0
```

**Iteration 1 (Recursive):**
```sql
JOIN employees e WHERE e.manager_id = Alice's emp_id
Found: Bob, Evan (Alice's direct reports)
Results: Bob | lvl=1, Evan | lvl=1
```

**Iteration 2 (Recursive):**
```sql
JOIN employees e WHERE e.manager_id = Bob OR Evan's emp_id
Found: Cara, Drew (Bob's reports)
Results: Cara | lvl=2, Drew | lvl=2
```

**Continues until**: No more employees found (reached bottom of hierarchy)

**Key Concepts:**
- **RECURSIVE**: Allows CTE to reference itself
- **UNION ALL**: Combines anchor with all recursive results
- **o.lvl + 1**: Each iteration goes one level deeper
- **Automatic termination**: Stops when JOIN finds no new rows
- **org o**: References the PREVIOUS iteration's results

**Collaboration Checkpoint:**
- Navigator: "What happens if there's a cycle? Like if Alice reports to Cara?"
- Driver: "Infinite loop! MySQL has a recursion limit (default 1000) to prevent crashes"
- Navigator: "How would we prevent that?"
- Driver: "Add WHERE o.lvl < 10 to limit depth, or track visited nodes"

**Alternative Without Recursion (For Small Hierarchies):**
```sql
-- If you only have 3 levels, you could do:
SELECT e1.name, 0 AS lvl FROM pp6_employees e1 WHERE manager_id IS NULL
UNION ALL
SELECT e2.name, 1 FROM pp6_employees e2 
  JOIN pp6_employees m1 ON e2.manager_id = m1.emp_id WHERE m1.manager_id IS NULL
UNION ALL
SELECT e3.name, 2 FROM pp6_employees e3
  JOIN pp6_employees m2 ON e3.manager_id = m2.emp_id
  JOIN pp6_employees m1 ON m2.manager_id = m1.emp_id WHERE m1.manager_id IS NULL;
-- But this gets messy fast! Recursive CTE is much cleaner.
```
