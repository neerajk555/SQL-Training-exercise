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

- Schema (single table with denormalized order data):
  ```sql
  -- Safe re-run: drop if exists to avoid conflicts
  DROP TEMPORARY TABLE IF EXISTS `pp_order_details`;

  CREATE TEMPORARY TABLE `pp_order_details` (
    `order_id` INT,
    `product_name` VARCHAR(50),
    `category` VARCHAR(50),
    `quantity` INT,
    `unit_price` DECIMAL(10,2),
    `order_date` DATE,
    `customer_name` VARCHAR(100)
  );
  INSERT INTO `pp_order_details` VALUES
  (101,'Cable','Cables',2,9.99,'2025-03-15','Alice Johnson'),
  (101,'Mouse','Accessories',1,19.99,'2025-03-15','Alice Johnson'),
  (102,'Keyboard','Accessories',1,79.99,'2025-03-16','Bob Smith'),
  (103,'Cable','Cables',5,9.99,'2025-03-17','Charlie Davis'),
  (103,'Mouse Pad','Accessories',2,6.50,'2025-03-17','Charlie Davis');
  ```

- Parts:
  - A) Calculate line totals: For each order line, compute `line_total` = `quantity * unit_price`. Display `order_id`, `product_name`, `quantity`, `unit_price`, and `line_total`.
  - B) Categorize orders: Add a computed column `order_size` with values 'LARGE' if `quantity` >= 3, otherwise 'SMALL'. Sort by `order_id` and `quantity` DESC.
  - C) Premium orders: Filter for orders where `line_total` >= 40.00 and add a `discount_eligible` column showing 'YES' for Accessories category, 'NO' for others.

  Expected outputs
  - A)
    ```
    order_id | product_name | quantity | unit_price | line_total
    101      | Cable        | 2        | 9.99       | 19.98
    101      | Mouse        | 1        | 19.99      | 19.99
    102      | Keyboard     | 1        | 79.99      | 79.99
    103      | Cable        | 5        | 9.99       | 49.95
    103      | Mouse Pad    | 2        | 6.50       | 13.00
    ```
  - B)
    ```
    order_id | product_name | quantity | order_size
    101      | Cable        | 2        | SMALL
    101      | Mouse        | 1        | SMALL
    102      | Keyboard     | 1        | SMALL
    103      | Cable        | 5        | LARGE
    103      | Mouse Pad    | 2        | SMALL
    ```
  - C)
    ```
    order_id | product_name | category    | line_total | discount_eligible
    102      | Keyboard     | Accessories | 79.99      | YES
    103      | Cable        | Cables      | 49.95      | NO
    ```

- Solutions:
  ```sql
  -- A: Calculate line totals
  SELECT `order_id`, `product_name`, `quantity`, `unit_price`,
         (`quantity` * `unit_price`) AS `line_total`
  FROM `pp_order_details`
  ORDER BY `order_id`, `product_name`;

  -- B: Categorize by order size
  SELECT `order_id`, `product_name`, `quantity`,
         CASE WHEN `quantity` >= 3 THEN 'LARGE' ELSE 'SMALL' END AS `order_size`
  FROM `pp_order_details`
  ORDER BY `order_id`, `quantity` DESC;

  -- C: Premium orders with discount eligibility
  SELECT `order_id`, `product_name`, `category`,
         (`quantity` * `unit_price`) AS `line_total`,
         CASE WHEN `category` = 'Accessories' THEN 'YES' ELSE 'NO' END AS `discount_eligible`
  FROM `pp_order_details`
  WHERE (`quantity` * `unit_price`) >= 40.00
  ORDER BY `order_id`;
  ```
