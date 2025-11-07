# Module 15 · Best Practices for SQL

**What You'll Learn:**
Write production-quality SQL that is readable, secure, maintainable, and performant. This module teaches you the industry standards and best practices that professional developers use every day.

**Why This Matters:**
In the real world, SQL code isn't just about getting results—it's about writing code that other people can understand, that's safe from security attacks, and that performs well under heavy load. Professional SQL practices separate junior developers from senior ones.

**For Beginners:**
Think of this module as learning the "manners" of SQL. Just like in conversation, there are polite ways to communicate that make everyone's life easier. These practices protect your data, make your code readable, and help your team work together effectively.

---

## Best Practices:

### 1. Code Style & Formatting

**What It Means:**
Just like writing an essay with proper paragraphs and punctuation, SQL code should be formatted clearly so anyone can read and understand it quickly.

**Why It Matters:**
- **Readability:** You (or your teammate) will need to modify this code later
- **Debugging:** Clean code makes finding errors much easier
- **Professionalism:** Well-formatted code shows attention to detail

**Key Formatting Rules:**
1. Put each major clause (SELECT, FROM, WHERE) on its own line
2. Indent conditions under WHERE to show they belong together
3. Use meaningful aliases (c for customers, not x or t1)
4. Align column names vertically for easy scanning
5. Use uppercase for SQL keywords (optional but common)

```sql
-- BAD: Hard to read, all squeezed together
SELECT c.customer_id,c.full_name,COUNT(o.order_id) AS order_count,SUM(o.amount) AS total_spent FROM customers c LEFT JOIN orders o ON c.customer_id=o.customer_id WHERE c.status='active' AND c.signup_date>=DATE_SUB(CURDATE(),INTERVAL 1 YEAR) GROUP BY c.customer_id,c.full_name HAVING total_spent>1000 ORDER BY total_spent DESC;

-- GOOD: Readable, consistent formatting
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
HAVING SUM(o.amount) > 1000
ORDER BY total_spent DESC;
```

**Beginner Tip:** Notice how the GOOD version reads almost like English? That's intentional! SQL should tell a story.

### 2. Security

**What It Means:**
Security in SQL means protecting your database from attackers who might try to steal, delete, or modify your data through malicious input.

**The Biggest Threat: SQL Injection**
Imagine someone types `' OR '1'='1` as their username. If you build your query by just combining strings, they can trick your database into running any SQL they want!

**Example of the Attack:**
```sql
-- BAD: SQL injection risk (NEVER DO THIS!)
-- If user_input = "'; DROP TABLE users; --"
-- Your query becomes: SELECT * FROM users WHERE username = ''; DROP TABLE users; --'
-- This deletes your entire users table!
query = "SELECT * FROM users WHERE username = '" + user_input + "'";
```

**Why This Is Dangerous:**
- Attackers can read ALL data (including passwords!)
- They can delete entire tables
- They can modify data (change prices, steal money, etc.)
- This is one of the most common ways websites get hacked

**The Solution: Prepared Statements**
```sql
-- GOOD: Parameterized query (Safe from SQL injection)
-- The ? is a placeholder that MySQL treats as pure data, never as SQL code
PREPARE stmt FROM 'SELECT * FROM users WHERE username = ?';
SET @username = 'alice';
EXECUTE stmt USING @username;

-- Even if someone tries: ' OR '1'='1
-- MySQL will search for a user literally named "' OR '1'='1" (won't find it)
-- The malicious code is treated as harmless text
```

**Beginner Tip:** NEVER build SQL queries by concatenating strings with user input. Always use prepared statements with placeholders (?).

### 3. Documentation

**What It Means:**
Documentation is like leaving notes for your future self (or your teammates). It explains WHAT the code does, WHY it exists, and HOW to use it.

**Why It Matters:**
- You'll forget why you wrote this code in 3 months
- New team members need to understand it quickly
- Bugs are easier to fix when you understand the intent
- Prevents duplicate work ("Oh, someone already built this!")

**What to Document:**
1. **Purpose:** What business problem does this solve?
2. **Author/Date:** Who to ask if there are questions
3. **Dependencies:** What tables/data does this need?
4. **Assumptions:** Any special conditions or edge cases
5. **Performance notes:** Known slow points or optimization needs

```sql
/*
 * Monthly Revenue Report
 * 
 * Purpose: Calculate revenue by product category for the last 30 days
 *          Used by the executive dashboard and monthly sales meetings
 * 
 * Author: Data Team
 * Date: 2025-03-01
 * Last Modified: 2025-03-15 (added category filter)
 * 
 * Dependencies: 
 *   - orders table (requires order_date, amount columns)
 *   - products table (requires product_id, category columns)
 * 
 * Performance: ~500ms on 1M orders, uses index on order_date
 * 
 * Notes: Revenue includes tax but excludes shipping
 */
SELECT 
  p.category,
  SUM(o.amount) AS revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE o.order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY p.category
ORDER BY revenue DESC;
```

**Beginner Tip:** If you need to explain your code to understand it, write that explanation as a comment!

### 4. Testing

**What It Means:**
Testing means trying to break your code before it breaks in production. Good developers think like hackers and try every weird scenario.

**Why It Matters:**
- Bugs in production can cost real money or lose customer trust
- Testing finds issues when they're easy to fix
- You sleep better knowing your code handles edge cases

**Essential Test Cases:**

1. **Empty Datasets:** What if there are no orders this month?
   ```sql
   -- Your query should return 0 or empty result, not crash
   SELECT COUNT(*) FROM orders WHERE order_date >= '2099-01-01';
   ```

2. **NULL Values:** What if someone forgot to enter a price?
   ```sql
   -- Test with NULL values
   INSERT INTO products (name, price) VALUES ('Test', NULL);
   -- Your calculations should handle this gracefully
   ```

3. **Edge Cases:** Boundary conditions
   ```sql
   -- Test with exactly 1 record, exactly 0, and millions
   -- Test with dates at month boundaries
   -- Test with maximum/minimum values
   ```

4. **Performance Testing:** How fast is it with real data?
   ```sql
   -- Test with 1,000 rows, then 100,000, then 1,000,000
   -- Use EXPLAIN to see if indexes are being used
   EXPLAIN SELECT * FROM orders WHERE order_date >= '2024-01-01';
   ```

5. **Cleanup After Tests:** Don't leave test data in production
   ```sql
   START TRANSACTION;
   -- Run your test
   INSERT INTO test_table VALUES ('test data');
   -- Verify results
   SELECT * FROM test_table WHERE data = 'test data';
   -- Clean up
   ROLLBACK;  -- Undo everything
   ```

**Beginner Tip:** Always ask "What could go wrong?" and test that scenario!

### 5. Version Control

**What It Means:**
Version control tracks every change to your code, who made it, and why. It's like having "undo" with unlimited history.

**Why It Matters:**
- You can see who changed what and when (helpful for debugging)
- You can roll back to previous versions if something breaks
- Multiple people can work on the same database without conflicts
- You have a complete history of how your database evolved

**Best Practices:**

1. **Store SQL scripts in Git**
   ```
   database/
     ├── schema/
     │   ├── tables/
     │   │   ├── users.sql
     │   │   └── orders.sql
     │   ├── procedures/
     │   └── views/
     └── migrations/
         ├── 001_create_users.sql
         └── 002_add_status_column.sql
   ```

2. **Use Migration Tools**
   - Tools like Flyway or Liquibase track which changes have been applied
   - Each change is numbered and applied in order
   - Prevents accidents like applying the same change twice

3. **Tag Releases**
   ```bash
   git tag -a v1.0.0 -m "Production release 1.0.0"
   ```
   - Mark stable versions so you can always go back

4. **Document Schema Changes**
   - Every migration should explain WHY the change was needed
   ```sql
   -- Migration 003: Add email_verified column
   -- Reason: Support email verification feature (Ticket #1234)
   -- Author: John Doe
   -- Date: 2025-03-15
   ALTER TABLE users ADD COLUMN email_verified BOOLEAN DEFAULT FALSE;
   ```

**Beginner Tip:** Treat your database schema like code—it should be versioned, reviewed, and tested!

## Professional Checklist:
✅ Consistent naming conventions  
✅ Clear, documented queries  
✅ Parameterized inputs (no SQL injection)  
✅ Error handling  
✅ Performance tested  
✅ Code reviewed  
✅ Version controlled
