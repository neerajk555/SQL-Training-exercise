# Module 1: Speed Drills (MySQL)

Ten quick questions (2–3 minutes each). Immediate answers provided for self-scoring.

---

1) Write a query to list all rows from `products`.
- Answer:
```sql
SELECT * FROM `products`;
```

2) Select only unique categories from `products`.
- Answer:
```sql
SELECT DISTINCT `category` FROM `products`;
```

3) Return products priced under 20, sorted by price descending.
- Answer:
```sql
SELECT `name`, `price`
FROM `products`
WHERE `price` < 20
ORDER BY `price` DESC;
```

4) Find students with missing emails.
- Answer:
```sql
SELECT `student_id`, `full_name`
FROM `students`
WHERE `email` IS NULL;
```

5) Concatenate first and last name as `full_name`.
- Answer:
```sql
SELECT CONCAT(`first_name`,' ',`last_name`) AS `full_name` FROM `customers`;
```

6) Show all scheduled appointments.
- Answer:
```sql
SELECT * FROM `appointments` WHERE `status`='SCHEDULED';
```

7) Return top 5 cheapest products.
- Answer:
```sql
SELECT `name`, `price`
FROM `products`
ORDER BY `price` ASC
LIMIT 5;
```

8) Show orders placed on '2025-03-21'.
- Answer:
```sql
SELECT * FROM `orders` WHERE `order_date` = '2025-03-21';
```

9) Replace NULL emails with 'unknown' in output only.
- Answer:
```sql
SELECT COALESCE(`email`, 'unknown') AS `email_display`
FROM `students`;
```

10) Find discontinued products or out-of-stock products.
- Answer:
```sql
SELECT `name`
FROM `products`
WHERE `discontinued` = 1 OR `stock` = 0;
```
