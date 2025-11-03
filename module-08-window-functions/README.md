# Module 08 · Window Functions

Welcome to Module 08: Window Functions. You'll master ROW_NUMBER(), RANK(), DENSE_RANK(), NTILE(), LAG(), LEAD(), aggregates with OVER(), partitioning, ordering, and frame specifications. Window functions are powerful for analytics without collapsing rows!

## What's inside
- **01-Quick-Warm-Ups.md** — 5 bite-size window function exercises (5-10 min each) with answers
- **02-Guided-Step-by-Step.md** — 3 guided activities with checkpoints (15-20 min each)
- **03-Independent-Practice.md** — 7 exercises: 3 Easy 🟢, 3 Medium 🟡, 1 Challenge 🔴
- **04-Paired-Programming.md** — 1 collaborative 3-part activity (30 min)
- **05-Real-World-Project.md** — 1 realistic analytics project (45-60 min)
- **06-Error-Detective.md** — 5 window function debugging challenges
- **07-Speed-Drills.md** — 10 quick questions (2-3 min each) with answers
- **08-Take-Home-Challenges.md** — 3 advanced multi-part scenarios

## How to use
- MySQL 8.0+ required (window functions introduced in 8.0). All examples tested with MySQL 8.0+.
- All activities are self-contained and include setup (CREATE/INSERT).
- Time estimates are guides—work at your own pace!

## Tips for success
- Window functions don't reduce rows (unlike GROUP BY)
- PARTITION BY creates separate "windows" within the result set
- ORDER BY within OVER() determines the calculation order
- Use ROWS/RANGE for custom frame specifications
- Common use cases: ranking, running totals, moving averages, lag/lead comparisons

**Encouragement:** Window functions unlock advanced analytics! They're essential for ranking, time series analysis, and comparative metrics. Take your time mastering them—you've got this! 🚀
