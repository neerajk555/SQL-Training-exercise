# Speed Drills — Joins (10 questions)

Answer quickly. Immediate answers follow each question.

**Beginner Tip:** Quick recall builds confidence! Try answering before looking. If you miss one, review that concept and try again later. Repetition builds mastery!

1) Which join keeps all rows from the left table and matches on keys?
- Answer: LEFT JOIN

2) Fill the blank to join orders to customers by customer_id:
- SELECT o.order_id, c.name FROM orders o ____ customers c ON c.customer_id = o.customer_id;
- Answer: JOIN (or INNER JOIN)

3) True/False: Filtering the right table’s columns in WHERE after a LEFT JOIN can remove NULL-extended rows.
- Answer: True

4) Choose the anti-join pattern to find products with no order items.
- Answer: LEFT JOIN order_items oi ON oi.product_id = p.product_id WHERE oi.product_id IS NULL

5) What clause defines the join condition?
- Answer: ON

6) Write the skeleton to join three tables A→B→C.
- Answer: FROM A JOIN B ON ... JOIN C ON ...

7) How do you prevent double-counting in many-to-many when counting customers per category?
- Answer: Use COUNT(DISTINCT customer_id)

8) Which join returns the cartesian product of two tables?
- Answer: CROSS JOIN (or missing ON with JOIN)

9) Pick the clearer way to test existence of a related row without returning it.
- Answer: EXISTS (SELECT 1 FROM ... WHERE ...)

10) Where should a filter go to keep unmatched left rows in a LEFT JOIN?
- Answer: In the ON clause (not WHERE)
