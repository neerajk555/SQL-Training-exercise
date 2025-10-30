# Paired Programming: Ops Dash Summaries (30 min)

**Beginner Tip:** Collaboration strengthens learning! Talk through your logic as driver—explaining helps you think clearly. As navigator, ask "what if?" questions to explore edge cases. Both roles teach different skills. Be patient and encouraging!

Roles
- Driver: Writes SQL, narrates choices.
- Navigator: Reviews logic, checks requirements, suggests edge cases.
- Switch roles after each part.

Schema (3 tables)
```sql
DROP TABLE IF EXISTS pp4_customers;
CREATE TABLE pp4_customers (
  customer_id INT PRIMARY KEY,
  city VARCHAR(40)
);
INSERT INTO pp4_customers VALUES
(1,'Austin'),(2,'Dallas'),(3,'Austin'),(4,NULL),(5,'Seattle');

DROP TABLE IF EXISTS pp4_orders;
CREATE TABLE pp4_orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  status VARCHAR(20)
);
INSERT INTO pp4_orders VALUES
(101,1,'2025-03-01','shipped'),(102,1,'2025-03-02','processing'),(103,2,'2025-03-05','shipped'),
(104,3,'2025-03-05','cancelled'),(105,5,'2025-03-07','processing');

DROP TABLE IF EXISTS pp4_order_items;
CREATE TABLE pp4_order_items (
  order_item_id INT PRIMARY KEY,
  order_id INT,
  qty INT,
  price DECIMAL(7,2)
);
INSERT INTO pp4_order_items VALUES
(1,101,2,12.00),(2,101,1,7.99),(3,102,1,18.00),(4,103,3,4.99),(5,104,2,3.75),(6,105,NULL,15.00);
```

Part A (Driver 1): Orders per Status
- Task: List `status`, `COUNT(*)` as `cnt` ordered desc.
- Solution
```sql
SELECT status, COUNT(*) AS cnt
FROM pp4_orders
GROUP BY status
ORDER BY cnt DESC, status;
```

Part B (Driver 2): Revenue by Order
- Task: For each order, compute `revenue = SUM(qty*price)` (NULL-safe) and show `order_id`, `revenue` ordered desc.
- Solution
```sql
SELECT order_id,
       SUM(COALESCE(qty,0) * price) AS revenue
FROM pp4_order_items
GROUP BY order_id
ORDER BY revenue DESC;
```

Part C (Driver 1): City-level Order Counts (customers with NULL city grouped as 'Unknown')
- Task: Show `city_label` and `orders_cnt` grouped by city from customers who placed orders.
- Solution
```sql
SELECT COALESCE(c.city,'Unknown') AS city_label,
       COUNT(*) AS orders_cnt
FROM pp4_orders o
JOIN pp4_customers c ON c.customer_id = o.customer_id
GROUP BY COALESCE(c.city,'Unknown')
ORDER BY orders_cnt DESC, city_label;
```

Role-switching points
- Switch after each part; Navigator summarizes validation steps.

Collaboration tips
- Navigator: Ask "Do we need WHERE or HAVING? Any NULLs to normalize?"
- Driver: Narrate: "Group by key, compute aggregate, then sort and label."
