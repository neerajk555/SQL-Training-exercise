# Take-Home Challenges — Professional Practices

## 📋 Before You Start

### Learning Objectives
By completing these take-home challenges, you will:
- Apply professional-grade security, testing, and deployment practices
- Master SQL injection prevention and parameterized queries
- Research industry standards for documentation and version control
- Develop skills for code review and performance testing
- Build production-ready database solutions with confidence

### How to Approach
**Time Allocation (90-120 min per challenge):**
- 📖 **20 min**: Research industry standards, understand security implications
- 🎯 **20 min**: Plan solution with documentation, testing strategy
- 💻 **50-70 min**: Implement with comments, test edge cases thoroughly
- ✅ **20 min**: Review solutions, perform security audit

**Success Tips:**
- ✅ Never trust user input—always validate and sanitize
- ✅ Use prepared statements (parameterized queries) to prevent SQL injection
- ✅ Write comprehensive header comments (purpose, author, date, params)
- ✅ Test with malicious inputs (', --, OR 1=1)
- ✅ Document deployment steps and rollback procedures
- ✅ Peer review your code before deployment
- ✅ Version control all database scripts

**🔐 CRITICAL SECURITY:** Always assume user input is malicious. Never concatenate user data into SQL!

---

**Welcome to the Big League!**

These are real-world challenges that professional database engineers face. Unlike the quick drills, these require:
- Research and planning
- Multiple files and scripts
- Testing and validation
- Complete documentation

**Instructions:**
1. Pick one challenge to start with
2. Read the entire challenge before coding
3. Create a project folder with organized files
4. Document your approach and decisions
5. Test thoroughly before submitting
6. Be prepared to explain your choices

**Skill Level:** Advanced (requires understanding of all previous modules)

---

## Challenge 1: Database Migration Strategy

### Scenario:
You're the lead database engineer at a growing e-commerce company. Your production database needs a major schema change: adding a `status` column to the `users` table (100 million rows). The site must stay online 24/7—any downtime costs $10,000 per minute.

**Business Requirements:**
- Zero downtime (site must remain operational)
- No data loss (every user must be preserved)
- Rollback capability (in case something goes wrong)
- Complete audit trail (document every change)
- Performance impact < 5% during migration

**Technical Constraints:**
- Production database: 100M users, 500GB total size
- Peak traffic: 10,000 queries/second
- Backup window: Limited to overnight maintenance window (2am-6am)
- Team approval required for all changes

### Your Deliverables:
Create a complete migration package with:

1. **Migration Scripts** (versioned, tested)
   - Forward migration (add column)
   - Data backfill (populate existing rows)
   - Rollback script (undo changes)

2. **Pre-flight Checks** (validate before running)
   - Database connectivity
   - Sufficient disk space
   - No blocking locks
   - Backup exists

3. **Post-migration Validation** (verify success)
   - All rows have status
   - No NULL values where unexpected
   - Indexes functioning
   - Application still works

4. **Documentation** (explain everything)
   - Migration plan (step-by-step)
   - Risk analysis (what could go wrong)
   - Rollback procedure (how to undo)
   - Communication plan (who to notify)

5. **Monitoring** (track progress)
   - Migration progress (% complete)
   - Performance impact (query times)
   - Error logging (what failed)
   - Estimated completion time

### Example Migration Scripts:

**File: migrations/v1.1_add_user_status.sql**
```sql
-- ============================================
-- MIGRATION: v1.0 -> v1.1
-- Author: DevOps Team
-- Date: 2024-01-15
-- Description: Add status field to users table
-- Note: May require significant processing for large tables (100M rows)
-- Rollback: migrations/rollback/v1.1_rollback.sql
-- Risk Level: MEDIUM (large table, but non-blocking approach)
-- ============================================

-- ============================================
-- STEP 1: PRE-MIGRATION CHECKS
-- ============================================

-- Check 1: Verify database connectivity
SELECT 'Database connection OK' AS check_1;

-- Check 2: Verify table exists and check row count
SELECT 
  COUNT(*) AS total_rows,
  'Row count verified' AS check_2
FROM users;

-- Check 3: Check for NULL IDs (data integrity)
SELECT COUNT(*) INTO @null_ids FROM users WHERE id IS NULL;
IF @null_ids > 0 THEN
  SIGNAL SQLSTATE '45000' 
  SET MESSAGE_TEXT = 'MIGRATION ABORTED: Found NULL user IDs';
END IF;

-- Check 4: Verify sufficient disk space (need ~10GB for index)
-- (Run this from shell: df -h /var/lib/mysql)

-- Check 5: Verify backup exists
-- (Confirm backup file dated today exists)

-- Check 6: Create tracking table for migration
CREATE TABLE IF NOT EXISTS schema_migrations (
  version VARCHAR(10) PRIMARY KEY,
  description TEXT,
  applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  applied_by VARCHAR(100),
  rollback_script VARCHAR(255)
);

-- ============================================
-- STEP 2: ADD COLUMN (Non-blocking approach)
-- ============================================

-- Add column with DEFAULT value (fast operation in MySQL 8.0+)
-- This uses INSTANT algorithm - no table copy needed
ALTER TABLE users 
ADD COLUMN status ENUM('active', 'inactive', 'suspended') 
DEFAULT 'active'
COMMENT 'User account status: active=can login, inactive=cannot login, suspended=banned';

-- Verify column added
SELECT 
  COLUMN_NAME, 
  COLUMN_DEFAULT, 
  IS_NULLABLE,
  COLUMN_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'users' AND COLUMN_NAME = 'status';

-- ============================================
-- STEP 3: BACKFILL EXISTING DATA (if needed)
-- ============================================

-- Note: With DEFAULT, new column already has 'active' for all rows
-- But let's verify and log any issues

-- Check for NULL values (shouldn't be any with DEFAULT)
SELECT COUNT(*) INTO @null_count 
FROM users 
WHERE status IS NULL;

IF @null_count > 0 THEN
  -- Backfill in batches to avoid long locks
  SET @batch_size = 10000;
  SET @rows_updated = 0;
  
  REPEAT
    UPDATE users 
    SET status = 'active' 
    WHERE status IS NULL 
    LIMIT @batch_size;
    
    SET @rows_updated = @rows_updated + ROW_COUNT();
    
    -- Log progress
    SELECT CONCAT('Backfilled ', @rows_updated, ' rows') AS progress;
    
    -- Small delay to avoid overwhelming system
    DO SLEEP(0.1);
  UNTIL ROW_COUNT() = 0 END REPEAT;
END IF;

-- ============================================
-- STEP 4: ADD INDEX (Can take time on large table)
-- ============================================

-- Add index for status queries (used in WHERE status = 'active')
-- This can take significant time on large tables (100M rows)
-- Monitor progress: SHOW PROCESSLIST;
CREATE INDEX idx_users_status ON users(status);

-- Verify index created
SHOW INDEX FROM users WHERE Key_name = 'idx_users_status';

-- ============================================
-- STEP 5: POST-MIGRATION VALIDATION
-- ============================================

-- Validation 1: Check all rows have status
SELECT 
  COUNT(*) AS total_users,
  COUNT(CASE WHEN status IS NULL THEN 1 END) AS null_status_count,
  COUNT(CASE WHEN status = 'active' THEN 1 END) AS active_count,
  COUNT(CASE WHEN status = 'inactive' THEN 1 END) AS inactive_count,
  COUNT(CASE WHEN status = 'suspended' THEN 1 END) AS suspended_count
FROM users;

-- Validation 2: Verify index is usable
EXPLAIN SELECT * FROM users WHERE status = 'active';
-- Should show "key: idx_users_status" in output

-- Validation 3: Test query performance
SET @start_time = NOW(6);
SELECT COUNT(*) FROM users WHERE status = 'active';
SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000 AS query_time_ms;
-- Should be < 100ms with index

-- ============================================
-- STEP 6: RECORD MIGRATION
-- ============================================

INSERT INTO schema_migrations (version, description, applied_by, rollback_script)
VALUES (
  '1.1',
  'Add status column to users table',
  CURRENT_USER(),
  'migrations/rollback/v1.1_rollback.sql'
);

-- ============================================
-- MIGRATION COMPLETE
-- ============================================
SELECT 
  'Migration v1.1 completed successfully' AS status,
  NOW() AS completed_at;
```

**File: migrations/rollback/v1.1_rollback.sql**
```sql
-- ============================================
-- ROLLBACK: v1.1 -> v1.0
-- Author: DevOps Team
-- Date: 2024-01-15
-- Description: Remove status column from users table
-- WARNING: This will DELETE the status column and all its data!
-- ============================================

-- ============================================
-- PRE-ROLLBACK CHECKS
-- ============================================

-- Verify migration was actually applied
SELECT * FROM schema_migrations WHERE version = '1.1';
-- If empty, migration was never applied - don't rollback!

-- Backup current state before rollback
-- (Confirm backup exists before proceeding)

-- ============================================
-- ROLLBACK STEPS
-- ============================================

-- Step 1: Remove index (fast)
DROP INDEX IF EXISTS idx_users_status ON users;
SELECT 'Index dropped' AS step_1;

-- Step 2: Remove column (fast in MySQL 8.0+, uses INSTANT algorithm)
ALTER TABLE users DROP COLUMN status;
SELECT 'Column dropped' AS step_2;

-- Step 3: Remove migration record
DELETE FROM schema_migrations WHERE version = '1.1';
SELECT 'Migration record removed' AS step_3;

-- ============================================
-- POST-ROLLBACK VALIDATION
-- ============================================

-- Verify column no longer exists
SELECT COUNT(*) INTO @status_exists
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'users' AND COLUMN_NAME = 'status';

IF @status_exists > 0 THEN
  SIGNAL SQLSTATE '45000' 
  SET MESSAGE_TEXT = 'ROLLBACK FAILED: status column still exists';
END IF;

-- Verify index no longer exists
SELECT COUNT(*) INTO @index_exists
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_NAME = 'users' AND INDEX_NAME = 'idx_users_status';

IF @index_exists > 0 THEN
  SIGNAL SQLSTATE '45000' 
  SET MESSAGE_TEXT = 'ROLLBACK FAILED: index still exists';
END IF;

-- ============================================
-- ROLLBACK COMPLETE
-- ============================================
SELECT 
  'Rollback v1.1 completed - database restored to v1.0' AS status,
  NOW() AS completed_at;
```

### Your Tasks:

Now create your own migration using this as a template:

**Task 1: Create Migration for Email Verification**
Add an `email_verified` column to the `users` table:
- Boolean field (0 = not verified, 1 = verified)
- Default to 0 (unverified) for existing users
- Add index for quick lookups
- Include all pre/post validation checks

**Task 2: Write Complete Rollback Script**
- Remove column and index
- Verify complete removal
- Update migration tracking table
- Add safety checks (don't rollback if never applied)

**Task 3: Create Deployment Documentation**
Write a `MIGRATION_PLAN.md` that includes:
- Executive summary (what, why, when)
- Risk analysis (what could go wrong)
- Rollback procedure (how to undo)
- Communication plan (who to notify)
- Success criteria (how to verify)

**Task 4: Test on Sample Data**
- Create test database with sample data
- Run migration and verify success
- Run rollback and verify restoration
- Document any issues encountered

**Bonus Challenge:**
Add monitoring queries that track:
- Migration progress (% complete)
- Performance impact (query latency)
- Error rate (failed operations)
- Estimated time remaining

**Evaluation Criteria:**
- ✅ Code works correctly (no data loss)
- ✅ Comprehensive error handling
- ✅ Clear documentation
- ✅ Proper validation (pre and post)
- ✅ Safe rollback capability
- ✅ Performance considerations (batching, indexing)

---

## Challenge 2: CI/CD Pipeline for Database

### Scenario:
Implement automated testing and deployment for database changes.

### Requirements:
- Automated schema validation
- Test data seeding
- Integration tests
- Deployment automation

### Example CI/CD Configuration:

**File: .github/workflows/database-ci.yml**
```yaml
name: Database CI/CD

on:
  pull_request:
    paths:
      - 'database/**'
  push:
    branches:
      - main

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: root
          MYSQL_DATABASE: test_db
        ports:
          - 3306:3306
    
    steps:
      - uses: actions/checkout@v2
      
      - name: Run migrations
        run: |
          mysql -h 127.0.0.1 -u root -proot test_db < database/schema.sql
      
      - name: Seed test data
        run: |
          mysql -h 127.0.0.1 -u root -proot test_db < database/test_data.sql
      
      - name: Run tests
        run: |
          mysql -h 127.0.0.1 -u root -proot test_db < database/tests/test_procedures.sql
      
      - name: Validate schema
        run: |
          ./scripts/validate_schema.sh
```

**File: database/tests/test_procedures.sql**
```sql
-- ============================================
-- TEST SUITE: User Procedures
-- ============================================

-- Test 1: Create user with valid data
CALL create_user('test@example.com', 'John', 'Doe', @user_id);
SELECT @user_id IS NOT NULL AS test1_passed;

-- Test 2: Reject duplicate email
CALL create_user('test@example.com', 'Jane', 'Doe', @user_id);
-- Should fail with error

-- Test 3: Order creation with sufficient stock
INSERT INTO products (id, name, price, stock_quantity) 
VALUES (1, 'Test Product', 10.00, 100);

CALL create_order(1, '[{"product_id":1,"quantity":2}]', @order_id);
SELECT @order_id IS NOT NULL AS test3_passed;

-- Test 4: Reject order with insufficient stock
CALL create_order(1, '[{"product_id":1,"quantity":999}]', @order_id);
-- Should fail

-- Cleanup
DELETE FROM order_items WHERE order_id = @order_id;
DELETE FROM orders WHERE id = @order_id;
DELETE FROM products WHERE id = 1;
DELETE FROM users WHERE email = 'test@example.com';
```

### Your Tasks:
1. Add schema validation script
2. Create integration tests for orders
3. Implement rollback on test failure
4. Add performance benchmarks

---

## Challenge 3: Compliance and Audit System

### Scenario:
Build GDPR-compliant audit system with data retention and privacy controls.

### Requirements:
- Audit all data access
- Data retention policies
- User data export
- Right to be forgotten

### Implementation:

```sql
-- ============================================
-- COMPLIANCE: Audit System
-- ============================================

CREATE TABLE access_log (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  table_name VARCHAR(50),
  record_id INT,
  action ENUM('SELECT', 'INSERT', 'UPDATE', 'DELETE'),
  ip_address VARCHAR(45),
  user_agent TEXT,
  accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_user_table (user_id, table_name),
  INDEX idx_accessed_at (accessed_at)
);

-- ============================================
-- COMPLIANCE: Data Retention
-- ============================================
CREATE EVENT cleanup_old_logs
ON SCHEDULE EVERY 1 DAY
DO
  DELETE FROM access_log 
  WHERE accessed_at < DATE_SUB(NOW(), INTERVAL 90 DAY);

-- ============================================
-- COMPLIANCE: User Data Export (GDPR)
-- ============================================
DELIMITER //
CREATE PROCEDURE export_user_data(IN p_user_id INT)
BEGIN
  -- Export all user data as JSON
  SELECT JSON_OBJECT(
    'user', (SELECT JSON_OBJECT(
      'id', id, 'email', email, 'name', CONCAT(first_name, ' ', last_name)
    ) FROM users WHERE id = p_user_id),
    'orders', (SELECT JSON_ARRAYAGG(
      JSON_OBJECT('id', id, 'total', total_amount, 'date', created_at)
    ) FROM orders WHERE user_id = p_user_id),
    'addresses', (SELECT JSON_ARRAYAGG(
      JSON_OBJECT('street', street, 'city', city, 'country', country)
    ) FROM addresses WHERE user_id = p_user_id)
  ) AS user_data;
END//

-- ============================================
-- COMPLIANCE: Right to be Forgotten
-- ============================================
CREATE PROCEDURE anonymize_user(IN p_user_id INT)
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Anonymization failed';
  END;
  
  START TRANSACTION;
  
  -- Anonymize personal data
  UPDATE users SET
    email = CONCAT('deleted_', id, '@anonymized.local'),
    first_name = 'Deleted',
    last_name = 'User',
    phone = NULL
  WHERE id = p_user_id;
  
  -- Remove addresses
  DELETE FROM addresses WHERE user_id = p_user_id;
  
  -- Log anonymization
  INSERT INTO compliance_log (action, user_id, timestamp)
  VALUES ('ANONYMIZE', p_user_id, NOW());
  
  COMMIT;
END//
DELIMITER ;

-- ============================================
-- COMPLIANCE: Access Logging Trigger
-- ============================================
DELIMITER //
CREATE TRIGGER log_user_access
AFTER SELECT ON users
FOR EACH ROW
BEGIN
  INSERT INTO access_log (user_id, table_name, record_id, action)
  VALUES (NEW.id, 'users', NEW.id, 'SELECT');
END//
DELIMITER ;
```

### Your Tasks:
1. Implement data retention for multiple tables
2. Create audit report for compliance officers
3. Add encryption for sensitive fields
4. Build consent management system

---

## Challenge 4: Performance Monitoring Dashboard

### Scenario:
Create real-time performance monitoring with alerts.

### Requirements:
- Query performance tracking
- Slow query identification
- Resource usage monitoring
- Automated alerts

### Implementation:

```sql
-- ============================================
-- MONITORING: Query Performance Log
-- ============================================
CREATE TABLE query_performance (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  query_hash VARCHAR(64),
  query_text TEXT,
  execution_time_ms INT,
  rows_examined INT,
  rows_returned INT,
  temp_tables_used BOOLEAN,
  executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_hash (query_hash),
  INDEX idx_execution_time (execution_time_ms),
  INDEX idx_executed_at (executed_at)
);

-- ============================================
-- MONITORING: Slow Query Report
-- ============================================
CREATE VIEW slow_queries AS
SELECT 
  query_hash,
  LEFT(query_text, 100) AS query_preview,
  COUNT(*) AS execution_count,
  AVG(execution_time_ms) AS avg_time_ms,
  MAX(execution_time_ms) AS max_time_ms,
  SUM(rows_examined) AS total_rows_examined
FROM query_performance
WHERE execution_time_ms > 1000  -- Slow queries
  AND executed_at > DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY query_hash, LEFT(query_text, 100)
ORDER BY avg_time_ms DESC;

-- ============================================
-- MONITORING: Performance Alert
-- ============================================
DELIMITER //
CREATE PROCEDURE check_performance_alerts()
BEGIN
  DECLARE v_slow_count INT;
  
  SELECT COUNT(*) INTO v_slow_count
  FROM query_performance
  WHERE execution_time_ms > 5000
    AND executed_at > DATE_SUB(NOW(), INTERVAL 1 HOUR);
  
  IF v_slow_count > 10 THEN
    -- Log alert
    INSERT INTO alerts (type, severity, message)
    VALUES ('PERFORMANCE', 'HIGH', CONCAT(v_slow_count, ' slow queries in last hour'));
  END IF;
END//
DELIMITER ;

-- Schedule hourly check
CREATE EVENT performance_check
ON SCHEDULE EVERY 1 HOUR
DO CALL check_performance_alerts();
```

### Your Tasks:
1. Add disk space monitoring
2. Track connection pool usage
3. Create performance trending reports
4. Implement automated optimization suggestions

---

## Challenge 5: Multi-Environment Configuration

### Scenario:
Manage database configurations across dev, staging, and production.

### Requirements:
- Environment-specific settings
- Secure credential management
- Configuration validation
- Deployment automation

### File Structure:
```
config/
  ├── dev.env
  ├── staging.env
  ├── prod.env
  └── validate_config.sql

scripts/
  ├── deploy.sh
  └── rollback.sh

migrations/
  ├── v1.0_initial.sql
  ├── v1.1_add_status.sql
  └── rollback/
```

### Your Tasks:
1. Create environment configuration system
2. Implement secure credential storage
3. Build automated deployment script
4. Add environment-specific validation

**Key Takeaways:**
- Professional database management requires automation, testing, and monitoring
- Compliance and security are non-negotiable
- Document everything for team collaboration
- Plan for failure with rollback strategies

