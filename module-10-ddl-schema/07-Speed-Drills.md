# Speed Drills — DDL & Schema Design (2 min each)

Quick-fire exercises to build muscle memory. Set a 2-minute timer!

---

## Drill 1: Create Basic Table
Create `products` table with id (PK, auto-increment), name (VARCHAR 100), price (DECIMAL).
```sql
CREATE TABLE sd10_products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  price DECIMAL(10,2)
);
```

---

## Drill 2: Add Column
Add `stock_quantity` (INT, default 0) to existing `products` table.
```sql
ALTER TABLE sd10_products ADD COLUMN stock_quantity INT DEFAULT 0;
```

---

## Drill 3: Add UNIQUE Constraint
Add UNIQUE constraint on `name` column in `products` table.
```sql
ALTER TABLE sd10_products ADD CONSTRAINT uk_name UNIQUE (name);
```

---

## Drill 4: Add Foreign Key
Create `orders` table with order_id and customer_id (FK to customers(customer_id)).
```sql
CREATE TABLE sd10_orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

---

## Drill 5: Modify Column Type
Change `name` column in `products` to VARCHAR(200).
```sql
ALTER TABLE sd10_products MODIFY COLUMN name VARCHAR(200);
```

---

## Drill 6: Drop Column
Remove `stock_quantity` column from `products`.
```sql
ALTER TABLE sd10_products DROP COLUMN stock_quantity;
```

---

## Drill 7: Create with CHECK Constraint
Create `employees` table with salary that must be > 0.
```sql
CREATE TABLE sd10_employees (
  emp_id INT PRIMARY KEY,
  salary DECIMAL(10,2) CHECK (salary > 0)
);
```

---

## Drill 8: Add ENUM Column
Add `status` column to `orders` (ENUM: pending, shipped, delivered).
```sql
ALTER TABLE sd10_orders 
ADD COLUMN status ENUM('pending', 'shipped', 'delivered') DEFAULT 'pending';
```

---

## Drill 9: Composite Primary Key
Create `enrollment` table with composite PK on (student_id, course_id).
```sql
CREATE TABLE sd10_enrollment (
  student_id INT,
  course_id INT,
  PRIMARY KEY (student_id, course_id)
);
```

---

## Drill 10: Drop Table Safely
Drop `old_data` table only if it exists.
```sql
DROP TABLE IF EXISTS old_data;
```

---

**Speed Tips:**
- Memorize common patterns (PK, FK, UNIQUE)
- Practice typing constraints without looking
- Use IF EXISTS/IF NOT EXISTS for safety
- AUTO_INCREMENT and PRIMARY KEY go together