# Module 1: Independent Practice (MySQL)

Seven exercises with progressive difficulty: 3 easy, 3 medium, 1 challenge. Each includes scenario, schema+sample data, requirements, example output, success criteria, multi-level hints, and detailed solutions.

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

## Independent 7: Orders Integrity Check (🔴 Challenge, 20–25 min)
- Scenario: Identify orders with no items or cancelled.
- Schema + Data:
  ```sql
  CREATE TEMPORARY TABLE `orders` (
    `order_id` INT,
    `status` VARCHAR(20)
  );
  CREATE TEMPORARY TABLE `order_items` (
    `order_id` INT,
    `product` VARCHAR(50)
  );
  INSERT INTO `orders` VALUES
  (1,'PAID'),(2,'CANCELLED'),(3,'PAID');
  INSERT INTO `order_items` VALUES
  (1,'Mouse'),(1,'Cable'),(3,'Keyboard');
  ```
- Requirements:
  1) Return orders that are CANCELLED or have zero items.
  2) Output: `order_id`, `status`, `item_count`.
- Example Output:
  | order_id | status    | item_count |
  |----------|-----------|------------|
  | 2        | CANCELLED | 0          |
- Success Criteria: Correct left join and grouping to find zero-match.
- Hints:
  - Level 1: Use LEFT JOIN from orders to items.
  - Level 2: COUNT item rows grouped by order.
  - Level 3: Use HAVING for zero or filter by status.
- Solution:
  ```sql
  SELECT o.`order_id`, o.`status`, COUNT(oi.`product`) AS `item_count`
  FROM `orders` o
  LEFT JOIN `order_items` oi ON o.`order_id` = oi.`order_id`
  GROUP BY o.`order_id`, o.`status`
  HAVING o.`status` = 'CANCELLED' OR COUNT(oi.`product`) = 0;
  ```
