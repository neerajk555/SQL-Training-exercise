# Module 1: Error Detective (MySQL)

Five debugging challenges. Each includes a scenario, broken query, error details, expected output or intent, guiding questions, and a fix with explanation.

---

## Error 1: Wrong NULL Comparison
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

---

## Error 2: Quoting Identifiers
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

---

## Error 3: Incorrect Date Comparison
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

---

## Error 4: Missing ORDER BY Column in SELECT
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

---

## Error 5: Wrong Operator for String Patterns
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
- Explanation: Use `=` for exact matches, `LIKE` for pattern matching with wildcards (% for any characters, _ for single character).
