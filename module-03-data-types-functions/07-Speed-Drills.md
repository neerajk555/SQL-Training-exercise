# Speed Drills: Data Types & Functions (10 questions, 2–3 min each)

Immediate answers provided for self-scoring.

---

1) Write: Cast string '12.5' to DECIMAL(5,2).
Answer
```sql
SELECT CAST('12.5' AS DECIMAL(5,2));
```

2) Choose: Which replaces NULL with a fallback—COALESCE or NULLIF?
Answer: COALESCE.

3) Fill-in: Trim and lowercase ' Ava@Example.com '.
Answer
```sql
SELECT LOWER(TRIM(' Ava@Example.com '));
```

4) True/False: `TIMESTAMPDIFF(DAY, '2025-03-01', '2025-03-02')` returns 1.
Answer: True.

5) Error spotting: What’s wrong?
```sql
SELECT STR_TO_DATE('03/01/2025','%Y-%m-%d');
```
Answer: Format mismatch; use '%m/%d/%Y'.

6) Write: Replace `$` and commas from '$1,299.95'.
Answer
```sql
SELECT REPLACE(REPLACE('$1,299.95','$',''),',','');
```

7) Choose: Which prevents divide-by-zero and returns NULL—IFNULL or NULLIF?
Answer: NULLIF (used on the denominator).

8) Fill-in: Extract domain from 'noah@EXAMPLE.org' lowercased.
Answer
```sql
SELECT LOWER(SUBSTRING_INDEX('noah@EXAMPLE.org','@',-1));
```

9) True/False: `CAST('12.34' AS UNSIGNED)` yields 12.
Answer: True (truncates decimals).

10) Write: Format date '2025-03-01' as 'March 2025'.
Answer
```sql
SELECT DATE_FORMAT('2025-03-01','%M %Y');
```
