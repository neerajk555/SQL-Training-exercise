# Quick Warm-Ups — DML Operations

## 📋 Before You Start

### Learning Objectives
By completing these warm-ups, you will:
- Insert data with INSERT INTO statements
- Update existing records with UPDATE and WHERE
- Delete records safely with DELETE
- Use INSERT...ON DUPLICATE KEY UPDATE for upserts
- Understand transaction safety for data modifications

### Key DML Concepts for Beginners
**DML = Data Manipulation Language:**
- `INSERT`: Add new rows to a table
- `UPDATE`: Modify existing rows
- `DELETE`: Remove rows from a table
- These operations CHANGE data (unlike SELECT which only reads)

**Critical Safety Rules:**
- ⚠️ **ALWAYS use WHERE with UPDATE/DELETE** (or you'll affect ALL rows!)
- ⚠️ **Test with SELECT first** to verify which rows will be affected
- ⚠️ **Use transactions** for important changes (START TRANSACTION, COMMIT, ROLLBACK)
- ⚠️ **Backup data** before bulk modifications

**INSERT Patterns:**
- Single row: `INSERT INTO table (col1, col2) VALUES (val1, val2)`
- Multiple rows: `INSERT INTO table (col1, col2) VALUES (v1, v2), (v3, v4)`
- From query: `INSERT INTO table SELECT ... FROM other_table`
- Upsert: `INSERT ... ON DUPLICATE KEY UPDATE ...`

**UPDATE Pattern:**
- `UPDATE table SET column = new_value WHERE condition`
- Without WHERE = updates ALL rows (dangerous!)
- Can update multiple columns: `SET col1 = val1, col2 = val2`

**DELETE Pattern:**
- `DELETE FROM table WHERE condition`
- Without WHERE = deletes ALL rows (very dangerous!)
- Consider soft deletes (UPDATE is_deleted = 1) for important data

### Execution Tips
1. **Always test with SELECT first**: `SELECT * FROM table WHERE condition` 
2. **Use transactions for safety**: Wrap changes in START TRANSACTION / COMMIT
3. **Verify affected rows**: Check the "rows affected" message
4. **Have backups**: Before bulk modifications, backup your data

**Beginner Tip:** DML operations change your data permanently! Always double-check your WHERE clauses. When in doubt, use transactions so you can ROLLBACK if something goes wrong.

---

## 1) Insert New Product — 6 min
```sql
DROP TABLE IF EXISTS wu9_products;
CREATE TABLE wu9_products (product_id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(60), price DECIMAL(8,2));
-- Task: Insert 3 products in one statement
INSERT INTO wu9_products (name, price) VALUES ('Laptop', 1200), ('Mouse', 25), ('Keyboard', 75);
SELECT * FROM wu9_products;
```

## 2) Update Prices — 7 min
```sql
-- Task: Increase all prices by 10%
UPDATE wu9_products SET price = price * 1.10;
SELECT * FROM wu9_products;
```

## 3) Conditional Update — 8 min
```sql
-- Task: Set price to 20 for products cheaper than 30
UPDATE wu9_products SET price = 20 WHERE price < 30;
```

## 4) Delete Expired Records — 7 min
```sql
DROP TABLE IF EXISTS wu9_sessions;
CREATE TABLE wu9_sessions (session_id INT, expires_at DATETIME);
INSERT INTO wu9_sessions VALUES (1, '2025-01-01'), (2, '2025-12-31');
-- Task: Delete expired sessions
DELETE FROM wu9_sessions WHERE expires_at < CURDATE();
```

## 5) Upsert Pattern — 9 min
```sql
DROP TABLE IF EXISTS wu9_user_stats;
CREATE TABLE wu9_user_stats (user_id INT PRIMARY KEY, login_count INT DEFAULT 0);
-- Task: Increment login_count, insert if not exists
INSERT INTO wu9_user_stats (user_id, login_count) VALUES (1, 1)
ON DUPLICATE KEY UPDATE login_count = login_count + 1;
```
