# Speed Drills — Subqueries & CTEs (10 questions)

Answer quickly. Immediate answers follow each question.

**Beginner Tip:** These questions test your understanding of subquery patterns and best practices. Try answering first, then check. Revisit any you miss—these concepts are crucial for advanced SQL!

1) Which predicate is more NULL-safe for anti-joins: NOT IN or NOT EXISTS?
- **Answer:** NOT EXISTS
- **Why:** NOT IN fails if the subquery returns ANY NULL value (returns 0 rows). NOT EXISTS safely checks for existence without NULL issues.
- **Example:** `WHERE id NOT IN (1, NULL)` breaks! Use `WHERE NOT EXISTS (SELECT 1 FROM ... WHERE id = t.id)` instead.

2) Where can subqueries appear? Name three positions.
- **Answer:** SELECT (scalar), WHERE/HAVING, FROM (derived table)
- **Details:**
  - **SELECT:** `SELECT (SELECT MAX(price) FROM products) AS max_price`
  - **WHERE/HAVING:** `WHERE price > (SELECT AVG(price) FROM products)`
  - **FROM:** `FROM (SELECT category, SUM(sales) FROM ... GROUP BY category) t`

3) True/False: A correlated subquery references columns from the outer query.
- **Answer:** True
- **Example:** `SELECT name, (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.customer_id) FROM customers c`
  - The inner query references `c.customer_id` from the outer query
  - Executes once per outer row (can be slower but sometimes more readable)

4) Fill-in: Use a derived table alias t to count orders per customer and join back.
- **Answer:** 
  ```sql
  FROM customers c LEFT JOIN (
    SELECT customer_id, COUNT(*) AS order_count 
    FROM orders 
    GROUP BY customer_id
  ) t ON t.customer_id = c.customer_id
  ```
- **Why derived table?** Pre-aggregating in a subquery prevents row explosion from joining before grouping.

5) What must a recursive CTE always include in its recursive member?
- **Answer:** A termination condition (e.g., WHERE ... to stop growth)
- **Example:** `WHERE level < 10` or `WHERE date < '2025-12-31'`
- **Without it:** Infinite loop! MySQL aborts after 1000+ iterations.

6) Choose the clearer way to test existence without returning data.
- **Answer:** EXISTS (SELECT 1 FROM ... WHERE ...)
- **Why SELECT 1?** We only check IF rows exist, not WHAT data they contain. Could use `SELECT *` or `SELECT id` - makes no difference!
- **Efficient:** Stops at first match (doesn't scan all rows).

7) Which clause filters aggregated results in the same SELECT block?
- **Answer:** HAVING
- **Remember:** WHERE filters BEFORE grouping, HAVING filters AFTER grouping
- **Example:** `GROUP BY category HAVING SUM(sales) > 1000`

8) What does WITH (CTE) primarily improve?
- **Answer:** Readability/structure (and can enable reuse within a single statement)
- **Benefits:**
  - Top-to-bottom flow (easier to follow than nested subqueries)
  - Named intermediate results (self-documenting)
  - Can reference earlier CTEs in same WITH clause
  - Easier to test each step independently

9) How to get the top 1 row per group with ties allowed?
- **Answer:** Use DENSE_RANK() OVER (PARTITION BY ... ORDER BY ...) = 1 in an outer query
- **Example:**
  ```sql
  SELECT * FROM (
    SELECT *, DENSE_RANK() OVER (PARTITION BY category ORDER BY price DESC) AS rnk
    FROM products
  ) t WHERE rnk = 1
  ```
- **DENSE_RANK vs ROW_NUMBER:** DENSE_RANK allows ties (both get rank 1), ROW_NUMBER picks one arbitrarily.

10) When is NOT IN safe?
- **Answer:** When the subquery cannot return NULL (e.g., filtered with WHERE col IS NOT NULL)
- **Examples:**
  - ✅ Safe: `WHERE id NOT IN (SELECT id FROM table WHERE id IS NOT NULL)`
  - ✅ Safe: `WHERE id NOT IN (1, 2, 3)` (literal values, no NULLs)
  - ❌ Unsafe: `WHERE id NOT IN (SELECT id FROM table)` (id might be NULL)
- **Golden Rule:** When in doubt, use NOT EXISTS instead!
