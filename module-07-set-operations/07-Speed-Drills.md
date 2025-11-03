# Speed Drills — Set Operations (2–3 min each)

Quick-fire questions to test your knowledge. Try to answer before looking at the solution!

---

## Drill 1: UNION vs UNION ALL
**Question:** What's the main difference between UNION and UNION ALL?

**Answer:** UNION removes duplicate rows from the combined result; UNION ALL keeps all rows including duplicates. UNION ALL is faster because it doesn't need to eliminate duplicates.

---

## Drill 2: Column Count Rule
**Question:** True or False: In a UNION query, all SELECT statements must have the same number of columns.

**Answer:** True. All SELECT statements in a UNION must return the same number of columns, and corresponding columns must have compatible data types.

---

## Drill 3: Column Names
**Question:** When you UNION three SELECT statements with different column names, which column names appear in the result?

**Answer:** The column names from the FIRST SELECT statement are used in the result set.

---

## Drill 4: ORDER BY Placement
**Question:** Where should ORDER BY be placed in a query using UNION?
```sql
-- A: SELECT ... ORDER BY ... UNION SELECT ...
-- B: (SELECT ... ORDER BY ...) UNION (SELECT ... ORDER BY ...)
-- C: SELECT ... UNION SELECT ... ORDER BY ...
```

**Answer:** C. ORDER BY must be placed at the end and applies to the entire combined result. You cannot use ORDER BY within individual SELECT statements in a UNION.

---

## Drill 5: INTERSECT Meaning
**Question:** What does `SELECT id FROM table_a INTERSECT SELECT id FROM table_b` return?

**Answer:** IDs that exist in BOTH table_a AND table_b. INTERSECT returns only the rows that appear in all result sets.

---

## Drill 6: EXCEPT/MINUS Meaning
**Question:** What does `SELECT email FROM customers EXCEPT SELECT email FROM unsubscribed` return?

**Answer:** Emails that exist in customers but NOT in unsubscribed. EXCEPT returns rows from the first result set that don't appear in the second.

---

## Drill 7: Duplicate Handling
**Question:** How many rows does this return?
```sql
SELECT 'A' AS letter
UNION
SELECT 'A'
UNION
SELECT 'B';
```

**Answer:** 2 rows ('A' and 'B'). UNION removes duplicates, so the two 'A' rows become one.

---

## Drill 8: Performance Question
**Question:** Which is faster for combining 100,000 rows from two tables if you don't care about duplicates: UNION or UNION ALL?

**Answer:** UNION ALL is faster. UNION requires sorting/hashing to eliminate duplicates, which is expensive on large datasets. If duplicates don't matter, always use UNION ALL.

---

## Drill 9: INTERSECT Alternative
**Question:** Fill in the blank to simulate INTERSECT:
```sql
SELECT DISTINCT a.id
FROM table_a a
_____ JOIN table_b b ON a.id = b.id;
```

**Answer:** INNER. `INNER JOIN` returns only matching rows, simulating INTERSECT. Add DISTINCT to handle duplicates within tables.

---

## Drill 10: Type Compatibility
**Question:** Will this query work?
```sql
SELECT customer_id FROM customers  -- INT column
UNION
SELECT order_amount FROM orders;   -- DECIMAL column
```

**Answer:** It will run (MySQL does implicit conversion), but it's bad practice. The result will convert both to a common type (likely DECIMAL), which may not make logical sense. Column types should be semantically compatible, not just technically castable.

---

**Speed Drill Complete!** Score yourself: 8-10 correct = Expert, 6-7 = Proficient, 4-5 = Review needed.

**Next Step:** Move to `08-Take-Home-Challenges.md` for advanced multi-part problems.
