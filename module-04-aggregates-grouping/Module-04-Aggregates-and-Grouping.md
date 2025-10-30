# Module 4: Aggregates & Grouping

In this module, you’ll summarize data using MySQL aggregate functions and groupings. You’ll count rows, total revenue, compute averages and extremes, group by categories and dates, and use HAVING to filter groups.

What you’ll practice
- Aggregates: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`
- Grouping: `GROUP BY` one or more columns, ordering aggregated results
- Group filters: `HAVING` vs `WHERE`
- Distinct counts: `COUNT(DISTINCT col)` and its caveats
- Text and lists: `GROUP_CONCAT` (MySQL)
- Date grouping: bucketing by day/week/month with `DATE_FORMAT`, `YEAR`, `MONTH`
- NULL behavior in aggregates and grouping

Guidelines
- MySQL syntax only; use backticks for reserved words.
- Include edge cases: NULLs, zero values, duplicates, empty groups.
- Prefer filtering early in `WHERE` for performance; use `HAVING` for aggregated predicates.

Files in this module
- 01-Quick-Warm-Ups.md
- 02-Guided-Step-by-Step.md
- 03-Independent-Practice.md
- 04-Paired-Programming.md
- 05-Real-World-Project.md
- 06-Error-Detective.md
- 07-Speed-Drills.md
- 08-Take-Home-Challenges.md

Tip: When `ONLY_FULL_GROUP_BY` is enabled, every selected non-aggregated column must appear in `GROUP BY`. Keep your SELECT list aligned with your grouping.
