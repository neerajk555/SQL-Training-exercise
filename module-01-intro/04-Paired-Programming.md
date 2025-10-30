# Module 1: Paired Programming (MySQL)

One collaborative activity designed for 30 minutes. Includes driver/navigator roles, schema, progressive parts (A/B/C), role-switching points, collaboration tips, and complete solutions.

---

## Activity: Order Totals Walkthrough
- Roles:
  - Driver: Types SQL, verifies outputs
  - Navigator: Reads requirements, checks logic, suggests tests
- Role-Switch Points: Switch after Part A and again after Part B.
- Collaboration Tips: Talk through join keys, verify arithmetic, and check for duplicate rows.

- Schema (2 tables):
  ```sql
  CREATE TEMPORARY TABLE `products` (
    `product_id` INT,
    `name` VARCHAR(50),
    `category` VARCHAR(50),
    `price` DECIMAL(10,2)
  );
  CREATE TEMPORARY TABLE `orders` (
    `order_id` INT,
    `product_id` INT,
    `quantity` INT
  );
  INSERT INTO `products` VALUES
  (1,'Cable','Cables',9.99),(2,'Mouse','Accessories',19.99),(3,'Keyboard','Accessories',79.99);
  INSERT INTO `orders` VALUES
  (101,1,2),(101,2,1),(102,3,1);
  ```

- Parts:
  - A) List all orders with product name and line total (`quantity * price`).
  - B) Add order totals per `order_id`.
  - C) Return only orders with totals >= 50.00.

- Solutions:
  ```sql
  -- A
  SELECT o.`order_id`, p.`name`, o.`quantity`, (o.`quantity` * p.`price`) AS `line_total`
  FROM `orders` o
  JOIN `products` p ON p.`product_id` = o.`product_id`;

  -- B
  SELECT o.`order_id`, SUM(o.`quantity` * p.`price`) AS `order_total`
  FROM `orders` o
  JOIN `products` p ON p.`product_id` = o.`product_id`
  GROUP BY o.`order_id`;

  -- C
  SELECT t.`order_id`, t.`order_total`
  FROM (
    SELECT o.`order_id`, SUM(o.`quantity` * p.`price`) AS `order_total`
    FROM `orders` o
    JOIN `products` p ON p.`product_id` = o.`product_id`
    GROUP BY o.`order_id`
  ) t
  WHERE t.`order_total` >= 50.00;
  ```
