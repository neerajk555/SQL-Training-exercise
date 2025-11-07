# Quick Warm-Ups — Best Practices for SQL

## 📋 Before You Start

### Learning Objectives
By completing these warm-ups, you will:
- Write clean, readable SQL code
- Add helpful comments and documentation
- Prevent SQL injection vulnerabilities
- Use meaningful naming conventions
- Follow professional SQL standards

### Key Professional Practices
**Code Formatting:**
- One clause per line (SELECT, FROM, WHERE, etc.)
- Indent conditions and subqueries
- Align related items
- Use uppercase for SQL keywords (optional but common)

**Documentation:**
- Comment complex queries
- Explain business logic
- Document assumptions
- Note performance considerations

**Security:**
- NEVER concatenate user input into SQL
- Always use parameterized queries/prepared statements
- Validate and sanitize inputs
- Use principle of least privilege for database users

**Naming Conventions:**
- Use descriptive names (not `tbl1`, `col_a`)
- Be consistent (snake_case or camelCase, pick one)
- Avoid reserved words
- Plural for tables (users), singular for columns (user_id)

### Execution Tips
1. **Format as you write**: Don't wait until code is messy
2. **Review your code**: Read it like someone else will
3. **Test for injection**: Try with malicious inputs
4. **Follow team standards**: Consistency matters more than personal preference

**Beginner Tip:** Professional SQL is readable, secure, and well-documented. Future you (and your team) will thank you!

---

## Exercise 1: Format This Query

**What's Wrong Here?**
This query is technically correct and will run, but it's hard to read—like a sentence with no punctuation or spaces.

```sql
select*from orders where status='pending'and amount>100;
```

**Your Task:** Reformat this query to make it readable and professional.

**What to Fix:**
- Add spaces around operators (*, =, >, AND)
- Put each major clause on its own line
- Indent conditions to show they're related
- Use consistent spacing

**Solution:**
```sql
-- Professional formatting: Clear, readable, easy to maintain
SELECT *
FROM orders
WHERE status = 'pending'
  AND amount > 100;
```

**Why This Matters:** When you come back to this query in 3 months (or a teammate reads it), the formatted version is instantly clear. The messy version requires mental effort to parse.

---

## Exercise 2: Add Comments

**What's Missing:**
This query works fine, but someone reading it has to figure out what it's for. Is it for a report? A dashboard? Debugging?

```sql
SELECT user_id, COUNT(*) FROM orders WHERE created_at > '2024-01-01' GROUP BY user_id;
```

**Your Task:** Add a helpful comment explaining what this query does and why it exists.

**What Good Comments Include:**
- **Purpose:** What business question does this answer?
- **Context:** Who uses this? Where is it used?
- **Assumptions:** Any important date ranges or filters?

**Solution:**
```sql
-- Get order count per user for 2024
-- Used by: Customer engagement report to identify active users
-- Business rule: Only counts completed orders from January 1, 2024 onwards
SELECT 
  user_id,
  COUNT(*) AS order_count
FROM orders
WHERE created_at > '2024-01-01'
GROUP BY user_id
ORDER BY order_count DESC;
```

**Beginner Tip:** If you need to explain the query to a teammate, write that explanation as a comment! Future you will thank present you.

---

## Exercise 3: Fix SQL Injection Risk

**The Danger:**
This code directly inserts user input into a SQL query. An attacker can type special characters to run ANY SQL they want!

```sql
-- DANGEROUS PHP code: NEVER DO THIS!
"SELECT * FROM users WHERE username = '$_POST[username]'"

-- If a hacker types: admin' OR '1'='1' --
-- Your query becomes:
-- SELECT * FROM users WHERE username = 'admin' OR '1'='1' --'
-- This returns ALL users (the OR '1'='1' is always true!)

-- Worse, they could type: '; DROP TABLE users; --
-- This DELETES your entire users table!
```

**Why This Happens:**
When you combine strings directly, you're mixing DATA (the username) with CODE (the SQL). MySQL can't tell the difference, so malicious input gets executed as SQL commands.

**The Fix: Prepared Statements**
Prepared statements keep data and code separate. The `?` is a placeholder that can ONLY hold data, never SQL code.

**Solution:**
```sql
-- MySQL Prepared Statement (safe from SQL injection)
PREPARE stmt FROM 'SELECT * FROM users WHERE username = ?';
SET @username = 'user_input_here';
EXECUTE stmt USING @username;
DEALLOCATE PREPARE stmt;

-- In application code (PHP with PDO):
-- $stmt = $pdo->prepare("SELECT * FROM users WHERE username = ?");
-- $stmt->execute([$_POST['username']]);

-- In application code (PHP with mysqli):
-- $stmt = $mysqli->prepare("SELECT * FROM users WHERE username = ?");
-- $stmt->bind_param("s", $_POST['username']);
-- $stmt->execute();
```

**Beginner Tip:** NEVER build SQL by concatenating strings with user input. Always use prepared statements. This is the #1 most important security rule!

---

## Exercise 4: Name This Better

**The Problem:**
What are `t1`, `t2`, `a`, `b`, and `fk`? This looks like a math problem, not a business query! You have to read the entire query to figure out what it does.

```sql
-- Cryptic naming: What does this query even do?
SELECT t1.a, t2.b FROM t1 JOIN t2 ON t1.id = t2.fk;
```

**Your Task:** Rename everything to be clear and self-documenting.

**Naming Best Practices:**
- Use full table names (not abbreviations like `t1`)
- Use descriptive column names that explain what the data represents
- Make foreign key relationships obvious (`customer_id` is clearly an ID from the customers table)
- The query should read like English

**Solution:**
```sql
-- Clear, self-documenting names: Anyone can understand this
SELECT 
  customers.name AS customer_name,
  orders.total_amount
FROM customers
JOIN orders ON customers.id = orders.customer_id;
```

**Why This Matters:** 
- `customers.name` tells you it's a customer's name
- `orders.customer_id` makes it obvious this links to customers
- No need to guess what `t1.a` means—it's immediately clear

**Beginner Tip:** If you need to explain what a variable means, the name is too vague. Choose names that explain themselves!

---

## Exercise 5: Add Error Handling

**The Problem:**
This procedure blindly updates prices without checking if anything goes wrong. What if the price is negative? What if the product doesn't exist? What if the database crashes mid-update?

```sql
DELIMITER //
CREATE PROCEDURE update_price(IN p_id INT, IN p_price DECIMAL)
BEGIN
  UPDATE products SET price = p_price WHERE id = p_id;
END//
DELIMITER ;
```

**What Could Go Wrong:**
- Someone passes a negative price
- The product ID doesn't exist (silent failure)
- Database connection fails during the update
- No audit trail of who changed what

**Your Task:** Add validation, error handling, and transaction safety.

**Solution:**
```sql
DELIMITER //
CREATE PROCEDURE update_price(IN p_id INT, IN p_price DECIMAL(10,2))
BEGIN
  -- Handler catches any SQL errors and rolls back
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price update failed';
  END;
  
  -- Validate inputs BEFORE making changes
  IF p_id IS NULL OR p_id <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid product ID';
  END IF;
  
  IF p_price IS NULL OR p_price < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price must be zero or positive';
  END IF;
  
  -- Check product exists
  IF NOT EXISTS (SELECT 1 FROM products WHERE id = p_id) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product not found';
  END IF;
  
  -- Use transaction for safety
  START TRANSACTION;
  
  -- Update the price
  UPDATE products SET price = p_price WHERE id = p_id;
  
  -- Log the change for audit trail
  INSERT INTO price_history (product_id, old_price, new_price, changed_at)
  SELECT id, price, p_price, NOW() FROM products WHERE id = p_id;
  
  COMMIT;
END//
DELIMITER ;
```

**What We Added:**
1. **Input validation:** Check for NULL, negative values, and invalid IDs
2. **Existence check:** Make sure the product exists before updating
3. **Error handler:** If anything fails, undo changes and return clear error
4. **Transaction:** Ensure all changes happen together or not at all
5. **Audit trail:** Log who changed what and when

**Beginner Tip:** Always ask "What could go wrong?" and handle those cases. Professional code doesn't assume everything will work perfectly!

