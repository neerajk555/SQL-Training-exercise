# Module 05 · Joins

Welcome to Module 05: Joins. You’ll learn to combine data across tables with INNER/LEFT/RIGHT/CROSS joins, self-joins, and patterns like anti-joins (LEFT ... IS NULL) and semi-joins (EXISTS). You’ll also tackle many-to-many relationships, ON vs WHERE nuances with outer joins, and aggregation after joins.

## What's inside
- **01-Quick-Warm-Ups.md** — 5 bite-size join exercises (5-10 min each) with answers
- **02-Guided-Step-by-Step.md** — 3 guided activities with checkpoints (15-20 min each)
- **03-Independent-Practice.md** — 7 exercises: 3 Easy 🟢, 3 Medium 🟡, 1 Challenge 🔴
- **04-Paired-Programming.md** — 1 collaborative 3-part activity (30 min)
- **05-Real-World-Project.md** — 1 realistic multi-table project (45-60 min)
- **06-Error-Detective.md** — 5 join debugging challenges
- **07-Speed-Drills.md** — 10 quick questions (2-3 min each) with answers
- **08-Take-Home-Challenges.md** — 3 advanced multi-part join scenarios

## How to use
- MySQL 8.0+ recommended; alternatives provided when relevant.
- All activities are self-contained: each includes the CREATE/INSERT setup it needs.
- Time estimates are guides—take what you need to understand the concepts!

## Tips for success
- Prefer explicit JOIN ... ON syntax.
- Put row-reduction predicates in ON when preserving unmatched rows with LEFT JOIN; otherwise use WHERE.
- Beware of duplicate rows with many-to-many joins; aggregate appropriately.

**Encouragement:** Joins unlock the power of relational databases! Start with INNER JOIN, then explore LEFT JOIN. You've got this! 🚀
