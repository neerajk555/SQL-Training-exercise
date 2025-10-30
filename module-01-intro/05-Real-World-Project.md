# Module 1: Real-World Project — TinyCart Analytics (MySQL)

Estimated Time: 45–60 minutes

Use the e-commerce schema from `module-01-setup.sql` (database: `m1_intro_ecom`). This provides products, customers, orders, and order_items tables with realistic edge cases (NULL emails, discontinued items, out-of-stock products).

---

## Company Background
TinyCart is a small e-commerce startup building its first analytics dashboards.

## Business Problem
Create initial analytical views for products, customers, and orders to guide basic operations and onboarding insights.

## Deliverables (with Acceptance Criteria)
1) Active products list with stock status
- Include: `product_id`, `name`, `category`, `price`, `stock`, `stock_status` ('IN_STOCK' when `stock`>0 else 'OUT_OF_STOCK')
- Exclude discontinued
- Sorted by `category`, then `name`

2) Customer signup recency
- Columns: `customer_id`, full name, `created_at`, `is_recent` (created within last 60 days of '2025-03-31')

3) Order revenue by order
- For PAID orders only, compute per-order total using `order_items.unit_price * quantity`

4) Bonus: Top categories by revenue
- Aggregate revenue by product category for PAID orders

## Evaluation Rubric
- Correctness (50%), Readability (20%), Edge Cases (15%), Performance Notes (15%)

---

## Model Solutions (MySQL)
```sql
USE m1_intro_ecom;

-- 1) Active products with stock status
SELECT `product_id`, `name`, `category`, `price`, `stock`,
       CASE WHEN `stock` > 0 THEN 'IN_STOCK' ELSE 'OUT_OF_STOCK' END AS `stock_status`
FROM `products`
WHERE `discontinued` = 0
ORDER BY `category`, `name`;

-- 2) Customer signup recency (reference date 2025-03-31)
SELECT `customer_id`, CONCAT(`first_name`,' ',`last_name`) AS `full_name`, `created_at`,
       CASE WHEN `created_at` >= DATE_SUB('2025-03-31', INTERVAL 60 DAY)
            THEN 'RECENT' ELSE 'NOT_RECENT' END AS `is_recent`
FROM `customers`;

-- 3) Order revenue by order (PAID only)
SELECT o.`order_id`, SUM(oi.`quantity` * oi.`unit_price`) AS `order_total`
FROM `orders` o
JOIN `order_items` oi ON oi.`order_id` = o.`order_id`
WHERE o.`status` = 'PAID'
GROUP BY o.`order_id`;

-- 4) Bonus: Top categories by revenue (PAID)
SELECT p.`category`, SUM(oi.`quantity` * oi.`unit_price`) AS `category_revenue`
FROM `orders` o
JOIN `order_items` oi ON oi.`order_id` = o.`order_id`
JOIN `products` p ON p.`product_id` = oi.`product_id`
WHERE o.`status` = 'PAID'
GROUP BY p.`category`
ORDER BY `category_revenue` DESC;
```

## Performance Notes
- For larger data, indexes on `orders(status)`, `order_items(order_id)`, and `order_items(product_id)` help.
- Consider composite indexes aligned with common joins and filters.
