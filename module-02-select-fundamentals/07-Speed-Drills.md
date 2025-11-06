# Speed Drills: SELECT Fundamentals (10 questions, 2–3 min each)

## 📋 Before You Start

### Learning Objectives
By completing these speed drills, you will:
- Build muscle memory for SELECT fundamentals
- Practice quick recall of WHERE, ORDER BY, LIMIT syntax
- Develop speed with column selection and filtering
- Reinforce DISTINCT, LIKE, BETWEEN patterns
- Test your mastery of SELECT variations

### How to Use Speed Drills
**Purpose:** Rapid-fire practice for instant recall. Each question: 2-3 minutes!

**Process:**
1. **Read question** - understand what's needed
2. **Answer immediately** - use your first instinct
3. **Check answer** - compare with solution
4. **Mark if wrong** - these need review
5. **Retry later** - build automatic recall

**Scoring:**
- 9-10: Mastery! Ready for advanced topics
- 7-8: Solid, review weak spots
- 5-6: Practice fundamentals more
- <5: Re-study module content

**Tip:** Don't overthink! Speed drills train automatic responses. Wrong answers show what to practice!

---

## Speed Drill Questions

How to use: Try to answer each quickly. Answers immediately follow each question for self-scoring.

---

1) Syntax writing: Select `name`, `price` from table `items`.
Answer
```sql
SELECT name, price FROM items;
```

2) Clause order: Put these in correct SELECT order: WHERE, SELECT, LIMIT, ORDER BY, FROM.
Answer
```
SELECT ... FROM ... WHERE ... ORDER BY ... LIMIT ...
```

3) Error spotting: What’s wrong?
```sql
SELECT 'city', country FROM places;
```
Answer: 'city' is a string literal; use city (or backticks if needed).

4) Fill-in: Return rows where `status` is NULL.
Answer
```sql
SELECT * FROM t WHERE status IS NULL;
```

5) True/False: DISTINCT removes duplicates across all selected columns.
Answer: True.

6) Write a LIKE pattern to find titles that start with "Intro" (case-sensitive by default).
Answer
```sql
WHERE title LIKE 'Intro%'
```

7) Choose the predicate to include dates from 2025-02-01 through 2025-02-28 inclusive.
Answer
```sql
WHERE order_date BETWEEN '2025-02-01' AND '2025-02-28'
```

8) Quick aliasing: Show `price` as `usd_price`.
Answer
```sql
SELECT price AS usd_price FROM t;
```

9) Fill-in: Replace NULL `email` with 'N/A'.
Answer
```sql
SELECT COALESCE(email, 'N/A') AS email_or_na FROM users;
```

10) Error spotting: Why does this fail?
```sql
SELECT name, price AS p
FROM items
WHERE p < 10;
```
Answer: WHERE cannot reference SELECT alias `p`; repeat the expression (price < 10) or use a subquery.
