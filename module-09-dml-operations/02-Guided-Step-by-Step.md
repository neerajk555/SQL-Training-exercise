# Guided Step-by-Step — DML Operations

## 📋 Before You Start

### Learning Objectives
Through these guided activities, you will:
- Update data using UPDATE with JOINs
- Archive data with INSERT...SELECT patterns
- Perform safe DELETE operations
- Use CASE in UPDATE for conditional logic
- Practice transaction safety

### Critical DML Safety Concepts
**Transaction Pattern:**
```sql
START TRANSACTION;
  -- Your INSERT/UPDATE/DELETE statements
  -- Check results with SELECT
COMMIT;  -- Or ROLLBACK if something's wrong
```

**Testing Strategy:**
1. Write SELECT to identify target rows
2. Convert to UPDATE/DELETE
3. Verify affected row count
4. Use transaction to protect data

### Execution Process
1. **Run complete setup** for each activity
2. **Follow steps** carefully—DML is permanent!
3. **Verify checkpoints** before proceeding
4. **Use transactions** for safety
5. **Study complete solution**

---

Activity 1: Product Inventory Update (17 min) - Practice UPDATE with JOIN
Activity 2: Order Archival (18 min) - INSERT...SELECT and DELETE patterns  
Activity 3: Customer Data Cleansing (19 min) - UPDATE with CASE and WHERE
