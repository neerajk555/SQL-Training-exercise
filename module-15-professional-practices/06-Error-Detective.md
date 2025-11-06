# Error Detective — Professional Practices

## 📋 Before You Start

### Learning Objectives
By completing these error detective challenges, you will:
- Develop debugging skills for security and quality issues
- Practice identifying SQL injection vulnerabilities
- Learn to recognize poor documentation and naming practices
- Build troubleshooting skills for production code
- Understand critical professional standards

### How to Approach Each Challenge
1. **Read code as attacker** - how could this be exploited?
2. **Identify security/quality issue** - SQL injection? Poor naming?
3. **Assess impact** - could this cause data breach or loss?
4. **Check the fix** - see secure/professional version
5. **Test with malicious input** - verify fix prevents attacks

**Beginner Tip:** Professional practice errors are the most dangerous in production! SQL injection can expose entire databases. Poor documentation causes maintenance nightmares. Build secure, readable habits now!

---

## Error Detective Challenges

**Welcome, Detective!**

Your mission: Find and fix dangerous bugs in production code. Each error represents a real-world mistake that causes security breaches, data loss, or system crashes.

**For Each Error:**
1. **Identify:** What's wrong?
2. **Explain:** Why is it dangerous?
3. **Fix:** Show the correct solution
4. **Learn:** Remember the pattern to avoid it in the future

---

## Error 1: SQL Injection Vulnerability (CRITICAL! 🚨)

```sql
-- Application code (EXTREMELY DANGEROUS!)
query = "SELECT * FROM users WHERE username = '" + input + "'";
```

**What's Wrong:**
User input is directly concatenated into SQL, allowing attackers to inject malicious SQL code.

**Why It's Dangerous:**
```javascript
// Normal use:
input = "john"
→ SELECT * FROM users WHERE username = 'john'  ✓

// Attacker's input:
input = "' OR '1'='1' --"
→ SELECT * FROM users WHERE username = '' OR '1'='1' --'
→ Returns ALL users! Attacker logs in as first user (usually admin) ✗

// Worse attack:
input = "'; DROP TABLE users; --"
→ SELECT * FROM users WHERE username = ''; DROP TABLE users; --'
→ DELETES YOUR ENTIRE USERS TABLE! ✗✗✗
```

**Real-World Impact:**
- SQL injection caused the 2017 Equifax breach (143 million records stolen)
- Consistently #1 on OWASP Top 10 vulnerabilities
- Can lead to complete database compromise

**The Fix:**
```sql
-- Use prepared statements (parameterized queries)
-- MySQL:
PREPARE stmt FROM 'SELECT * FROM users WHERE username = ?';
SET @username = 'user_input_here';
EXECUTE stmt USING @username;
DEALLOCATE PREPARE stmt;

-- In application code (PHP with PDO):
$stmt = $pdo->prepare("SELECT * FROM users WHERE username = ?");
$stmt->execute([$input]);

-- The ? placeholder can ONLY hold data, never SQL code
-- Attack becomes: username = "' OR '1'='1' --" (literal string, returns nothing)
```

**Key Lesson:** NEVER concatenate user input into SQL. Always use prepared statements with placeholders.

---

---

## Error 2: Weak Password Storage (CRITICAL! 🚨)

```sql
CREATE TABLE users (
  id INT PRIMARY KEY,
  password VARCHAR(50)  -- Storing plain-text passwords!
);

-- Later in code:
INSERT INTO users (id, password) VALUES (1, 'mypassword123');
```

**What's Wrong:**
Passwords are stored as plain text—anyone with database access can read them!

**Why It's Dangerous:**
```sql
-- Attacker gets database access (SQL injection, backup theft, insider threat)
SELECT id, password FROM users;
-- Result:
-- id | password
-- 1  | mypassword123
-- 2  | hunter2
-- 3  | letmein

-- Attacker now has EVERYONE'S passwords!
-- Most people reuse passwords across sites
-- Attacker can access their email, bank, social media, etc.
```

**Real-World Impact:**
- LinkedIn breach (2012): 6.5M passwords in plain SHA1 (easily cracked)
- Adobe breach (2013): 153M passwords weakly encrypted
- Yahoo breach (2013): 3 billion accounts with weak hashing
- Companies fined millions, lawsuits, reputation destroyed

**Common Mistakes:**
```sql
-- WRONG: Plain text
password VARCHAR(50)  ✗

-- WRONG: MD5 (too fast, rainbow tables exist)
password_hash CHAR(32)  -- MD5('password123') = '482c811da5d5b4bc6d497ffa98491e38'
-- Cracked in milliseconds ✗

-- WRONG: SHA1 (also too fast)
password_hash CHAR(40)  ✗

-- WRONG: Simple hashing without salt
password_hash = SHA256(password)  -- Same password = same hash (bad!) ✗
```

**The Fix:**
```sql
-- CORRECT: Use bcrypt (slow by design, auto-salted)
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) UNIQUE NOT NULL,
  password_hash CHAR(60) NOT NULL,  -- bcrypt produces 60 characters
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- In application code (NEVER hash in SQL!):
-- PHP:
$hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
// Produces: $2y$12$Ls9FwLt2qyAJvD4i8zKGZOXsaF/lXxYgE3x0bP3yDvKjNc8JqVk7K

-- Verification:
if (password_verify($input_password, $stored_hash)) {
  // Login successful
}

-- Python:
import bcrypt
hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt(rounds=12))

-- Node.js:
const bcrypt = require('bcrypt');
const hash = await bcrypt.hash(password, 12);
```

**Why bcrypt is Better:**
- **Slow:** Takes ~100ms to hash (fast for users, impossibly slow for attackers)
- **Auto-salted:** Each password gets unique salt (same password = different hash)
- **Future-proof:** Cost factor can increase as computers get faster
- **Industry standard:** Used by banks, governments, major platforms

**Key Lesson:** Never store passwords in plain text or with fast hashing (MD5/SHA). Always use bcrypt or Argon2 with high cost factor.

---

---

## Error 3: Missing Transaction (DATA LOSS RISK! 🚨)

```sql
-- Transfer $100 from Account 1 to Account 2
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
-- What if second UPDATE fails? Money disappears!
```

**What's Wrong:**
No transaction wrapping these updates. They're not atomic (all-or-nothing).

**Why It's Dangerous:**
```sql
-- Scenario: Account 1 has $100, Account 2 has $50
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
-- ✓ Account 1: $100 - $100 = $0

-- ** POWER FAILURE! DATABASE CRASHES! **

UPDATE accounts SET balance = balance + 100 WHERE id = 2;
-- ✗ This line NEVER RUNS

-- Final result:
-- Account 1: $0 (lost $100)
-- Account 2: $50 (gained nothing)
-- $100 disappeared into thin air!
```

**Real-World Examples:**
1. **Bank Transfer Failure:**
   - Money deducted from sender
   - Database crashes before crediting receiver
   - Customer loses money, bank liable

2. **Inventory Management:**
   - Item removed from warehouse stock
   - Error before adding to shipment
   - Item lost in system, can't be sold or found

3. **Order Processing:**
   - Payment charged
   - Database fails before creating order
   - Customer charged but no order exists

**The Fix:**
```sql
-- Wrap in transaction (atomic: all succeed or all fail)
START TRANSACTION;

-- Try to perform both updates
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

-- If both succeed, make changes permanent
COMMIT;

-- With error handling:
DELIMITER //
CREATE PROCEDURE transfer_money(
  IN from_id INT,
  IN to_id INT,
  IN amount DECIMAL(10,2)
)
BEGIN
  -- If ANY error occurs, rollback everything
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transfer failed - no changes made';
  END;
  
  START TRANSACTION;
  
  -- Deduct from sender
  UPDATE accounts SET balance = balance - amount WHERE id = from_id;
  
  -- Add to receiver  
  UPDATE accounts SET balance = balance + amount WHERE id = to_id;
  
  -- Both succeeded, commit
  COMMIT;
END//
DELIMITER ;

-- Now it's safe:
-- Either BOTH updates happen, or NEITHER happens
-- Money can never disappear!
```

**ACID Properties (What Transactions Guarantee):**
- **A**tomic: All or nothing (no partial updates)
- **C**onsistent: Database always in valid state
- **I**solated: Concurrent transactions don't interfere
- **D**urable: Committed changes survive crashes

**Key Lesson:** Any related updates that must succeed together MUST be wrapped in a transaction. Never leave financial or critical operations without transaction safety.

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

---

## Error 7: Non-Deterministic Generated Column

```sql
CREATE TABLE t (
  id INT,
  created TIMESTAMP GENERATED ALWAYS AS (NOW())
);
-- MySQL Error: Expression of generated column contains a disallowed function
```

**What's Wrong:**
GENERATED columns must be deterministic (same input = same output). NOW() returns different values each time, so it's non-deterministic.

**Why It's Wrong:**
```sql
-- NOW() changes every second
SELECT NOW();  -- 2025-03-15 10:30:45
SELECT NOW();  -- 2025-03-15 10:30:46 (different!)

-- For GENERATED columns, MySQL needs to be able to recalculate the value
-- from other columns. But NOW() doesn't use any other columns—it uses time!

-- This would make NO sense:
-- "Calculate created by looking at id... but there's no relationship!"
```

**Generated Column Rules:**
```sql
-- WRONG: Non-deterministic functions
created TIMESTAMP GENERATED ALWAYS AS (NOW())  ✗
random_num INT GENERATED ALWAYS AS (RAND())  ✗
user_var VARCHAR(50) GENERATED ALWAYS AS (@myvar)  ✗

-- RIGHT: Deterministic expressions based on other columns
full_name VARCHAR(100) GENERATED ALWAYS AS (CONCAT(first_name, ' ', last_name))  ✓
total DECIMAL(10,2) GENERATED ALWAYS AS (quantity * price)  ✓
age INT GENERATED ALWAYS AS (YEAR(CURDATE()) - YEAR(birth_date))  ✓
```

**The Fix:**
```sql
-- For timestamps, use DEFAULT (not GENERATED)
CREATE TABLE t (
  id INT PRIMARY KEY AUTO_INCREMENT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- ✓ Set once when row created
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  -- ✓ Auto-updates on changes
);

-- GENERATED columns are for calculated fields based on OTHER columns:
CREATE TABLE orders (
  id INT PRIMARY KEY AUTO_INCREMENT,
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  tax_rate DECIMAL(3,2) DEFAULT 0.08,
  
  -- These are GENERATED (calculated from other columns)
  subtotal DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
  tax_amount DECIMAL(10,2) GENERATED ALWAYS AS (subtotal * tax_rate) STORED,
  total DECIMAL(10,2) GENERATED ALWAYS AS (subtotal + tax_amount) STORED
);

-- Example:
INSERT INTO orders (quantity, unit_price) VALUES (5, 10.00);
-- Automatically calculates:
-- subtotal = 5 * 10.00 = 50.00
-- tax_amount = 50.00 * 0.08 = 4.00  
-- total = 50.00 + 4.00 = 54.00
```

**Key Lesson:** Use DEFAULT for timestamps, use GENERATED for calculations based on other columns in the same row.

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

---

## Summary: Common Professional SQL Errors

**Security Errors (CRITICAL):**
- ❌ SQL injection (string concatenation)
- ❌ Plain-text passwords
- ❌ Weak hashing (MD5/SHA1)

**Data Integrity Errors:**
- ❌ Missing transactions for related updates
- ❌ Poor naming (cryptic aliases, reserved words)
- ❌ Missing indexes on foreign keys
- ❌ Wrong column types for generated columns

**Code Quality Errors:**
- ❌ No error handling in procedures
- ❌ Missing documentation
- ❌ Poor formatting (unreadable queries)

**How to Prevent These:**
1. ✅ Always use prepared statements
2. ✅ Always use bcrypt for passwords
3. ✅ Always use transactions for related updates
4. ✅ Always add error handlers to procedures
5. ✅ Always add indexes to foreign keys
6. ✅ Always document complex code
7. ✅ Always format code for readability
8. ✅ Always validate inputs

**Key Takeaways:** 
- Professional code requires security, clarity, error handling, and performance optimization
- Most errors are preventable with good habits and checklists
- Code review catches errors before they reach production
- Testing reveals edge cases that look correct but fail in practice

**Beginner Tip:** Create a personal checklist of these errors and review it before committing code. Professional developers don't memorize everything—they use checklists!

