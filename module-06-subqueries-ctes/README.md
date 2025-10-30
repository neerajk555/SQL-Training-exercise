# Module 06 · Subqueries & CTEs

Welcome to Module 06: Subqueries & CTEs. You’ll learn scalar, row, and table subqueries; correlated vs non-correlated patterns; EXISTS/NOT EXISTS vs IN/NOT IN; derived tables; CTEs for readability; and recursive CTEs for hierarchies and sequences.

What’s inside
- 01-Quick-Warm-Ups.md — 5 bite-size subquery/CTE exercises with answers
- 02-Guided-Step-by-Step.md — 3 guided activities with checkpoints and pitfalls
- 03-Independent-Practice.md — 7 exercises (easy→challenge) with full solutions
- 04-Paired-Programming.md — Collaborative 3-part activity
- 05-Real-World-Project.md — A realistic dataset and deliverables
- 06-Error-Detective.md — 5 debugging challenges
- 07-Speed-Drills.md — 10 quick questions with answers
- 08-Take-Home-Challenges.md — 3 advanced multi-part scenarios

Assumptions
- MySQL 8.0+ (CTEs and recursive CTEs supported). Where helpful, alternatives are suggested.
- All activities are self-contained and include setup (CREATE/INSERT).

Tips
- Prefer EXISTS/NOT EXISTS for semi/anti-joins, especially with NULLs.
- Use derived tables or CTEs to stage complex logic, then filter/order outside.
- With recursive CTEs, always include a clear termination condition.
