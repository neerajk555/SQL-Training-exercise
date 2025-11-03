# Guided Step-by-Step (SELECT Fundamentals)

Three 15–20 minute activities. Each includes setup, checkpoints, and a fully explained solution.

## 📋 Before You Start

### Learning Objectives
Through these guided activities, you will:
- Build queries using SELECT, WHERE, and ORDER BY with real business scenarios
- Learn to use column aliases for cleaner output
- Practice handling NULL values with COALESCE
- Master string functions (CONCAT, LOWER, UPPER)
- Understand pattern matching with LIKE
- Develop structured problem-solving skills with checkpoints

### How to Execute Each Activity
**Step-by-step execution process:**
1. **Copy and run the complete setup code** (DROP TABLE through INSERT statements)
2. **Follow each numbered step** in order:
   - Read the step description
   - Write and execute the SQL described
   - Compare your results with the checkpoint
   - ✅ If checkpoint passes: move to next step
   - ❌ If checkpoint fails: debug before continuing
3. **Read "Common Mistakes"** to avoid typical pitfalls
4. **Study the complete solution** with comments
5. **Answer discussion questions** to deepen understanding

**Checkpoint Strategy:**
- Checkpoints verify you're on the right track
- Build incrementally—each step adds to the previous one
- If stuck, review the step and your query syntax carefully

---

## Activity 1: Clean Product Listing for a Promo Email
- Business context: Marketing needs a clean list of products under $20, showing a friendly name and whole-dollar rounded price for display.
- Database setup
```sql
DROP TABLE IF EXISTS gss_products;
CREATE TABLE gss_products (
  product_id INT PRIMARY KEY,
  name VARCHAR(60),
  price DECIMAL(7,2),
  category VARCHAR(30)
);
INSERT INTO gss_products VALUES
(1, 'Stainless Bottle', 19.95, 'kitchen'),
(2, 'Yoga Mat', 24.49, 'fitness'),
(3, 'Wireless Mouse', 18.00, 'electronics'),
(4, 'Desk Lamp', 12.75, 'home'),
(5, 'Sticker Pack', 3.20, 'stationery');
```
- Final goal: Return products priced <= 20 with columns: `name` as `product_name`, rounded price as `rounded_price`, category.

Step-by-step with checkpoints
1) Select basic columns from the table.
   - Checkpoint: Do you see all rows and columns you selected?
2) Filter to price <= 20 using WHERE.
   - Checkpoint: Are only products $20 or less included?
3) Add aliases and rounding: `name AS product_name`, `ROUND(price) AS rounded_price`.
   - Checkpoint: Are column headers correct with aliases?
4) Sort ascending by `rounded_price`, then `product_name`.
   - Checkpoint: Are the cheapest items first, and ties alphabetical?

Common mistakes
- Using `price < 20` instead of `<= 20`.
- Forgetting `AS` with aliases (it’s optional, but clearer).
- Sorting by `name` instead of `product_name` after aliasing.

Complete solution (with comments)
```sql
-- 1) Select only the columns we need, with friendly aliases
SELECT 
  name AS product_name,
  ROUND(price) AS rounded_price,
  category
FROM gss_products
-- 2) Filter by the price threshold
WHERE price <= 20
-- 3) Order for display consistency
ORDER BY rounded_price ASC, product_name ASC;
```

Discussion questions
- Why might rounding change the apparent order vs ordering by original price?
- When would you avoid rounding in a dataset used for calculations?

---

## Activity 2: Student Directory With Missing Emails
- Business context: A student services team wants a directory with names and emails, but some are missing and should show "N/A".
- Database setup
```sql
DROP TABLE IF EXISTS gss_students;
CREATE TABLE gss_students (
  id INT PRIMARY KEY,
  first_name VARCHAR(30),
  last_name VARCHAR(30),
  email VARCHAR(60)
);
INSERT INTO gss_students VALUES
(1, 'Liam', 'Nguyen', 'liam@example.edu'),
(2, 'Emma', 'Jones', NULL),
(3, 'Oliver', 'Garcia', 'ogarcia@example.edu'),
(4, 'Sophia', 'Patel', NULL),
(5, 'Elijah', 'Davis', 'elijah@example.edu');
```
- Final goal: Return `full_name` as `last_name, first_name` and `safe_email` that shows email or `N/A`.

Step-by-step with checkpoints
1) Create a full name using CONCAT and commas: `CONCAT(last_name, ', ', first_name)`.
   - Checkpoint: Names should look like "Jones, Emma".
2) Replace NULL emails with `N/A` using COALESCE.
   - Checkpoint: Only NULL emails show `N/A`.
3) Return just those two columns.
   - Checkpoint: Exactly two columns in the result.
4) Order by last_name then first_name.
   - Checkpoint: Alphabetical list by last then first.

Common mistakes
- Using `= NULL` instead of `IS NULL` (not needed if using COALESCE).
- Forgetting the space after the comma in CONCAT.
- Sorting by `full_name` may not sort exactly by last then first unless constructed correctly.

Complete solution (with comments)
```sql
SELECT 
  CONCAT(last_name, ', ', first_name) AS full_name,
  COALESCE(email, 'N/A') AS safe_email
FROM gss_students
ORDER BY last_name, first_name;
```

Discussion questions
- What are pros/cons of storing `full_name` vs computing it at query time?
- When would you choose IFNULL vs COALESCE in MySQL?

---

## Activity 3: Clinic Appointments—Today’s Schedule
- Business context: Front desk needs today’s appointments sorted by time; show a fallback when notes are missing.
- Database setup
```sql
DROP TABLE IF EXISTS gss_appointments;
CREATE TABLE gss_appointments (
  appt_id INT PRIMARY KEY,
  patient VARCHAR(60),
  appt_date DATE,
  appt_time TIME,
  notes VARCHAR(100)
);
INSERT INTO gss_appointments VALUES
(1, 'Ana Ruiz', CURRENT_DATE, '09:00:00', 'New patient'),
(2, 'Ben King', CURRENT_DATE, '10:30:00', NULL),
(3, 'Cora Lee', DATE_ADD(CURRENT_DATE, INTERVAL 1 DAY), '08:00:00', 'Follow-up'),
(4, 'Dan Wu', CURRENT_DATE, '11:15:00', NULL),
(5, 'Eli Park', CURRENT_DATE, '13:00:00', 'X-ray review');
```
- Final goal: Return only today’s appointments with columns: `patient`, `appt_time`, `note_or_dash` (notes or '-') sorted by `appt_time`.

Step-by-step with checkpoints
1) Filter to `appt_date = CURRENT_DATE`.
   - Checkpoint: Only today’s rows remain.
2) Replace NULL notes with '-' using COALESCE.
   - Checkpoint: Rows with missing notes show '-'.
3) Select desired columns only.
   - Checkpoint: Output has 3 columns.
4) Sort by time ascending.
   - Checkpoint: Earliest time first.

Common mistakes
- Using `NOW()` instead of `CURRENT_DATE` (includes time; comparison may fail).
- Forgetting that tomorrow’s appointment should be excluded.
- Sorting by `patient` by mistake.

Complete solution (with comments)
```sql
SELECT 
  patient,
  appt_time,
  COALESCE(notes, '-') AS note_or_dash
FROM gss_appointments
WHERE appt_date = CURRENT_DATE
ORDER BY appt_time ASC;
```

Discussion questions
- How does time zone or server date affect `CURRENT_DATE`?
- Would a generated column for `appt_datetime` be helpful for other queries?
