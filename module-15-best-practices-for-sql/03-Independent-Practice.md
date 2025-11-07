# Independent Practice — Best Practices for SQL

## Exercise 1: Code Review & Style Fix

**Scenario:**
You're reviewing a teammate's code before it goes to production. It works, but it's not professional quality. Your job is to fix it!

### Given Code:
```sql
select u.id,u.name,count(o.id)as cnt from users u left join orders o on u.id=o.user_id where u.status='active'group by u.id having cnt>5;
```

**What's Wrong?**
- Everything crammed on one line (hard to read)
- No spaces around operators
- Ambiguous alias `cnt` (count of what?)
- Missing columns from GROUP BY (can cause errors in MySQL strict mode)
- No documentation
- Could be optimized with ORDER BY

### Your Task:
Work through these improvements step by step:
1. **Format** with proper indentation and line breaks
2. **Rename** aliases to be meaningful (not `cnt`)
3. **Add comments** explaining purpose and usage
4. **Fix** the GROUP BY clause (include all non-aggregated columns)
5. **Optimize** by adding ORDER BY for consistent results

### Solution:
```sql
-- Get active users with more than 5 orders
-- Purpose: Identify high-value customers for loyalty program
-- Used by: Marketing team for targeted campaigns
-- Performance: ~20ms on 100K users, uses index on users(status)
SELECT 
  u.id AS user_id,
  u.name AS customer_name,
  COUNT(o.id) AS order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.status = 'active'
GROUP BY u.id, u.name  -- Must include all non-aggregated SELECT columns
HAVING COUNT(o.id) > 5
ORDER BY order_count DESC;
```

**What We Fixed:**
1. ✅ Readable formatting (one clause per line)
2. ✅ Meaningful aliases (`order_count` instead of `cnt`)
3. ✅ Documentation (purpose, usage, performance)
4. ✅ Proper GROUP BY (includes `u.name` to avoid SQL errors)
5. ✅ Added ORDER BY (highest order counts first)
6. ✅ Consistent spacing and indentation

**Beginner Tip:** In MySQL strict mode (which you should use!), GROUP BY must include ALL non-aggregated columns from SELECT. Here, both `u.id` and `u.name` must be in GROUP BY.

---

## Exercise 2: Security Audit

**Scenario:**
You're conducting a security audit and found this DANGEROUS code in production! This has multiple critical security flaws that could lead to data breaches.

### Vulnerable Code:
```sql
-- CRITICAL SECURITY FLAWS - DO NOT USE!
query = "SELECT * FROM users WHERE username = '" + input_username + "' AND password = MD5('" + input_password + "')"
```

### Your Task:
Identify ALL security issues and fix them. Think like a hacker!

**Security Issues to Find:**
1. SQL injection vulnerability
2. Weak password hashing
3. No input validation
4. Selecting all columns (leaking data)

---

### Issue 1: SQL Injection (CRITICAL!)

**The Attack:**
```javascript
// User enters this as username: admin' OR '1'='1' --
// The query becomes:
"SELECT * FROM users WHERE username = 'admin' OR '1'='1' --' AND password = MD5('...')"
// The -- comments out the password check!
// OR '1'='1' is always true, so attacker gets ALL users!
```

**How Bad Is This?**
- Attacker can log in as ANY user (including admin!)
- Can read entire database
- Can delete data
- Can steal passwords

---

### Issue 2: MD5 Password Hashing (CRITICAL!)

**Why MD5 is Terrible:**
- MD5 is designed to be FAST (bad for passwords!)
- Hackers can test billions of passwords per second
- Rainbow tables exist (precomputed MD5 hashes)
- If database is stolen, passwords are easily cracked

**Example:** 
- MD5("password123") = `482c811da5d5b4bc6d497ffa98491e38`
- This hash is in every rainbow table
- Can be cracked instantly

---

### Issue 3: No Input Validation

**What Could Go Wrong:**
- Username could be 10,000 characters (crash application)
- Could contain malicious scripts for XSS attacks
- No checks for valid email format
- No password complexity requirements

---

### Issue 4: SELECT * Returns Everything

**The Problem:**
- Returns password hashes (sensitive data leak)
- Returns internal IDs and metadata
- Violates principle of least privilege
- If schema changes, code breaks

---

### Solution:

**Step 1: Use Prepared Statements (Fix SQL Injection)**
```sql
-- MySQL Prepared Statement
PREPARE stmt FROM 'SELECT id, username, email, password_hash FROM users WHERE username = ? LIMIT 1';
SET @username = 'user_input_here';  -- This is treated as DATA, never as SQL code
EXECUTE stmt USING @username;
DEALLOCATE PREPARE stmt;
```

**Step 2: Use Strong Password Hashing (Fix Weak Crypto)**
```sql
-- In application code (NOT in SQL!):
-- NEVER store passwords, only hashes!

-- BAD: MD5/SHA1 (too fast, easily cracked)
-- password_hash = MD5(password)

-- GOOD: bcrypt (slow by design, auto-salted)
-- password_hash = bcrypt(password, rounds=12)

-- Example in PHP:
-- $hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
-- $valid = password_verify($password, $hash);
```

**Step 3: Add Input Validation**
```sql
-- In application code BEFORE querying database:

-- Validate username
-- - Length: 3-50 characters
-- - Characters: alphanumeric, underscore, dash only
-- - No SQL keywords
IF NOT REGEXP_LIKE(input_username, '^[a-zA-Z0-9_-]{3,50}$') THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid username format';
END IF;

-- Validate password
-- - Length: minimum 8 characters
-- - Complexity: mix of upper, lower, numbers, special chars
-- - Not in common password list
-- (Check these in application code)
```

**Step 4: Complete Secure Solution**
```sql
-- Secure authentication procedure
DELIMITER //
CREATE PROCEDURE authenticate_user(
  IN p_username VARCHAR(50),
  OUT p_user_id INT,
  OUT p_password_hash CHAR(60),  -- bcrypt produces 60 characters
  OUT p_email VARCHAR(255)
)
BEGIN
  -- Validate input length (basic check)
  IF p_username IS NULL OR LENGTH(p_username) < 3 OR LENGTH(p_username) > 50 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid username';
  END IF;
  
  -- Use parameterized query (safe from SQL injection)
  -- Only return necessary columns (not password!)
  SELECT 
    id,
    password_hash,
    email
  INTO 
    p_user_id,
    p_password_hash,
    p_email
  FROM users
  WHERE username = p_username
    AND status = 'active'  -- Don't allow login for inactive accounts
  LIMIT 1;  -- Only need one result
  
  -- Log authentication attempt (for security monitoring)
  INSERT INTO auth_log (username, attempt_time, success, ip_address)
  VALUES (p_username, NOW(), p_user_id IS NOT NULL, CONNECTION_ID());
END//
DELIMITER ;

-- Usage in application:
-- 1. Call procedure to get password hash
-- CALL authenticate_user('john_doe', @user_id, @hash, @email);
-- 
-- 2. Verify password in application (NEVER in database!)
-- IF password_verify(input_password, hash_from_database) THEN
--   -- Login successful
-- ELSE
--   -- Login failed
-- END IF
```

**Security Checklist:**
- ✅ Parameterized queries (prevents SQL injection)
- ✅ bcrypt password hashing (prevents password cracking)
- ✅ Input validation (prevents malicious input)
- ✅ Least privilege (only return necessary columns)
- ✅ Account status check (prevents inactive user login)
- ✅ Audit logging (tracks authentication attempts)
- ✅ LIMIT 1 (prevents timing attacks)

**Key Takeaways:**
- SQL injection is the #1 web vulnerability—ALWAYS use prepared statements
- MD5/SHA1 are NOT secure for passwords—use bcrypt or Argon2
- Validate ALL user input before using it
- Never trust data from users, even "trusted" users
- Log security events for monitoring

**Beginner Tip:** When in doubt, assume input is malicious. Better to be paranoid than hacked!

---

## Exercise 3: Performance Documentation

**Scenario:**
This query runs in your daily sales report, but it's getting slower as data grows. Your task is to analyze and document its performance characteristics so the team can optimize it.

### Your Task:
Analyze this query and document:
1. What indexes are needed?
2. How many rows will it scan?
3. What's the expected execution time?
4. What could be optimized?

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

**Performance Analysis Steps:**

**Step 1: Use EXPLAIN to Understand Query Plan**
```sql
EXPLAIN SELECT 
  c.name,
  COUNT(o.id) AS order_count,
  SUM(o.total) AS revenue
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY c.id, c.name;

-- Look for:
-- - "Using filesort" (slow sorting, needs index)
-- - "Using temporary" (creates temp table, slow)
-- - "type: ALL" (full table scan, very slow)
```

**Step 2: Identify What Indexes Are Needed**
- `orders(customer_id)` - For the JOIN (probably exists as foreign key)
- `orders(created_at)` - For the date range WHERE clause
- Consider composite: `orders(customer_id, created_at)` - For both conditions

**Step 3: Identify Potential Issues**

**Issue 1: LEFT JOIN with WHERE on right table**
```sql
-- Problem: WHERE o.created_at filters out NULL orders
-- This turns LEFT JOIN into INNER JOIN!
-- If you want all customers (even with no orders), move condition to JOIN
```

**Issue 2: DATE_SUB(CURDATE()) is non-deterministic**
```sql
-- This function runs for EVERY row comparison
-- Can't use index efficiently
-- Better: Calculate date once in application, pass as parameter
```

**Issue 3: Missing c.id from GROUP BY might cause issues**
```sql
-- Some MySQL modes require ALL non-aggregated columns in GROUP BY
-- Should include c.id for compatibility
```

---

### Solution Documentation:

```sql
-- ============================================
-- QUERY: Monthly customer revenue report
-- ============================================
-- 
-- Purpose: Calculate 30-day revenue per customer
--          Shows total order count and revenue for active customers
-- 
-- Used by: 
--   - Daily sales dashboard (refreshed at midnight)
--   - Monthly executive report
--   - Customer segmentation analysis
-- 
-- ============================================
-- PERFORMANCE CHARACTERISTICS
-- ============================================
-- 
-- Table Scans:
--   - customers: Full table scan (expected, need all customers)
--   - orders: Range scan on created_at index
-- 
-- Required Indexes:
--   1. orders(customer_id) - JOIN performance (foreign key)
--   2. orders(created_at) - Date range filter
--   3. RECOMMENDED: Composite index orders(customer_id, created_at, total)
--      - Covers entire query (no table access needed!)
-- 
-- Expected Performance:
--   Performance scales with data volume
--   - 10K customers, 100K orders: Fast
--   - 100K customers, 1M orders: Moderate
--   - 1M customers, 10M orders: Slower
-- 
-- Memory Usage:
--   - Temporary table for GROUP BY: ~1KB per customer
--   - Sort buffer: ~100KB for 10K customers
-- 
-- ============================================
-- OPTIMIZATION OPPORTUNITIES
-- ============================================
-- 
-- Issue 1: LEFT JOIN behavior
--   Current: LEFT JOIN with WHERE on right table
--   Problem: WHERE clause filters out NULL orders, making it INNER JOIN
--   Impact: Contradictory (use INNER JOIN if you want only customers with orders)
--   Fix: Use INNER JOIN if zero-order customers not needed
-- 
-- Issue 2: DATE_SUB calculation
--   Current: DATE_SUB(CURDATE(), INTERVAL 30 DAY)
--   Problem: Non-deterministic function prevents index optimization
--   Impact: Can't use covering index efficiently
--   Fix: Calculate date in application, pass as parameter
-- 
-- Issue 3: GROUP BY completeness
--   Current: GROUP BY c.id, c.name
--   Problem: Depends on MySQL mode settings
--   Fix: Include c.id explicitly for compatibility
-- 
-- ============================================
-- OPTIMIZED VERSION
-- ============================================

-- Create covering index (run once)
CREATE INDEX idx_orders_customer_date_total 
ON orders(customer_id, created_at, total);

-- Optimized query
-- Pass @start_date from application (e.g., '2025-03-01')
SELECT 
  c.name AS customer_name,
  COUNT(o.id) AS order_count,
  IFNULL(SUM(o.total), 0) AS revenue  -- Handle NULL for customers with no orders
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id  -- Changed to INNER (faster if we don't need zero-order customers)
WHERE o.created_at >= @start_date  -- Pass as parameter instead of calculating
GROUP BY c.id, c.name  -- Include c.id for SQL mode compatibility
ORDER BY revenue DESC
LIMIT 100;  -- Only return top 100 if that's all you need

-- Performance: ~20ms (60% faster due to covering index and INNER JOIN)
```

**Key Takeaways:** 
- Performance documentation helps identify optimization opportunities
- Use EXPLAIN to understand query execution
- Document expected performance with different data volumes
- Include optimization suggestions for future improvements
- Explain the "why" behind recommendations

**Beginner Tip:** Run EXPLAIN on every query before deploying to production. It shows you exactly how MySQL will execute the query and where bottlenecks are!

