# Real-World Project — Set Operations (45–60 min)

Apply set operations to a realistic business scenario with multiple requirements and datasets.

**Project Tip:** Read the entire project first. Plan your queries. Test incrementally. Set operations shine when combining and comparing multiple data sources!

---

## Project: Enterprise Data Integration & Reconciliation

### Company Background
TechMerge Corp recently acquired two smaller companies (Alpha Systems and Beta Solutions). You're the data analyst tasked with integrating customer databases, identifying overlaps, reconciling discrepancies, and preparing a unified customer master for the CRM system.

### Business Problem
The three companies have separate customer databases with different structures and coverage. Before full integration, management needs:
1. Total unique customer count across all three companies
2. Customers shared between companies (potential duplicate accounts)
3. Company-exclusive customers (for retention campaigns)
4. Data quality issues (mismatched information for same customer)
5. Unified customer master with source tracking

### Database Setup
```sql
-- TechMerge (parent company) customers
DROP TABLE IF EXISTS rw7_techmerge_customers;
CREATE TABLE rw7_techmerge_customers (
  customer_id INT PRIMARY KEY,
  email VARCHAR(100),
  company_name VARCHAR(100),
  industry VARCHAR(50),
  annual_revenue DECIMAL(12,2),
  signup_date DATE
);
INSERT INTO rw7_techmerge_customers VALUES
(1001,'acme@example.com','Acme Corp','Manufacturing',5000000,'2023-01-15'),
(1002,'globex@example.com','Globex Inc','Technology',8000000,'2023-03-20'),
(1003,'initech@example.com','Initech','Finance',3000000,'2023-05-10'),
(1004,'umbrella@example.com','Umbrella Co','Healthcare',6000000,'2023-07-01'),
(1005,'wayne@example.com','Wayne Enterprises','Retail',12000000,'2023-09-15');

-- Alpha Systems customers
DROP TABLE IF EXISTS rw7_alpha_customers;
CREATE TABLE rw7_alpha_customers (
  customer_id INT PRIMARY KEY,
  email VARCHAR(100),
  company_name VARCHAR(100),
  industry VARCHAR(50),
  annual_revenue DECIMAL(12,2),
  signup_date DATE
);
INSERT INTO rw7_alpha_customers VALUES
(2001,'acme@example.com','Acme Corporation','Manufacturing',5000000,'2022-06-01'),
(2002,'stark@example.com','Stark Industries','Technology',15000000,'2022-08-15'),
(2003,'oscorp@example.com','Oscorp','Biotech',7000000,'2022-10-20'),
(2004,'initech@example.com','Initech LLC','Financial Services',3200000,'2022-11-30'),
(2005,'cyberdyne@example.com','Cyberdyne Systems','Technology',9000000,'2023-01-10');

-- Beta Solutions customers
DROP TABLE IF EXISTS rw7_beta_customers;
CREATE TABLE rw7_beta_customers (
  customer_id INT PRIMARY KEY,
  email VARCHAR(100),
  company_name VARCHAR(100),
  industry VARCHAR(50),
  annual_revenue DECIMAL(12,2),
  signup_date DATE
);
INSERT INTO rw7_beta_customers VALUES
(3001,'globex@example.com','Globex Inc','Tech',8500000,'2021-05-15'),
(3002,'umbrella@example.com','Umbrella Corporation','Pharma',6200000,'2021-07-20'),
(3003,'tyrell@example.com','Tyrell Corp','Robotics',11000000,'2021-09-10'),
(3004,'weyland@example.com','Weyland-Yutani','Aerospace',20000000,'2021-11-05'),
(3005,'aperture@example.com','Aperture Science','Research',4000000,'2022-01-30');
```

### Deliverables

---

## Deliverable 1: Total Unique Customer Reach (10 min)

**Requirement:** Calculate total unique customers across all three companies using email as the unique identifier.

**Acceptance Criteria:**
- Return count of unique email addresses
- Handle company name variations for same email
- Document any assumptions

**Hint:** Use UNION to deduplicate emails across all three tables.

**Solution:**
```sql
-- Total unique customers by email
SELECT COUNT(DISTINCT email) AS unique_customers
FROM (
  SELECT email FROM rw7_techmerge_customers
  UNION
  SELECT email FROM rw7_alpha_customers
  UNION
  SELECT email FROM rw7_beta_customers
) AS all_customers;
-- Result: 12 unique email addresses

-- Detailed list with earliest signup
SELECT 
  email,
  MIN(signup_date) AS first_signup
FROM (
  SELECT email, signup_date FROM rw7_techmerge_customers
  UNION ALL
  SELECT email, signup_date FROM rw7_alpha_customers
  UNION ALL
  SELECT email, signup_date FROM rw7_beta_customers
) AS all_signups
GROUP BY email
ORDER BY first_signup;
-- Shows 12 unique customers with their earliest engagement date
```

---

## Deliverable 2: Cross-Company Customer Overlap (15 min)

**Requirement:** Identify customers who exist in multiple company databases (potential duplicate accounts).

**Acceptance Criteria:**
- Show customers in 2+ databases
- Indicate which companies have their records
- Count number of systems per customer

**Hint:** Use UNION ALL with company labels, then GROUP BY email and filter with HAVING.

**Solution:**
```sql
-- Customers with records in multiple systems
SELECT 
  email,
  COUNT(*) AS system_count,
  GROUP_CONCAT(DISTINCT source ORDER BY source) AS systems
FROM (
  SELECT email, 'TechMerge' AS source FROM rw7_techmerge_customers
  UNION ALL
  SELECT email, 'Alpha' AS source FROM rw7_alpha_customers
  UNION ALL
  SELECT email, 'Beta' AS source FROM rw7_beta_customers
) AS all_records
GROUP BY email
HAVING COUNT(*) > 1
ORDER BY system_count DESC, email;

-- Results:
-- acme@example.com: 2 systems (Alpha, TechMerge)
-- globex@example.com: 2 systems (Beta, TechMerge)
-- initech@example.com: 2 systems (Alpha, TechMerge)
-- umbrella@example.com: 2 systems (Beta, TechMerge)
-- Total: 4 customers with duplicate records
```

---

## Deliverable 3: Company-Exclusive Customers (12 min)

**Requirement:** For each company, identify customers who exist ONLY in that company's database (not in the other two).

**Acceptance Criteria:**
- Three separate lists (TechMerge-only, Alpha-only, Beta-only)
- Show customer details (email, company_name, industry)
- Count per company

**Hint:** Use LEFT JOIN ... IS NULL or NOT IN for exclusion patterns.

**Solution:**
```sql
-- TechMerge-exclusive customers
SELECT 
  'TechMerge Only' AS exclusivity,
  email,
  company_name,
  industry
FROM rw7_techmerge_customers
WHERE email NOT IN (
  SELECT email FROM rw7_alpha_customers
  UNION
  SELECT email FROM rw7_beta_customers
)
ORDER BY email;
-- Result: wayne@example.com (Wayne Enterprises)

-- Alpha-exclusive customers
SELECT 
  'Alpha Only' AS exclusivity,
  email,
  company_name,
  industry
FROM rw7_alpha_customers
WHERE email NOT IN (
  SELECT email FROM rw7_techmerge_customers
  UNION
  SELECT email FROM rw7_beta_customers
)
ORDER BY email;
-- Results: cyberdyne@example.com, oscorp@example.com, stark@example.com

-- Beta-exclusive customers
SELECT 
  'Beta Only' AS exclusivity,
  email,
  company_name,
  industry
FROM rw7_beta_customers
WHERE email NOT IN (
  SELECT email FROM rw7_techmerge_customers
  UNION
  SELECT email FROM rw7_alpha_customers
)
ORDER BY email;
-- Results: aperture@example.com, tyrell@example.com, weyland@example.com

-- Combined exclusivity report
SELECT 'TechMerge Only' AS exclusivity, COUNT(*) AS customer_count FROM rw7_techmerge_customers
WHERE email NOT IN (SELECT email FROM rw7_alpha_customers UNION SELECT email FROM rw7_beta_customers)
UNION ALL
SELECT 'Alpha Only', COUNT(*) FROM rw7_alpha_customers
WHERE email NOT IN (SELECT email FROM rw7_techmerge_customers UNION SELECT email FROM rw7_beta_customers)
UNION ALL
SELECT 'Beta Only', COUNT(*) FROM rw7_beta_customers
WHERE email NOT IN (SELECT email FROM rw7_techmerge_customers UNION SELECT email FROM rw7_alpha_customers);
-- TechMerge: 1, Alpha: 3, Beta: 3 (Total exclusive: 7 out of 12)
```

---

## Deliverable 4: Data Quality Issues (15 min)

**Requirement:** Identify customers with inconsistent data across systems (different company names, industries, or revenue for same email).

**Acceptance Criteria:**
- Find emails with multiple company_name values
- Find emails with multiple industry values
- Find emails with significantly different revenue values (>10% variance)
- Flag for manual review

**Hint:** Combine all records, group by email, check for distinct counts > 1.

**Solution:**
```sql
-- Data inconsistencies for shared customers
WITH all_customer_data AS (
  SELECT email, company_name, industry, annual_revenue, 'TechMerge' AS source
  FROM rw7_techmerge_customers
  UNION ALL
  SELECT email, company_name, industry, annual_revenue, 'Alpha' AS source
  FROM rw7_alpha_customers
  UNION ALL
  SELECT email, company_name, industry, annual_revenue, 'Beta' AS source
  FROM rw7_beta_customers
),
inconsistencies AS (
  SELECT 
    email,
    COUNT(DISTINCT company_name) AS name_variants,
    COUNT(DISTINCT industry) AS industry_variants,
    MIN(annual_revenue) AS min_revenue,
    MAX(annual_revenue) AS max_revenue,
    (MAX(annual_revenue) - MIN(annual_revenue)) / MIN(annual_revenue) * 100 AS revenue_variance_pct
  FROM all_customer_data
  GROUP BY email
  HAVING COUNT(DISTINCT company_name) > 1 
     OR COUNT(DISTINCT industry) > 1 
     OR ((MAX(annual_revenue) - MIN(annual_revenue)) / MIN(annual_revenue) * 100) > 10
)
SELECT 
  i.email,
  i.name_variants,
  i.industry_variants,
  i.min_revenue,
  i.max_revenue,
  ROUND(i.revenue_variance_pct, 2) AS revenue_variance_pct,
  GROUP_CONCAT(DISTINCT a.company_name ORDER BY a.company_name SEPARATOR ' | ') AS name_variations,
  GROUP_CONCAT(DISTINCT a.industry ORDER BY a.industry SEPARATOR ' | ') AS industry_variations
FROM inconsistencies i
JOIN all_customer_data a ON i.email = a.email
GROUP BY i.email, i.name_variants, i.industry_variants, i.min_revenue, i.max_revenue, i.revenue_variance_pct
ORDER BY i.revenue_variance_pct DESC;

-- Issues found:
-- acme@example.com: "Acme Corp" vs "Acme Corporation" (name variant)
-- globex@example.com: $8M vs $8.5M (6.25% variance), "Technology" vs "Tech"
-- initech@example.com: "Initech" vs "Initech LLC", "Finance" vs "Financial Services", $3M vs $3.2M
-- umbrella@example.com: "Umbrella Co" vs "Umbrella Corporation", "Healthcare" vs "Pharma", $6M vs $6.2M
```

---

## Deliverable 5: Unified Customer Master (20 min)

**Requirement:** Create a unified customer master table with:
- Unique email (primary key)
- Best/most complete company_name (longest version)
- Standardized industry
- Highest annual_revenue (most recent estimate)
- Earliest signup_date
- Source system(s) as comma-separated list

**Acceptance Criteria:**
- One row per unique email
- Data reconciliation rules applied
- Source tracking included
- Ready for CRM import

**Solution:**
```sql
-- Unified customer master with data reconciliation
WITH all_customer_records AS (
  SELECT 
    email,
    company_name,
    industry,
    annual_revenue,
    signup_date,
    'TechMerge' AS source
  FROM rw7_techmerge_customers
  UNION ALL
  SELECT 
    email,
    company_name,
    industry,
    annual_revenue,
    signup_date,
    'Alpha' AS source
  FROM rw7_alpha_customers
  UNION ALL
  SELECT 
    email,
    company_name,
    industry,
    annual_revenue,
    signup_date,
    'Beta' AS source
  FROM rw7_beta_customers
),
master_data AS (
  SELECT 
    email,
    -- Longest company name (likely most complete)
    (SELECT company_name 
     FROM all_customer_records sub 
     WHERE sub.email = main.email 
     ORDER BY LENGTH(company_name) DESC 
     LIMIT 1) AS company_name,
    -- Most common industry (or first alphabetically if tie)
    (SELECT industry 
     FROM all_customer_records sub 
     WHERE sub.email = main.email 
     GROUP BY industry 
     ORDER BY COUNT(*) DESC, industry 
     LIMIT 1) AS industry,
    -- Highest revenue (most recent estimate)
    MAX(annual_revenue) AS annual_revenue,
    -- Earliest signup
    MIN(signup_date) AS first_signup_date,
    -- All source systems
    GROUP_CONCAT(DISTINCT source ORDER BY source) AS source_systems,
    -- Number of systems
    COUNT(DISTINCT source) AS system_count
  FROM all_customer_records main
  GROUP BY email
)
-- 📚 Note: ROW_NUMBER() is a window function covered in Module 8 (next module)
-- For this module, you can use a simpler sequential ID or auto-increment approach
SELECT 
  ROW_NUMBER() OVER (ORDER BY email) AS master_customer_id,  -- Preview of Module 8
  email,
  company_name,
  industry,
  annual_revenue,
  first_signup_date,
  source_systems,
  system_count,
  CASE 
    WHEN system_count > 1 THEN 'Deduplicate'
    ELSE 'Clean'
  END AS data_quality_status
FROM master_data
ORDER BY system_count DESC, email;

-- Result: 12 rows (unified master)
-- 4 customers flagged for deduplication
-- 8 customers with clean single-source data
```

---

## Bonus Objectives

### Bonus 1: Revenue Impact Analysis
Calculate total potential revenue if duplicate accounts are consolidated (sum max revenue per customer).

```sql
-- Revenue impact of deduplication
WITH all_records AS (
  SELECT email, annual_revenue FROM rw7_techmerge_customers
  UNION ALL
  SELECT email, annual_revenue FROM rw7_alpha_customers
  UNION ALL
  SELECT email, annual_revenue FROM rw7_beta_customers
)
SELECT 
  SUM(revenue) AS current_total_revenue,
  (SELECT SUM(max_rev) FROM (
    SELECT email, MAX(annual_revenue) AS max_rev 
    FROM all_records 
    GROUP BY email
  ) AS dedupe) AS deduplicated_revenue,
  SUM(revenue) - (SELECT SUM(max_rev) FROM (
    SELECT email, MAX(annual_revenue) AS max_rev 
    FROM all_records 
    GROUP BY email
  ) AS dedupe) AS overcount_amount
FROM (SELECT annual_revenue AS revenue FROM all_records) AS totals;
```

### Bonus 2: Industry Distribution
Show customer count by industry in the unified master.

```sql
SELECT 
  industry,
  COUNT(DISTINCT email) AS customer_count,
  ROUND(COUNT(DISTINCT email) * 100.0 / (SELECT COUNT(DISTINCT email) FROM (
    SELECT email FROM rw7_techmerge_customers
    UNION
    SELECT email FROM rw7_alpha_customers
    UNION
    SELECT email FROM rw7_beta_customers
  ) AS total), 2) AS percentage
FROM (
  SELECT email, industry FROM rw7_techmerge_customers
  UNION ALL
  SELECT email, industry FROM rw7_alpha_customers
  UNION ALL
  SELECT email, industry FROM rw7_beta_customers
) AS all_industries
GROUP BY industry
ORDER BY customer_count DESC;
```

---

## Evaluation Rubric

| Criteria | Excellent (9-10) | Good (7-8) | Needs Work (5-6) |
|----------|------------------|------------|------------------|
| **Query Correctness** | All deliverables return accurate results | Minor errors in 1-2 deliverables | Significant errors or incomplete |
| **Set Operations** | Proper use of UNION/INTERSECT/EXCEPT patterns | Mostly correct with some inefficiencies | Incorrect operation choices |
| **Data Quality** | Comprehensive inconsistency detection | Basic inconsistency detection | Missing key quality checks |
| **Code Quality** | Well-commented, efficient, readable | Functional but lacks comments | Hard to follow or inefficient |
| **Business Value** | Clear insights and recommendations | Basic reporting without analysis | Raw data without interpretation |

---

## Model Solution Summary

**Key Findings:**
1. **Total Reach**: 12 unique customers across 3 systems
2. **Duplicates**: 4 customers (33%) exist in multiple systems
3. **Exclusive**: 7 customers (58%) are single-system
4. **Data Quality**: All 4 duplicate customers have inconsistencies requiring review
5. **Revenue**: Proper deduplication prevents $34.9M overcounting

**Recommendations:**
1. Merge duplicate accounts for acme, globex, initech, umbrella
2. Standardize company names and industry classifications
3. Implement master data management process going forward
4. Use email as primary unique identifier across systems
5. Regular reconciliation audits to catch new duplicates

**Technical Notes:**
- UNION for deduplication, UNION ALL for counting touches
- NOT IN pattern effective for exclusion with proper NULL handling
- GROUP BY with HAVING useful for multi-system detection
- Indexes on email column critical for performance at scale

---

**Project Complete!** You've integrated multi-source data using set operations, identified data quality issues, and created a unified master. Excellent work!

**Next Step:** Move to `06-Error-Detective.md` to practice debugging set operation queries.
