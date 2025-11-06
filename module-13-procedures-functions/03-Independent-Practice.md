# Independent Practice — Procedures & Functions

## Exercise 1: Discount Calculator (Easy)

**Goal:** Create a function to calculate discounted prices based on customer tier!

**Beginner Explanation:** Different customers get different discounts (bronze=5%, silver=10%, gold=15%). A function makes this easy to use anywhere!

### Setup
```sql
DROP TABLE IF EXISTS ip13_products;
CREATE TABLE ip13_products (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(100),
  price DECIMAL(10,2)
);

INSERT INTO ip13_products VALUES
(1, 'Laptop', 1000.00),
(2, 'Mouse', 50.00),
(3, 'Keyboard', 100.00);
```

### Your Task
Create a function that accepts price and tier, returns discounted price.

### Solution

```sql
DROP FUNCTION IF EXISTS ip13_calculate_discount;

DELIMITER //
CREATE FUNCTION ip13_calculate_discount(
  price DECIMAL(10,2),
  tier VARCHAR(10)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE discount_rate DECIMAL(4,3);
  
  -- Determine discount rate based on tier
  CASE tier
    WHEN 'gold' THEN SET discount_rate = 0.15;
    WHEN 'silver' THEN SET discount_rate = 0.10;
    WHEN 'bronze' THEN SET discount_rate = 0.05;
    ELSE SET discount_rate = 0.00;  -- No discount for unknown tiers
  END CASE;
  
  -- Calculate and return discounted price
  RETURN ROUND(price * (1 - discount_rate), 2);
END //
DELIMITER ;

-- Test the function
SELECT ip13_calculate_discount(1000.00, 'gold') AS discounted_price;    -- $850
SELECT ip13_calculate_discount(1000.00, 'silver') AS discounted_price;  -- $900
SELECT ip13_calculate_discount(1000.00, 'bronze') AS discounted_price;  -- $950

-- Use in query
SELECT 
  product_name,
  price AS original_price,
  ip13_calculate_discount(price, 'gold') AS gold_price,
  ip13_calculate_discount(price, 'silver') AS silver_price,
  ip13_calculate_discount(price, 'bronze') AS bronze_price
FROM ip13_products;
```

### What You Learned
- ✅ Using CASE statements in functions
- ✅ Local variables with DECLARE
- ✅ Functions make pricing logic reusable
- ✅ One function = one place to update discount rules!

---

## Exercise 2: Inventory Management (Medium)

**Goal:** Create procedures for: add_stock, remove_stock, check_low_stock with validation!

**Beginner Explanation:** Inventory management needs careful validation - can't have negative stock, need to track low inventory, must handle errors gracefully.

### Setup
```sql
DROP TABLE IF EXISTS ip13_inventory;
CREATE TABLE ip13_inventory (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(100),
  stock_quantity INT CHECK (stock_quantity >= 0),
  min_stock_level INT DEFAULT 10
);

INSERT INTO ip13_inventory VALUES
(1, 'Laptop', 50, 10),
(2, 'Mouse', 200, 50),
(3, 'Keyboard', 5, 20);  -- This is below minimum!
```

### Your Task
Create three procedures with proper validation.

### Solution

**Procedure 1: Add Stock**
```sql
DROP PROCEDURE IF EXISTS ip13_add_stock;

DELIMITER //
CREATE PROCEDURE ip13_add_stock(
  IN p_product_id INT,
  IN p_quantity INT,
  OUT p_message VARCHAR(255)
)
BEGIN
  DECLARE current_stock INT;
  
  -- Validate positive quantity
  IF p_quantity <= 0 THEN
    SET p_message = 'Error: Quantity must be positive';
  ELSE
    -- Check if product exists
    SELECT stock_quantity INTO current_stock
    FROM ip13_inventory
    WHERE product_id = p_product_id;
    
    IF current_stock IS NULL THEN
      SET p_message = 'Error: Product not found';
    ELSE
      -- Add stock
      UPDATE ip13_inventory
      SET stock_quantity = stock_quantity + p_quantity
      WHERE product_id = p_product_id;
      
      SET p_message = CONCAT('Success: Added ', p_quantity, ' units. New stock: ', current_stock + p_quantity);
    END IF;
  END IF;
END //
DELIMITER ;

-- Test
CALL ip13_add_stock(1, 20, @msg);
SELECT @msg;
```

**Procedure 2: Remove Stock**
```sql
DROP PROCEDURE IF EXISTS ip13_remove_stock;

DELIMITER //
CREATE PROCEDURE ip13_remove_stock(
  IN p_product_id INT,
  IN p_quantity INT,
  OUT p_message VARCHAR(255)
)
BEGIN
  DECLARE current_stock INT;
  
  -- Validate positive quantity
  IF p_quantity <= 0 THEN
    SET p_message = 'Error: Quantity must be positive';
  ELSE
    -- Get current stock
    SELECT stock_quantity INTO current_stock
    FROM ip13_inventory
    WHERE product_id = p_product_id;
    
    IF current_stock IS NULL THEN
      SET p_message = 'Error: Product not found';
    ELSEIF current_stock < p_quantity THEN
      SET p_message = CONCAT('Error: Insufficient stock. Available: ', current_stock);
    ELSE
      -- Remove stock
      UPDATE ip13_inventory
      SET stock_quantity = stock_quantity - p_quantity
      WHERE product_id = p_product_id;
      
      SET p_message = CONCAT('Success: Removed ', p_quantity, ' units. New stock: ', current_stock - p_quantity);
    END IF;
  END IF;
END //
DELIMITER ;

-- Test
CALL ip13_remove_stock(1, 10, @msg);
SELECT @msg;

-- Test error case
CALL ip13_remove_stock(1, 1000, @msg);
SELECT @msg;
```

**Procedure 3: Check Low Stock**
```sql
DROP PROCEDURE IF EXISTS ip13_check_low_stock;

DELIMITER //
CREATE PROCEDURE ip13_check_low_stock()
BEGIN
  -- Return all products below minimum stock level
  SELECT 
    product_id,
    product_name,
    stock_quantity AS current_stock,
    min_stock_level,
    (min_stock_level - stock_quantity) AS units_needed
  FROM ip13_inventory
  WHERE stock_quantity < min_stock_level
  ORDER BY (min_stock_level - stock_quantity) DESC;
  
  -- Also return count
  SELECT COUNT(*) AS low_stock_count
  FROM ip13_inventory
  WHERE stock_quantity < min_stock_level;
END //
DELIMITER ;

-- Test
CALL ip13_check_low_stock();
```

### What You Learned
- ✅ **Input validation** before modifying data
- ✅ **Error handling** with meaningful messages
- ✅ **Multiple validations** (exists? positive? sufficient stock?)
- ✅ **Defensive programming** - check everything!
- ✅ Procedures can return **multiple result sets**

---

## Exercise 3: Report Generator (Hard)

**Goal:** Create a comprehensive sales report procedure!

**Beginner Explanation:** Business reports need to aggregate data from multiple angles. This procedure generates a complete sales summary with multiple result sets!

### Setup
```sql
DROP TABLE IF EXISTS ip13_sales;
CREATE TABLE ip13_sales (
  sale_id INT PRIMARY KEY,
  product_name VARCHAR(100),
  category VARCHAR(50),
  quantity INT,
  unit_price DECIMAL(10,2),
  sale_date DATE
);

INSERT INTO ip13_sales VALUES
(1, 'Laptop', 'Electronics', 2, 1000.00, '2024-01-15'),
(2, 'Mouse', 'Electronics', 10, 25.00, '2024-01-15'),
(3, 'Desk', 'Furniture', 1, 500.00, '2024-01-16'),
(4, 'Chair', 'Furniture', 4, 150.00, '2024-01-16'),
(5, 'Laptop', 'Electronics', 1, 1000.00, '2024-01-17'),
(6, 'Monitor', 'Electronics', 3, 300.00, '2024-01-17');
```

### Your Task
Create procedure that generates: total sales, top products, revenue by category.

### Solution

```sql
DROP PROCEDURE IF EXISTS ip13_sales_report;

DELIMITER //
CREATE PROCEDURE ip13_sales_report(
  IN p_start_date DATE,
  IN p_end_date DATE
)
BEGIN
  -- Report 1: Overall Summary
  SELECT 
    'Overall Summary' AS report_section,
    COUNT(*) AS total_transactions,
    SUM(quantity) AS total_units_sold,
    SUM(quantity * unit_price) AS total_revenue,
    AVG(quantity * unit_price) AS avg_transaction_value,
    MIN(sale_date) AS first_sale_date,
    MAX(sale_date) AS last_sale_date
  FROM ip13_sales
  WHERE sale_date BETWEEN p_start_date AND p_end_date;
  
  -- Report 2: Top 5 Products by Revenue
  SELECT 
    'Top Products' AS report_section,
    product_name,
    SUM(quantity) AS units_sold,
    SUM(quantity * unit_price) AS revenue,
    COUNT(*) AS number_of_sales
  FROM ip13_sales
  WHERE sale_date BETWEEN p_start_date AND p_end_date
  GROUP BY product_name
  ORDER BY revenue DESC
  LIMIT 5;
  
  -- Report 3: Revenue by Category
  SELECT 
    'Category Performance' AS report_section,
    category,
    COUNT(*) AS transactions,
    SUM(quantity) AS units_sold,
    SUM(quantity * unit_price) AS revenue,
    ROUND(SUM(quantity * unit_price) * 100.0 / 
      (SELECT SUM(quantity * unit_price) FROM ip13_sales 
       WHERE sale_date BETWEEN p_start_date AND p_end_date), 2) AS revenue_percentage
  FROM ip13_sales
  WHERE sale_date BETWEEN p_start_date AND p_end_date
  GROUP BY category
  ORDER BY revenue DESC;
  
  -- Report 4: Daily Sales Trend
  SELECT 
    'Daily Trend' AS report_section,
    sale_date,
    COUNT(*) AS transactions,
    SUM(quantity) AS units_sold,
    SUM(quantity * unit_price) AS daily_revenue
  FROM ip13_sales
  WHERE sale_date BETWEEN p_start_date AND p_end_date
  GROUP BY sale_date
  ORDER BY sale_date;
END //
DELIMITER ;

-- Run the report
CALL ip13_sales_report('2024-01-01', '2024-12-31');
```

### Advanced Version with Temp Table

```sql
DROP PROCEDURE IF EXISTS ip13_sales_report_advanced;

DELIMITER //
CREATE PROCEDURE ip13_sales_report_advanced(
  IN p_start_date DATE,
  IN p_end_date DATE
)
BEGIN
  -- Create temporary table for calculations
  DROP TEMPORARY TABLE IF EXISTS temp_sales_calc;
  CREATE TEMPORARY TABLE temp_sales_calc AS
  SELECT 
    product_name,
    category,
    quantity,
    unit_price,
    quantity * unit_price AS line_total,
    sale_date
  FROM ip13_sales
  WHERE sale_date BETWEEN p_start_date AND p_end_date;
  
  -- Use temp table for reports (faster for multiple aggregations)
  SELECT 'Summary' AS section, 
         SUM(line_total) AS total_revenue,
         AVG(line_total) AS avg_sale
  FROM temp_sales_calc;
  
  SELECT 'By Category' AS section,
         category,
         SUM(line_total) AS revenue
  FROM temp_sales_calc
  GROUP BY category;
  
  -- Clean up
  DROP TEMPORARY TABLE temp_sales_calc;
END //
DELIMITER ;

CALL ip13_sales_report_advanced('2024-01-01', '2024-12-31');
```

### What You Learned
- ✅ **Multiple result sets** from one procedure
- ✅ **Aggregate functions** (SUM, AVG, COUNT)
- ✅ **GROUP BY** for dimensional analysis
- ✅ **Subqueries** for percentage calculations
- ✅ **Temporary tables** for complex reports
- ✅ **Date filtering** with parameters
- ✅ This is real business intelligence reporting! 📊

