# Quick Warm-Ups — Professional Practices

## 📋 Before You Start

### Learning Objectives
By completing these warm-ups, you will:
- Write clean, readable SQL code
- Add helpful comments and documentation
- Prevent SQL injection vulnerabilities
- Use meaningful naming conventions
- Follow professional SQL standards

### Key Professional Practices
**Code Formatting:**
- One clause per line (SELECT, FROM, WHERE, etc.)
- Indent conditions and subqueries
- Align related items
- Use uppercase for SQL keywords (optional but common)

**Documentation:**
- Comment complex queries
- Explain business logic
- Document assumptions
- Note performance considerations

**Security:**
- NEVER concatenate user input into SQL
- Always use parameterized queries/prepared statements
- Validate and sanitize inputs
- Use principle of least privilege for database users

**Naming Conventions:**
- Use descriptive names (not `tbl1`, `col_a`)
- Be consistent (snake_case or camelCase, pick one)
- Avoid reserved words
- Plural for tables (users), singular for columns (user_id)

### Execution Tips
1. **Format as you write**: Don't wait until code is messy
2. **Review your code**: Read it like someone else will
3. **Test for injection**: Try with malicious inputs
4. **Follow team standards**: Consistency matters more than personal preference

**Beginner Tip:** Professional SQL is readable, secure, and well-documented. Future you (and your team) will thank you!

---

## Exercise 1: Format This Query
```sql
select*from orders where status='pending'and amount>100;
```

**Solution:**
```sql
SELECT *
FROM orders
WHERE status = 'pending'
  AND amount > 100;
```

---

## Exercise 2: Add Comments
```sql
SELECT user_id, COUNT(*) FROM orders WHERE created_at > '2024-01-01' GROUP BY user_id;
```

**Solution:**
```sql
-- Get order count per user for 2024
SELECT 
  user_id,
  COUNT(*) AS order_count
FROM orders
WHERE created_at > '2024-01-01'
GROUP BY user_id;
```

---

## Exercise 3: Fix SQL Injection Risk
```sql
-- PHP code: "SELECT * FROM users WHERE username = '$_POST[username]'"
```

**Solution:**
```sql
-- Use parameterized queries instead:
-- PDO: $stmt = $pdo->prepare("SELECT * FROM users WHERE username = ?");
-- mysqli: $stmt->bind_param("s", $username);
```

---

## Exercise 4: Name This Better
```sql
SELECT t1.a, t2.b FROM t1 JOIN t2 ON t1.id = t2.fk;
```

**Solution:**
```sql
SELECT 
  customers.name,
  orders.total_amount
FROM customers
JOIN orders ON customers.id = orders.customer_id;
```

---

## Exercise 5: Add Error Handling
```sql
DELIMITER //
CREATE PROCEDURE update_price(IN p_id INT, IN p_price DECIMAL)
BEGIN
  UPDATE products SET price = p_price WHERE id = p_id;
END//
```

**Solution:**
```sql
DELIMITER //
CREATE PROCEDURE update_price(IN p_id INT, IN p_price DECIMAL)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price update failed';
  END;
  
  START TRANSACTION;
  UPDATE products SET price = p_price WHERE id = p_id;
  COMMIT;
END//
```

**Beginner Tip:** Professional SQL is readable, secure, and well-documented.

