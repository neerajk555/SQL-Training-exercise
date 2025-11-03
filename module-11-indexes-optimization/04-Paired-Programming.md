# Paired Programming — Indexes & Optimization

## Challenge: Optimize Slow E-Commerce Queries — 40 min

**Roles:** Driver (writes code), Navigator (analyzes EXPLAIN, suggests strategies)

**Scenario:** E-commerce site with performance issues

```sql
-- Setup
DROP TABLE IF EXISTS pp11_products, pp11_orders, pp11_order_items;

CREATE TABLE pp11_products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200),
  category VARCHAR(50),
  price DECIMAL(10,2),
  stock INT
);

CREATE TABLE pp11_orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  status VARCHAR(20)
);

CREATE TABLE pp11_order_items (
  item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT,
  product_id INT,
  quantity INT,
  price DECIMAL(10,2)
);
```

**Tasks:**
1. Identify slow query: Customer order history
2. Add indexes to optimize JOINs
3. Optimize: Popular products (most ordered)
4. Verify all indexes are actually used

**Discuss:** Which indexes help? Which are redundant?

