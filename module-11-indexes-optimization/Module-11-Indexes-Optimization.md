# Module 11 · Indexes & Query Optimization

Indexes speed up queries but require maintenance. Learn when and how to use them.

## Key Concepts:
```sql
-- Create index
CREATE INDEX idx_email ON users(email);
CREATE INDEX idx_name_date ON orders(customer_name, order_date);

-- Analyze query
EXPLAIN SELECT * FROM users WHERE email = 'test@example.com';

-- Drop index
DROP INDEX idx_email ON users;
```

## Best Practices:
- Index columns in WHERE, JOIN, ORDER BY
- Don't over-index (write performance suffers)
- Use composite indexes for multi-column queries
- Monitor index usage with EXPLAIN
- Regular INDEX maintenance
