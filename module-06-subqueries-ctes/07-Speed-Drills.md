# Speed Drills — Subqueries & CTEs (10 questions)

Answer quickly. Immediate answers follow each question.

**Beginner Tip:** These questions test your understanding of subquery patterns and best practices. Try answering first, then check. Revisit any you miss—these concepts are crucial for advanced SQL!

1) Which predicate is more NULL-safe for anti-joins: NOT IN or NOT EXISTS?
- Answer: NOT EXISTS

2) Where can subqueries appear? Name three positions.
- Answer: SELECT (scalar), WHERE/HAVING, FROM (derived table)

3) True/False: A correlated subquery references columns from the outer query.
- Answer: True

4) Fill-in: Use a derived table alias t to count orders per customer and join back.
- Answer: FROM customers c LEFT JOIN (
           SELECT customer_id, COUNT(*) AS order_count FROM orders GROUP BY customer_id
         ) t ON t.customer_id = c.customer_id

5) What must a recursive CTE always include in its recursive member?
- Answer: A termination condition (e.g., WHERE ... to stop growth)

6) Choose the clearer way to test existence without returning data.
- Answer: EXISTS (SELECT 1 FROM ... WHERE ...)

7) Which clause filters aggregated results in the same SELECT block?
- Answer: HAVING

8) What does WITH (CTE) primarily improve?
- Answer: Readability/structure (and can enable reuse within a single statement)

9) How to get the top 1 row per group with ties allowed?
- Answer: Use DENSE_RANK() OVER (PARTITION BY ... ORDER BY ...) = 1 in an outer query

10) When is NOT IN safe?
- Answer: When the subquery cannot return NULL (e.g., filtered with WHERE col IS NOT NULL)
