# Speed Drills: Aggregates & Grouping (10 questions, 2–3 min each)

Immediate answers follow each question.

**Beginner Tip:** Speed drills build quick recall of syntax and concepts. Try each question before checking the answer. These aren't tests—they're practice tools. Repeat them until the patterns feel natural!

---

1) Write: Count all rows in table `t`.
Answer
```sql
SELECT COUNT(*) FROM t;
```

2) Choose: Which ignores NULLs—COUNT(*) or COUNT(col)?
Answer: COUNT(col) ignores NULLs; COUNT(*) counts rows.

3) Write: Total revenue from `qty` and `price` in table `items`.
Answer
```sql
SELECT SUM(qty * price) AS revenue FROM items;
```

4) Fill-in: Group orders by status and show their counts.
Answer
```sql
SELECT status, COUNT(*) AS cnt
FROM orders
GROUP BY status;
```

5) True/False: You can use AVG(price) in WHERE.
Answer: False; use HAVING for aggregated conditions.

6) Write: Show categories with total qty >= 10.
Answer
```sql
SELECT category, SUM(qty) AS total_qty
FROM sales
GROUP BY category
HAVING SUM(qty) >= 10;
```

7) Choose: Which gets unique customer count—COUNT(customer_id) or COUNT(DISTINCT customer_id)?
Answer: COUNT(DISTINCT customer_id).

8) Write: Month label from DATE `order_date` like 'March 2025'.
Answer
```sql
SELECT DATE_FORMAT(order_date, '%M %Y') FROM orders;
```

9) Error spotting: What’s missing?
```sql
SELECT status, COUNT(*) FROM orders;
```
Answer: GROUP BY status.

10) Write: Concatenate order IDs per month in ascending order, comma-separated.
Answer
```sql
SELECT DATE_FORMAT(order_date,'%Y-%m') AS ym,
       GROUP_CONCAT(order_id ORDER BY order_id SEPARATOR ',') AS ids
FROM orders
GROUP BY DATE_FORMAT(order_date,'%Y-%m');
```
