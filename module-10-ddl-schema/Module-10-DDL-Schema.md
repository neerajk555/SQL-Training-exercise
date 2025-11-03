# Module 10 · DDL & Schema Design

DDL defines database structure. CREATE makes objects, ALTER modifies them, DROP removes them.

## Key Operations:
```sql
-- Create table with constraints
CREATE TABLE employees (
  emp_id INT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(100) UNIQUE NOT NULL,
  dept_id INT,
  salary DECIMAL(10,2) CHECK (salary > 0),
  hired_date DATE DEFAULT (CURDATE()),
  FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- Alter table
ALTER TABLE employees ADD COLUMN phone VARCHAR(20);
ALTER TABLE employees MODIFY COLUMN email VARCHAR(150);
ALTER TABLE employees DROP COLUMN phone;

-- Drop table
DROP TABLE IF EXISTS temp_data;
```

## Best Practices:
- Use appropriate data types
- Define primary keys
- Add foreign keys for relationships
- Use NOT NULL where appropriate
- Index frequently queried columns
- Plan for migrations (use ALTER, not DROP/CREATE)
