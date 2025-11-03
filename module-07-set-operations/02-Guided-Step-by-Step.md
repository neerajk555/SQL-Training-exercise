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
- **Column mismatch**: Forgetting to alias `phone` as `contact` to match `email AS contact` → different column names cause errors
- **Wrong column count**: Including different numbers of columns in each SELECT
- **ORDER BY placement**: Putting ORDER BY inside parentheses instead of at the end
- **Expecting deduplication**: UNION removes duplicate *rows* but if any column differs, rows aren't duplicates

### Complete Solution
```sql
-- Unified contact list from two systems
SELECT 
  customer_id,
  email AS contact,
  source
FROM gs7_email_contacts

UNION  -- Removes exact duplicate rows (none here because source differs)

SELECT 
  customer_id,
  phone AS contact,
  source
FROM gs7_phone_contacts

ORDER BY customer_id;
-- Result: 8 rows showing all contacts from both systems
-- Note: IDs 2,3 appear twice because they have both email and phone
```

### Discussion Questions
1. **Why do customers 2 and 3 appear twice?** *(Each has an email row and a phone row; UNION sees them as different rows)*
2. **What if you wanted just one row per customer?** *(You'd need to JOIN or use GROUP BY with GROUP_CONCAT/JSON_ARRAYAGG)*
3. **When would UNION ALL be better here?** *(If you want to count total contact points regardless of duplicates)*

---

## Activity 2: Inventory Reconciliation (INTERSECT) — 17 min

### Business Context
Your warehouse uses two inventory systems. You need to identify products that exist in BOTH systems to reconcile discrepancies.

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
- **Using UNION instead of INTERSECT**: UNION combines all; INTERSECT finds common
- **Forgetting DISTINCT**: When simulating INTERSECT with JOIN, duplicates may appear
- **Comparing only codes**: For reconciliation, you need quantities too (full JOIN query)
- **MySQL version**: INTERSECT requires 8.0.31+; use INNER JOIN alternative for older versions

### Complete Solution
```sql
-- Find products in both systems with quantity comparison
SELECT 
  a.product_code,
  a.quantity AS qty_system_a,
  b.quantity AS qty_system_b,
  (a.quantity - b.quantity) AS difference
FROM gs7_system_a a
INNER JOIN gs7_system_b b ON a.product_code = b.product_code
ORDER BY a.product_code;

-- Alternative with INTERSECT (MySQL 8.0.31+) - just codes
-- SELECT product_code FROM gs7_system_a
-- INTERSECT
-- SELECT product_code FROM gs7_system_b;
```

### Discussion Questions
1. **Why is INNER JOIN more useful than INTERSECT here?** *(We need quantities from both sides, not just matching codes)*
2. **How would you find products ONLY in system A?** *(LEFT JOIN ... WHERE b.product_code IS NULL, or EXCEPT)*
3. **What if quantities differ significantly?** *(Flag for manual review, investigate data entry or system sync issues)*

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
