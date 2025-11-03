# Take-Home Challenges — Indexes & Optimization

## Challenge 1: Optimize Complex JOIN Query
Given a 5-table JOIN with slow performance, identify bottlenecks and add strategic indexes. Compare execution times.

## Challenge 2: Index Strategy for Time-Series Data
Design index strategy for IoT sensor data (billions of rows). Consider partitioning + indexes. Balance write vs read performance.

## Challenge 3: Covering Index Analysis
Find queries that would benefit from covering indexes. Calculate space vs performance trade-offs.

## Challenge 4: Index Maintenance Script
Write script to identify unused indexes (never used in EXPLAIN). Safely remove them in production.

## Challenge 5: Query Rewriting
Given queries that can't use indexes (functions on columns, OR conditions), rewrite to be index-friendly.

## Challenge 6: Composite Index Order Optimization
Given query patterns, determine optimal column order for composite indexes. Test with different orderings.

## Challenge 7: Full-Text Search vs Regular Indexes
Compare FULLTEXT indexes vs LIKE queries with regular indexes for text search. When to use each?

**Research:** MySQL query optimizer, index selectivity, query execution plans, performance_schema

