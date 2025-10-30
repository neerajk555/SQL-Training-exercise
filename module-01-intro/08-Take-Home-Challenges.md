# Module 1: Take-Home Challenges (MySQL)

Three advanced exercises with multi-part problems (3–4 related queries), realistic datasets, open-ended components, and detailed solutions with trade-offs.

Tip: Use databases from `module-01-setup.sql` (`m1_intro_ecom`, `m1_intro_edu`).

---

## Take-Home 1: Customer Overview Starter
- Dataset: Use `m1_intro_ecom`.
- Parts:
  A) Return customers with a computed `full_name` and `created_at`.
  B) Count orders per customer (include customers with zero orders).
  C) Open-ended: Suggest 2 additional columns to help onboarding insights and explain why.
- Solution:
  ```sql
  USE m1_intro_ecom;

  -- A
  SELECT `customer_id`, CONCAT(`first_name`,' ',`last_name`) AS `full_name`, `created_at`
  FROM `customers`;

  -- B
  SELECT c.`customer_id`, CONCAT(c.`first_name`,' ',c.`last_name`) AS `full_name`,
         COUNT(o.`order_id`) AS `order_count`
  FROM `customers` c
  LEFT JOIN `orders` o ON o.`customer_id` = c.`customer_id`
  GROUP BY c.`customer_id`, c.`first_name`, c.`last_name`;
  ```
- Trade-offs: LEFT JOIN includes new customers with zero orders; INNER JOIN would exclude them. Counting on order_id is safe since it's PK.

---

## Take-Home 2: Product Availability and Sales
- Dataset: Use `m1_intro_ecom`.
- Parts:
  A) List active products with `stock_status`.
  B) For each product, compute total units sold (only PAID orders).
  C) Open-ended: Recommend an index to speed B and justify.
- Solution:
  ```sql
  USE m1_intro_ecom;

  -- A
  SELECT `product_id`, `name`, `price`, `stock`,
         CASE WHEN `stock` > 0 THEN 'IN_STOCK' ELSE 'OUT_OF_STOCK' END AS `stock_status`
  FROM `products`
  WHERE `discontinued` = 0;

  -- B
  SELECT p.`product_id`, p.`name`, SUM(oi.`quantity`) AS `units_sold`
  FROM `products` p
  JOIN `order_items` oi ON oi.`product_id` = p.`product_id`
  JOIN `orders` o ON o.`order_id` = oi.`order_id`
  WHERE o.`status` = 'PAID'
  GROUP BY p.`product_id`, p.`name`;
  ```
- Trade-offs: Filtering early on `o.status` reduces rows joined; adding index on `orders(status)` and `order_items(product_id)` helps.

---

## Take-Home 3: Education Snapshot
- Dataset: Use `m1_intro_edu`.
- Parts:
  A) Show active courses only with `course_id`, `title`.
  B) For each course, show enrollment count (include 0 for inactive—then decide to include/exclude).
  C) Open-ended: Discuss pros/cons of allowing NULL grades.
- Solution:
  ```sql
  USE m1_intro_edu;

  -- A
  SELECT `course_id`, `title`
  FROM `courses`
  WHERE `active` = 1;

  -- B (include courses with 0 enrollments)
  SELECT c.`course_id`, c.`title`, COUNT(e.`student_id`) AS `enrolled`
  FROM `courses` c
  LEFT JOIN `enrollments` e ON e.`course_id` = c.`course_id`
  GROUP BY c.`course_id`, c.`title`;
  ```
- Trade-offs: LEFT JOIN keeps all courses visible; if performance is a concern at scale, pre-aggregate enrollment counts.
