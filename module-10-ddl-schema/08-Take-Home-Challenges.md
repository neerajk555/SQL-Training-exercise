# Take-Home Challenges — DDL & Schema Design

Advanced challenges for deeper practice. Research and experiment!

---

## Challenge 1: Schema Migration Strategy

**Task:** Design a migration from a poorly designed schema to a normalized one.

**Bad Schema:**
```sql
CREATE TABLE bad_orders (
  order_id INT PRIMARY KEY,
  customer_name VARCHAR(100),
  customer_email VARCHAR(100),
  product_names TEXT,  -- Comma-separated!
  prices TEXT,  -- Comma-separated!
  quantities TEXT  -- Comma-separated!
);
```

**Your Mission:**
1. Design normalized schema (customers, products, orders, order_items)
2. Write ALTER/CREATE statements to build new schema
3. Write INSERT...SELECT to migrate data
4. Handle data inconsistencies

---

## Challenge 2: Multi-Tenancy Schema Design

**Task:** Design schema for SaaS app where each client (tenant) has isolated data.

**Requirements:**
- Support 1000+ tenants
- Each tenant has users, projects, tasks
- Enforce data isolation
- Optimize for tenant-specific queries

**Approaches to Research:**
1. Single database, shared schema (tenant_id in every table)
2. Single database, separate schemas per tenant
3. Separate database per tenant

Choose one and implement with explanation of trade-offs.

---

## Challenge 3: Temporal Tables (History Tracking)

**Task:** Implement a system to track all changes to a users table.

**Requirements:**
- Every UPDATE creates history record
- Query user state at any point in time
- Implement using triggers or application logic
- Compare approaches

```sql
-- Users table
CREATE TABLE users (
  user_id INT PRIMARY KEY,
  email VARCHAR(100),
  name VARCHAR(100),
  updated_at TIMESTAMP
);

-- History table design?
-- How to query historical state?
```

---

## Challenge 4: Polymorphic Associations

**Task:** Design a comments system where comments can be on posts, photos, OR videos.

**Research:**
- Single Table Inheritance
- Class Table Inheritance  
- Shared Primary Key

**Implement and test:**
```sql
-- How to structure so a comment can belong to different entity types?
-- How to maintain referential integrity?
```

---

## Challenge 5: Performance-Oriented Schema

**Task:** Design a high-performance analytics schema for billion-row dataset.

**Scenario:** E-commerce click tracking
- 100M clicks per day
- Need aggregated reports (hourly, daily, monthly)
- Real-time dashboard queries

**Considerations:**
- Partitioning strategies
- Summary tables
- Indexing strategy
- Archiving old data

---

## Challenge 6: Schema Versioning System

**Task:** Build a migration system to track schema changes over time.

**Requirements:**
```sql
CREATE TABLE schema_migrations (
  version INT PRIMARY KEY,
  description VARCHAR(255),
  applied_at TIMESTAMP,
  migration_sql TEXT
);

-- Write migrations for common operations
-- Up/down migration pairs
-- Rollback capability
```

---

## Challenge 7: Soft Delete Patterns

**Task:** Implement and compare different soft delete strategies.

**Strategies:**
1. `is_deleted` BOOLEAN flag
2. `deleted_at` TIMESTAMP (NULL = active)
3. Separate `deleted_records` archive table

**Requirements:**
- Maintain referential integrity
- Query active vs deleted easily
- Purge old deleted records
- Compare performance impact

---

**Research Tips:**
- Read database documentation on advanced features
- Study open-source project schemas (GitHub)
- Consider performance implications of each design
- Test with realistic data volumes
- Document trade-offs of your choices