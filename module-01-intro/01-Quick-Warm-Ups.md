# Module 1: Quick Warm-Ups (MySQL)

Each warm-up includes a tiny dataset, a focused task, expected output, and a solution. Time per exercise: 5–10 minutes.

Tip: These use temporary tables and won’t affect your database. You can also load optional data from `module-01-setup.sql`.

---

## Warm-Up 1: List Active Products
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
  | product_id | name        | price |
  |------------|-------------|-------|
  | 1          | USB-C Cable | 9.99  |
  | 3          | Mouse Pad   | 6.50  |
- Time: 5–7 min
- Solution:
  ```sql
  SELECT `product_id`, `name`, `price`
  FROM `products`
  WHERE `discontinued` = 0;
  ```

---

## Warm-Up 2: Students Missing Email
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

---

## Warm-Up 3: Upcoming Appointments
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
- Task: Select `appt_id`, `appt_date` where `status` = 'SCHEDULED'. Order by `appt_date` ascending.
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

---

## Warm-Up 4: Price Filter
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

---

## Warm-Up 5: Sort by Last Name
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
