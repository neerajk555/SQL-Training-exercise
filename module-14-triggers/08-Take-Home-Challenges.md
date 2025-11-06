# Take-Home Challenges — Triggers

## 📋 Before You Start

### Learning Objectives
By completing these take-home challenges, you will:
- Apply triggers for advanced validation and auditing
- Master BEFORE vs AFTER timing and OLD/NEW references
- Research trigger performance implications and best practices
- Develop skills for preventing infinite trigger loops
- Build confidence with multi-trigger coordination

### How to Approach
**Time Allocation (60-90 min per challenge):**
- 📖 **10 min**: Research trigger timing, understand business rule
- 🎯 **10 min**: Plan trigger logic, identify OLD/NEW usage
- 💻 **35-60 min**: Create trigger with DELIMITER, test thoroughly
- ✅ **15 min**: Review solutions, analyze performance impact

**Success Tips:**
- ✅ Use BEFORE triggers for validation (prevent bad data)
- ✅ Use AFTER triggers for auditing (log after success)
- ✅ Test with NEW.column_name references carefully
- ✅ Avoid triggers that modify same table (infinite loops!)
- ✅ Document trigger purpose in header comments
- ✅ Use SHOW TRIGGERS to verify creation

**⚠️ Performance Warning:** Triggers fire on EVERY row—keep logic minimal!

---

## 🎯 Overview
These advanced challenges are designed for deeper learning outside of class. Each challenge requires research, experimentation, and documentation. Take your time and explore!

---

## Challenge 1: Trigger Performance Analysis

### 📋 Objective
Measure and document the performance impact of triggers on bulk operations. Create a comprehensive performance report.

### 🎓 What You'll Learn
- Benchmarking techniques
- Performance profiling
- Query optimization
- Trade-offs in database design

### 📝 Requirements

**Part 1: Setup Benchmark Environment**
```sql
-- Create test table with space for 100,000+ rows
CREATE TABLE perf_test (
  id INT AUTO_INCREMENT PRIMARY KEY,
  data VARCHAR(100),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Create audit table to log operations
CREATE TABLE perf_audit (
  audit_id INT AUTO_INCREMENT PRIMARY KEY,
  test_id INT,
  action VARCHAR(20),
  timestamp TIMESTAMP
);

-- Populate with sample data using stored procedure
DELIMITER //
CREATE PROCEDURE populate_test_data(num_rows INT)
BEGIN
  DECLARE i INT DEFAULT 1;
  WHILE i <= num_rows DO
    INSERT INTO perf_test (data, created_at, updated_at)
    VALUES (CONCAT('Test data ', i), NOW(), NOW());
    SET i = i + 1;
  END WHILE;
END //
DELIMITER ;

-- Generate 100,000 rows (may take a few minutes)
CALL populate_test_data(100000);
```

**Beginner Note:** 
- Benchmarking means measuring how fast something runs
- We're comparing trigger performance vs no trigger
- More data = more realistic test (that's why 100,000 rows!)

**Part 2: Create Test Scenarios**
1. Baseline (no triggers)
2. Simple AFTER INSERT trigger (log to audit table)
3. Complex BEFORE INSERT trigger (multiple validations + calculations)
4. Multiple triggers (3+ triggers on same table)
5. Trigger with subqueries

**Part 3: Benchmark Operations**
Measure time for:
- Single INSERT
- Bulk INSERT (1,000 rows)
- Bulk INSERT (10,000 rows)
- Single UPDATE
- Bulk UPDATE (all rows)
- DELETE operations

**Part 4: Document Findings**
Create report with:
- Execution time comparisons (table/chart)
- Memory usage analysis
- Lock contention observations
- Recommendations for optimization

### 💡 Tools to Use (Beginner Guide)

**Method 1: Manual timing with NOW(6)**
```sql
-- NOW(6) gives timestamp with microsecond precision
SET @start = NOW(6);

-- Your operation here (e.g., INSERT 1000 rows)
INSERT INTO perf_test (data) VALUES ('test');

SET @end = NOW(6);

-- Calculate difference in microseconds (1 second = 1,000,000 microseconds)
SELECT TIMESTAMPDIFF(MICROSECOND, @start, @end) AS execution_time_microseconds;

-- Convert to milliseconds for easier reading
SELECT TIMESTAMPDIFF(MICROSECOND, @start, @end) / 1000 AS execution_time_ms;
```

**Method 2: MySQL Profiling (more detailed)**
```sql
-- Turn on profiling
SET profiling = 1;

-- Run your operations
INSERT INTO perf_test (data) VALUES ('test1');
INSERT INTO perf_test (data) VALUES ('test2');

-- See summary of all queries
SHOW PROFILES;

-- Get detailed breakdown of specific query (use Query_ID from SHOW PROFILES)
SHOW PROFILE FOR QUERY 1;

-- Turn off profiling when done
SET profiling = 0;
```

**Understanding the numbers:**
- 1 microsecond = 0.000001 seconds (very fast!)
- 1 millisecond = 1,000 microseconds = 0.001 seconds
- 1 second = 1,000,000 microseconds
- Example: 50,000 microseconds = 50 ms = 0.05 seconds

### 🎯 Deliverables
- [ ] SQL scripts for all test scenarios
- [ ] Performance data (CSV or table format)
- [ ] Charts/graphs comparing scenarios
- [ ] Written analysis (500+ words)
- [ ] Recommendations document

---

## Challenge 2: Temporal Data System

### 📋 Objective
Implement a complete temporal (time-based) data system that tracks the entire history of every table using triggers.

### 🎓 What You'll Learn
- Temporal database design
- History tracking patterns
- Point-in-time queries
- Data versioning

### 📝 Requirements

**Part 1: Design History Schema**
For each table, create a corresponding history table:
```sql
CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100),
  status VARCHAR(20),
  -- System columns
  row_version INT DEFAULT 1,
  valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  valid_to TIMESTAMP NULL
);

CREATE TABLE customers_history (
  history_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  name VARCHAR(100),
  email VARCHAR(100),
  status VARCHAR(20),
  row_version INT,
  valid_from TIMESTAMP,
  valid_to TIMESTAMP,
  change_type VARCHAR(10),  -- UPDATE, DELETE
  changed_by VARCHAR(50)
);
```

**Part 2: Implement Trigger System**
Create triggers that:
1. On UPDATE: Copy old row to history table, increment version
2. On DELETE: Mark row as deleted in history, set valid_to
3. Track who made changes and when
4. Handle multiple columns changing at once

**Part 3: Build Query Interface**
Create stored procedures or views for:
- Get current state of any record
- Get state of record at specific date/time
- Get all changes for a record
- Get who changed what and when
- Rollback to previous version

**Part 4: Test Scenarios**
1. Make multiple changes to same record
2. Query historical state
3. Find who changed specific data
4. Generate change report
5. Restore deleted record from history

### 💡 Advanced Features
- Bi-temporal data (business time + system time)
- Compression of old history
- Partitioning by date range
- Archival strategy

### 🎯 Deliverables
- [ ] Complete schema with history tables
- [ ] All triggers created and tested
- [ ] Query interface (procedures/views)
- [ ] User documentation
- [ ] Test results demonstrating time-travel queries

---

## Challenge 3: Business Rule Engine

### 📋 Objective
Build a sophisticated business rule engine using triggers that implements complex discount calculations, eligibility checks, and workflow automation.

### 🎓 What You'll Learn
- Business logic in database layer
- Complex rule evaluation
- Workflow state machines
- Decision trees in SQL

### 📝 Requirements

**Implement these business rules:**

1. **Dynamic Pricing Rules**
   - Bulk discount: 10% off if quantity > 10
   - Loyalty discount: 5% off for customers with 100+ loyalty points
   - Seasonal discount: 15% off specific categories during promotions
   - Stacking rules: Maximum 30% total discount

2. **Customer Eligibility Rules**
   - New customers: Can't exceed $1,000 first order
   - Credit checks: Balance + new order ≤ credit limit
   - Account status: Only active accounts can order
   - VIP customers: Can order out-of-stock items (backorder)

3. **Workflow Automation**
   - Order status progression: pending → confirmed → shipped → delivered
   - Auto-cancel orders not paid within 24 hours
   - Auto-complete orders delivered 7+ days ago
   - Prevent status going backward (can't un-ship)

4. **Inventory Rules**
   - Reserve stock when order placed
   - Release stock if order cancelled
   - Alert purchasing when stock < min_stock
   - Prevent overselling

**Part 2: Implementation**
Create triggers that enforce all rules automatically. Use tables for configuration:

```sql
CREATE TABLE discount_rules (
  rule_id INT PRIMARY KEY,
  rule_name VARCHAR(100),
  rule_type VARCHAR(50),
  threshold_value DECIMAL(10,2),
  discount_percent DECIMAL(5,2),
  is_active BOOLEAN,
  priority INT
);

CREATE TABLE workflow_rules (
  rule_id INT PRIMARY KEY,
  from_status VARCHAR(20),
  to_status VARCHAR(20),
  conditions TEXT,
  actions TEXT
);
```

**Part 3: Testing**
Create comprehensive test cases for:
- Each rule individually
- Multiple rules applying together
- Edge cases and boundary conditions
- Rule conflicts
- Rule priority

### 🎯 Deliverables
- [ ] Complete rule engine schema
- [ ] All business rule triggers
- [ ] Configuration tables populated
- [ ] Test suite with 20+ test cases
- [ ] Documentation of each rule
- [ ] Performance analysis

---

## Challenge 4: Trigger Debugging System

### 📋 Objective
Build a comprehensive logging and debugging system to trace trigger execution order, data flow, and performance issues.

### 📝 Requirements

**Part 1: Debug Infrastructure**
```sql
CREATE TABLE trigger_debug_log (
  log_id INT AUTO_INCREMENT PRIMARY KEY,
  trigger_name VARCHAR(100),
  table_name VARCHAR(50),
  event_type VARCHAR(20),
  execution_order INT,
  execution_start TIMESTAMP(6),
  execution_end TIMESTAMP(6),
  duration_microseconds INT,
  row_data TEXT,
  notes TEXT
);

CREATE TABLE trigger_call_stack (
  stack_id INT AUTO_INCREMENT PRIMARY KEY,
  session_id VARCHAR(50),
  trigger_name VARCHAR(100),
  call_level INT,
  parent_trigger VARCHAR(100),
  timestamp TIMESTAMP(6)
);
```

**Part 2: Instrumentation**
Add debug logging to all triggers:
```sql
DELIMITER //
CREATE TRIGGER tr_example_with_debug
BEFORE INSERT ON my_table
FOR EACH ROW
BEGIN
  DECLARE start_time TIMESTAMP(6);
  DECLARE end_time TIMESTAMP(6);
  
  SET start_time = NOW(6);
  
  -- Original trigger logic here
  
  SET end_time = NOW(6);
  
  -- Log execution
  INSERT INTO trigger_debug_log (
    trigger_name, table_name, event_type,
    execution_start, execution_end,
    duration_microseconds, row_data
  ) VALUES (
    'tr_example_with_debug',
    'my_table',
    'BEFORE INSERT',
    start_time,
    end_time,
    TIMESTAMPDIFF(MICROSECOND, start_time, end_time),
    JSON_OBJECT('id', NEW.id, 'name', NEW.name)
  );
END //
DELIMITER ;
```

**Part 3: Analysis Tools**
Create queries/procedures to:
- Show trigger execution order for an operation
- Find slowest triggers
- Visualize trigger call chains
- Detect trigger loops
- Generate execution reports

### 🎯 Deliverables
- [ ] Debug infrastructure schema
- [ ] Instrumented trigger examples
- [ ] Analysis query library
- [ ] Dashboard/report templates
- [ ] Documentation for using debug system

---

## Challenge 5: Conflict Resolution

### 📋 Objective
Handle scenarios where multiple triggers fire simultaneously and ensure correct execution order using trigger naming conventions and design patterns.

### 📝 Scenarios to Handle

1. **Multiple BEFORE triggers on same table**
   - Validation trigger
   - Default value trigger
   - Calculated field trigger
   - How to ensure they execute in correct order?

2. **Cascading updates across tables**
   - Order placed → Update inventory
   - Update inventory → Create alert
   - Create alert → Send notification
   - Prevent infinite loops!

3. **Concurrent trigger execution**
   - Two users update same product simultaneously
   - Both trigger stock alerts
   - Prevent duplicate alerts

4. **Transaction boundaries**
   - Multiple operations in one transaction
   - Some triggers succeed, some fail
   - Ensure consistency

### 💡 Implementation Strategies

**Strategy 1: Naming Convention**
```sql
-- Use prefixes to control order (alphabetical execution)
CREATE TRIGGER tr_01_validate ...
CREATE TRIGGER tr_02_calculate ...
CREATE TRIGGER tr_03_audit ...
```

**Strategy 2: Coordinator Trigger**
```sql
-- Single trigger calls stored procedures in order
CREATE TRIGGER tr_coordinator ...
BEGIN
  CALL validate_data(NEW.id);
  CALL calculate_fields(NEW.id);
  CALL audit_changes(NEW.id);
END;
```

**Strategy 3: Flag Columns**
```sql
-- Prevent re-triggering
ALTER TABLE my_table ADD processing BOOLEAN DEFAULT FALSE;

CREATE TRIGGER tr_example ...
BEGIN
  IF NEW.processing = FALSE THEN
    SET NEW.processing = TRUE;
    -- Do work
    SET NEW.processing = FALSE;
  END IF;
END;
```

### 🎯 Deliverables
- [ ] Documentation of 5+ conflict scenarios
- [ ] Solution for each scenario
- [ ] Test cases proving solutions work
- [ ] Best practices guide
- [ ] Decision flowchart for conflict resolution

---

## Challenge 6: Trigger vs Application Logic

### 📋 Objective
Create a comprehensive decision framework for when to use triggers versus application code.

### 📝 Analysis Areas

**Part 1: Comparison Matrix**
Create table comparing:
- Performance
- Maintainability
- Testability
- Portability
- Debugging difficulty
- Team skill requirements
- Documentation needs

**Part 2: Use Case Analysis**
Analyze 10+ scenarios:
1. Email validation
2. Audit logging
3. Calculated fields
4. Complex business rules
5. External API calls
6. Data encryption
7. Notification sending
8. Report generation
9. Data archival
10. Referential integrity

For each: triggers better or application better? Why?

**Part 3: Decision Flowchart**
Create visual flowchart that helps developers decide. Include decision points like:
- Is it data validation?
- Does it need to happen regardless of application?
- Is it performance-critical?
- Does it require external services?
- How often does it change?

**Part 4: Migration Guide**
Document how to:
- Move logic from triggers to application
- Move logic from application to triggers
- Hybrid approach

### 🎯 Deliverables
- [ ] Comparison matrix (table format)
- [ ] Use case analysis document
- [ ] Decision flowchart (visual diagram)
- [ ] Migration guide
- [ ] Code examples for both approaches

---

## Challenge 7: Transaction-Safe Triggers

### 📋 Objective
Ensure triggers work correctly with transactions, including proper COMMIT and ROLLBACK behavior.

### 📝 Requirements

**Part 1: Transaction Behavior Study**
Test and document:
```sql
-- Scenario 1: Successful transaction
START TRANSACTION;
INSERT INTO orders (customer_id, total) VALUES (1, 100);
-- Trigger fires, updates inventory
COMMIT;
-- Both order and inventory update saved

-- Scenario 2: Rolled back transaction
START TRANSACTION;
INSERT INTO orders (customer_id, total) VALUES (1, 100);
-- Trigger fires, updates inventory
ROLLBACK;
-- Both order and inventory update rolled back

-- Scenario 3: Trigger error
START TRANSACTION;
INSERT INTO orders (customer_id, total) VALUES (1, 100);
-- Trigger fires, raises error
-- Transaction automatically rolled back

-- Scenario 4: Nested transactions (savepoints)
START TRANSACTION;
INSERT INTO orders VALUES (1, 100);
SAVEPOINT sp1;
INSERT INTO orders VALUES (2, 200);  -- This might trigger error
ROLLBACK TO sp1;  -- Only rollback second insert
COMMIT;  -- First insert and its trigger effects saved
```

**Part 2: Build Transaction-Safe Triggers**
Create triggers that:
- Handle partial failures gracefully
- Use SAVEPOINT when needed
- Implement compensating transactions
- Log transaction boundaries

**Part 3: Test Suite**
Create tests for:
- Normal commit path
- Rollback scenarios
- Error handling
- Nested transactions
- Deadlock scenarios
- Concurrent transactions

### 🎯 Deliverables
- [ ] Transaction behavior documentation
- [ ] Transaction-safe trigger examples
- [ ] Test suite (20+ test cases)
- [ ] Best practices guide
- [ ] Troubleshooting guide

---

## 📚 Research Topics

Deepen your understanding by researching:

### 1. **Trigger Execution Order**
- MySQL trigger firing order
- How to control execution sequence
- Platform differences (MySQL vs PostgreSQL vs SQL Server)

### 2. **Performance Tuning**
- Minimizing trigger overhead
- Indexing strategies for triggered queries
- Batching trigger operations
- Async trigger alternatives

### 3. **Debugging Techniques**
- Using SHOW WARNINGS
- Error logging strategies
- Debug tables and instrumentation
- Performance profiling

### 4. **Best Practices**
- Industry standards for trigger use
- Anti-patterns to avoid
- Trigger naming conventions
- Documentation standards

### 5. **Advanced Patterns**
- Event-driven architecture
- Pub/sub patterns with triggers
- Trigger-based ETL
- Change data capture (CDC)

---

## 🎓 Learning Resources

**Recommended reading:**
- MySQL Reference Manual: Triggers chapter
- Database Design and Relational Theory by C.J. Date
- SQL Performance Explained by Markus Winand
- High Performance MySQL by Baron Schwartz

**Online resources:**
- MySQL forums and Stack Overflow
- Database performance blogs
- GitHub repositories with trigger examples

---

## 🎯 Completion Certificate

Complete all 7 challenges and document your work. Your portfolio should include:

- [ ] All SQL code (well-commented)
- [ ] Test results and benchmarks
- [ ] Written analysis and reports
- [ ] Diagrams and visualizations
- [ ] README with project overview
- [ ] Lessons learned document



**Congratulations on taking your trigger skills to an advanced level!**

