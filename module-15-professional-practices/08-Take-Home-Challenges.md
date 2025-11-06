# Take-Home Challenges — Professional Practices

## Challenge 1: Database Migration Strategy

### Scenario:
You need to migrate a production database from version 1.0 to 2.0 with zero downtime.

### Requirements:
1. Create versioned migration scripts
2. Implement rollback capability
3. Document deployment steps
4. Add data validation

### Example Migration Scripts:

**File: migrations/v1.1_add_user_status.sql**
```sql
-- ============================================
-- MIGRATION: v1.0 -> v1.1
-- Author: DevOps Team
-- Date: 2024-01-15
-- Description: Add status field to users table
-- Rollback: migrations/rollback/v1.1_rollback.sql
-- ============================================

-- Pre-migration checks
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM users WHERE id IS NULL) THEN
    RAISE EXCEPTION 'Data integrity issue: NULL user IDs found';
  END IF;
END $$;

-- Add column with default
ALTER TABLE users 
ADD COLUMN status ENUM('active', 'inactive', 'suspended') DEFAULT 'active';

-- Backfill existing data
UPDATE users SET status = 'active' WHERE status IS NULL;

-- Make column NOT NULL
ALTER TABLE users MODIFY COLUMN status ENUM('active', 'inactive', 'suspended') NOT NULL;

-- Add index
CREATE INDEX idx_users_status ON users(status);

-- Post-migration validation
SELECT 
  COUNT(*) AS total_users,
  COUNT(CASE WHEN status IS NULL THEN 1 END) AS null_status
FROM users;

-- Record migration
INSERT INTO schema_migrations (version, applied_at) VALUES ('1.1', NOW());
```

**File: migrations/rollback/v1.1_rollback.sql**
```sql
-- Rollback for v1.1 migration
DROP INDEX idx_users_status ON users;
ALTER TABLE users DROP COLUMN status;
DELETE FROM schema_migrations WHERE version = '1.1';
```

### Your Tasks:
1. Create migration for adding email verification
2. Write rollback script
3. Add pre/post validation checks
4. Document deployment process

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
WHERE execution_time_ms > 1000  -- Queries over 1 second
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

