# Error Detective — Indexes & Optimization

## Error 1: Index Not Used
```sql
CREATE INDEX idx_name ON users(name);
SELECT * FROM users WHERE UPPER(name) = 'ALICE';
```
**Issue:** Function on indexed column prevents index use.  
**Fix:** `SELECT * FROM users WHERE name = 'Alice'` or create functional index.

## Error 2: Wrong Column Order
```sql
CREATE INDEX idx_date_customer ON orders(order_date, customer_id);
SELECT * FROM orders WHERE customer_id = 1 AND order_date >= '2025-01-01';
```
**Issue:** Index not fully utilized (customer_id is second column).  
**Fix:** `CREATE INDEX idx_customer_date ON orders(customer_id, order_date);`

## Error 3: Over-Indexing
```sql
CREATE INDEX idx1 ON products(category);
CREATE INDEX idx2 ON products(category, price);
CREATE INDEX idx3 ON products(category, price, stock);
```
**Issue:** idx2 and idx3 make idx1 redundant.  
**Fix:** Keep only idx3 (covers all three query patterns).

## Error 4: Indexing Low-Cardinality Column
```sql
CREATE INDEX idx_status ON orders(status);
-- status only has 3 values: pending, shipped, delivered
```
**Issue:** Index not selective enough (scans large % of table).  
**Fix:** Only index if combined with high-cardinality column in composite index.

## Error 5: Missing FK Index
```sql
CREATE TABLE order_items (
  item_id INT PRIMARY KEY,
  order_id INT,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
-- No index on order_id!
```
**Issue:** JOINs on order_id will be slow.  
**Fix:** `CREATE INDEX idx_order ON order_items(order_id);`

