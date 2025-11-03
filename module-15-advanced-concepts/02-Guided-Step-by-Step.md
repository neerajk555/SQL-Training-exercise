# Guided Step-by-Step — Advanced Concepts

## Activity 1: Product Catalog with JSON — 18 min
Store product attributes (color, size, features) in JSON for flexibility.

**Setup:**
```sql
CREATE TABLE gs15_products (
  product_id INT PRIMARY KEY,
  name VARCHAR(100),
  attributes JSON
);
INSERT INTO gs15_products VALUES
(1, 'T-Shirt', '{"color":"blue","size":"M","material":"cotton"}'),
(2, 'Laptop', '{"brand":"Dell","ram":"16GB","storage":"512GB SSD"}');
```

**Tasks:**
1. Query products by specific attribute
2. Update single JSON field
3. Add new attribute to existing JSON
4. Convert JSON to columns with JSON_TABLE

---

## Activity 2: Employee Hierarchy Navigation — 20 min
Build org chart traversal with recursive CTE.

**Setup:**
```sql
CREATE TABLE gs15_org (emp_id INT PRIMARY KEY, name VARCHAR(50), manager_id INT);
INSERT INTO gs15_org VALUES
(1, 'CEO', NULL), (2, 'VP Engineering', 1), (3, 'VP Sales', 1),
(4, 'Team Lead', 2), (5, 'Developer 1', 4), (6, 'Developer 2', 4);
```

**Tasks:**
1. Get all subordinates of a manager
2. Find reporting chain for an employee
3. Calculate organization depth
4. List employees at each level

