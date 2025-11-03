# Speed Drills — Indexes & Optimization (2 min each)

## Drill 1: Create Index
`CREATE INDEX idx_email ON users(email);`

## Drill 2: Analyze Query
`EXPLAIN SELECT * FROM products WHERE category = 'Electronics';`

## Drill 3: Composite Index
`CREATE INDEX idx_cat_price ON products(category, price);`

## Drill 4: Drop Index
`DROP INDEX idx_old ON table_name;`

## Drill 5: Show All Indexes
`SHOW INDEXES FROM products;`

## Drill 6: Unique Index
`CREATE UNIQUE INDEX idx_email ON users(email);`

## Drill 7: Prefix Index
`CREATE INDEX idx_url ON articles(url(100));`

## Drill 8: Covering Index
`CREATE INDEX idx_cover ON users(user_id, email, name);`

## Drill 9: Check Index Usage
`EXPLAIN SELECT * FROM orders WHERE customer_id = 1;`

## Drill 10: Optimize JOIN
`CREATE INDEX idx_fk ON order_items(order_id);`

