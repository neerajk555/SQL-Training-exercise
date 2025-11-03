# Independent Practice — DML Operations

## 📋 Before You Start

### Learning Objectives
Through independent practice, you will:
- Apply INSERT, UPDATE, DELETE without step-by-step guidance
- Perform bulk data operations safely
- Migrate data between tables
- Use transactions for complex multi-step changes
- Validate data modifications

### Difficulty Progression
- 🟢 **Easy (1-3)**: Single-table INSERT/UPDATE/DELETE, 10-12 minutes
- 🟡 **Medium (4-6)**: Multi-row updates, conditional logic, JOINs, 15-20 minutes
- 🔴 **Challenge (7)**: Data migration with validation and error handling, 25-30 minutes

### Problem-Solving Strategy
1. **READ** requirements carefully—understand WHAT data to change
2. **SETUP** sample data
3. **PLAN** your DML:
   - Which rows to affect? → Write WHERE clause first
   - Test with SELECT → Verify target rows
   - Write INSERT/UPDATE/DELETE → Apply changes
   - Verify results → Check affected rows
4. **USE TRANSACTIONS** for multi-step operations
5. **TRY** solving independently
6. **REVIEW** solution

### Critical Safety Guidelines
**Before ANY UPDATE or DELETE:**
1. Write and run: `SELECT * FROM table WHERE condition`
2. Verify row count matches expectations
3. Only then change SELECT to UPDATE/DELETE
4. Start with small test changes on non-production data

**Common Pitfalls:**
- ❌ Forgetting WHERE clause (affects ALL rows!)
- ❌ Not testing SELECT first (modify wrong rows)
- ❌ Updating without transaction (can't undo mistakes)
- ❌ Wrong join condition (updates wrong rows)
- ✅ Always use transactions for important changes!

**Recovery Strategy if Mistake:**
- If you used transaction: `ROLLBACK;`
- If you didn't: Restore from backup (always have backups!)
- Prevention is better than recovery!

---

Ex 1-3 (Easy): Basic INSERT, UPDATE, DELETE | Ex 4-6 (Medium): Conditional updates, bulk operations | Ex 7 (Challenge): Complex data migration with validation
