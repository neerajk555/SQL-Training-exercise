# Speed Drills — Professional Practices

**Goal:** Build muscle memory for professional SQL patterns. Speed matters, but accuracy matters more!

**Instructions:**
- Set a timer for each drill
- Try to complete without looking at the solution
- If stuck, peek at the solution and try again
- The goal is to internalize these patterns so they become automatic

**Beginner Tip:** Professional developers don't memorize everything—they memorize PATTERNS. After doing these drills, you'll recognize these patterns instantly in real code.

---

## Drill 1: Fix Naming

**Challenge:** Rename this cryptic query to be self-documenting.

```sql
-- BAD: Cryptic abbreviations
SELECT t.a, t.b FROM t WHERE t.c = 1
```

**What to Fix:**
- Table name `t` → Use descriptive name
- Columns `a`, `b`, `c` → Use meaningful names
- Magic number `1` → Use readable value

**Solution:**
```sql
-- GOOD: Clear, self-documenting
SELECT 
  users.name,
  users.email
FROM users
WHERE users.status = 'active';  -- 1 probably meant 'active'
```

**Why This Matters:** Six months from now, which version will you understand instantly?

---

---

## Drill 2: Add Parameter Validation

**Challenge:** Add validation to prevent invalid inputs.

```sql
-- BAD: No validation
CREATE PROCEDURE update_stock(p_id INT, p_qty INT)
BEGIN
  UPDATE products SET stock = p_qty WHERE id = p_id;
END;
```

**What Could Go Wrong:**
- Negative quantity (stock = -100?)
- NULL values
- Product doesn't exist (silent failure)

**Solution:**
```sql
DELIMITER //
CREATE PROCEDURE update_stock(p_id INT, p_qty INT)
BEGIN
  -- Validate quantity (must be non-negative)
  IF p_qty IS NULL OR p_qty < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantity must be zero or positive';
  END IF;
  
  -- Validate product ID
  IF p_id IS NULL OR p_id <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid product ID';
  END IF;
  
  -- Check product exists
  IF NOT EXISTS (SELECT 1 FROM products WHERE id = p_id) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product not found';
  END IF;
  
  -- Now it's safe to update
  UPDATE products SET stock = p_qty WHERE id = p_id;
END//
DELIMITER ;
```

**Key Pattern:** Always validate inputs at the start of procedures. Fail fast with clear error messages.

---

---

## Drill 3: Secure This Query

**Challenge:** Fix this SQL injection vulnerability.

```sql
-- DANGER: SQL injection!
query = "SELECT * FROM users WHERE id = " + userId
```

**Why It's Dangerous:**
```javascript
// Normal: userId = 5
→ SELECT * FROM users WHERE id = 5  ✓

// Attack: userId = "1 OR 1=1"
→ SELECT * FROM users WHERE id = 1 OR 1=1  ✗
// Returns ALL users!
```

**Solution:**
```sql
-- Use prepared statement (parameterized query)
PREPARE stmt FROM 'SELECT * FROM users WHERE id = ?';
SET @userId = 5;  -- User input treated as DATA only
EXECUTE stmt USING @userId;
DEALLOCATE PREPARE stmt;

-- In application code:
-- PHP: $stmt = $pdo->prepare("SELECT * FROM users WHERE id = ?");
-- The ? placeholder can ONLY hold data, never SQL code
```

**Key Rule:** NEVER concatenate user input into SQL. Always use ? placeholders.

---

## Drill 4: Add Comments
```sql
-- Calculate monthly revenue by product category
SELECT 
  category,
  SUM(amount) AS revenue
FROM orders
WHERE order_date >= '2024-01-01'
GROUP BY category;
```

---

## Drill 5: Transaction Safety
```sql
START TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;
```

---

## Drill 6: Add Index
```sql
CREATE INDEX idx_orders_user_date ON orders(user_id, order_date);
```

---

## Drill 7: Error Handler
```sql
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
  ROLLBACK;
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Operation failed';
END;
```

---

## Practice Recommendations:

**Daily Practice:**
Do these drills once per day for a week. By day 7, you should be able to:
- Spot SQL injection risks instantly
- Write parameter validation automatically
- Format queries professionally without thinking
- Add transactions to financial operations by reflex

**Increasing Difficulty:**
Once these are easy, challenge yourself:
- Do them with eyes closed (verbalize the code)
- Explain each drill to a rubber duck or friend
- Create your own drills from code you see online
- Time yourself and try to beat your record

**Building Muscle Memory:**
Professional SQL is like learning to drive:
1. At first, you think about every step
2. With practice, patterns become automatic
3. Eventually, you spot problems instantly
4. Your hands type correct code without conscious thought

**Key Takeaways:** 
- Speed in professional practices comes from consistent patterns and templates
- Professional developers have "patterns library" in their brain
- Practice makes these patterns automatic
- The goal isn't speed—it's writing secure, correct code without effort

**Beginner Tip:** Don't worry if these feel slow at first. Every expert was once a beginner who practiced daily!

