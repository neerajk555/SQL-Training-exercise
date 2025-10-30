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

## Error 3: Missing Join Condition
- Scenario: Compute order totals.
- Broken Query:
  ```sql
  SELECT * FROM orders o, order_items oi;
  ```
- Error: Cartesian product explosion.
- Expected: Join on key.
- Fix:
  ```sql
  SELECT o.`order_id`, SUM(oi.`quantity` * oi.`unit_price`) AS total
  FROM `orders` o
  JOIN `order_items` oi ON oi.`order_id` = o.`order_id`
  GROUP BY o.`order_id`;
  ```
- Explanation: Always specify join predicates.

---

## Error 4: Ambiguous Column
- Scenario: Filter by `status` but column exists in multiple tables.
- Broken Query:
  ```sql
  SELECT *
  FROM orders
  JOIN order_items ON order_items.order_id = orders.order_id
  WHERE status = 'PAID';
  ```
- Error: Ambiguous column 'status'.
- Fix:
  ```sql
  SELECT *
  FROM `orders` o
  JOIN `order_items` oi ON oi.`order_id` = o.`order_id`
  WHERE o.`status` = 'PAID';
  ```
- Explanation: Qualify columns when duplicates may exist.

---

## Error 5: COUNT With WHERE vs HAVING
- Scenario: Find orders with zero items.
- Broken Query:
  ```sql
  SELECT o.order_id
  FROM orders o
  LEFT JOIN order_items oi ON o.order_id = oi.order_id
  WHERE COUNT(oi.product) = 0
  GROUP BY o.order_id;
  ```
- Error: `WHERE` cannot use aggregates; also order of clauses.
- Fix:
  ```sql
  SELECT o.`order_id`
  FROM `orders` o
  LEFT JOIN `order_items` oi ON o.`order_id` = oi.`order_id`
  GROUP BY o.`order_id`
  HAVING COUNT(oi.`product`) = 0;
  ```
- Explanation: Use HAVING for aggregate filters.
