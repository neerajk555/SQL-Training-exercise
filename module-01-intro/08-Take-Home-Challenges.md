# Module 1: Take-Home Challenges (MySQL)

## 📋 Before You Start

### Learning Objectives
By completing these take-home challenges, you will:
- Apply multiple concepts to complex, multi-part problems
- Practice working with realistic datasets and edge cases
- Develop problem-solving skills for open-ended requirements
- Build confidence tackling advanced scenarios independently
- Learn to evaluate trade-offs in different solution approaches

### Challenge Characteristics
**What Makes These "Take-Home":**
- **Longer time commitment**: 45-60 minutes per challenge
- **Multi-part problems**: 3-4 related queries that build on each other
- **Open-ended components**: Require creativity and decision-making
- **Realistic complexity**: Edge cases, NULLs, and ambiguous requirements
- **Trade-offs**: Multiple valid approaches with different pros/cons

### How to Approach
**Recommended Process:**
1. **Read entire challenge** before writing any SQL (10 min)
2. **Plan your approach** - sketch out queries on paper (5 min)
3. **Complete parts in order** - they often build on each other (30-35 min)
4. **Test thoroughly** - verify edge cases and NULL handling (5 min)
5. **Review solutions** - compare approaches and understand trade-offs (5-10 min)

**Success Tips:**
- ✅ Take breaks - these require sustained focus
- ✅ Don't rush - thorough beats fast
- ✅ Test edge cases deliberately (NULL, empty, duplicates)
- ✅ Compare your solution with provided one
- ✅ Understand WHY alternative approaches exist

**Beginner Tip:** These are challenging by design! If stuck for 10+ minutes, check the hints or solution. Learning from solutions is valid—study them, understand them, then try similar problems!

Tip: Use databases from `module-01-setup.sql` (`m1_intro_ecom`, `m1_intro_edu`).

---

## Take-Home Challenges

Three advanced exercises with multi-part problems (3–4 related queries), realistic datasets, open-ended components, and detailed solutions with trade-offs.

---

## Take-Home 1: Customer Data Enrichment
- Dataset: Use `m1_intro_ecom`.
- Parts:
  A) Return customers with a computed `full_name` (first + last) and `created_at`.
  B) Add computed columns: `account_age_days` (days since created_at until '2025-03-31') and `email_status` ('HAS_EMAIL' if email exists, 'MISSING' if NULL).
  C) Filter for customers created in March 2025 AND sort by most recent first.
  D) Open-ended: Suggest 2 additional columns to help customer onboarding insights and explain why.
- Solution:
  ```sql
  USE m1_intro_ecom;

  -- A
  SELECT `customer_id`, CONCAT(`first_name`,' ',`last_name`) AS `full_name`, `created_at`
  FROM `customers`;

  -- B
  SELECT `customer_id`, CONCAT(`first_name`,' ',`last_name`) AS `full_name`, `created_at`,
         DATEDIFF('2025-03-31', `created_at`) AS `account_age_days`,
         CASE WHEN `email` IS NULL THEN 'MISSING' ELSE 'HAS_EMAIL' END AS `email_status`
  FROM `customers`;

  -- C
  SELECT `customer_id`, CONCAT(`first_name`,' ',`last_name`) AS `full_name`, `created_at`,
         DATEDIFF('2025-03-31', `created_at`) AS `account_age_days`,
         CASE WHEN `email` IS NULL THEN 'MISSING' ELSE 'HAS_EMAIL' END AS `email_status`
  FROM `customers`
  WHERE `created_at` >= '2025-03-01' AND `created_at` < '2025-04-01'
  ORDER BY `created_at` DESC;
  ```
- Trade-offs: DATEDIFF provides numeric days for easy comparison. CASE expressions are readable for status fields. Date range filtering is efficient with proper indexes.

---

## Take-Home 2: Product Catalog Analysis
- Dataset: Use `m1_intro_ecom`.
- Parts:
  A) List active products with `stock_status` ('IN_STOCK' or 'OUT_OF_STOCK').
  B) Add a `price_category` column: 'BUDGET' for price < 20, 'STANDARD' for 20-50, 'PREMIUM' for > 50.
  C) Filter for Accessories category only, show products that are either out of stock OR priced > $50.
  D) Open-ended: Recommend how to identify products needing restocking and explain your criteria.
- Solution:
  ```sql
  USE m1_intro_ecom;

  -- A
  SELECT `product_id`, `name`, `category`, `price`, `stock`,
         CASE WHEN `stock` > 0 THEN 'IN_STOCK' ELSE 'OUT_OF_STOCK' END AS `stock_status`
  FROM `products`
  WHERE `discontinued` = 0;

  -- B
  SELECT `product_id`, `name`, `price`,
         CASE 
           WHEN `price` < 20 THEN 'BUDGET'
           WHEN `price` <= 50 THEN 'STANDARD'
           ELSE 'PREMIUM'
         END AS `price_category`
  FROM `products`
  WHERE `discontinued` = 0
  ORDER BY `price`;

  -- C
  SELECT `product_id`, `name`, `price`, `stock`,
         CASE WHEN `stock` > 0 THEN 'IN_STOCK' ELSE 'OUT_OF_STOCK' END AS `stock_status`
  FROM `products`
  WHERE `discontinued` = 0 
    AND `category` = 'Accessories' 
    AND (`stock` = 0 OR `price` > 50)
  ORDER BY `stock`, `price` DESC;
  ```
- Trade-offs: Nested CASE expressions provide clear categorization. Combining conditions with OR requires careful parentheses. Sorting by stock helps prioritize restocking needs.

---

## Take-Home 3: Course Catalog Review
- Dataset: Use `m1_intro_edu`.
- Parts:
  A) Show active courses only with `course_id`, `title`, and `credits`.
  B) Add a computed column `course_level`: 'INTRO' if title contains 'Introduction' or 'Fundamentals', 'ADVANCED' otherwise.
  C) Filter for courses with 3 or more credits, sorted by credits DESC then title ASC.
  D) Open-ended: Create a query to identify courses that might need updating (consider title keywords, credit hours, active status). Explain your criteria.
- Solution:
  ```sql
  USE m1_intro_edu;

  -- A
  SELECT `course_id`, `title`, `credits`
  FROM `courses`
  WHERE `active` = 1;

  -- B
  SELECT `course_id`, `title`, `credits`,
         CASE 
           WHEN `title` LIKE '%Introduction%' OR `title` LIKE '%Fundamentals%' 
           THEN 'INTRO'
           ELSE 'ADVANCED'
         END AS `course_level`
  FROM `courses`
  WHERE `active` = 1;

  -- C
  SELECT `course_id`, `title`, `credits`,
         CASE 
           WHEN `title` LIKE '%Introduction%' OR `title` LIKE '%Fundamentals%' 
           THEN 'INTRO'
           ELSE 'ADVANCED'
         END AS `course_level`
  FROM `courses`
  WHERE `active` = 1 AND `credits` >= 3
  ORDER BY `credits` DESC, `title` ASC;
  ```
- Trade-offs: LIKE with wildcards enables text pattern matching but can be slower on large datasets without full-text indexes. Multiple OR conditions in CASE are readable but could be refactored into a lookup table for complex categorizations.
