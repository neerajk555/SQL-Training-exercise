# Speed Drills — Window Functions (2-3 min each)

## Drill 1: ROW_NUMBER vs RANK
**Q:** What's the difference between ROW_NUMBER() and RANK()?
**A:** ROW_NUMBER() always gives unique sequential numbers (1,2,3,4...). RANK() gives same rank for ties and skips next (1,2,2,4...).

## Drill 2: DENSE_RANK
**Q:** With scores [95,90,90,85], what does DENSE_RANK() return?
**A:** 1,2,2,3 (no gap after ties)

## Drill 3: PARTITION BY
**Q:** What does PARTITION BY do in a window function?
**A:** Divides result set into partitions; window function applies separately to each partition.

## Drill 4: Frame Specification
**Q:** What does ROWS BETWEEN 2 PRECEDING AND CURRENT ROW mean?
**A:** Includes the current row plus 2 rows before it (3 rows total) in the calculation.

## Drill 5: LAG() Function
**Q:** LAG(salary, 2) returns what?
**A:** The salary value from 2 rows before the current row.

## Drill 6: LEAD() Function
**Q:** LEAD(revenue, 1, 0) - what does the third parameter do?
**A:** It's the default value returned when there's no following row (e.g., last row).

## Drill 7: ORDER BY Requirement
**Q:** Which window functions REQUIRE ORDER BY in OVER()?
**A:** ROW_NUMBER(), RANK(), DENSE_RANK(), LAG(), LEAD(), and any function using frames (ROWS/RANGE).

## Drill 8: NTILE()
**Q:** NTILE(4) divides 100 rows into how many groups?
**A:** 4 groups of 25 rows each (quartiles).

## Drill 9: Window Functions vs GROUP BY
**Q:** True or False: Window functions reduce the number of rows like GROUP BY.
**A:** False. Window functions preserve all rows while adding calculated columns.

## Drill 10: Performance
**Q:** Does ORDER BY inside OVER() require sorting?
**A:** Yes, which can impact performance on large datasets. Indexes on ordered columns help.

**Score:** 8-10 = Expert, 6-7 = Proficient, <6 = Review needed

**Next:** Move to `08-Take-Home-Challenges.md`
