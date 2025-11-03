# Module 1: Intro to Databases — Complete Activity Pack (MySQL)

Audience: Recent college graduates new to SQL. MySQL syntax only. Edge cases included. Beginner-friendly with progressive difficulty.

Contents:
- 1) Quick Warm-Ups (5)
- 2) Guided Step-by-Step (3)
- 3) Independent Practice (7)
- 4) Paired Programming (1)
- 5) Real-World Project (1)
- 6) Error Detective (5)
- 7) Speed Drills (10)
- 8) Take-Home Challenges (3)

Tip: You can optionally run the reusable setup in `module-01-setup.sql` for larger datasets.

---

## 1) Quick Warm-Ups (5 exercises, 5–10 min each)
Each includes: title, scenario, sample data, task, expected output, time estimate.

### Warm-Up 1: List Active Products
- Scenario: You just joined an e-commerce team and need a quick view of active products.
- Sample Data:
  ```sql
  CREATE TEMPORARY TABLE `products` (
    `product_id` INT,
    `name` VARCHAR(50),
    `price` DECIMAL(10,2),
    `discontinued` TINYINT(1)
  );
  INSERT INTO `products` VALUES
  (1,'USB-C Cable',9.99,0),
  (2,'Old Webcam',24.99,1),
  (3,'Mouse Pad',6.50,0);
  ```
- Task: Select `product_id`, `name`, `price` for products that are NOT discontinued.
- Expected Output:
  | product_id | name       | price |
  |------------|------------|-------|
  | 1          | USB-C Cable| 9.99  |
  | 3          | Mouse Pad  | 6.50  |
- Time: 5–7 min
- Solution:
  ```sql
  SELECT `product_id`, `name`, `price`
  FROM `products`
  WHERE `discontinued` = 0;
  ```

### Warm-Up 2: Students Missing Email
- Scenario: Education platform wants to find student records missing an email.
- Sample Data:
  ```sql
  CREATE TEMPORARY TABLE `students` (
    `student_id` INT,
    `full_name` VARCHAR(100),
    `email` VARCHAR(100)
  );
  INSERT INTO `students` VALUES
  (1,'Maya Patel','maya@example.com'),
  (2,'Omar Ali',NULL),
  (3,'Jin Park','jin.park@example.com');
  ```
- Task: Return `student_id`, `full_name` where email is NULL.
- Expected Output:
  | student_id | full_name |
  |------------|-----------|
  | 2          | Omar Ali  |
- Time: 5 min
- Solution:
  ```sql
  SELECT `student_id`, `full_name`
  FROM `students`
  WHERE `email` IS NULL;
  ```

### Warm-Up 3: Upcoming Appointments
- Scenario: Healthcare clinic wants to list scheduled (future) appointments.
- Sample Data:
  ```sql
  CREATE TEMPORARY TABLE `appointments` (
    `appt_id` INT,
    `appt_date` DATETIME,
    `status` VARCHAR(20)
  );
  INSERT INTO `appointments` VALUES
  (1,'2025-03-10 09:00:00','COMPLETED'),
  (2,'2025-12-01 14:00:00','SCHEDULED'),
  (3,'2025-11-15 11:30:00','SCHEDULED');
  ```
- Task: Select `appt_id`, `appt_date` where `status`='SCHEDULED'. Order by `appt_date` ascending.
- Expected Output:
  | appt_id | appt_date           |
  |---------|---------------------|
  | 3       | 2025-11-15 11:30:00 |
  | 2       | 2025-12-01 14:00:00 |
- Time: 6–8 min
- Solution:
  ```sql
  SELECT `appt_id`, `appt_date`
  FROM `appointments`
  WHERE `status` = 'SCHEDULED'
  ORDER BY `appt_date` ASC;
  ```

### Warm-Up 4: Price Filter
- Scenario: Browse products over a minimum threshold.
- Sample Data:
  ```sql
  CREATE TEMPORARY TABLE `products2` (
    `name` VARCHAR(50),
    `price` DECIMAL(10,2)
  );
  INSERT INTO `products2` VALUES
  ('Notebook',3.00),('Backpack',29.99),('Headphones',49.99);
  ```
- Task: Return products priced >= 20.00.
- Expected Output:
  | name       | price |
  |------------|-------|
  | Backpack   | 29.99 |
  | Headphones | 49.99 |
- Time: 5 min
- Solution:
  ```sql
  SELECT `name`, `price`
  FROM `products2`
  WHERE `price` >= 20.00;
  ```

### Warm-Up 5: Sort by Last Name
- Scenario: Sort a short contact list.
- Sample Data:
  ```sql
  CREATE TEMPORARY TABLE `contacts` (
    `first_name` VARCHAR(50),
    `last_name` VARCHAR(50)
  );
  INSERT INTO `contacts` VALUES
  ('Ava','Lee'),('Ben','Kim'),('Cara','Singh');
  ```
- Task: Select all columns ordered by `last_name` ascending.
- Expected Output:
  | first_name | last_name |
  |------------|-----------|
  | Ben        | Kim       |
  | Ava        | Lee       |
  | Cara       | Singh     |
- Time: 5 min
- Solution:
  ```sql
  SELECT *
  FROM `contacts`
  ORDER BY `last_name` ASC;
  ```

---

## 2) Guided Step-by-Step (3 activities, 15–20 min each)
Each includes: business context, setup, final goal, 4 steps with checkpoints, mistakes, full solution, discussion questions.

### Guided 1: First Look at an E-commerce DB
- Business Context: You’re onboarding to an online shop. You need to explore basic tables and extract a simple report.
- Setup:
  ```sql
  CREATE DATABASE IF NOT EXISTS g1_shop;
  USE g1_shop;
  CREATE TABLE `products` (
    `product_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50),
    `category` VARCHAR(50),
    `price` DECIMAL(10,2),
    `discontinued` TINYINT(1) DEFAULT 0
  );
  INSERT INTO `products` (`name`,`category`,`price`,`discontinued`) VALUES
  ('USB-C Cable','Cables',9.99,0),
  ('Old Webcam','Cameras',24.99,1),
  ('Mouse Pad','Accessories',6.50,0);
  ```
- Final Goal: List non-discontinued products with name and price, sorted by price ascending.
- Steps:
  1) Verify table structure using `DESCRIBE products;` Checkpoint: Columns appear as defined.
  2) Select all rows `SELECT * FROM products;` Checkpoint: 3 rows returned.
  3) Filter active products `WHERE discontinued = 0`. Checkpoint: 2 rows remain.
  4) Sort by price ascending `ORDER BY price ASC`. Checkpoint: lowest price first.
- Common Mistakes:
  - Using single quotes around column names instead of backticks.
  - Forgetting to include the WHERE clause.
- Solution:
  ```sql
  SELECT `name`, `price`
  FROM `products`
  WHERE `discontinued` = 0
  ORDER BY `price` ASC;
  ```
- Discussion:
  1) When might you still include discontinued items?
  2) How would you display a note for discontinued products?

### Guided 2: Student Enrollment Check
- Business Context: A university dashboard flags missing student emails and inactive courses.
- Setup:
  ```sql
  CREATE DATABASE IF NOT EXISTS g2_uni;
  USE g2_uni;
  CREATE TABLE `students` (
    `student_id` INT PRIMARY KEY AUTO_INCREMENT,
    `full_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100)
  );
  CREATE TABLE `courses` (
    `course_id` INT PRIMARY KEY AUTO_INCREMENT,
    `title` VARCHAR(100) NOT NULL,
    `active` TINYINT(1) DEFAULT 1
  );
  INSERT INTO `students` (`full_name`,`email`) VALUES
  ('Maya Patel','maya@example.com'),
  ('Omar Ali',NULL),
  ('Jin Park','jin.park@example.com');
  INSERT INTO `courses` (`title`,`active`) VALUES
  ('SQL Basics',1),('Python 101',1),('Project Management',0);
  ```
- Final Goal: Return inactive courses and students missing emails in two separate queries.
- Steps:
  1) List all courses; identify `active=0`.
  2) Filter inactive: `WHERE active = 0`.
  3) List all students; identify `email IS NULL`.
  4) Filter `WHERE email IS NULL`.
- Mistakes:
  - Using `= NULL` instead of `IS NULL`.
- Solution:
  ```sql
  SELECT `course_id`, `title`
  FROM `courses`
  WHERE `active` = 0;

  SELECT `student_id`, `full_name`
  FROM `students`
  WHERE `email` IS NULL;
  ```
- Discussion:
  1) Why do some fields allow NULLs?
  2) How could you enforce email presence later?

### Guided 3: Appointment Status Report
- Business Context: Clinic wants a simple status breakdown of upcoming appointments.
- Setup:
  ```sql
  CREATE DATABASE IF NOT EXISTS g3_health;
  USE g3_health;
  CREATE TABLE `appointments` (
    `appt_id` INT PRIMARY KEY AUTO_INCREMENT,
    `appt_date` DATETIME NOT NULL,
    `status` VARCHAR(20) NOT NULL
  );
  INSERT INTO `appointments` (`appt_date`,`status`) VALUES
  ('2025-03-10 09:00:00','COMPLETED'),
  ('2025-12-01 14:00:00','SCHEDULED'),
  ('2025-11-15 11:30:00','SCHEDULED');
  ```
- Final Goal: Show scheduled appointments ordered by date with a status indicator.
- Steps:
  1) Select scheduled only: `WHERE status='SCHEDULED'`.
  2) Order by date ascending.
  3) Add computed column `days_until_appt` using DATEDIFF from reference date '2025-03-31'.
  4) Verify the date ordering and calculation logic.
- Mistakes:
  - Forgetting to filter by status.
  - Wrong date order in DATEDIFF function.
- Solution:
  ```sql
  SELECT `appt_id`, `appt_date`,
         DATEDIFF(`appt_date`, '2025-03-31') AS `days_until_appt`
  FROM `appointments`
  WHERE `status` = 'SCHEDULED'
  ORDER BY `appt_date` ASC;
  ```
- Discussion:
  1) When would you include a date range filter?
  2) What additional columns might matter for triage?

---

## 3) Independent Practice (7 exercises)
Each includes: difficulty badge, time, scenario, schema+data, requirements, example output, success criteria, hints (3 levels), detailed solution.

### Independent 1: Email Rollup (🟢 Easy, 10–12 min)
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

### Independent 2: Active Products Only (🟢 Easy, 10 min)
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

### Independent 3: Upcoming Schedules (🟢 Easy, 12 min)
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

### Independent 4: Price Bands (🟡 Medium, 15–18 min)
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

### Independent 5: First and Last Names (🟡 Medium, 15–18 min)
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

### Independent 6: Unique Categories (🟡 Medium, 15–18 min)
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

### Independent 7: Order Status Review (🔴 Challenge, 20–25 min)
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

---

## 4) Paired Programming (1 activity, 30 min)
- Roles:
  - Driver: Types SQL, verifies outputs
  - Navigator: Reads requirements, checks logic, suggests tests
- Schema (single table with denormalized order data):
  ```sql
  CREATE TEMPORARY TABLE `order_details` (
    `order_id` INT,
    `product_name` VARCHAR(50),
    `category` VARCHAR(50),
    `quantity` INT,
    `unit_price` DECIMAL(10,2),
    `order_date` DATE,
    `customer_name` VARCHAR(100)
  );
  INSERT INTO `order_details` VALUES
  (101,'Cable','Cables',2,9.99,'2025-03-15','Alice Johnson'),
  (101,'Mouse','Accessories',1,19.99,'2025-03-15','Alice Johnson'),
  (102,'Keyboard','Accessories',1,79.99,'2025-03-16','Bob Smith'),
  (103,'Cable','Cables',5,9.99,'2025-03-17','Charlie Davis'),
  (103,'Mouse Pad','Accessories',2,6.50,'2025-03-17','Charlie Davis');
  ```
- Parts:
  - A) Calculate line totals: For each order line, compute `line_total` = `quantity * unit_price`. Display `order_id`, `product_name`, `quantity`, `unit_price`, and `line_total`.
  - B) Categorize orders: Add a computed column `order_size` with values 'LARGE' if `quantity` >= 3, otherwise 'SMALL'. Sort by `order_id` and `quantity` DESC.
  - C) Premium orders: Filter for orders where `line_total` >= 40.00 and add a `discount_eligible` column showing 'YES' for Accessories category, 'NO' for others.
- Role-Switch Points: Switch after A and after B.
- Collaboration Tips: Discuss computed column logic, verify arithmetic, test edge cases with different quantities.
- Solutions:
  ```sql
  -- A: Calculate line totals
  SELECT `order_id`, `product_name`, `quantity`, `unit_price`,
         (`quantity` * `unit_price`) AS `line_total`
  FROM `order_details`
  ORDER BY `order_id`, `product_name`;

  -- B: Categorize by order size
  SELECT `order_id`, `product_name`, `quantity`,
         CASE WHEN `quantity` >= 3 THEN 'LARGE' ELSE 'SMALL' END AS `order_size`
  FROM `order_details`
  ORDER BY `order_id`, `quantity` DESC;

  -- C: Premium orders with discount eligibility
  SELECT `order_id`, `product_name`, `category`,
         (`quantity` * `unit_price`) AS `line_total`,
         CASE WHEN `category` = 'Accessories' THEN 'YES' ELSE 'NO' END AS `discount_eligible`
  FROM `order_details`
  WHERE (`quantity` * `unit_price`) >= 40.00
  ORDER BY `order_id`;
  ```

---

## 5) Real-World Project (45–60 min)
- Company Background: TinyCart is a small e-commerce startup.
- Business Problem: Build initial analytical views for products, customers, and orders.
- Database: Use `m1_intro_ecom` from `module-01-setup.sql` (30+ rows across tables).
- Deliverables (with Acceptance Criteria):
  1) Active products list with stock status
     - Include: `product_id`, `name`, `category`, `price`, `stock`, `stock_status` ('IN_STOCK' when `stock`>0 else 'OUT_OF_STOCK')
     - Exclude discontinued
     - Sorted by `category`, then `name`
  2) Customer signup recency
     - Columns: `customer_id`, full name, `created_at`, `is_recent` (created within last 60 days of '2025-03-31')
  3) Order export by status
     - For PAID orders only, list all `order_id`, `customer_id`, `order_date`, `status` with a computed column `days_since_order` (days between order_date and '2025-03-31')
     - Sort by most recent orders first
  4) Product categories summary (bonus)
     - Create a distinct list of all product categories from active (non-discontinued) products
     - Add a computed column `category_type`: 'TECH' for categories containing 'Cables' or 'Cameras', 'OTHER' for all else
     - Sort alphabetically by category
- Evaluation Rubric:
  - Correctness (50%), Readability (20%), Edge Cases (15%), Performance Notes (15%)
- Model Solutions:
  ```sql
  USE m1_intro_ecom;

  -- 1) Active products with stock status
  SELECT `product_id`, `name`, `category`, `price`, `stock`,
         CASE WHEN `stock` > 0 THEN 'IN_STOCK' ELSE 'OUT_OF_STOCK' END AS `stock_status`
  FROM `products`
  WHERE `discontinued` = 0
  ORDER BY `category`, `name`;

  -- 2) Customer signup recency (reference date 2025-03-31)
  SELECT `customer_id`, CONCAT(`first_name`,' ',`last_name`) AS `full_name`, `created_at`,
         CASE WHEN `created_at` >= DATE_SUB('2025-03-31', INTERVAL 60 DAY)
              THEN 'RECENT' ELSE 'NOT_RECENT' END AS `is_recent`
  FROM `customers`;

  -- 3) Order export by status (PAID only)
  SELECT `order_id`, `customer_id`, `order_date`, `status`,
         DATEDIFF('2025-03-31', `order_date`) AS `days_since_order`
  FROM `orders`
  WHERE `status` = 'PAID'
  ORDER BY `order_date` DESC;

  -- 4) Bonus: Product categories summary
  SELECT DISTINCT `category`,
         CASE WHEN `category` IN ('Cables', 'Cameras') THEN 'TECH' ELSE 'OTHER' END AS `category_type`
  FROM `products`
  WHERE `discontinued` = 0
  ORDER BY `category`;
  ```
- Performance Notes:
  - For larger data, indexes on `orders(status)` and `orders(order_date)` help with filtering and sorting.
  - DISTINCT operations can be optimized with indexes on the category column.
  - Date calculations like DATEDIFF are efficient for single-row operations.

---

## 6) Error Detective (5 challenges)
Each includes: scenario, broken query, error, expected output, guiding questions, explanation.

### Error 1: Wrong NULL Comparison
- Scenario: Find students without emails.
- Broken Query:
  ```sql
  SELECT * FROM `students` WHERE `email` = NULL;
  ```
- Error: Returns 0 rows incorrectly; `= NULL` never matches.
- Expected: Rows with `email` IS NULL.
- Guiding Questions: What operator checks NULL? Why does `= NULL` fail?
- Fix:
  ```sql
  SELECT * FROM `students` WHERE `email` IS NULL;
  ```
- Explanation: In SQL, NULL is unknown; use IS NULL / IS NOT NULL.

### Error 2: Quoting Identifiers
- Scenario: Filter by column but used single quotes.
- Broken Query:
  ```sql
  SELECT 'name' FROM products WHERE 'discontinued' = 0;
  ```
- Error: Returns literal strings; filter not applied.
- Expected: Use backticks for identifiers.
- Fix:
  ```sql
  SELECT `name` FROM `products` WHERE `discontinued` = 0;
  ```
- Explanation: Single quotes denote string literals in MySQL.

### Error 3: Incorrect Date Comparison
- Scenario: Find orders from March 2025.
- Broken Query:
  ```sql
  SELECT * FROM `orders` WHERE `order_date` = '2025-03';
  ```
- Error: Returns 0 rows; partial date string doesn't match full DATE values.
- Expected: Use proper date range or LIKE pattern.
- Fix Option 1 (Range):
  ```sql
  SELECT * FROM `orders` 
  WHERE `order_date` >= '2025-03-01' AND `order_date` < '2025-04-01';
  ```
- Fix Option 2 (LIKE with caution):
  ```sql
  SELECT * FROM `orders` WHERE `order_date` LIKE '2025-03-%';
  ```
- Explanation: DATE columns need complete date values or proper range comparisons. LIKE works but is less efficient than range queries.

### Error 4: Missing ORDER BY Column in SELECT
- Scenario: Sort products by price but forgot to include price in output.
- Broken Query:
  ```sql
  SELECT `product_id`, `name` FROM `products` ORDER BY price;
  ```
- Error: Works in MySQL but ambiguous—sorting by column not in SELECT can confuse readers.
- Expected: Include all ORDER BY columns in SELECT for clarity (best practice).
- Fix:
  ```sql
  SELECT `product_id`, `name`, `price` FROM `products` ORDER BY `price`;
  ```
- Explanation: While MySQL allows ordering by columns not in SELECT, including them improves query readability and is required in DISTINCT queries.

### Error 5: Wrong Operator for String Patterns
- Scenario: Find products with names starting with 'USB'.
- Broken Query:
  ```sql
  SELECT * FROM `products` WHERE `name` = 'USB%';
  ```
- Error: Returns 0 rows; `=` looks for exact match including the % character.
- Expected: Use LIKE for pattern matching.
- Fix:
  ```sql
  SELECT * FROM `products` WHERE `name` LIKE 'USB%';
  ```
- Explanation: Use `=` for exact matches, `LIKE` for pattern matching with wildcards (% for any characters, _ for single character)
  GROUP BY o.`order_id`
  HAVING COUNT(oi.`product`) = 0;
  ```
---

## 7) Speed Drills (10 questions, 2–3 min each)
Immediate answers for self-scoring.

1) Write a query to list all rows from `products`.
   - Answer:
   ```sql
   SELECT * FROM `products`;
   ```
2) Select only unique categories from `products`.
   - Answer:
   ```sql
   SELECT DISTINCT `category` FROM `products`;
   ```
3) Return products priced under 20, sorted by price descending.
   - Answer:
   ```sql
   SELECT `name`, `price`
   FROM `products`
   WHERE `price` < 20
   ORDER BY `price` DESC;
   ```
4) Find students with missing emails.
   - Answer:
   ```sql
   SELECT `student_id`, `full_name`
   FROM `students`
   WHERE `email` IS NULL;
   ```
5) Concatenate first and last name as `full_name`.
   - Answer:
   ```sql
   SELECT CONCAT(`first_name`,' ',`last_name`) AS `full_name` FROM `customers`;
   ```
6) Show all scheduled appointments.
   - Answer:
   ```sql
   SELECT * FROM `appointments` WHERE `status`='SCHEDULED';
   ```
7) Return top 5 cheapest products.
   - Answer:
   ```sql
   SELECT `name`, `price`
   FROM `products`
   ORDER BY `price` ASC
   LIMIT 5;
   ```
8) Show orders placed on '2025-03-21'.
   - Answer:
   ```sql
   SELECT * FROM `orders` WHERE `order_date` = '2025-03-21';
   ```
9) Replace NULL emails with 'unknown' in output only.
   - Answer:
   ```sql
   SELECT COALESCE(`email`, 'unknown') AS `email_display`
   FROM `students`;
   ```
10) Find discontinued products or out-of-stock products.
    - Answer:
    ```sql
    SELECT `name`
    FROM `products`
    WHERE `discontinued` = 1 OR `stock` = 0;
    ```

---

## 8) Take-Home Challenges (3 advanced exercises)
Each includes multi-part queries, realistic dataset, an open-ended component, and detailed solutions with trade-offs.

### Take-Home 1: Customer Overview Starter
- Dataset: Use `m1_intro_ecom`.
- Parts:
  A) Return customers with a computed `full_name` and `created_at`.
  B) Add computed columns: `account_age_days` (days since created_at until '2025-03-31') and `email_status` ('HAS_EMAIL' if email exists, 'MISSING' if NULL).
  C) Filter for customers created in March 2025 AND sort by most recent first.
  D) Open-ended: Suggest 2 additional columns to help onboarding insights and explain why.
- Solution:
  ```sql
  USE m1_intro_ecom;

  -- A
  SELECT `customer_id`, CONCAT(`first_name`,' ',`last_name`) AS `full_name`, `created_at`
  FROM `customers`;

  -- B
  SELECT `customer_id`, CONCAT(`first_name`,' ',`last_name`) AS `full_name`, `created_at`,
         DATEDIFF('2025-03-31', `created_at`) AS `account_age_days`,
         CASE WHEN `email` IS NULL THEN 'MISSING' ELSE 'HAS_EMAIL' END AS `email_status`
  FROM `customers`;

  -- C
  SELECT `customer_id`, CONCAT(`first_name`,' ',`last_name`) AS `full_name`, `created_at`,
         DATEDIFF('2025-03-31', `created_at`) AS `account_age_days`,
         CASE WHEN `email` IS NULL THEN 'MISSING' ELSE 'HAS_EMAIL' END AS `email_status`
  FROM `customers`
  WHERE `created_at` >= '2025-03-01' AND `created_at` < '2025-04-01'
  ORDER BY `created_at` DESC;
  ```
- Trade-offs: DATEDIFF provides numeric days for easy comparison. CASE expressions are readable for status fields. Date range filtering is efficient with proper indexes.

### Take-Home 2: Product Catalog Analysis
- Dataset: Use `m1_intro_ecom`.
- Parts:
  A) List active products with `stock_status` ('IN_STOCK' or 'OUT_OF_STOCK').
  B) Add a `price_category` column: 'BUDGET' for price < 20, 'STANDARD' for 20-50, 'PREMIUM' for > 50.
  C) Filter for Accessories category only, show products that are either out of stock OR priced > $50.
  D) Open-ended: Recommend how to identify products needing restocking and explain your criteria.
- Solution:
  ```sql
  USE m1_intro_ecom;

  -- A
  SELECT `product_id`, `name`, `category`, `price`, `stock`,
         CASE WHEN `stock` > 0 THEN 'IN_STOCK' ELSE 'OUT_OF_STOCK' END AS `stock_status`
  FROM `products`
  WHERE `discontinued` = 0;

  -- B
  SELECT `product_id`, `name`, `price`,
         CASE 
           WHEN `price` < 20 THEN 'BUDGET'
           WHEN `price` <= 50 THEN 'STANDARD'
           ELSE 'PREMIUM'
         END AS `price_category`
  FROM `products`
  WHERE `discontinued` = 0
  ORDER BY `price`;

  -- C
  SELECT `product_id`, `name`, `price`, `stock`,
         CASE WHEN `stock` > 0 THEN 'IN_STOCK' ELSE 'OUT_OF_STOCK' END AS `stock_status`
  FROM `products`
  WHERE `discontinued` = 0 
    AND `category` = 'Accessories' 
    AND (`stock` = 0 OR `price` > 50)
  ORDER BY `stock`, `price` DESC;
  ```
- Trade-offs: Nested CASE expressions provide clear categorization. Combining conditions with OR requires careful parentheses. Sorting by stock helps prioritize restocking needs.

### Take-Home 3: Course Catalog Review
- Dataset: Use `m1_intro_edu`.
- Parts:
  A) Show active courses only with `course_id`, `title`, and `credits`.
  B) Add a computed column `course_level`: 'INTRO' if title contains 'Introduction' or 'Fundamentals', 'ADVANCED' otherwise.
  C) Filter for courses with 3 or more credits, sorted by credits DESC then title ASC.
  D) Open-ended: Create a query to identify courses that might need updating (consider title keywords, credit hours, active status). Explain your criteria.
- Solution:
  ```sql
  USE m1_intro_edu;

  -- A
  SELECT `course_id`, `title`, `credits`
  FROM `courses`
  WHERE `active` = 1;

  -- B
  SELECT `course_id`, `title`, `credits`,
         CASE 
           WHEN `title` LIKE '%Introduction%' OR `title` LIKE '%Fundamentals%' 
           THEN 'INTRO'
           ELSE 'ADVANCED'
         END AS `course_level`
  FROM `courses`
  WHERE `active` = 1;

  -- C
  SELECT `course_id`, `title`, `credits`,
         CASE 
           WHEN `title` LIKE '%Introduction%' OR `title` LIKE '%Fundamentals%' 
           THEN 'INTRO'
           ELSE 'ADVANCED'
         END AS `course_level`
  FROM `courses`
  WHERE `active` = 1 AND `credits` >= 3
  ORDER BY `credits` DESC, `title` ASC;
  ```
- Trade-offs: LIKE with wildcards enables text pattern matching but can be slower on large datasets without full-text indexes. Multiple OR conditions in CASE are readable but could be refactored into a lookup table for complex categorizations.

---

## Encouragement and Time Guidance
- You’ve got this—aim to finish warm-ups quickly and spend more time on the project and take-home questions.
- If you’re stuck, start with smaller queries and verify each step.
- Performance tip: On larger datasets, ensure selective WHERE filters and appropriate indexes on join/filter keys.
