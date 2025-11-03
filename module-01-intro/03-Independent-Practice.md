# Module 1: Independent Practice (MySQL)

Seven exercises with progressive difficulty: 3 easy, 3 medium, 1 challenge. Each includes scenario, schema+sample data, requirements, example output, success criteria, multi-level hints, and detailed solutions.

## 📋 Before You Start

### Learning Objectives
Through independent practice, you will:
- Apply SQL concepts without step-by-step guidance
- Progress from easy to challenging problems systematically
- Learn to break down requirements into SQL clauses
- Practice strategic hint usage to develop problem-solving skills
- Build confidence in writing queries independently

### Difficulty Progression
- 🟢 **Easy (1-3)**: Focus on single concepts, 10-12 minutes each
- 🟡 **Medium (4-6)**: Combine 2-3 concepts, 15-20 minutes each  
- 🔴 **Challenge (7)**: Multi-concept integration, 25-30 minutes

### How to Approach Each Exercise
**Strategic Problem-Solving Process:**

1. **READ** the scenario and requirements carefully (don't rush!)
2. **SETUP** the data:
   ```sql
   -- Copy and run the CREATE TEMPORARY TABLE and INSERT statements
   -- Verify: SELECT * FROM table_name; to see all data
   ```
3. **PLAN** your query:
   - What columns do I need? → SELECT clause
   - What rows should I filter? → WHERE clause
   - What order? → ORDER BY clause
   - Any special cases (NULL, CASE, etc.)? → Note them
4. **TRY** writing the query yourself (resist peeking at hints!)
5. **TEST** your query and compare output with expected results
6. **USE HINTS** strategically if stuck:
   - Level 1: General direction (try this first)
   - Level 2: More specific guidance
   - Level 3: Nearly complete hint (use only if really stuck)
7. **REVIEW** the solution even if you solved it (learn alternative approaches)

**Success Criteria Tips:**
- Success criteria describe what makes your solution correct
- Check BOTH output AND the approach (e.g., correct handling of NULLs)
- Your query might differ from the solution but still be correct!

**Troubleshooting:**
- ❌ Output doesn't match: Check ORDER BY clause (sort order matters!)
- ❌ Wrong row count: Review your WHERE conditions
- ❌ NULL handling issues: Use `IS NULL` / `IS NOT NULL`, not `= NULL`
- ✅ Multiple valid solutions: There's often more than one correct approach

**Learning from Hints:**
- Don't feel bad using hints—they're learning tools!
- After using a hint, close the file and try writing the query from memory
- Practice the same exercise again tomorrow without hints

Tip: Quick to run with temporary tables; optional larger datasets in `module-01-setup.sql`.

---

## Independent 1: Email Rollup (🟢 Easy, 10–12 min)
- Scenario: List students with and without emails.
- Schema + Data:
  ```sql
  CREATE TEMPORARY TABLE `students` (
    `student_id` INT,
    `full_name` VARCHAR(100),
    `email` VARCHAR(100)
  );
  INSERT INTO `students` VALUES
  (1,'Maya Patel','maya@example.com'),
  (2,'Omar Ali',NULL),
  (3,'Jin Park','jin.park@example.com'),
  (4,'Ada Gomez',NULL);
  ```
- Requirements:
  1) Return `student_id`, `full_name`, and a new column `has_email` with values 'YES'/'NO'.
  2) Sort by `full_name`.
- Example Output:
  | student_id | full_name   | has_email |
  |------------|-------------|-----------|
  | 4          | Ada Gomez   | NO        |
  | 3          | Jin Park    | YES       |
  | 1          | Maya Patel  | YES       |
  | 2          | Omar Ali    | NO        |
- Success Criteria: Correct logic for NULL emails and ordering.
- Hints:
  - Level 1: Use a CASE expression.
  - Level 2: `email IS NULL` vs `IS NOT NULL`.
  - Level 3: Remember ORDER BY text ascending.
- Solution:
  ```sql
  SELECT `student_id`, `full_name`,
         CASE WHEN `email` IS NULL THEN 'NO' ELSE 'YES' END AS `has_email`
  FROM `students`
  ORDER BY `full_name` ASC;
  ```

---

## Independent 2: Active Products Only (🟢 Easy, 10 min)
- Scenario: Filter out discontinued products.
- Schema + Data:
  ```sql
  CREATE TEMPORARY TABLE `products` (
    `name` VARCHAR(50),
    `category` VARCHAR(50),
    `price` DECIMAL(10,2),
    `discontinued` TINYINT(1)
  );
  INSERT INTO `products` VALUES
  ('USB-C Cable','Cables',9.99,0),
  ('Old Webcam','Cameras',24.99,1),
  ('Mouse Pad','Accessories',6.50,0),
  ('USB-C Cable','Cables',9.99,0); -- duplicate name edge case
  ```
- Requirements:
  1) Return all columns for non-discontinued rows.
  2) Keep duplicates; this is a data quality check.
- Example Output: 3 rows (duplicates included) without discontinued.
- Success Criteria: Correct WHERE filter.
- Hints: Use `WHERE discontinued = 0`.
- Solution:
  ```sql
  SELECT *
  FROM `products`
  WHERE `discontinued` = 0;
  ```

---

## Independent 3: Upcoming Schedules (🟢 Easy, 12 min)
- Scenario: Sort scheduled appointments by date.
- Schema + Data:
  ```sql
  CREATE TEMPORARY TABLE `appointments` (
    `id` INT,
    `appt_date` DATETIME,
    `status` VARCHAR(20)
  );
  INSERT INTO `appointments` VALUES
  (1,'2025-03-10 09:00:00','COMPLETED'),
  (2,'2025-12-01 14:00:00','SCHEDULED'),
  (3,'2025-11-15 11:30:00','SCHEDULED'),
  (4,'2025-11-15 11:30:00','SCHEDULED'); -- same time edge case
  ```
- Requirements:
  1) Return only `status='SCHEDULED'`.
  2) Sort by `appt_date` then by `id`.
- Example Output: ids 3,4,2 in that order.
- Success Criteria: Stable sort by two columns.
- Hints: Use `ORDER BY appt_date, id`.
- Solution:
  ```sql
  SELECT `id`, `appt_date`
  FROM `appointments`
  WHERE `status` = 'SCHEDULED'
  ORDER BY `appt_date` ASC, `id` ASC;
  ```

---

## Independent 4: Price Bands (🟡 Medium, 15–18 min)
- Scenario: Classify products by price tier.
- Schema + Data:
  ```sql
  CREATE TEMPORARY TABLE `products3` (
    `name` VARCHAR(50),
    `price` DECIMAL(10,2)
  );
  INSERT INTO `products3` VALUES
  ('Cable',9.99),('Mouse',19.99),('Keyboard',79.99),('Monitor',299.00);
  ```
- Requirements:
  1) Add column `price_band` with rules: <10='LOW', 10–99.99='MID', >=100='HIGH'.
  2) Sort by `price`.
- Example Output: Cable LOW, Mouse MID, Keyboard MID, Monitor HIGH.
- Success Criteria: Correct CASE boundaries.
- Hints: Use `CASE WHEN price < 10 ... WHEN price < 100 ... ELSE ...`.
- Solution:
  ```sql
  SELECT `name`, `price`,
         CASE
           WHEN `price` < 10 THEN 'LOW'
           WHEN `price` < 100 THEN 'MID'
           ELSE 'HIGH'
         END AS `price_band`
  FROM `products3`
  ORDER BY `price` ASC;
  ```

---

## Independent 5: First and Last Names (🟡 Medium, 15–18 min)
- Scenario: Format full names for display.
- Schema + Data:
  ```sql
  CREATE TEMPORARY TABLE `people` (
    `first_name` VARCHAR(50),
    `last_name` VARCHAR(50)
  );
  INSERT INTO `people` VALUES
  ('ava','lee'),('BEN','KIM'),('Cara','Singh');
  ```
- Requirements:
  1) Return a column `display_name` = CONCAT(UCASE first letter + lower rest) "First Last".
  2) No additional tables.
- Example Output:
  | display_name |
  |--------------|
  | Ava Lee      |
  | Ben Kim      |
  | Cara Singh   |
- Success Criteria: Proper string functions.
- Hints: Use `CONCAT`, `UCASE/UPPER`, `LCASE/LOWER`, `SUBSTRING`.
- Solution:
  ```sql
  SELECT CONCAT(
           UPPER(SUBSTRING(`first_name`,1,1)), LOWER(SUBSTRING(`first_name`,2)),
           ' ',
           UPPER(SUBSTRING(`last_name`,1,1)), LOWER(SUBSTRING(`last_name`,2))
         ) AS `display_name`
  FROM `people`;
  ```

---

## Independent 6: Unique Categories (🟡 Medium, 15–18 min)
- Scenario: List distinct product categories.
- Schema + Data:
  ```sql
  CREATE TEMPORARY TABLE `items` (
    `name` VARCHAR(50),
    `category` VARCHAR(50)
  );
  INSERT INTO `items` VALUES
  ('USB-C Cable','Cables'),('HDMI Cable','Cables'),('Mouse','Accessories');
  ```
- Requirements: Return distinct categories sorted alphabetically.
- Example Output: Accessories, Cables.
- Success Criteria: Correct use of DISTINCT and ORDER BY.
- Hints: `SELECT DISTINCT category ... ORDER BY category`.
- Solution:
  ```sql
  SELECT DISTINCT `category`
  FROM `items`
  ORDER BY `category` ASC;
  ```

---

## Independent 7: Order Status Review (🔴 Challenge, 20–25 min)
- Scenario: Find high-priority orders that need attention (cancelled or pending review).
- Schema + Data:
  ```sql
  CREATE TEMPORARY TABLE `orders` (
    `order_id` INT,
    `status` VARCHAR(20),
    `order_date` DATE,
    `total_amount` DECIMAL(10,2),
    `needs_review` TINYINT(1)
  );
  INSERT INTO `orders` VALUES
  (1,'PAID','2025-03-15',59.99,0),
  (2,'CANCELLED','2025-03-16',129.50,1),
  (3,'PAID','2025-03-17',45.00,0),
  (4,'PENDING','2025-03-18',89.99,1),
  (5,'CANCELLED','2025-03-19',75.00,0);
  ```
- Requirements:
  1) Return orders that are CANCELLED or marked for review (`needs_review` = 1).
  2) Add a computed column `priority_level`: 'HIGH' if status is CANCELLED, 'MEDIUM' otherwise.
  3) Include only columns: `order_id`, `status`, `order_date`, `total_amount`, `priority_level`.
  4) Sort by `priority_level` DESC, then by `order_date` DESC.
- Example Output:
  | order_id | status    | order_date | total_amount | priority_level |
  |----------|-----------|------------|--------------|----------------|
  | 5        | CANCELLED | 2025-03-19 | 75.00        | HIGH           |
  | 2        | CANCELLED | 2025-03-16 | 129.50       | HIGH           |
  | 4        | PENDING   | 2025-03-18 | 89.99        | MEDIUM         |
- Success Criteria: Correct use of WHERE with OR conditions, CASE expression, and multi-column ORDER BY.
- Hints:
  - Level 1: Use WHERE with OR to filter by status or needs_review flag.
  - Level 2: CASE expression to create priority_level based on status.
  - Level 3: ORDER BY with DESC on priority_level, then order_date.
- Solution:
  ```sql
  SELECT `order_id`, `status`, `order_date`, `total_amount`,
         CASE WHEN `status` = 'CANCELLED' THEN 'HIGH' ELSE 'MEDIUM' END AS `priority_level`
  FROM `orders`
  WHERE `status` = 'CANCELLED' OR `needs_review` = 1
  ORDER BY `priority_level` DESC, `order_date` DESC;
  ```
