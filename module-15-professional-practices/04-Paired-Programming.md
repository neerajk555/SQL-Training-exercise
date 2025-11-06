# Paired Programming — Professional Practices

## 📋 Before You Start

### Learning Objectives
Through paired programming, you will:
- Experience collaborative code review processes
- Learn to identify SQL injection vulnerabilities together
- Practice discussing code quality and readability standards
- Build teamwork skills for security and performance reviews
- Apply professional SQL practices collaboratively

### Paired Programming Roles
**🚗 Driver (Controls Keyboard):**
- Types refactored SQL code
- Verbalizes security concerns ("This needs parameterization...")
- Asks navigator about best practices
- Focuses on implementation

**🧭 Navigator (Reviews & Guides):**
- Keeps code quality checklist visible
- **Spots security vulnerabilities**
- Suggests formatting and naming improvements
- Discusses performance implications
- **Does NOT touch the keyboard**

### Execution Flow
1. **Setup**: Both review problematic code together
2. **Section 1**: Navigator identifies issues → discuss fixes → Driver refactors → **SWITCH ROLES**
3. **Section 2**: Repeat with reversed roles → **SWITCH ROLES**
4. **Section 3**: Repeat with reversed roles
5. **Review**: Compare with solutions, discuss trade-offs

**Critical Focus Areas:**
- 🔒 SQL injection prevention
- 📝 Code readability and formatting
- ⚡ Performance considerations
- 🏗️ Naming conventions and structure

---

## Challenge: Complete Database Code Review

### Scenario:
Your team is reviewing a junior developer's code before merging to production. This is a critical security and quality review—the code has several serious issues that could cause data breaches or system failures. Work in pairs to find and fix all problems.

**Pair Programming Approach:**
- **Person A (Driver):** Types the code and explains their thinking
- **Person B (Navigator):** Reviews, suggests improvements, catches errors
- **Switch roles** after each section to keep both engaged

**Why Pair Programming?**
- Two sets of eyes catch more bugs
- Knowledge sharing (learn from each other)
- Better code quality (real-time review)
- Reduces knowledge silos (both understand the code)

---

### Code Under Review:

**⚠️ WARNING: This code has critical security flaws! DO NOT use in production!**

```sql
-- File: user_management.sql
-- Submitted by: Junior Developer
-- Status: NEEDS MAJOR REVISION

CREATE TABLE user (
  id int,
  user_name varchar(50),
  pass varchar(50),
  email varchar(100),
  status int
);

CREATE PROCEDURE get_user(user_id int)
BEGIN
  select * from user where id=user_id;
END;

CREATE PROCEDURE login(uname varchar(50), pwd varchar(50))
BEGIN
  select * from user where user_name=uname and pass=pwd;
END;

CREATE TRIGGER update_user
AFTER UPDATE ON user
FOR EACH ROW
BEGIN
  INSERT INTO log VALUES (NEW.id, 'updated', NOW());
END;
```

**First Impressions—Spot the Problems:**
Take a moment with your pair to list everything wrong. How many issues can you find?

<details>
<summary>Click to see the 15+ issues we found</summary>

**Security Issues (CRITICAL):**
1. Plain-text passwords (`pass varchar(50)`)
2. Login procedure allows SQL injection (though params are safer than concatenation)
3. Returns passwords in `get_user` SELECT *
4. No account lockout after failed attempts

**Data Integrity Issues:**
5. No PRIMARY KEY on id
6. No AUTO_INCREMENT on id
7. No UNIQUE constraint on user_name or email
8. No NOT NULL constraints (allows invalid data)
9. status is INT (should be ENUM for clarity)

**Code Quality Issues:**
10. Reserved word `user` as table name (causes syntax errors!)
11. Poor column names (`pass` instead of `password_hash`)
12. No data types specified (int vs INT)
13. No character sets/collations
14. Inconsistent formatting

**Missing Features:**
15. No created_at/updated_at timestamps
16. No indexes (slow queries!)
17. No input validation
18. Log table not defined (trigger will fail!)
19. No error handling
20. Zero documentation

</details>

---

### Paired Review Checklist:

Work through each section together. Take turns being the driver (typing) and navigator (reviewing).

#### Part 1: Security Issues (Person A leads, Person B reviews)

**Task List:**
1. ❌ Fix plain-text password storage → Use bcrypt hash storage
2. ❌ Remove password from SELECT * queries → Return only safe columns
3. ❌ Add input validation → Check for NULL, length limits, format
4. ❌ Add audit logging → Track all login attempts
5. ❌ Implement account lockout → Prevent brute force attacks

**Discussion Questions:**
- Why is plain-text password storage dangerous?
- What happens if the database is stolen?
- How can we prevent SQL injection?

---

#### Part 2: Code Quality (Person B leads, Person A reviews)

**Task List:**
1. ❌ Rename `user` table → Avoid reserved words (use `users`)
2. ❌ Fix column names → Use descriptive names (`password_hash` not `pass`)
3. ❌ Add PRIMARY KEY and AUTO_INCREMENT
4. ❌ Add UNIQUE constraints → Prevent duplicate usernames/emails
5. ❌ Add NOT NULL constraints → Prevent invalid data
6. ❌ Use ENUM for status → Replace INT with meaningful values
7. ❌ Add indexes → Speed up queries
8. ❌ Add timestamps → Track when records created/modified
9. ❌ Specify character sets → Use utf8mb4 for full Unicode support

**Discussion Questions:**
- What problems does a PRIMARY KEY solve?
- Why use ENUM instead of INT for status?
- Where should we add indexes?

---

#### Part 3: Documentation (Both work together)

**Task List:**
1. ❌ Add table header comment → Purpose, dependencies, business rules
2. ❌ Document each procedure → Purpose, parameters, examples
3. ❌ Add column comments → Explain what each field stores
4. ❌ Create usage examples → Show how to call procedures correctly
5. ❌ Document security requirements → bcrypt, input validation

**Discussion Questions:**
- What information would help a new developer?
- What might be confusing 6 months from now?
- What assumptions should we document?

---

### Improved Version:

```sql
-- ============================================
-- TABLE: users
-- Purpose: Store user account information
-- Security: Passwords hashed with bcrypt
-- ============================================
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) UNIQUE NOT NULL,
  password_hash CHAR(60) NOT NULL,  -- bcrypt produces 60 chars
  email VARCHAR(255) UNIQUE NOT NULL,
  status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_username (username),
  INDEX idx_email (email),
  INDEX idx_status (status)
);

-- ============================================
-- PROCEDURE: get_user_by_id
-- Purpose: Retrieve user details by ID
-- Security: Returns safe user data (no password)
-- Parameters:
--   IN p_user_id INT - The user ID to retrieve
-- Example: CALL get_user_by_id(123);
-- ============================================
DELIMITER //
CREATE PROCEDURE get_user_by_id(IN p_user_id INT)
BEGIN
  -- Validate input
  IF p_user_id IS NULL OR p_user_id <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid user ID';
  END IF;
  
  -- Return user data (excluding password)
  SELECT 
    id,
    username,
    email,
    status,
    created_at,
    updated_at
  FROM users
  WHERE id = p_user_id;
END//

-- ============================================
-- PROCEDURE: authenticate_user
-- Purpose: Verify user credentials
-- Security: Uses parameterized queries, returns boolean
-- Note: Application must verify password hash
-- Parameters:
--   IN p_username VARCHAR(50) - Username to check
--   OUT p_user_id INT - User ID if found (NULL otherwise)
--   OUT p_password_hash CHAR(60) - Hash for verification
-- Example: 
--   CALL authenticate_user('john', @uid, @hash);
--   -- Then verify hash in application code
-- ============================================
CREATE PROCEDURE authenticate_user(
  IN p_username VARCHAR(50),
  OUT p_user_id INT,
  OUT p_password_hash CHAR(60)
)
BEGIN
  -- Validate input
  IF p_username IS NULL OR LENGTH(TRIM(p_username)) = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid username';
  END IF;
  
  -- Get user data for verification
  SELECT id, password_hash 
  INTO p_user_id, p_password_hash
  FROM users
  WHERE username = p_username
    AND status = 'active'
  LIMIT 1;
  
  -- Log authentication attempt
  INSERT INTO auth_log (username, attempt_time, success)
  VALUES (p_username, NOW(), p_user_id IS NOT NULL);
END//

-- ============================================
-- TRIGGER: audit_user_changes
-- Purpose: Log all user table modifications
-- Dependencies: audit_log table must exist
-- ============================================
CREATE TRIGGER audit_user_changes
AFTER UPDATE ON users
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (
    table_name,
    record_id,
    action,
    old_values,
    new_values,
    changed_by,
    changed_at
  ) VALUES (
    'users',
    NEW.id,
    'UPDATE',
    JSON_OBJECT('username', OLD.username, 'email', OLD.email, 'status', OLD.status),
    JSON_OBJECT('username', NEW.username, 'email', NEW.email, 'status', NEW.status),
    CURRENT_USER(),
    NOW()
  );
END//
DELIMITER ;

-- ============================================
-- Supporting table for audit
-- ============================================
CREATE TABLE audit_log (
  id INT PRIMARY KEY AUTO_INCREMENT,
  table_name VARCHAR(50) NOT NULL,
  record_id INT NOT NULL,
  action ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
  old_values JSON,
  new_values JSON,
  changed_by VARCHAR(100),
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_table_record (table_name, record_id),
  INDEX idx_changed_at (changed_at)
);
```

---

### Discussion Points:

1. **Security Improvements:**
   - Removed plain-text password storage
   - Separated authentication logic from database
   - Added input validation
   - Used parameterized queries
   - Limited returned data

2. **Code Quality:**
   - Proper naming conventions
   - Type-safe ENUM for status
   - Added indexes for performance
   - Comprehensive error handling

3. **Professional Practices:**
   - Detailed documentation
   - Audit logging
   - Usage examples
   - Supporting infrastructure

---

### Pair Exercise:
Now review this query together and apply the same improvements:

```sql
CREATE PROCEDURE transfer(from_id int, to_id int, amt decimal)
BEGIN
  UPDATE accounts SET balance = balance - amt WHERE id = from_id;
  UPDATE accounts SET balance = balance + amt WHERE id = to_id;
END;
```

**What's wrong?**
- No transaction
- No balance check
- No error handling
- Poor parameter names
- No documentation

---

### Pair Exercise:
Now review this query together and apply the same improvements:

**New Code to Review:**
```sql
CREATE PROCEDURE transfer(from_id int, to_id int, amt decimal)
BEGIN
  UPDATE accounts SET balance = balance - amt WHERE id = from_id;
  UPDATE accounts SET balance = balance + amt WHERE id = to_id;
END;
```

**Pair Discussion:**
Take some time to identify problems:
- What's wrong with this code?
- What could go wrong at runtime?
- How would you fix it?

<details>
<summary>Click to see issues and fixes</summary>

**What's Wrong:**
1. ❌ No transaction (not atomic!)
2. ❌ No balance check (could go negative)
3. ❌ No error handling (fails silently)
4. ❌ Poor parameter names (from_id is vague)
5. ❌ No validation (amt could be negative)
6. ❌ No audit trail (who transferred what?)
7. ❌ No documentation

**Example of What Could Go Wrong:**
```sql
-- Account 1 has $100
-- Transfer $50 from Account 1 to Account 2
CALL transfer(1, 2, 50);

-- Step 1: balance = 100 - 50 = 50 ✓
-- ** DATABASE CRASHES HERE **
-- Step 2: Never happens! ✗

-- Result: Account 1 lost $50, Account 2 gained nothing
-- Money disappeared! This is called a "partial update" bug
```

**Fixed Version:**
```sql
DELIMITER //
CREATE PROCEDURE transfer_funds(
  IN p_from_account_id INT,
  IN p_to_account_id INT,
  IN p_amount DECIMAL(10,2)
)
BEGIN
  DECLARE v_from_balance DECIMAL(10,2);
  
  -- Error handler: rollback on any error
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transfer failed';
  END;
  
  -- Validate inputs
  IF p_amount <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Amount must be positive';
  END IF;
  
  IF p_from_account_id = p_to_account_id THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot transfer to same account';
  END IF;
  
  -- Start transaction (atomic: all or nothing)
  START TRANSACTION;
  
  -- Check sufficient balance
  SELECT balance INTO v_from_balance
  FROM accounts
  WHERE id = p_from_account_id
  FOR UPDATE;  -- Lock row to prevent concurrent transfers
  
  IF v_from_balance < p_amount THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds';
  END IF;
  
  -- Perform transfer
  UPDATE accounts SET balance = balance - p_amount WHERE id = p_from_account_id;
  UPDATE accounts SET balance = balance + p_amount WHERE id = p_to_account_id;
  
  -- Audit log
  INSERT INTO transfer_log (from_account, to_account, amount, timestamp)
  VALUES (p_from_account_id, p_to_account_id, p_amount, NOW());
  
  COMMIT;
END//
DELIMITER ;
```

</details>

---

**Key Takeaways:**
- Code review catches critical bugs before they reach production
- Pair programming produces higher quality code (two brains > one)
- Security issues are often invisible to the original developer
- Documentation and validation are NOT optional extras
- Transactions prevent data corruption from partial updates
- Always ask: "What could go wrong?" and handle those cases

**Beginner Tip:** The best time to catch bugs is during code review. The worst time is in production when customers are affected!

