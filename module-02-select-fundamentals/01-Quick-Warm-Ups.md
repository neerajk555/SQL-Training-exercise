# Quick Warm-Ups (SELECT Fundamentals)

Each exercise: 5–10 minutes. Copy sample data into a scratch database first.

## 📋 Before You Start

### Learning Objectives
By completing these warm-ups, you will:
- Select specific columns instead of using SELECT *
- Filter data with multiple conditions (AND, OR)
- Sort and limit results for better presentation
- Handle NULL values safely with COALESCE
- Use wildcards for pattern matching with LIKE

### Environment Setup
1. **Connect to MySQL**: Open your MySQL client (MySQL Workbench, command line, or any SQL IDE)
2. **Choose a database**: 
   ```sql
   USE your_database_name;  -- Replace with your practice database
   -- OR create a new one:
   CREATE DATABASE IF NOT EXISTS sql_practice;
   USE sql_practice;
   ```
3. **Verify connection**: Run `SELECT 1;` to confirm you're connected

### How to Execute Each Exercise
**Step-by-step process:**
1. **Copy the setup code** (DROP TABLE IF EXISTS + CREATE TABLE + INSERT statements)
2. **Paste and run it** in your SQL client to create sample data
3. **Read the task carefully** and identify what's needed
4. **Write your query** (try solving it yourself first!)
5. **Run your query** and compare results with the expected output
6. **If stuck**, peek at the solution and understand each part
7. **Verify**: Run the solution query to confirm expected results

**Troubleshooting Tips:**
- ❌ Error "Table doesn't exist": Re-run the CREATE TABLE statements
- ❌ Wrong results: Check your WHERE clause and comparison operators
- ❌ Syntax error: Verify commas between columns and proper quoting
- ✅ These tables are permanent—use DROP TABLE when done or use a test database!

---

## 1) Pick the Columns You Need
- Scenario: You’re browsing a small product catalog and want a lightweight view.
- Sample data
```sql
DROP TABLE IF EXISTS products_qwu;
CREATE TABLE products_qwu (
  product_id INT PRIMARY KEY,
  name VARCHAR(50),
  price DECIMAL(7,2),
  category VARCHAR(30)
);
INSERT INTO products_qwu VALUES
(1, 'Notebook', 4.99, 'stationery'),
(2, 'Gel Pen', 1.49, 'stationery'),
(3, 'Coffee Mug', 7.99, 'kitchen'),
(4, 'T-Shirt', 12.00, 'apparel');
```
- Task: Return only `name` and `price` for all products.
- Expected output
```
name        | price
------------+-------
Notebook    | 4.99
Gel Pen     | 1.49
Coffee Mug  | 7.99
T-Shirt     | 12.00
```
- Time: 5 min
- Solution
```sql
SELECT name, price
FROM products_qwu;
```

---

## 2) Filter With WHERE and AND
- Scenario: A stakeholder wants only stationery items under $5.00.
- Sample data: Use `products_qwu` from Exercise 1.
- Task: Return `product_id`, `name` for category `stationery` priced < 5.
- Expected output
```
product_id | name
-----------+---------
1          | Notebook
2          | Gel Pen
```
- Time: 5–7 min
- Solution
```sql
SELECT product_id, name
FROM products_qwu
WHERE category = 'stationery'
  AND price < 5.00;
```

---

## 3) Sort Results and Limit Rows
- Scenario: Show the top 2 most expensive products so we can spotlight them.
- Sample data: Use `products_qwu` from Exercise 1.
- Task: Return `name`, `price` ordered by `price` DESC, limited to 2 rows.
- Expected output
```
name       | price
-----------+------
T-Shirt    | 12.00
Coffee Mug | 7.99
```
- Time: 5–7 min
- Solution
```sql
SELECT name, price
FROM products_qwu
ORDER BY price DESC
LIMIT 2;
```

---

## 4) Handle NULLs With COALESCE
- Scenario: Some students are missing emails; provide a fallback label.
- Sample data
```sql
DROP TABLE IF EXISTS students_qwu;
CREATE TABLE students_qwu (
  student_id INT PRIMARY KEY,
  full_name VARCHAR(60),
  email VARCHAR(60)
);
INSERT INTO students_qwu VALUES
(1, 'Ava Brown', 'ava@example.com'),
(2, 'Noah Smith', NULL),
(3, 'Mia Chen', 'mia@example.com');
```
- Task: Select `full_name` and `COALESCE(email, 'no email')` as `email_or_note`.
- Expected output
```
full_name | email_or_note
----------+--------------
Ava Brown | ava@example.com
Noah Smith| no email
Mia Chen  | mia@example.com
```
- Time: 5–7 min
- Solution
```sql
SELECT full_name,
       COALESCE(email, 'no email') AS email_or_note
FROM students_qwu;
```

---

## 5) DISTINCT and LIKE (Case-insensitive)
- Scenario: Marketing wants distinct cities containing the substring "san".
- Sample data
```sql
DROP TABLE IF EXISTS addresses_qwu;
CREATE TABLE addresses_qwu (
  id INT PRIMARY KEY,
  city VARCHAR(50)
);
INSERT INTO addresses_qwu VALUES
(1, 'San Diego'),
(2, 'SAN JOSE'),
(3, 'Boston'),
(4, 'Santa Fe'),
(5, 'san marino');
```
- Task: Return distinct `city` values that include "san" regardless of case.
- Expected output (order not important)
```
city
----------
San Diego
SAN JOSE
Santa Fe
san marino
```
- Time: 7–10 min
- Solution
```sql
SELECT DISTINCT city
FROM addresses_qwu
WHERE LOWER(city) LIKE '%san%';
```

Performance note: On large tables, add an index on the searched column and avoid wrapping it in functions (use a computed/normalized column or store LOWER(city)).
