# Guided Step-by-Step — Set Operations (15–20 min each)

Each activity includes business context, database setup, a final goal, step-by-step instructions with checkpoints, common mistakes, a complete solution with comments, and discussion questions.

## 📋 Before You Start

### Learning Objectives
Through these guided activities, you will:
- Combine data from multiple sources with UNION
- Choose between UNION and UNION ALL appropriately
- Find common records with INTERSECT patterns
- Identify differences with EXCEPT patterns
- Handle column alignment and naming

### Execution Process
1. **Run complete setup** for each activity
2. **Follow numbered steps** building the query incrementally
3. **Verify checkpoints** carefully—row counts matter!
4. **Read "Common Mistakes"** before attempting full solution
5. **Study complete solution** with annotations
6. **Answer discussion questions**

**Critical Concepts:**
- UNION removes duplicates by comparing ENTIRE rows
- Column order and types must match exactly
- ORDER BY applies to final combined result
- Performance: UNION ALL is faster when duplicates don't matter

**Beginner Tip:** Follow each step carefully. Check your results at each checkpoint. Set operations are powerful—understanding how to combine, intersect, and subtract datasets opens up many analysis possibilities!

---

## Activity 1: Customer Contact Consolidation (UNION) — 18 min

### Business Context
Your company has customer contact information in two systems: an email list and a phone list. Some customers appear in both. You need to create a unified contact list for a marketing campaign.

### Database Setup
```sql
DROP TABLE IF EXISTS gs7_email_contacts;
CREATE TABLE gs7_email_contacts (
  customer_id INT PRIMARY KEY,
  email VARCHAR(100),
  source VARCHAR(20) DEFAULT 'email_system'
);
INSERT INTO gs7_email_contacts VALUES
(1,'alice@example.com','email_system'),
(2,'bob@example.com','email_system'),
(3,'carol@example.com','email_system'),
(5,'eve@example.com','email_system');

DROP TABLE IF EXISTS gs7_phone_contacts;
CREATE TABLE gs7_phone_contacts (
  customer_id INT PRIMARY KEY,
  phone VARCHAR(20),
  source VARCHAR(20) DEFAULT 'phone_system'
);
INSERT INTO gs7_phone_contacts VALUES
(2,'555-0102','phone_system'),
(3,'555-0103','phone_system'),
(4,'555-0104','phone_system'),
(6,'555-0106','phone_system');
```

### Final Goal
Create a unified list showing:
1. All unique customer_ids from both systems
2. Their contact info (email or phone)
3. The source system
4. Sorted by customer_id

### Steps

#### Step 1: List all email contacts
```sql
SELECT customer_id, email AS contact, source
FROM gs7_email_contacts;
```
**Checkpoint:** You should see 4 rows (IDs 1,2,3,5) with emails.

#### Step 2: List all phone contacts with same column names
```sql
SELECT customer_id, phone AS contact, source
FROM gs7_phone_contacts;
```
**Checkpoint:** You should see 4 rows (IDs 2,3,4,6) with phones. Note: column name is `contact` to match Step 1.

#### Step 3: Combine both lists using UNION (removes duplicates)
```sql
SELECT customer_id, email AS contact, source
FROM gs7_email_contacts
UNION
SELECT customer_id, phone AS contact, source
FROM gs7_phone_contacts;
```
**Checkpoint:** You should see 8 rows. IDs 2 and 3 appear twice (once with email, once with phone) because the full row is different.

#### Step 4: Add ORDER BY to sort the combined result
```sql
SELECT customer_id, email AS contact, source
FROM gs7_email_contacts
UNION
SELECT customer_id, phone AS contact, source
FROM gs7_phone_contacts
ORDER BY customer_id;
```
**Checkpoint:** All 8 rows sorted by customer_id. IDs: 1,2,2,3,3,4,5,6.

### Common Mistakes
- **Column mismatch**: Forgetting to alias `phone` as `contact` to match `email AS contact` → MySQL won't complain about names, but having consistent names makes queries clearer
- **Wrong column count**: Including different numbers of columns in each SELECT → ERROR: "different number of columns"
- **ORDER BY placement**: Putting ORDER BY inside parentheses instead of at the end → Syntax error, ORDER BY must be LAST
- **Expecting deduplication**: UNION removes duplicate *rows* but if any column differs (even just the source), rows aren't considered duplicates

**Beginner Tip:** Test each SELECT independently first! Make sure they return the same structure (column count and compatible types) before combining with UNION.

### Complete Solution
```sql
-- Unified contact list from two systems
SELECT 
  customer_id,
  email AS contact,  -- Alias email as 'contact' for consistency
  source             -- Source column shows where data came from
FROM gs7_email_contacts

UNION  -- Removes exact duplicate rows (none here because source differs)
       -- Even if same customer_id, if contact or source differs, it's not a duplicate

SELECT 
  customer_id,
  phone AS contact,  -- Alias phone as 'contact' to match first SELECT
  source
FROM gs7_phone_contacts

ORDER BY customer_id;  -- Sort final combined result
-- Result: 8 rows showing all contacts from both systems
-- Note: IDs 2,3 appear twice because they have both email AND phone (different rows)
-- Customer 1: email only (in email system only)
-- Customer 2: email + phone (in both systems)
-- Customer 3: email + phone (in both systems)
-- Customer 4: email only
-- Customer 5: email only
-- Customer 6: phone only (in phone system only)
```

**What's Happening Here:**
1. First SELECT gets email contacts with 'contact' and 'source' columns
2. Second SELECT gets phone contacts with matching column structure
3. UNION combines them, checking for exact row duplicates (there are none)
4. ORDER BY sorts the final 8 rows by customer_id

### Discussion Questions
1. **Why do customers 2 and 3 appear twice?** 
   - *Answer:* Each has an email row AND a phone row. Even though the customer_id is the same, the 'contact' value differs (email vs phone), so UNION sees them as different rows.

2. **What if you wanted just one row per customer with both email and phone?** 
   - *Answer:* You'd need to JOIN the tables instead: `SELECT a.customer_id, a.email, b.phone FROM email_contacts a LEFT JOIN phone_contacts b ON a.customer_id = b.customer_id`

3. **When would UNION ALL be better here?** 
   - *Answer:* If you're counting total contact points (e.g., "we have 8 contact records") or if you know there are no actual duplicates and want faster performance.

4. **What if both systems had the exact same email for a customer?**
   - *Answer:* If the entire row is identical (same customer_id, same email in the 'contact' column, same source), UNION would remove one. But here, sources differ ('email_system' vs 'phone_system'), so they'd still be seen as different rows.

---

## Activity 2: Inventory Reconciliation (INTERSECT) — 17 min

### Business Context
Your warehouse uses two inventory systems (maybe one is legacy, one is new). You need to identify products that exist in BOTH systems to reconcile discrepancies. This is a classic INTERSECT use case—finding the overlap.

**Why This Matters:** If a product exists in both systems but with different quantities, you have a data quality issue to investigate. First, you need to find which products are in BOTH systems.

### Database Setup
```sql
DROP TABLE IF EXISTS gs7_system_a;
CREATE TABLE gs7_system_a (
  product_code VARCHAR(10) PRIMARY KEY,
  quantity INT
);
INSERT INTO gs7_system_a VALUES
('A101',50),('A102',30),('A103',20),('A105',60);

DROP TABLE IF EXISTS gs7_system_b;
CREATE TABLE gs7_system_b (
  product_code VARCHAR(10) PRIMARY KEY,
  quantity INT
);
INSERT INTO gs7_system_b VALUES
('A101',48),('A102',30),('A104',15),('A106',25);
```

### Final Goal
Find products that exist in BOTH systems for reconciliation (INTERSECT or INNER JOIN).

### Steps

#### Step 1: List product codes from system A
```sql
SELECT product_code FROM gs7_system_a;
```
**Checkpoint:** 4 codes (A101, A102, A103, A105).

#### Step 2: List product codes from system B
```sql
SELECT product_code FROM gs7_system_b;
```
**Checkpoint:** 4 codes (A101, A102, A104, A106).

#### Step 3: Find common products using INNER JOIN
```sql
SELECT DISTINCT a.product_code
FROM gs7_system_a a
INNER JOIN gs7_system_b b ON a.product_code = b.product_code;
```
**Checkpoint:** 2 codes (A101, A102) appear in both.

#### Step 4: Add quantities from both systems for comparison
```sql
SELECT 
  a.product_code,
  a.quantity AS qty_system_a,
  b.quantity AS qty_system_b,
  (a.quantity - b.quantity) AS difference
FROM gs7_system_a a
INNER JOIN gs7_system_b b ON a.product_code = b.product_code
ORDER BY a.product_code;
```
**Checkpoint:** A101 shows difference of +2, A102 shows 0 (match).

### Common Mistakes
- **Using UNION instead of INTERSECT**: UNION combines ALL items from both tables; INTERSECT finds only COMMON items
- **Forgetting DISTINCT**: When simulating INTERSECT with JOIN, if tables have internal duplicates, you might see duplicate results
- **Comparing only codes**: For business needs, finding common codes is step 1, but reconciliation requires comparing quantities too (that's why INNER JOIN with both quantities is more practical here)
- **MySQL version**: INTERSECT requires MySQL 8.0.31+; if you're on an older version, use the INNER JOIN pattern instead

**Beginner Tip:** INTERSECT is conceptually clean ("show me the overlap"), but INNER JOIN is often more practical because you can include additional columns for comparison.

### Complete Solution
```sql
-- Find products in both systems with quantity comparison
SELECT 
  a.product_code,           -- The product code that exists in BOTH systems
  a.quantity AS qty_system_a, -- How many system A says we have
  b.quantity AS qty_system_b, -- How many system B says we have
  (a.quantity - b.quantity) AS difference  -- The discrepancy to investigate
FROM gs7_system_a a
INNER JOIN gs7_system_b b ON a.product_code = b.product_code  
-- INNER JOIN only keeps rows where product_code matches in BOTH tables
-- This is the set intersection: products in A AND B
ORDER BY a.product_code;

/* Results explained:
   A101: System A has 50, System B has 48 → Difference of +2 (investigate!)
   A102: Both systems have 30 → Perfect match! ✓
   
   Notice what's NOT here:
   - A103, A105 (only in system A)
   - A104, A106 (only in system B)
*/

-- Alternative with INTERSECT (MySQL 8.0.31+) - just codes, no quantities
-- SELECT product_code FROM gs7_system_a
-- INTERSECT
-- SELECT product_code FROM gs7_system_b;
-- This gives you: A101, A102 (the intersection)
-- But you lose the ability to compare quantities!
```

**Why INNER JOIN is Better Here:**
- INTERSECT only tells you "these products exist in both" (A101, A102)
- INNER JOIN tells you that PLUS the quantities from each system
- For reconciliation, you need both pieces of information

### Discussion Questions
1. **Why is INNER JOIN more useful than INTERSECT here?** 
   - *Answer:* INTERSECT only gives you product codes that exist in both systems. But for reconciliation, you need to see the quantities from BOTH sides to compare them. INNER JOIN lets you include columns from both tables.

2. **How would you find products ONLY in system A?** 
   - *Answer:* Use LEFT JOIN ... WHERE b.product_code IS NULL (or EXCEPT for MySQL 8.0.31+)
   ```sql
   SELECT a.product_code FROM gs7_system_a a
   LEFT JOIN gs7_system_b b ON a.product_code = b.product_code
   WHERE b.product_code IS NULL;
   -- Result: A103, A105 (only in A)
   ```

3. **What if quantities differ significantly?** 
   - *Answer:* Add a WHERE clause to flag large discrepancies: `WHERE ABS(a.quantity - b.quantity) > 5`. This helps prioritize which mismatches to investigate first.

4. **Could you use UNION here?**
   - *Answer:* UNION would give you ALL products from both systems (A101, A102, A103, A104, A105, A106), not just the overlap. Wrong tool for finding commonalities!

---

## Activity 3: Email Campaign Exclusion List (EXCEPT) — 19 min

### Business Context
You're preparing an email campaign. You have a target list but need to exclude people who've unsubscribed. Use EXCEPT (or LEFT JOIN alternative) to create the final send list.

### Database Setup
```sql
DROP TABLE IF EXISTS gs7_campaign_targets;
CREATE TABLE gs7_campaign_targets (
  email VARCHAR(100) PRIMARY KEY,
  segment VARCHAR(30)
);
INSERT INTO gs7_campaign_targets VALUES
('alice@example.com','premium'),
('bob@example.com','standard'),
('carol@example.com','premium'),
('dave@example.com','standard'),
('eve@example.com','premium'),
('frank@example.com','standard');

DROP TABLE IF EXISTS gs7_unsubscribed;
CREATE TABLE gs7_unsubscribed (
  email VARCHAR(100) PRIMARY KEY,
  unsub_date DATE
);
INSERT INTO gs7_unsubscribed VALUES
('bob@example.com','2025-01-15'),
('eve@example.com','2025-02-20');
```

### Final Goal
Create a send list: target emails EXCEPT those who unsubscribed.

### Steps

#### Step 1: Count total campaign targets
```sql
SELECT COUNT(*) AS total_targets FROM gs7_campaign_targets;
```
**Checkpoint:** 6 targets.

#### Step 2: Count unsubscribed emails
```sql
SELECT COUNT(*) AS unsubscribed FROM gs7_unsubscribed;
```
**Checkpoint:** 2 unsubscribed.

#### Step 3: Find emails to send using LEFT JOIN ... IS NULL (EXCEPT alternative)
```sql
SELECT t.email, t.segment
FROM gs7_campaign_targets t
LEFT JOIN gs7_unsubscribed u ON t.email = u.email
WHERE u.email IS NULL;
```
**Checkpoint:** 4 emails (alice, carol, dave, frank). Bob and Eve excluded.

#### Step 4: Add count and segment breakdown
```sql
SELECT 
  COUNT(*) AS emails_to_send,
  segment,
  GROUP_CONCAT(email ORDER BY email) AS email_list
FROM (
  SELECT t.email, t.segment
  FROM gs7_campaign_targets t
  LEFT JOIN gs7_unsubscribed u ON t.email = u.email
  WHERE u.email IS NULL
) AS send_list
GROUP BY segment
ORDER BY segment;
```
**Checkpoint:** Premium: 2 emails (alice, carol). Standard: 2 emails (dave, frank).

### Common Mistakes
- **Using INNER JOIN**: Would return unsubscribed emails instead of excluding them
- **Forgetting IS NULL**: LEFT JOIN alone doesn't filter; need WHERE u.email IS NULL
- **Column name confusion**: Make sure to check the right table's column in WHERE
- **Not validating count**: Always verify (targets - unsubscribed = send list)

### Complete Solution
```sql
-- Final send list: targets excluding unsubscribed
SELECT 
  t.email,
  t.segment
FROM gs7_campaign_targets t
LEFT JOIN gs7_unsubscribed u ON t.email = u.email
WHERE u.email IS NULL  -- This filters out unsubscribed emails
ORDER BY t.segment, t.email;

-- Alternative with EXCEPT (MySQL 8.0.31+)
-- SELECT email FROM gs7_campaign_targets
-- EXCEPT
-- SELECT email FROM gs7_unsubscribed
-- ORDER BY email;

-- Summary by segment
SELECT 
  segment,
  COUNT(*) AS emails_to_send
FROM gs7_campaign_targets t
LEFT JOIN gs7_unsubscribed u ON t.email = u.email
WHERE u.email IS NULL
GROUP BY segment;
-- Premium: 2, Standard: 2. Total: 4 emails to send.
```

### Discussion Questions
1. **Why LEFT JOIN instead of INNER JOIN?** *(INNER JOIN would only show matching emails; we want non-matching)*
2. **How would you find recently unsubscribed (last 30 days)?** *(Add AND u.unsub_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY))*
3. **What happens if unsubscribed table is empty?** *(All targets pass through; WHERE u.email IS NULL is always true)*

---

**Completion Check:** You should now understand UNION, INTERSECT, and EXCEPT patterns with practical business scenarios.

**Next Step:** Move to `03-Independent-Practice.md` for self-guided exercises with hints and solutions.
