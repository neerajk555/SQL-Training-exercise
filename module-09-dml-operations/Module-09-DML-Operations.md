# Module 09 · DML Operations

DML (Data Manipulation Language) statements modify data in tables: INSERT adds rows, UPDATE modifies existing rows, DELETE removes rows, and REPLACE handles upserts.

## Topics: INSERT (single/multi-row, from SELECT), UPDATE (simple/conditional, with JOIN), DELETE (safe patterns, with JOIN), REPLACE, TRUNCATE vs DELETE, Bulk operations, ON DUPLICATE KEY UPDATE

## Key Concepts:
- **INSERT**: Add new rows with VALUES or SELECT
- **UPDATE**: Modify existing data, use WHERE carefully
- **DELETE**: Remove rows, always test with SELECT first
- **Transaction safety**: Wrap in BEGIN/COMMIT for rollback capability
- **Performance**: Bulk operations vs individual statements

## Common Patterns:
```sql
-- Insert single row
INSERT INTO products (name, price) VALUES ('Laptop', 1200.00);

-- Insert multiple rows
INSERT INTO products (name, price) VALUES ('Mouse', 25), ('Keyboard', 75);

-- Insert from SELECT
INSERT INTO archive_orders SELECT * FROM orders WHERE order_date < '2024-01-01';

-- Update with WHERE
UPDATE products SET price = price * 1.10 WHERE category = 'Electronics';

-- Update with JOIN
UPDATE inventory i JOIN products p ON i.product_id = p.product_id
SET i.quantity = i.quantity - 1 WHERE p.name = 'Laptop';

-- Safe DELETE (always test with SELECT first!)
SELECT * FROM orders WHERE status = 'cancelled' AND order_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);
DELETE FROM orders WHERE status = 'cancelled' AND order_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- Upsert pattern
INSERT INTO user_stats (user_id, visit_count) VALUES (1, 1)
ON DUPLICATE KEY UPDATE visit_count = visit_count + 1;
```

## Practice Strategy:
1. Master basic INSERT/UPDATE/DELETE
2. Practice conditional updates with complex WHERE clauses
3. Learn JOIN-based UPDATEs and DELETEs
4. Understand transaction safety
5. Apply to real-world data migrations
