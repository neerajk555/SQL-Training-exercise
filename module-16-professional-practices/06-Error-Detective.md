# Error Detective — Professional Practices

## Error 1: SQL Injection Vulnerability
```sql
-- Application code
query = "SELECT * FROM users WHERE username = '" + input + "'";
```
**Issue:** SQL injection attack possible  
**Fix:** Use parameterized queries: `SELECT * FROM users WHERE username = ?`

---

## Error 2: Weak Password Storage
```sql
CREATE TABLE users (
  id INT PRIMARY KEY,
  password VARCHAR(50)  -- Plain text!
);
```
**Issue:** Passwords stored in plain text  
**Fix:** Use `password_hash CHAR(60)` with bcrypt hashing

---

## Error 3: Missing Transaction
```sql
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
-- What if second UPDATE fails?
```
**Issue:** No atomic transaction  
**Fix:** Wrap in `START TRANSACTION ... COMMIT`

---

## Error 4: Poor Naming
```sql
SELECT t1.a, t2.b FROM t1 JOIN t2 ON t1.id = t2.fk;
```
**Issue:** Cryptic aliases and column names  
**Fix:** Use descriptive names: `customers.name, orders.total`

---

## Error 5: No Error Handling
```sql
CREATE PROCEDURE update_price(p_id INT, p_price DECIMAL)
BEGIN
  UPDATE products SET price = p_price WHERE id = p_id;
END;
```
**Issue:** No validation or error handling  
**Fix:** Add `DECLARE EXIT HANDLER` and input validation

---

## Error 6: Missing Documentation
```sql
CREATE PROCEDURE calc_total(x INT, y INT, OUT z INT)
BEGIN
  SET z = x + y;
END;
```
**Issue:** No comments explaining purpose/parameters  
**Fix:** Add header comment with purpose, params, example

---

## Error 7: Non-Deterministic Generated Column
```sql
CREATE TABLE t (
  id INT,
  created TIMESTAMP GENERATED ALWAYS AS (NOW())
);
```
**Issue:** Generated columns must be deterministic  
**Fix:** Use `DEFAULT CURRENT_TIMESTAMP` instead

---

## Error 8: Missing Index on Foreign Key
```sql
CREATE TABLE orders (
  id INT PRIMARY KEY,
  user_id INT,
  FOREIGN KEY (user_id) REFERENCES users(id)
  -- No index on user_id!
);
```
**Issue:** Poor JOIN performance  
**Fix:** Add `INDEX idx_user_id (user_id)`

**Key Takeaways:** Professional code requires security, clarity, error handling, and performance optimization.

