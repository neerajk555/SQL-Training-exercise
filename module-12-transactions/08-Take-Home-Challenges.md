# Take-Home Challenges — Transactions

## 📋 Before You Start

### Learning Objectives
By completing these take-home challenges, you will:
- Apply ACID principles to complex multi-step operations
- Master isolation levels and concurrency control
- Research advanced transaction patterns (sagas, optimistic locking)
- Develop skills for handling race conditions and deadlocks
- Build confidence with commit/rollback strategies

### How to Approach
**Time Allocation (75-105 min per challenge):**
- 📖 **15 min**: Research pattern (saga, locking), understand problem
- 🎯 **15 min**: Plan transaction boundaries, identify atomicity needs
- 💻 **40-60 min**: Implement with BEGIN/COMMIT, test edge cases
- ✅ **15 min**: Verify ACID compliance, review solutions

**Success Tips:**
- ✅ Always test rollback scenarios first
- ✅ Research isolation levels (READ COMMITTED vs REPEATABLE READ)
- ✅ Use multiple terminal windows to test concurrency
- ✅ Handle errors with DECLARE handlers
- ✅ Document compensation logic for saga patterns
- ✅ Test with simultaneous transactions to expose race conditions

**⚠️ CRITICAL:** Never commit without testing rollback paths!

---

## Challenge 1: Saga Pattern Implementation
Research compensating transactions for microservices. Implement order cancellation with refunds.

## Challenge 2: Optimistic Locking
Implement versioning strategy: add `version` column, check before update, handle conflicts.

## Challenge 3: Transaction Retry Logic
Write application code to retry transactions on deadlock. Exponential backoff strategy.

## Challenge 4: Read Phenomena Analysis
Test and document: Dirty Read, Non-Repeatable Read, Phantom Read at different isolation levels.

## Challenge 5: Long-Running Transaction Optimization
Design strategy for batch processing with periodic commits to avoid locking everything.

## Challenge 6: Two-Phase Commit
Research XA transactions for distributed systems. When to use, when to avoid?

## Challenge 7: Transaction Performance
Measure performance impact of different isolation levels. Balance consistency vs throughput.

**Research:** ACID properties, MVCC, transaction logs, isolation levels, concurrency control

