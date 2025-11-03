# Paired Programming — Professional Practices

## Challenge: Complete Database Code Review

### Scenario:
Your team is reviewing a new developer's code before merging to production. Work in pairs to review and improve this code.

---

### Code Under Review:

```sql
-- File: user_management.sql

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

---

### Paired Review Checklist:

#### Part 1: Security Issues (Person A leads)
1. Identify all security vulnerabilities
2. Propose fixes for each
3. Add input validation

#### Part 2: Code Quality (Person B leads)
1. Fix naming conventions
2. Add proper data types
3. Improve table structure

#### Part 3: Documentation (Both)
1. Add comprehensive comments
2. Document all procedures
3. Create usage examples

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

**Key Takeaways:**
- Code review catches issues before production
- Pair programming improves code quality
- Security and documentation are non-negotiable

