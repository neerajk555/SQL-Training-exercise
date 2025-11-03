# Paired Programming — Set Operations (30 min)

Work with a partner on this collaborative activity. Switch roles at indicated points. One person is the **Driver** (types), the other is the **Navigator** (guides, reviews, suggests).

**Collaboration Tip:** Navigator should actively review each query before running. Driver should explain their thought process. Discuss trade-offs between different approaches!

---

## Activity: Multi-Channel Marketing Campaign Analysis

### Business Context
Your marketing team runs campaigns across email, SMS, and social media. You need to analyze overlap, unique reach, and total engagement to optimize budget allocation for next quarter.

### Setup (Run together before starting)
```sql
DROP TABLE IF EXISTS pp7_email_campaign;
CREATE TABLE pp7_email_campaign (
  customer_id INT PRIMARY KEY,
  email VARCHAR(100),
  opened BOOLEAN,
  clicked BOOLEAN
);
INSERT INTO pp7_email_campaign VALUES
(1,'alice@example.com',TRUE,TRUE),
(2,'bob@example.com',TRUE,FALSE),
(3,'carol@example.com',FALSE,FALSE),
(4,'dave@example.com',TRUE,TRUE),
(5,'eve@example.com',TRUE,FALSE);

DROP TABLE IF EXISTS pp7_sms_campaign;
CREATE TABLE pp7_sms_campaign (
  customer_id INT PRIMARY KEY,
  phone VARCHAR(20),
  delivered BOOLEAN,
  replied BOOLEAN
);
INSERT INTO pp7_sms_campaign VALUES
(2,'555-0102',TRUE,TRUE),
(3,'555-0103',TRUE,FALSE),
(4,'555-0104',TRUE,TRUE),
(6,'555-0106',TRUE,FALSE),
(7,'555-0107',TRUE,TRUE);

DROP TABLE IF EXISTS pp7_social_campaign;
CREATE TABLE pp7_social_campaign (
  customer_id INT PRIMARY KEY,
  social_handle VARCHAR(60),
  impression BOOLEAN,
  engagement BOOLEAN
);
INSERT INTO pp7_social_campaign VALUES
(1,'@alice_social',TRUE,TRUE),
(4,'@dave_social',TRUE,FALSE),
(5,'@eve_social',TRUE,TRUE),
(7,'@frank_social',TRUE,FALSE),
(8,'@grace_social',TRUE,TRUE);
```

---

## Part A: Channel Reach (Driver: Partner 1, Navigator: Partner 2) — 10 min

### Task
Find the total unique customer reach across all three channels. How many unique customers were contacted?

### Navigator Guiding Questions
- Should we use UNION or UNION ALL? Why?
- Do we need all columns or just customer_id?
- How do we count unique customers after combining?

### Hints
- UNION removes duplicates automatically
- Can combine three SELECTs with two UNIONs
- Count rows or use COUNT(DISTINCT)

### Solution
```sql
-- Total unique reach across all channels
SELECT COUNT(*) AS unique_customers_reached
FROM (
  SELECT customer_id FROM pp7_email_campaign
  UNION
  SELECT customer_id FROM pp7_sms_campaign
  UNION
  SELECT customer_id FROM pp7_social_campaign
) AS all_reach;
-- Result: 8 unique customers (1,2,3,4,5,6,7,8)

-- Alternative: see all customer IDs
SELECT customer_id
FROM pp7_email_campaign
UNION
SELECT customer_id FROM pp7_sms_campaign
UNION
SELECT customer_id FROM pp7_social_campaign
ORDER BY customer_id;
```

### Discussion
- Why UNION instead of UNION ALL? *(Want unique count, not total sends)*
- What's the cost of UNION? *(Duplicate elimination requires sorting/hashing)*
- How many customers got multiple touches? *(Will find in Part B)*

**Switch Roles:** Partner 2 becomes Driver, Partner 1 becomes Navigator

---

## Part B: Multi-Touch Customers (Driver: Partner 2, Navigator: Partner 1) — 10 min

### Task
Find customers who were contacted through AT LEAST TWO channels. These high-touch customers should be prioritized for follow-up.

### Navigator Guiding Questions
- How can we find customers in multiple channels?
- Should we use INTERSECT or another approach?
- How do we count how many channels each customer was in?

### Hints
- Combine all channels with UNION ALL and GROUP BY customer_id
- Use HAVING COUNT(*) >= 2 to filter multi-touch
- Or use multiple INTERSECT operations (MySQL 8.0.31+)

### Solution
```sql
-- Customers contacted through 2+ channels
SELECT 
  customer_id,
  COUNT(*) AS channel_count,
  GROUP_CONCAT(channel ORDER BY channel) AS channels
FROM (
  SELECT customer_id, 'Email' AS channel FROM pp7_email_campaign
  UNION ALL
  SELECT customer_id, 'SMS' AS channel FROM pp7_sms_campaign
  UNION ALL
  SELECT customer_id, 'Social' AS channel FROM pp7_social_campaign
) AS all_touches
GROUP BY customer_id
HAVING COUNT(*) >= 2
ORDER BY channel_count DESC, customer_id;
-- Results:
-- Customer 4: 3 channels (Email, SMS, Social)
-- Customer 2: 2 channels (Email, SMS)
-- Customer 3: 2 channels (Email, SMS)
-- Customer 5: 2 channels (Email, Social)
-- Customer 7: 2 channels (SMS, Social)
```

### Discussion
- How many customers got 3 touches? *(1 customer: ID 4)*
- How would you find customers in ALL 3 channels using INTERSECT? *(Chain two INTERSECTs)*
- Why use UNION ALL here? *(Want to count each touch separately)*

**Switch Roles:** Partner 1 becomes Driver, Partner 2 becomes Navigator

---

## Part C: Channel-Exclusive Customers (Driver: Partner 1, Navigator: Partner 2) — 10 min

### Task
For each channel, find customers who were contacted ONLY through that channel (no other channels). This helps measure channel-exclusive reach.

### Navigator Guiding Questions
- How do we find "in channel A but not in B or C"?
- Should we use LEFT JOIN or EXCEPT?
- Do we need three separate queries?

### Hints
- Use LEFT JOIN ... IS NULL pattern for exclusion
- Need to exclude from BOTH other channels
- Can also use nested EXCEPT operations

### Solution
```sql
-- Email-only customers
SELECT customer_id, 'Email Only' AS exclusivity
FROM pp7_email_campaign
WHERE customer_id NOT IN (
  SELECT customer_id FROM pp7_sms_campaign
  UNION
  SELECT customer_id FROM pp7_social_campaign
);
-- Result: 1 (alice) - email only

-- SMS-only customers
SELECT customer_id, 'SMS Only' AS exclusivity
FROM pp7_sms_campaign
WHERE customer_id NOT IN (
  SELECT customer_id FROM pp7_email_campaign
  UNION
  SELECT customer_id FROM pp7_social_campaign
);
-- Result: 6 - SMS only

-- Social-only customers
SELECT customer_id, 'Social Only' AS exclusivity
FROM pp7_social_campaign
WHERE customer_id NOT IN (
  SELECT customer_id FROM pp7_email_campaign
  UNION
  SELECT customer_id FROM pp7_sms_campaign
);
-- Result: 8 - social only

-- Combined report
SELECT customer_id, 'Email Only' AS exclusivity
FROM pp7_email_campaign
WHERE customer_id NOT IN (
  SELECT customer_id FROM pp7_sms_campaign
  UNION
  SELECT customer_id FROM pp7_social_campaign
)
UNION ALL
SELECT customer_id, 'SMS Only' AS exclusivity
FROM pp7_sms_campaign
WHERE customer_id NOT IN (
  SELECT customer_id FROM pp7_email_campaign
  UNION
  SELECT customer_id FROM pp7_social_campaign
)
UNION ALL
SELECT customer_id, 'Social Only' AS exclusivity
FROM pp7_social_campaign
WHERE customer_id NOT IN (
  SELECT customer_id FROM pp7_email_campaign
  UNION
  SELECT customer_id FROM pp7_sms_campaign
)
ORDER BY exclusivity, customer_id;
-- Email: 1, SMS: 6, Social: 8
```

**Alternative with LEFT JOINs:**
```sql
-- Email-only with LEFT JOINs
SELECT e.customer_id, 'Email Only' AS exclusivity
FROM pp7_email_campaign e
LEFT JOIN pp7_sms_campaign s ON e.customer_id = s.customer_id
LEFT JOIN pp7_social_campaign so ON e.customer_id = so.customer_id
WHERE s.customer_id IS NULL AND so.customer_id IS NULL;
```

### Discussion
- Which approach is clearer: NOT IN or LEFT JOIN? *(NOT IN is more readable for this case)*
- How many customers got only one channel? *(3 customers: 1, 6, 8)*
- What percentage of reach is multi-channel? *(5 out of 8 = 62.5%)*

---

## Final Discussion (Both Partners) — 5 min

### Campaign Insights
1. **Total reach**: 8 unique customers across all channels
2. **Multi-touch**: 5 customers (62.5%) contacted through 2+ channels
3. **Single-touch**: 3 customers (37.5%) contacted through only one channel
4. **Triple-touch**: 1 customer (ID 4) got all three channels

### Business Recommendations
- **Customer 4**: High-engagement candidate, should be priority for sales follow-up
- **Multi-touch customers (2,3,5,7)**: Warm leads, send targeted offers
- **Single-touch customers (1,6,8)**: Consider additional channel outreach
- **Budget**: Multi-channel approach reaches 62.5% with redundancy—optimize spend

### Technical Reflection
- **UNION vs UNION ALL**: UNION for deduplication, UNION ALL for counting touches
- **NOT IN vs LEFT JOIN**: Both work; NOT IN is cleaner for multi-exclusion
- **Performance**: With proper indexes on customer_id, these queries scale well

### Extension Challenge (Optional)
Add engagement metrics: find customers who engaged (clicked/replied/engaged) across multiple channels. Hint: Filter each channel before UNION ALL.

---

**Completion Check:** You've analyzed multi-channel reach using UNION, EXCEPT patterns, and GROUP BY. Great teamwork!

**Next Step:** Move to `05-Real-World-Project.md` for a comprehensive scenario.
