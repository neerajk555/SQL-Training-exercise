# Speed Drills — Window Functions

## 📋 Before You Start

### Learning Objectives
By completing these speed drills, you will:
- Build muscle memory for ROW_NUMBER, RANK, LAG/LEAD
- Practice quick recall of OVER, PARTITION BY, ORDER BY
- Develop speed with window function syntax
- Reinforce frame specifications and analytical patterns
- Test your mastery of window functions

### How to Use Speed Drills
**Purpose:** Rapid practice for window function mastery. 2-3 minutes per question!

**Process:**
1. Answer without looking
2. Check solution immediately
3. Mark missed questions
4. Practice until natural
5. Revisit tomorrow

**Scoring:** 9-10: Mastery | 7-8: Strong | 5-6: More practice | <5: Re-study

**🎯 Goal:** Quick-fire questions to test your understanding. Answer without looking, then check!

---

## Speed Drill Questions

---

## Drill 1: ROW_NUMBER vs RANK

**Q:** What's the difference between ROW_NUMBER() and RANK()?

<details>
<summary>Click for Answer</summary>

**A:** 
- **ROW_NUMBER()**: Always gives unique sequential numbers (1, 2, 3, 4...) even with ties
- **RANK()**: Gives same rank for ties and skips next (1, 2, 2, 4...)

**Example with scores [95, 90, 90, 85]:**
- ROW_NUMBER(): 1, 2, 3, 4 (breaks tie arbitrarily)
- RANK(): 1, 2, 2, 4 (ties get same rank, then gap)
- DENSE_RANK(): 1, 2, 2, 3 (ties get same rank, no gap)

**💡 Remember:** ROW_NUMBER = always unique, RANK = honors ties with gaps
</details>

---

## Drill 2: DENSE_RANK

**Q:** With scores [95, 90, 90, 85], what does DENSE_RANK() return?

<details>
<summary>Click for Answer</summary>

**A:** 1, 2, 2, 3 (no gap after ties)

**Why?**
- Score 95: Rank 1 (highest)
- Scores 90 & 90: Both get Rank 2 (tied)
- Score 85: Rank 3 (NOT rank 4 - no gap!)

**Compare to RANK():** Would return 1, 2, 2, 4 (with gap)
</details>

---

## Drill 3: PARTITION BY

**Q:** What does PARTITION BY do in a window function?

<details>
<summary>Click for Answer</summary>

**A:** Divides the result set into separate groups (partitions), and the window function applies independently to each partition.

**Example:**
```sql
RANK() OVER (PARTITION BY department ORDER BY salary DESC)
```
- Creates separate rankings for each department
- Rankings restart at 1 for each new department
- Sales department rankings don't affect IT department rankings

**💡 Remember:** PARTITION BY = "separate competitions" for each group
</details>

---

## Drill 4: Frame Specification

**Q:** What does `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` mean?

<details>
<summary>Click for Answer</summary>

**A:** Includes the current row plus 2 rows before it (3 rows total) in the calculation.

**Visual Example:**
```
Row 1: [X]                    ← Only 1 row available
Row 2: [X, X]                 ← Only 2 rows available  
Row 3: [X, X, X]              ← Full 3-row window (2 before + current)
Row 4: [_, X, X, X]           ← Window slides (drops row 1, includes rows 2,3,4)
Row 5: [_, _, X, X, X]        ← Window slides (drops row 2, includes rows 3,4,5)
```

**💡 Remember:** N PRECEDING + CURRENT = (N+1) rows total
- 2 PRECEDING = 3 rows (2 before + current)
- 6 PRECEDING = 7 rows (6 before + current)
</details>

---

## Drill 5: LAG() Function

**Q:** `LAG(salary, 2)` returns what?

<details>
<summary>Click for Answer</summary>

**A:** The salary value from 2 rows before the current row.

**Example:**
```
Row 1: salary=50000, LAG(salary,2) = NULL  (no row 2 positions back)
Row 2: salary=60000, LAG(salary,2) = NULL  (no row 2 positions back)
Row 3: salary=70000, LAG(salary,2) = 50000 (gets Row 1's salary)
Row 4: salary=80000, LAG(salary,2) = 60000 (gets Row 2's salary)
```

**💡 Remember:** 
- LAG(col, 1) = previous row (1 back)
- LAG(col, 2) = two rows back
- LAG(col, 1, 0) = previous row, or 0 if none exists (default value)
</details>

---

## Drill 6: LEAD() Function

**Q:** `LEAD(revenue, 1, 0)` - what does the third parameter (0) do?

<details>
<summary>Click for Answer</summary>

**A:** It's the default value returned when there's no following row (e.g., the last row).

**Example:**
```
Row 1: revenue=10000, LEAD(revenue,1,0) = 12000 (gets Row 2)
Row 2: revenue=12000, LEAD(revenue,1,0) = 11000 (gets Row 3)
Row 3: revenue=11000, LEAD(revenue,1,0) = 0     (no Row 4, returns default)
```

**💡 Remember:** 
- LEAD looks FORWARD, LAG looks BACKWARD
- Without default: last row returns NULL
- With default: last row returns your specified value (often 0)
</details>

---

## Drill 7: ORDER BY Requirement

**Q:** Which window functions REQUIRE ORDER BY in the OVER() clause?

<details>
<summary>Click for Answer</summary>

**A:** 
- ✅ **ROW_NUMBER()** - needs order to assign numbers
- ✅ **RANK()** - needs order to determine ranks
- ✅ **DENSE_RANK()** - needs order to rank
- ✅ **LAG()** - needs order to know "previous"
- ✅ **LEAD()** - needs order to know "next"
- ✅ **Any function with frames** (ROWS/RANGE) - needs order for "preceding/following"

**Do NOT require ORDER BY:**
- ⚠️ **SUM(), AVG(), COUNT()** - optional (but affects result with frames!)
- ⚠️ **MIN(), MAX()** - optional

**💡 Remember:** If it involves sequence or position, it needs ORDER BY!
</details>

---

## Drill 8: NTILE()

**Q:** `NTILE(4)` divides 100 rows into how many groups? How many rows per group?

<details>
<summary>Click for Answer</summary>

**A:** 4 groups (quartiles) with 25 rows each (since 100 ÷ 4 = 25 exactly)

**What if uneven?** NTILE(4) with 102 rows:
- Q1: 26 rows (gets extra)
- Q2: 26 rows (gets extra)
- Q3: 25 rows
- Q4: 25 rows
- Extra rows distributed to first groups!

**Use Cases:**
- NTILE(4) = quartiles (Q1-Q4, 25% each)
- NTILE(10) = deciles (10% each)
- NTILE(100) = percentiles (1% each)

**💡 Remember:** NTILE(N) creates N roughly equal buckets
</details>

---

## Drill 9: Window Functions vs GROUP BY

**Q:** True or False: Window functions reduce the number of rows like GROUP BY does.

<details>
<summary>Click for Answer</summary>

**A:** **FALSE!** 

**Key Differences:**
- **GROUP BY**: Collapses rows (100 employees → 3 rows for 3 departments)
- **Window Functions**: Preserve all rows (100 employees stay 100 rows, with added calculations)

**Example:**
```sql
-- GROUP BY: 3 rows (one per department)
SELECT dept, AVG(salary) 
FROM employees 
GROUP BY dept;

-- Window Function: All employee rows preserved
SELECT emp_name, dept, salary,
  AVG(salary) OVER (PARTITION BY dept) AS dept_avg
FROM employees;
```

**💡 Remember:** Window = "see through the window at other rows" while keeping your seat!
</details>

---

## Drill 10: Performance

**Q:** Does ORDER BY inside OVER() require sorting? How can you improve performance?

<details>
<summary>Click for Answer</summary>

**A:** **Yes**, ORDER BY requires sorting, which can be slow on large datasets.

**Performance Tips:**
1. **Index your ORDER BY columns**: If you order by `ORDER BY salary DESC`, index the salary column
2. **Index PARTITION BY columns**: If you use `PARTITION BY department`, index department
3. **Use ROWS instead of RANGE**: ROWS is faster (physical count vs value comparison)
4. **Filter first, window second**: Use WHERE to reduce rows before applying window functions
5. **Reuse window definitions** (MySQL 8.0.11+):
```sql
-- ❌ Slower: Define same window multiple times
SELECT AVG(salary) OVER (PARTITION BY dept ORDER BY hire_date),
       SUM(salary) OVER (PARTITION BY dept ORDER BY hire_date)
FROM employees;

-- ✅ Faster: Define window once
SELECT AVG(salary) OVER w, SUM(salary) OVER w
FROM employees
WINDOW w AS (PARTITION BY dept ORDER BY hire_date);
```

**💡 Remember:** Window functions are powerful but can be resource-intensive. Optimize when working with large datasets!
</details>

---

## 📊 Your Score

Count how many you got right on first try:

- **9-10 correct**: 🏆 **Expert Level** - You've mastered window functions!
- **7-8 correct**: ⭐ **Proficient** - Strong understanding, minor review needed
- **5-6 correct**: 📚 **Intermediate** - Good foundation, practice more
- **< 5 correct**: 🎯 **Beginner** - Review the module exercises again

**💡 Study Tip:** For questions you missed, go back to that section in the module materials!

---

**Next:** Move to `08-Take-Home-Challenges.md` for advanced multi-day projects!
