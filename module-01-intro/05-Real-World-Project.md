# Module 1: Real-World Project — TinyCart Analytics (MySQL)

## 📋 Before You Start

### Learning Objectives
By completing this real-world project, you will:
- Apply basic SELECT, WHERE, ORDER BY to business problems
- Practice translating business requirements into SQL queries
- Work with realistic e-commerce data including edge cases
- Build foundational analytical queries
- Develop problem-solving skills for data analysis

### Project Approach
**Time Allocation (45-60 minutes):**
- 📖 **10 min**: Read all deliverables, understand business goals
- 🔧 **5 min**: Run module-01-setup.sql, explore tables
- 💻 **30-35 min**: Complete deliverables one at a time
- ✅ **5-10 min**: Review solutions, verify acceptance criteria

**Work Process:**
1. **Load the database** using `module-01-setup.sql`
2. **Explore tables** with SELECT * to understand structure
3. **Complete deliverables in order** (they build your skills progressively)
4. **Verify each query** matches acceptance criteria
5. **Handle edge cases** (NULLs, discontinued items, etc.)

**Success Tips:**
- ✅ Read acceptance criteria carefully
- ✅ Test with LIMIT to preview results
- ✅ Handle NULLs explicitly with IS NULL or COALESCE
- ✅ Use ORDER BY to match expected output
- ✅ Verify row counts make sense

**Beginner Tip:** This is your first complete project! Take your time, work methodically, and don't skip testing. Real-world projects have edge cases—practice finding and handling them!

---

## Project Overview

Use the e-commerce schema from `module-01-setup.sql` (database: `m1_intro_ecom`). This provides products, customers, orders, and order_items tables with realistic edge cases (NULL emails, discontinued items, out-of-stock products).

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

3) Order export by status
- For PAID orders only, list all `order_id`, `customer_id`, `order_date`, `status` with a computed column `days_since_order` (days between order_date and '2025-03-31')
- Sort by most recent orders first

4) Bonus: Product categories summary
- Create a distinct list of all product categories from active (non-discontinued) products
- Add a computed column `category_type`: 'TECH' for categories containing 'Cables' or 'Cameras', 'OTHER' for all else
- Sort alphabetically by category

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

-- 3) Order export by status (PAID only)
SELECT `order_id`, `customer_id`, `order_date`, `status`,
       DATEDIFF('2025-03-31', `order_date`) AS `days_since_order`
FROM `orders`
WHERE `status` = 'PAID'
ORDER BY `order_date` DESC;

-- 4) Bonus: Product categories summary
SELECT DISTINCT `category`,
       CASE WHEN `category` IN ('Cables', 'Cameras') THEN 'TECH' ELSE 'OTHER' END AS `category_type`
FROM `products`
WHERE `discontinued` = 0
ORDER BY `category`;
```

## Performance Notes
- For larger data, indexes on `orders(status)` and `orders(order_date)` help with filtering and sorting.
- DISTINCT operations can be optimized with indexes on the category column.
- Date calculations like DATEDIFF are efficient for single-row operations.
