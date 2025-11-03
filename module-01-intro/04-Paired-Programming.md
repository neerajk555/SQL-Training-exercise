# Module 1: Paired Programming (MySQL)

One collaborative activity designed for 30 minutes. Includes driver/navigator roles, schema, progressive parts (A/B/C), role-switching points, collaboration tips, and complete solutions.

## 📋 Before You Start

### Learning Objectives
Through paired programming, you will:
- Experience collaborative SQL problem-solving
- Learn to communicate technical decisions clearly
- Practice giving and receiving constructive feedback
- Build teamwork skills essential for professional development
- Understand how different perspectives improve solutions

### Paired Programming Setup
**Finding a Partner:**
- Classmate, study buddy, or online learning partner
- Screen sharing works great for remote pairing
- Even better: sit side-by-side sharing one computer

**Setting Up Your Environment:**
1. **One computer, two people** (or screen share)
2. **Driver controls the keyboard**—types SQL queries
3. **Navigator has the exercise open**—reads requirements, catches errors
4. **Both have MySQL connected** to the same practice database

### Understanding Roles

**🚗 Driver Responsibilities:**
- Types all SQL code
- Verbalizes thought process ("I'm adding a WHERE clause because...")
- Asks navigator for confirmation before running queries
- Focuses on syntax and typing correctly

**🧭 Navigator Responsibilities:**
- Keeps the requirements in view
- Spots errors before code runs ("Did you join on the right key?")
- Suggests tests ("Let's verify the row count matches")
- Thinks about edge cases and alternative approaches
- **Does NOT touch the keyboard** (resist the urge!)

### How to Execute This Activity

**Initial Setup (Together, 3-5 min):**
1. **Decide who starts as Driver** (you'll switch roles)
2. **Driver runs the schema setup** (CREATE TABLE + INSERT)
3. **Both verify data**: `SELECT * FROM pp_products; SELECT * FROM pp_orders;`
4. **Navigator reads Part A aloud**

**For Each Part (A, B, C):**
1. **Navigator**: Read requirements and expected output
2. **Both**: Discuss approach for 1-2 minutes
   - "What columns do we need?"
   - "Do we need JOIN, WHERE, GROUP BY?"
3. **Driver**: Types query while explaining each line
4. **Navigator**: Reviews logic, asks clarifying questions
5. **Driver**: Runs query
6. **Both**: Verify output matches requirements
7. **Compare with solution** and discuss differences
8. **SWITCH ROLES** at designated points

**Role-Switching Protocol:**
1. **Save/comment the current query** so both can refer to it
2. **Switch seats** (or pass keyboard control)
3. **New navigator reviews** what's been completed
4. **Continue with next part**

**Collaboration Best Practices:**
- 🗣️ **Talk continuously**: Silence means someone is lost
- ❓ **Ask "why" questions**: "Why use LEFT JOIN here?"
- ✋ **Pause to discuss**: Don't rush through disagreements
- 🎯 **Stay focused**: One part at a time
- 🎉 **Celebrate small wins**: Got a checkpoint? High five!

**Troubleshooting:**
- 🤔 **Stuck together?** Look at hint or solution, discuss it, then try again
- 😤 **Disagreement?** Try both approaches and compare results
- 😴 **Navigator disengaged?** Switch roles immediately
- 🏎️ **Driver going too fast?** Navigator: "Slow down, let's verify this"

---

## Activity: Order Totals Walkthrough
- Roles:
  - Driver: Types SQL, verifies outputs
  - Navigator: Reads requirements, checks logic, suggests tests
- Role-Switch Points: Switch after Part A and again after Part B.
- Collaboration Tips: Talk through join keys, verify arithmetic, and check for duplicate rows.

- Schema (2 tables):
  ```sql
  -- Safe re-run: drop if exists to avoid conflicts
  DROP TEMPORARY TABLE IF EXISTS `pp_orders`;
  DROP TEMPORARY TABLE IF EXISTS `pp_products`;

  CREATE TEMPORARY TABLE `pp_products` (
    `product_id` INT,
    `name` VARCHAR(50),
    `category` VARCHAR(50),
    `price` DECIMAL(10,2)
  );
  CREATE TEMPORARY TABLE `pp_orders` (
    `order_id` INT,
    `product_id` INT,
    `quantity` INT
  );
  INSERT INTO `pp_products` VALUES
  (1,'Cable','Cables',9.99),(2,'Mouse','Accessories',19.99),(3,'Keyboard','Accessories',79.99);
  INSERT INTO `pp_orders` VALUES
  (101,1,2),(101,2,1),(102,3,1);
  ```

- Parts:
  - A) List all orders with product name and line total (`quantity * price`).
  - B) Add order totals per `order_id`.
  - C) Return only orders with totals >= 50.00.

  Expected outputs
  - A)
    ```
    order_id | name     | quantity | line_total
    101      | Cable    | 2        | 19.98
    101      | Mouse    | 1        | 19.99
    102      | Keyboard | 1        | 79.99
    ```
  - B)
    ```
    order_id | order_total
    101      | 39.97
    102      | 79.99
    ```
  - C)
    ```
    order_id | order_total
    102      | 79.99
    ```

- Solutions:
  ```sql
  -- A
  SELECT o.`order_id`, p.`name`, o.`quantity`, (o.`quantity` * p.`price`) AS `line_total`
  FROM `pp_orders` o
  JOIN `pp_products` p ON p.`product_id` = o.`product_id`
  ORDER BY o.`order_id`, p.`name`;

  -- B
  SELECT o.`order_id`, SUM(o.`quantity` * p.`price`) AS `order_total`
  FROM `pp_orders` o
  JOIN `pp_products` p ON p.`product_id` = o.`product_id`
  GROUP BY o.`order_id`
  ORDER BY o.`order_id`;

  -- C
  SELECT t.`order_id`, t.`order_total`
  FROM (
    SELECT o.`order_id`, SUM(o.`quantity` * p.`price`) AS `order_total`
    FROM `pp_orders` o
    JOIN `pp_products` p ON p.`product_id` = o.`product_id`
    GROUP BY o.`order_id`
  ) t
  WHERE t.`order_total` >= 50.00
  ORDER BY t.`order_id`;
  ```
