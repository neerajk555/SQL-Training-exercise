# Guided Step-by-Step — Triggers

## Activity 1: Complete Audit System — 20 min

Build comprehensive audit logging for user management.

**Setup:**
```sql
CREATE TABLE gs14_users (user_id INT PRIMARY KEY, email VARCHAR(100), status VARCHAR(20));
CREATE TABLE gs14_user_audit (audit_id INT AUTO_INCREMENT PRIMARY KEY, user_id INT, action VARCHAR(20), old_data TEXT, new_data TEXT, timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
```

**Steps:**
1. Create AFTER INSERT trigger to log new users
2. Create AFTER UPDATE trigger to log changes
3. Create AFTER DELETE trigger to archive deletions
4. Test all operations
5. Query audit trail

---

## Activity 2: Inventory Auto-Update — 18 min

When order created, automatically deduct from inventory.

**Setup:**
```sql
CREATE TABLE gs14_inventory (product_id INT PRIMARY KEY, stock INT);
CREATE TABLE gs14_orders (order_id INT PRIMARY KEY, product_id INT, quantity INT);
```

**Steps:**
1. Create AFTER INSERT trigger on orders
2. Deduct quantity from inventory
3. Add validation to prevent overselling (use IF statement)
4. Test with sufficient and insufficient stock

**Key Learning:** Triggers can modify other tables!

