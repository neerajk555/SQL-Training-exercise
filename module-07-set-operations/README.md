# Module 07 · Set Operations

Welcome to Module 07: Set Operations. You'll learn to combine result sets with UNION, UNION ALL, INTERSECT (MySQL 8.0.31+), EXCEPT/MINUS patterns, and handling duplicates, column alignment, and ORDER BY placement. You'll also explore use cases like merging data sources, finding common items, and identifying differences.

## What's inside
- **01-Quick-Warm-Ups.md** — 5 bite-size set operation exercises with answers
- **02-Guided-Step-by-Step.md** — 3 guided activities with checkpoints
- **03-Independent-Practice.md** — 7 exercises: 3 Easy 🟢, 3 Medium 🟡, 1 Challenge 🔴
- **04-Paired-Programming.md** — 1 collaborative 3-part activity
- **05-Real-World-Project.md** — 1 realistic data consolidation project
- **06-Error-Detective.md** — 5 set operation debugging challenges
- **07-Speed-Drills.md** — 10 quick questions with answers
- **08-Take-Home-Challenges.md** — 3 advanced multi-part scenarios

## How to use
- MySQL 8.0+ recommended; INTERSECT requires 8.0.31+. Alternatives provided for earlier versions.
- All activities are self-contained and include setup (CREATE/INSERT).

## Tips for success
- UNION removes duplicates; UNION ALL keeps all rows (faster).
- All SELECT statements must have the same number of columns with compatible types.
- Use parentheses and ORDER BY at the end for the combined result.
- Simulate INTERSECT with INNER JOIN or EXISTS; simulate EXCEPT with LEFT JOIN ... IS NULL.

**Encouragement:** Set operations elegantly merge, compare, and contrast data sources. Master them and you'll handle multi-source analytics with ease. You've got this! 🚀
