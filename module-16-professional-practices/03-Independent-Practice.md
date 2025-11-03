# Independent Practice — Professional Practices

## Exercise 1: Code Review & Style Fix

### Given Code:
```sql
select u.id,u.name,count(o.id)as cnt from users u left join orders o on u.id=o.user_id where u.status='active'group by u.id having cnt>5;
```

### Your Task:
1. Format with proper indentation
2. Add meaningful aliases
3. Add comments
4. Optimize the query

### Solution:
```sql
-- Get active users with more than 5 orders
-- Used by: Customer loyalty program
SELECT 
  u.id AS user_id,
  u.name AS customer_name,
  COUNT(o.id) AS order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.status = 'active'
GROUP BY u.id, u.name
HAVING COUNT(o.id) > 5
ORDER BY order_count DESC;
```

---

## Exercise 2: Security Audit

### Vulnerable Code:
```sql
-- Application code building dynamic SQL
query = "SELECT * FROM users WHERE username = '" + input_username + "' AND password = MD5('" + input_password + "')"
```

### Your Task:
1. Identify security issues
2. Fix SQL injection vulnerability
3. Fix weak password hashing
4. Add input validation

### Solution:
```sql
-- Use parameterized queries (pseudo-code example)
-- stmt = prepare("SELECT * FROM users WHERE username = ? AND password_hash = ?")
-- password_hash = bcrypt(input_password)  -- Use bcrypt instead of MD5
-- stmt.execute([sanitize(input_username), password_hash])

-- Additional: Add input validation
-- - Username: alphanumeric only, max 50 chars
-- - Password: min 8 chars, complexity requirements
-- - Use LIMIT 1 to prevent timing attacks
```

**Security Checklist:**
- ✅ Parameterized queries
- ✅ Strong password hashing (bcrypt/argon2)
- ✅ Input validation and sanitization
- ✅ Least privilege database accounts
- ✅ No sensitive data in logs

---

## Exercise 3: Performance Documentation

### Your Task:
Document this query's performance characteristics:
```sql
SELECT 
  c.name,
  COUNT(o.id) AS order_count,
  SUM(o.total) AS revenue
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY c.id, c.name;
```

### Solution Documentation:
```sql
-- ============================================
-- QUERY: Monthly customer revenue report
-- ============================================
-- Purpose: Calculate 30-day revenue per customer
-- Performance Characteristics:
--   - Scans: customers (full), orders (range scan on created_at)
--   - Required Indexes: orders(customer_id, created_at)
--   - Estimated rows: customers * 0.7 (assuming 70% have orders)
--   - Execution time: ~50ms for 10K customers, 100K orders
-- Optimization Notes:
--   - LEFT JOIN may be inefficient if most customers have orders
--   - Consider INNER JOIN if zero-order customers not needed
--   - DATE_SUB(CURDATE(), ...) prevents index use; consider fixed date
-- Dependencies: customers, orders tables
-- Used by: Monthly sales dashboard
-- ============================================
```

**Key Takeaways:** Professional documentation includes performance impact, dependencies, and usage context.

