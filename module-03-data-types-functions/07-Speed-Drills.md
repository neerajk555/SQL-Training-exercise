# Speed Drills: Data Types & Functions (10 questions, 2–3 min each)

## 📋 Before You Start

### Learning Objectives
By completing these speed drills, you will:
- Build muscle memory for function syntax (CAST, TRIM, DATE functions)
- Practice quick recall of data type conversions
- Develop speed with string and date manipulation
- Reinforce COALESCE, CASE, and formatting patterns
- Test your mastery of data transformation

### How to Use Speed Drills
**Purpose:** Rapid practice for instant recall. 2-3 minutes per question!

**Process:**
1. Answer immediately from memory
2. Check answer right away
3. Mark wrong answers for review
4. Repeat until automatic
5. Revisit tomorrow for spaced repetition

**Scoring:** 9-10: Mastery | 7-8: Solid | 5-6: More practice | <5: Re-study

**Beginner Tip:** These are for building muscle memory! Try to answer without looking, then check immediately. Repeat any you miss. Speed comes with practice—don't worry if you need to look things up at first!

---

## Speed Drill Questions

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
