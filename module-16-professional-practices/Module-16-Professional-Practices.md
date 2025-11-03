# Module 16 · Professional SQL Practices

Write production-quality SQL: readable, secure, maintainable, and performant.

## Best Practices:

### 1. Code Style & Formatting
```sql
-- Good: Readable, consistent formatting
SELECT 
  c.customer_id,
  c.full_name,
  COUNT(o.order_id) AS order_count,
  SUM(o.amount) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE c.status = 'active'
  AND c.signup_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY c.customer_id, c.full_name
HAVING total_spent > 1000
ORDER BY total_spent DESC;
```

### 2. Security
```sql
-- BAD: SQL injection risk
query = "SELECT * FROM users WHERE username = '" + user_input + "'";

-- GOOD: Parameterized query (application code)
PREPARE stmt FROM 'SELECT * FROM users WHERE username = ?';
SET @username = 'alice';
EXECUTE stmt USING @username;
```

### 3. Documentation
```sql
/*
 * Monthly Revenue Report
 * Purpose: Calculate revenue by product category for the last 30 days
 * Author: Data Team
 * Date: 2025-03-01
 * Dependencies: orders, products tables
 */
SELECT 
  p.category,
  SUM(o.amount) AS revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE o.order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY p.category;
```

### 4. Testing
- Test with empty datasets
- Test with NULL values
- Test edge cases
- Verify performance with realistic data volumes
- Use transactions for test data cleanup

### 5. Version Control
- Store SQL scripts in Git
- Use migration tools (Flyway, Liquibase)
- Tag releases
- Document schema changes

## Professional Checklist:
✅ Consistent naming conventions  
✅ Clear, documented queries  
✅ Parameterized inputs (no SQL injection)  
✅ Error handling  
✅ Performance tested  
✅ Code reviewed  
✅ Version controlled
