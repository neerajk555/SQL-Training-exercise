# Module 05 · Joins

Welcome to Module 05: Joins. You’ll learn to combine data across tables with INNER/LEFT/RIGHT/CROSS joins, self-joins, and patterns like anti-joins (LEFT ... IS NULL) and semi-joins (EXISTS). You’ll also tackle many-to-many relationships, ON vs WHERE nuances with outer joins, and aggregation after joins.

What’s inside
- 01-Quick-Warm-Ups.md — 5 bite-size join exercises with answers
- 02-Guided-Step-by-Step.md — 3 guided activities with checkpoints and mistakes to avoid
- 03-Independent-Practice.md — 7 exercises (easy→challenge) with full solutions
- 04-Paired-Programming.md — Collaborative 3-part activity
- 05-Real-World-Project.md — A realistic, multi-table dataset and deliverables
- 06-Error-Detective.md — 5 join debugging challenges
- 07-Speed-Drills.md — 10 quick questions with answers
- 08-Take-Home-Challenges.md — 3 advanced multi-part join scenarios

Assumptions
- MySQL 8.0+ (for window functions where used); alternatives provided when relevant.
- All activities are self-contained: each includes the CREATE/INSERT setup it needs.

Tips
- Prefer explicit JOIN ... ON syntax.
- Put row-reduction predicates in ON when preserving unmatched rows with LEFT JOIN; otherwise use WHERE.
- Beware of duplicate rows with many-to-many joins; aggregate appropriately.
