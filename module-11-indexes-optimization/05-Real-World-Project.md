# Real-World Project — Database Performance Audit

## 📋 Before You Start

### Learning Objectives
By completing this real-world project, you will:
- Apply indexing strategies to optimize query performance
- Practice using EXPLAIN to identify bottlenecks
- Work with realistic slow query scenarios
- Build composite indexes for common query patterns
- Develop performance tuning skills

### Project Approach
**Time Allocation (60-90 minutes):**
- 📖 **10 min**: Read audit requirements, understand goals
- 🔧 **15 min**: Run EXPLAIN on queries, identify issues
- 💻 **40-55 min**: Add indexes, measure improvements
- ✅ **10 min**: Review results, document optimizations

**Success Tips:**
- ✅ Use EXPLAIN before and after indexing
- ✅ Index columns in WHERE, JOIN, ORDER BY
- ✅ Consider composite indexes for multi-column queries
- ✅ Monitor query time improvements
- ✅ Balance read speed vs write overhead

---

## Project: Optimize Legacy E-Commerce Database

**Goal:** Conduct performance audit and optimize slow queries

### Phase 1: Audit Current Performance
1. Run SHOW INDEXES on all tables
2. Identify tables with no indexes on foreign keys
3. Find queries with full table scans (type: ALL in EXPLAIN)
4. Document current query times

### Phase 2: Add Strategic Indexes
1. Index all foreign key columns
2. Create composite indexes for common WHERE + ORDER BY patterns
3. Add covering indexes where beneficial
4. Test each with EXPLAIN

### Phase 3: Query Optimization
1. Rewrite N+1 query patterns
2. Add indexes for JOIN operations
3. Optimize GROUP BY and ORDER BY
4. Eliminate unnecessary columns in SELECT

### Phase 4: Measure Improvements
1. Compare EXPLAIN output before/after
2. Document query time improvements
3. Monitor index usage
4. Remove unused indexes

### Deliverable:
- Performance report with before/after metrics
- List of indexes added with justification
- Optimized versions of top 5 slowest queries

