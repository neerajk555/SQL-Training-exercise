# Paired Programming — Window Functions (30 min)

## � Before You Start

### Learning Objectives
Through paired programming, you will:
- Experience collaborative SQL problem-solving with window functions
- Learn to communicate OVER, PARTITION BY, ORDER BY logic clearly
- Practice distinguishing between aggregates and window functions
- Build teamwork skills essential for professional development
- Apply ROW_NUMBER, RANK, LAG/LEAD collaboratively

### Paired Programming Roles
**🚗 Driver (Controls Keyboard):**
- Types all SQL code
- Verbalizes thought process ("Partitioning by category because...")
- Asks navigator for confirmation
- Focuses on syntax and window clauses

**🧭 Navigator (Reviews & Guides):**
- Keeps requirements visible
- Spots errors before execution
- Suggests tests and edge cases
- **Does NOT touch the keyboard**

### Execution Flow
1. **Setup**: Driver runs schema (CREATE + INSERT)
2. **Part A**: Navigator reads requirements → discuss approach → Driver codes → verify → **SWITCH ROLES**
3. **Part B**: Repeat with reversed roles → **SWITCH ROLES**
4. **Part C**: Repeat with reversed roles
5. **Review**: Compare solutions together

**Communication Tips:**
- Navigator: Explain your thinking out loud
- Driver: Ask questions if unclear
- Both: Discuss results before moving to next part

---

## Activity: Quarterly Sales Analysis

**🎯 Business Context:** Your company tracks regional sales quarterly. Management wants three analyses:
1. Which region wins each quarter?
2. Is each region growing or declining?
3. What are cumulative totals and trends?

### Setup:
```sql
DROP TABLE IF EXISTS pp8_sales;
CREATE TABLE pp8_sales (quarter VARCHAR(10), region VARCHAR(30), revenue DECIMAL(12,2));
INSERT INTO pp8_sales VALUES 
('2024-Q1','North',100000),('2024-Q1','South',95000),
('2024-Q2','North',110000),('2024-Q2','South',105000),
('2024-Q3','North',115000),('2024-Q3','South',120000);
```

---

### Part A: Regional Ranking (Driver: Partner 1, Navigator: Partner 2) — 10 min

**🎯 Goal:** Rank regions by revenue for each quarter (who's #1 each quarter?).

**💡 What to discuss:**
- Do we need PARTITION BY? (Hint: Yes - separate ranking per quarter)
- Should we use RANK() or ROW_NUMBER()? (Either works - no ties here)
- What should ORDER BY be? (Highest revenue first)

**Expected Output:**
```
quarter | region | revenue | quarterly_rank
2024-Q1 | North  | 100000  | 1              ← North wins Q1
2024-Q1 | South  | 95000   | 2
2024-Q2 | North  | 110000  | 1              ← North wins Q2
2024-Q2 | South  | 105000  | 2
2024-Q3 | South  | 120000  | 1              ← South wins Q3!
2024-Q3 | North  | 115000  | 2
```

**Solution:**
```sql
SELECT 
  quarter, 
  region, 
  revenue,
  RANK() OVER (PARTITION BY quarter ORDER BY revenue DESC) AS quarterly_rank
FROM pp8_sales
ORDER BY quarter, quarterly_rank;
```

**🔍 Explanation:**
- `PARTITION BY quarter`: Separate rankings for Q1, Q2, Q3
- `ORDER BY revenue DESC`: Highest revenue = rank 1
- **Insight**: North dominated Q1 and Q2, but South overtook them in Q3!

---

### Part B: Quarter-over-Quarter Growth (Driver: Partner 2, Navigator: Partner 1) — 10 min

**🎯 Goal:** Calculate growth rate for each region compared to their previous quarter.

**💡 What to discuss:**
- How do we get previous quarter's revenue? (LAG function)
- Do we need PARTITION BY? (Yes - each region tracks its own growth)
- What's the growth formula? ((current - previous) / previous * 100)
- What happens in Q1? (No previous quarter - LAG returns NULL)

**Expected Output:**
```
quarter | region | revenue | prev_quarter | qoq_growth_pct
2024-Q1 | North  | 100000  | NULL         | NULL           ← No previous data
2024-Q1 | South  | 95000   | NULL         | NULL
2024-Q2 | North  | 110000  | 100000       | 10.00          ← +10% growth!
2024-Q2 | South  | 105000  | 95000        | 10.53          ← +10.53% growth!
2024-Q3 | North  | 115000  | 110000       | 4.55           ← Slowing down
2024-Q3 | South  | 120000  | 105000       | 14.29          ← Accelerating!
```

**Solution:**
```sql
SELECT 
  quarter, 
  region, 
  revenue,
  LAG(revenue) OVER (PARTITION BY region ORDER BY quarter) AS prev_quarter,
  ROUND(
    (revenue - LAG(revenue) OVER (PARTITION BY region ORDER BY quarter)) / 
    LAG(revenue) OVER (PARTITION BY region ORDER BY quarter) * 100, 
    2
  ) AS qoq_growth_pct
FROM pp8_sales
ORDER BY region, quarter;
```

**🔍 Explanation:**
- `PARTITION BY region`: Each region compares to its own previous quarter
- `LAG(revenue)`: Gets previous quarter's revenue for that region
- `ORDER BY quarter`: Ensures chronological comparison
- **Insight**: South's growth is accelerating (10.53% → 14.29%), North is slowing (10% → 4.55%)!

---

### Part C: Cumulative Analysis (Both Partners Collaborate) — 10 min

**🎯 Goal:** Show cumulative revenue per region and 2-quarter moving average.

**💡 What to discuss:**
- Running total: SUM() with ORDER BY
- Moving average: Need frame specification (ROWS BETWEEN...)
- Why PARTITION BY region? (Separate cumulative totals per region)
- 2-quarter average = current + 1 PRECEDING (not 2!)

**Expected Output:**
```
quarter | region | revenue | cumulative_revenue | moving_avg_2q
2024-Q1 | North  | 100000  | 100000             | 100000        ← Only 1 quarter
2024-Q2 | North  | 110000  | 210000             | 105000        ← Avg of Q1+Q2
2024-Q3 | North  | 115000  | 325000             | 112500        ← Avg of Q2+Q3
2024-Q1 | South  | 95000   | 95000              | 95000
2024-Q2 | South  | 105000  | 200000             | 100000
2024-Q3 | South  | 120000  | 320000             | 112500
```

**Solution:**
```sql
SELECT 
  quarter, 
  region, 
  revenue,
  SUM(revenue) OVER (
    PARTITION BY region 
    ORDER BY quarter
  ) AS cumulative_revenue,
  AVG(revenue) OVER (
    PARTITION BY region 
    ORDER BY quarter 
    ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
  ) AS moving_avg_2q
FROM pp8_sales
ORDER BY region, quarter;
```

**🔍 Explanation:**
- **Cumulative Revenue**: Running total for each region (resets per region)
- **Moving Average**: Average of current + previous quarter (smooths volatility)
- `ROWS BETWEEN 1 PRECEDING AND CURRENT ROW`: 2 quarters (1 before + current)
- **Insight**: Both regions have similar cumulative revenue (~320k), but South is trending stronger!

---

## 🎓 Paired Programming Reflection (5 min)

**Discuss with your partner:**
1. Which part was hardest? Why?
2. When did PARTITION BY matter most?
3. How did LAG() compare to frame specifications?
4. What real-world reports could use these techniques?

**Key Takeaways:**
✅ PARTITION BY creates independent calculations per group
✅ LAG() compares current row to previous row(s)
✅ Frame specifications (ROWS BETWEEN) control moving windows
✅ Window functions preserve all rows while adding analytics

**Next:** Move to `05-Real-World-Project.md` for a comprehensive project!
