# Module 1: Guided Step-by-Step (MySQL)

Three structured activities with business context, setup, final goal, stepwise checkpoints, common mistakes, and full solutions. Time per activity: 15–20 minutes.

Tip: You can also load larger sample data from `module-01-setup.sql`.

---

## Guided 1: First Look at an E-commerce DB
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

---

## Guided 2: Student Enrollment Check
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

---

## Guided 3: Appointment Status Report
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
- Final Goal: Show scheduled appointments ordered by date, plus count of scheduled.
- Steps:
  1) Select scheduled only: `WHERE status='SCHEDULED'`.
  2) Order by date ascending.
  3) Count scheduled: basic aggregate with `COUNT(*)` on the same filter.
  4) Verify counts match number of returned rows.
- Mistakes:
  - Forgetting to repeat the WHERE when counting.
- Solution:
  ```sql
  SELECT `appt_id`, `appt_date`
  FROM `appointments`
  WHERE `status` = 'SCHEDULED'
  ORDER BY `appt_date` ASC;

  SELECT COUNT(*) AS scheduled_count
  FROM `appointments`
  WHERE `status` = 'SCHEDULED';
  ```
- Discussion:
  1) When would you include a date range filter?
  2) What additional columns might matter for triage?
