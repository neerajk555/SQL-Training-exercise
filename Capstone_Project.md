# 🎓 MySQL Capstone Project: CityLibrary Management System

## 📖 Project Title & Overview

Welcome to the **CityLibrary Management System** capstone project! You'll build a complete database system for a modern public library that serves thousands of patrons. This real-world scenario will test your MySQL skills across all fundamental concepts while keeping complexity manageable for beginners.

**Real-World Context:** CityLibrary is a community library that has been using paper records and spreadsheets to manage their operations. They need a proper database system to track books, members, loans, fines, and events. Your job is to design and implement this system from scratch!

---

## 🎯 Learning Objectives

By completing this capstone project, you will practice:

### Module Coverage:
- **Module 1 & 10 (Database Design & DDL)**: Create tables with appropriate data types, constraints, and relationships
- **Module 2 (SELECT Fundamentals)**: Query data with WHERE, ORDER BY, LIMIT, and basic filtering
- **Module 3 (Data Types & Functions)**: Use string, numeric, and date functions; handle NULL values
- **Module 4 (Aggregates & Grouping)**: Calculate statistics with COUNT, SUM, AVG, MIN, MAX, and GROUP BY
- **Module 5 (Joins)**: Combine data from multiple tables using INNER, LEFT, and self-joins
- **Module 6 (Subqueries & CTEs)**: Write nested queries and use WITH clauses for complex logic
- **Module 7 (Set Operations)**: Combine result sets with UNION and UNION ALL
- **Module 8 (Window Functions)**: Rank data and calculate running totals
- **Module 9 (DML Operations)**: Insert, update, and delete data safely
- **Module 11 (Indexes)**: Optimize query performance
- **Module 12 (Transactions)**: Handle multi-step operations safely
- **Module 13 (Procedures & Functions)**: Create reusable database logic
- **Module 14 (Triggers)**: Automate data integrity rules
- **Module 15 (Professional Practices)**: Write clean, maintainable SQL code

---

## 📚 Problem Statement

**The Challenge:**

CityLibrary has been struggling with manual record-keeping. Librarians spend hours searching through filing cabinets to find overdue books, calculating fines by hand, and manually tracking which books are available. Member information is scattered across different spreadsheets, and there's no easy way to see borrowing patterns or popular books.

The library director has approved funding for a digital transformation. They need a database that can:
- Track their entire book collection (15,000+ books)
- Manage 3,500 active library members
- Record book loans and returns
- Calculate and track overdue fines automatically
- Manage library events (book clubs, reading programs, workshops)
- Generate reports on popular books, active members, and revenue

**Your Mission:**

You've been hired as the database developer. Your job is to design a normalized database schema, populate it with realistic test data, and create queries and procedures that librarians can use for daily operations. The system must be reliable, efficient, and easy to maintain.

**Business Requirements:**
- Members can borrow multiple books simultaneously (limit: 5 books at a time)
- Loan period is 14 days; after that, fines accrue at $0.25 per day
- Books can have multiple copies (different physical copies of the same title)
- The library hosts events that members can register for
- Staff need quick reports: overdue books, top borrowers, popular genres, and monthly statistics

---

## 🗂️ Database Requirements

### Tables to Create:

#### 1. **members**
Stores library patron information.
- `member_id` (Primary Key, Auto-increment)
- `first_name` (Required)
- `last_name` (Required)
- `email` (Unique, Required)
- `phone` (Optional)
- `address` (Optional)
- `join_date` (Default: current date)
- `membership_type` (ENUM: 'standard', 'premium', 'student')
- `status` (ENUM: 'active', 'suspended', 'expired')

#### 2. **authors**
Information about book authors.
- `author_id` (Primary Key, Auto-increment)
- `author_name` (Required)
- `birth_year` (Optional)
- `country` (Optional)

#### 3. **books**
Catalog of unique book titles (not individual copies).
- `book_id` (Primary Key, Auto-increment)
- `title` (Required)
- `author_id` (Foreign Key → authors)
- `isbn` (Unique, Required)
- `publication_year` (Optional)
- `genre` (Required: Fiction, Non-Fiction, Science, History, Biography, Children, etc.)
- `total_copies` (Default: 1, must be > 0)

#### 4. **book_copies**
Individual physical copies of books (for tracking which specific copy is borrowed).
- `copy_id` (Primary Key, Auto-increment)
- `book_id` (Foreign Key → books)
- `copy_number` (e.g., Copy 1, Copy 2)
- `condition` (ENUM: 'excellent', 'good', 'fair', 'poor')
- `acquisition_date` (When the library got this copy)

#### 5. **loans**
Records of book borrowing transactions.
- `loan_id` (Primary Key, Auto-increment)
- `member_id` (Foreign Key → members)
- `copy_id` (Foreign Key → book_copies)
- `loan_date` (When borrowed)
- `due_date` (14 days after loan_date)
- `return_date` (NULL until returned)
- `status` (ENUM: 'active', 'returned', 'lost')

#### 6. **fines**
Overdue and damage fines.
- `fine_id` (Primary Key, Auto-increment)
- `loan_id` (Foreign Key → loans)
- `fine_amount` (Decimal, must be >= 0)
- `fine_reason` (ENUM: 'overdue', 'damage', 'lost')
- `paid` (BOOLEAN: 0 = unpaid, 1 = paid)
- `payment_date` (NULL until paid)

#### 7. **events**
Library events like book clubs, workshops, and reading programs.
- `event_id` (Primary Key, Auto-increment)
- `event_name` (Required)
- `event_date` (Required)
- `event_type` (ENUM: 'book_club', 'workshop', 'reading_program', 'author_visit')
- `max_attendees` (Optional)
- `description` (TEXT, Optional)

#### 8. **event_registrations**
Tracks which members signed up for which events.
- `registration_id` (Primary Key, Auto-increment)
- `event_id` (Foreign Key → events)
- `member_id` (Foreign Key → members)
- `registration_date` (Default: current date)
- UNIQUE constraint on (event_id, member_id) - can't register twice for same event

#### 9. **audit_log**
Tracks important database changes for security and troubleshooting.
- `log_id` (Primary Key, Auto-increment)
- `table_name` (VARCHAR)
- `action` (ENUM: 'INSERT', 'UPDATE', 'DELETE')
- `record_id` (INT)
- `changed_at` (TIMESTAMP, default: current timestamp)
- `changed_by` (VARCHAR, default: 'SYSTEM')
- `description` (TEXT)

---

## 🎯 Project Goals

Complete the following 12 tasks in order. Each builds on previous concepts.

### **BASIC LEVEL (Goals 1-4): Database Setup & Simple Queries**

---

### **Goal 1: Create the Database Schema**
**Module Focus:** DDL (Module 10), Database Design (Module 1)

**Task:** Create all 9 tables with proper data types, primary keys, foreign keys, and constraints.

**Requirements:**
- Use appropriate data types for each column
- Add PRIMARY KEY with AUTO_INCREMENT where needed
- Create FOREIGN KEY relationships with appropriate ON DELETE rules
- Add CHECK constraints for fine_amount >= 0, total_copies > 0
- Add UNIQUE constraints for email (members) and isbn (books)
- Add DEFAULT values for dates and status fields
- Use ENUM types for status fields to prevent invalid data

**Hints:**
- Start with tables that have no dependencies (members, authors, events)
- Then create tables that reference them (books → authors)
- Finally create junction/relationship tables (loans, event_registrations)
- Think about cascading: If a member is deleted, should their loans be deleted too?
  - Use `ON DELETE RESTRICT` for critical references
  - Use `ON DELETE CASCADE` for dependent records that should be removed
- Remember the syntax: `CONSTRAINT fk_name FOREIGN KEY (column) REFERENCES other_table(column) ON DELETE action`

**Common Pitfalls:**
- Creating foreign keys before the referenced table exists
- Forgetting NOT NULL on required fields
- Using wrong data types (e.g., VARCHAR for dates)
- Not setting AUTO_INCREMENT on primary keys

---

### **Goal 2: Populate with Realistic Sample Data**
**Module Focus:** DML Operations (Module 9)

**Task:** Insert comprehensive test data that represents realistic library operations.

**Requirements:**
- Insert at least 20 members with varied membership types and statuses
- Insert at least 10 authors from different countries
- Insert at least 25 books across multiple genres
- Insert at least 40 book copies (some books have multiple copies)
- Insert at least 30 loans (mix of active, returned, and overdue)
- Insert at least 10 fines (some paid, some unpaid)
- Insert at least 8 events of different types
- Insert at least 25 event registrations

**Hints:**
- Use multi-row INSERT statements for efficiency: `INSERT INTO table VALUES (...), (...), (...);`
- Make data realistic: vary join dates across past 2 years, vary loan dates across past 6 months
- Create edge cases for testing:
  - Members with no loans (newly joined)
  - Books with no copies available (all loaned out)
  - Overdue loans (loan_date more than 14 days ago, return_date is NULL)
  - Members with unpaid fines
  - Events that are full (registrations = max_attendees)
- For dates, use formats like '2024-10-15' or use functions like DATE_SUB(CURDATE(), INTERVAL 30 DAY)
- Remember the order: insert parent records before children (members before loans)

**Data Tips:**
```sql
-- Example pattern for dates spread over time
INSERT INTO members (first_name, last_name, email, join_date, membership_type, status)
VALUES 
  ('Alice', 'Johnson', 'alice.j@email.com', DATE_SUB(CURDATE(), INTERVAL 400 DAY), 'premium', 'active'),
  ('Bob', 'Smith', 'bob.smith@email.com', DATE_SUB(CURDATE(), INTERVAL 200 DAY), 'standard', 'active');
```

**Common Pitfalls:**
- Inserting child records before parent records (violates foreign keys)
- Using inconsistent date formats
- Creating impossible data (e.g., return_date before loan_date)
- Forgetting to vary the data (all loans on same date, all members named John)

---

### **Goal 3: Basic Information Retrieval Queries**
**Module Focus:** SELECT Fundamentals (Module 2), Functions (Module 3)

**Task:** Write queries to retrieve basic library information.

**Write queries for the following:**

**3a)** List all active members, showing first name, last name, and email, sorted alphabetically by last name.

**3b)** Find all books in the 'Fiction' genre published after 2010, sorted by publication year (newest first).

**3c)** Show all book copies in 'fair' or 'poor' condition that need replacement.

**3d)** List all currently active loans (not yet returned) with member names and book titles.

**3e)** Find members whose membership has expired (status = 'expired') and whose email ends with '.edu'.

**3f)** Display all loans that are currently overdue (due_date is in the past and return_date is NULL). Show member name, book title, due date, and days overdue.

**3g)** Use string functions to display member names in format "LASTNAME, Firstname" (e.g., "JOHNSON, Alice").

**3h)** Calculate how many days each book copy has been in the library (DATEDIFF between today and acquisition_date).

**Hints:**
- Use WHERE with comparison operators (=, >, <, >=, <=, !=)
- Use LIKE with wildcards for pattern matching: '%.edu' matches emails ending in .edu
- Use IS NULL to find missing data
- Combine conditions with AND, OR, NOT
- Use JOIN to combine related tables (members with loans, loans with book_copies, book_copies with books)
- Date comparison: `due_date < CURDATE()` finds past dates
- Date difference: `DATEDIFF(date1, date2)` returns days between dates
- String functions: `UPPER()`, `LOWER()`, `CONCAT()`, `SUBSTRING()`
- Format: `SELECT CONCAT(UPPER(last_name), ', ', first_name) AS full_name FROM members`

**Common Pitfalls:**
- Forgetting to JOIN tables when you need columns from multiple tables
- Using = instead of LIKE for pattern matching
- Using = NULL instead of IS NULL
- Forgetting to filter out returned loans when looking for "active" loans

---

### **Goal 4: Statistical Summaries and Aggregation**
**Module Focus:** Aggregates & Grouping (Module 4)

**Task:** Calculate statistics about library operations.

**Write queries for the following:**

**4a)** Count the total number of books in each genre. Sort by count (highest first).

**4b)** Calculate the total number of copies available for each book (show book title and total copies).

**4c)** Find the average, minimum, and maximum fine amounts for unpaid fines.

**4d)** Count how many loans each member has made (include members with 0 loans using LEFT JOIN).

**4e)** Calculate total fine revenue per month (group by year-month). Show month and total collected fines.

**4f)** Find genres with more than 5 books. Show genre and book count.

**4g)** Show the count of events by event_type, and the average number of registrations per event type.

**4h)** For each membership_type, calculate: total members, total active loans, and average loans per member.

**Hints:**
- Aggregate functions: `COUNT(*)`, `SUM(column)`, `AVG(column)`, `MIN(column)`, `MAX(column)`
- GROUP BY comes after WHERE, before ORDER BY
- Use HAVING to filter grouped results (HAVING COUNT(*) > 5)
- COUNT(*) counts all rows; COUNT(column) counts non-NULL values
- For "per member" calculations with members who have 0 loans: use LEFT JOIN, then COUNT(loan_id)
- Date grouping: `DATE_FORMAT(date_column, '%Y-%m')` extracts year-month
- Including groups with zero counts requires LEFT JOIN from the parent table
- Aggregate function syntax: `SELECT genre, COUNT(*) as book_count FROM books GROUP BY genre`

**Common Pitfalls:**
- Using WHERE to filter grouped results (use HAVING instead)
- Forgetting to include columns in GROUP BY that appear in SELECT (unless aggregated)
- Using COUNT(*) when you should use COUNT(column) to exclude NULLs
- Not using LEFT JOIN when you want to include groups with zero counts

---

### **INTERMEDIATE LEVEL (Goals 5-8): Complex Queries & Multiple Table Operations**

---

### **Goal 5: Multi-Table Joins and Analysis**
**Module Focus:** Joins (Module 5)

**Task:** Combine data from multiple tables to answer complex questions.

**Write queries for the following:**

**5a)** Create a complete loan history report showing: member name, book title, author name, loan date, return date, and loan status. Sort by loan date (most recent first).

**5b)** Find all members who have never borrowed any book (anti-join pattern).

**5c)** List books that have multiple copies, showing: book title, author name, and total number of copies.

**5d)** Show all members who currently have overdue books. Include: member name, email, book title, due date, days overdue, and fine amount (if fine exists).

**5e)** Find all events with fewer registrations than their max_attendees limit (events with available space). Show event name, event date, current registrations, and available spots.

**5f)** Create a "popular authors" report: show author name, count of their books in the collection, and total number of times their books have been borrowed.

**5g)** Find members who have borrowed books from at least 3 different genres (shows diverse reading habits).

**5h)** Self-join: Find pairs of members who live at the same address (potential family members or duplicate accounts).

**Hints:**
- Chain multiple joins: `FROM table1 JOIN table2 ON ... JOIN table3 ON ...`
- Anti-join pattern: `LEFT JOIN ... WHERE foreign_key IS NULL`
- For counts across joins, use COUNT(DISTINCT column) to avoid duplicate counting
- Self-join requires table aliases: `FROM members m1 JOIN members m2 ON m1.address = m2.address AND m1.member_id < m2.member_id`
- The condition `m1.member_id < m2.member_id` prevents showing same pair twice
- Combine joins with WHERE to filter, and with GROUP BY to aggregate
- For "at least N different" queries: use COUNT(DISTINCT column) with HAVING

**Common Pitfalls:**
- Cartesian products (forgetting ON clause in JOIN)
- Using INNER JOIN when you need LEFT JOIN (missing data when one side has no matches)
- In self-joins, showing each pair twice or showing a row matching itself
- Forgetting to use DISTINCT when counting across many-to-many relationships

---

### **Goal 6: Subqueries and Common Table Expressions**
**Module Focus:** Subqueries & CTEs (Module 6)

**Task:** Use nested queries and CTEs to solve complex problems.

**Write queries for the following:**

**6a)** Find all books that have been borrowed more times than the average borrowing frequency. (Use subquery in WHERE).

**6b)** List members who have paid more in fines than the average member. (Use subquery in WHERE).

**6c)** Show books that have never been borrowed. (Use NOT EXISTS or NOT IN).

**6d)** For each genre, find the most recently published book. (Correlated subquery or window function).

**6e)** Using a CTE, calculate the "member engagement score" (loans + event registrations) for each member, then rank members by this score.

**6f)** Create a multi-step CTE query: 
   - Step 1: Calculate total loans per book
   - Step 2: Calculate average loans per genre
   - Step 3: Find books performing below their genre average

**6g)** Use a CTE to create a "fine summary report" showing: member name, total fines, paid fines, unpaid fines, and categorize as 'Good Standing' (no unpaid fines) or 'Owes Money'.

**6h)** Find members who have borrowed ALL books by a specific author (relational division - advanced!).

**Hints:**
- Scalar subquery (returns one value): `WHERE column > (SELECT AVG(column) FROM table)`
- Table subquery: `FROM (SELECT ... FROM table) AS subquery_alias`
- EXISTS is efficient: `WHERE EXISTS (SELECT 1 FROM table2 WHERE condition)`
- NOT EXISTS for "never" queries: `WHERE NOT EXISTS (SELECT 1 FROM ...)`
- CTE syntax: `WITH cte_name AS (SELECT ...) SELECT ... FROM cte_name`
- Multiple CTEs: `WITH cte1 AS (...), cte2 AS (...) SELECT ...`
- For "most recent per group": use window function `ROW_NUMBER() OVER (PARTITION BY genre ORDER BY publication_year DESC)`
- For relational division: find members where COUNT(DISTINCT books borrowed) = COUNT(books by that author)

**Common Pitfalls:**
- Forgetting to alias subqueries in FROM clause
- Using IN with NULL values (can cause unexpected results; prefer EXISTS)
- Correlated subqueries can be slow on large datasets
- Not handling NULLs properly in calculations (use COALESCE)

---

### **Goal 7: Set Operations and Combined Results**
**Module Focus:** Set Operations (Module 7)

**Task:** Combine different result sets using UNION, INTERSECT concepts.

**Write queries for the following:**

**7a)** Create a combined contact list of all library users (members and any staff emails if you add a staff table, or just show members with type label). Use UNION to combine results.

**7b)** Find books that are both: (1) in the Fiction genre AND (2) have been borrowed more than 5 times. (Can use INTERSECT logic or JOIN with conditions).

**7c)** Generate a "library activity feed" combining recent loans (last 30 days) and recent event registrations (last 30 days). Show: activity_type ('LOAN' or 'EVENT'), member_name, details (book title or event name), activity_date. Sort by date descending.

**7d)** Find members who registered for events but never borrowed books, and separately find members who borrowed books but never registered for events. Combine with UNION ALL.

**7e)** List all books that are either: (1) in poor condition OR (2) currently overdue OR (3) marked as lost. Show book title, issue_type, and details.

**Hints:**
- UNION removes duplicates; UNION ALL keeps all rows
- All SELECT statements in UNION must have same number of columns with compatible types
- Column names come from first SELECT
- Use literals to add type labels: `SELECT email, 'Member' AS type FROM members`
- Order by date in combined results: `(SELECT ... UNION SELECT ...) ORDER BY date_column`
- For INTERSECT in MySQL 8.0.31+: use INTERSECT; in older versions use INNER JOIN or WHERE EXISTS with matching conditions
- Pattern: `SELECT columns FROM table1 WHERE condition1 UNION SELECT columns FROM table2 WHERE condition2`

**Common Pitfalls:**
- Mismatched column counts between UNION queries
- Incompatible data types between corresponding columns
- Forgetting to alias calculated/literal columns consistently
- Using ORDER BY in individual queries instead of after the final UNION

---

### **Goal 8: Window Functions for Ranking and Analytics**
**Module Focus:** Window Functions (Module 8)

**Task:** Use analytical functions to rank and analyze data.

**Write queries for the following:**

**8a)** Rank books by the number of times they've been borrowed, within each genre. Show: genre, book title, borrow count, rank within genre.

**8b)** Calculate a running total of fine revenue by payment date (for paid fines only). Show: payment_date, fine_amount, running_total.

**8c)** For each member, show their loan history with a running count of their loans. Show: member name, book title, loan date, loan_number (1st loan, 2nd loan, etc.).

**8d)** Find the top 3 most borrowed books in each genre using window functions.

**8e)** Calculate the difference in days between each member's consecutive loans (use LAG function).

**8f)** Show each event with its registration count and how it compares to the average registrations for that event_type (use AVG() OVER with PARTITION BY).

**8g)** Categorize members into quartiles based on their total borrowing activity (use NTILE(4)).

**8h)** For each month, show: total new loans, total returns, and net change in active loans (using window functions on aggregated monthly data).

**Hints:**
- Basic window function syntax: `FUNCTION() OVER (PARTITION BY column ORDER BY column)`
- PARTITION BY divides data into groups (like GROUP BY but doesn't collapse rows)
- ORDER BY within OVER defines the ordering for the function
- Ranking functions: `ROW_NUMBER()` (1,2,3), `RANK()` (1,1,3), `DENSE_RANK()` (1,1,2)
- Running totals: `SUM(column) OVER (ORDER BY date_column)`
- LAG/LEAD: `LAG(column, 1) OVER (ORDER BY date)` gets previous row's value
- To get top N per group: use `ROW_NUMBER() OVER (PARTITION BY group ORDER BY metric DESC)`, then filter WHERE row_number <= N
- NTILE(4) divides into quartiles; NTILE(100) would be percentiles

**Common Pitfalls:**
- Forgetting PARTITION BY when you want separate calculations per group
- Using window functions in WHERE clause (use a subquery or CTE instead)
- Not understanding the difference between RANK() and DENSE_RANK()
- Forgetting to ORDER BY in the OVER clause for functions like ROW_NUMBER() or LAG()

---

### **CHALLENGING LEVEL (Goals 9-12): Advanced Features & Automation**

---

### **Goal 9: Create Stored Procedures and Functions**
**Module Focus:** Procedures & Functions (Module 13)

**Task:** Build reusable database logic.

**9a)** Create a function `calculate_fine(loan_id INT)` that:
   - Takes a loan_id as input
   - Calculates overdue fine: $0.25 per day past due_date (only if not returned)
   - Returns the fine amount (DECIMAL(10,2))
   - Returns 0.00 if returned on time or not overdue

**9b)** Create a procedure `sp_return_book(p_loan_id INT)` that:
   - Sets return_date to current date
   - Sets loan status to 'returned'
   - If overdue, automatically creates a fine record
   - Uses transactions for data integrity
   - Returns success/error message via SELECT or OUT parameter

**9c)** Create a procedure `sp_register_for_event(p_member_id INT, p_event_id INT)` that:
   - Checks if event is full (registrations >= max_attendees)
   - Checks if member already registered for this event
   - If valid, inserts registration record
   - Returns appropriate success/error message

**9d)** Create a function `get_member_status(p_member_id INT)` that returns VARCHAR:
   - 'EXCELLENT' if no unpaid fines and 5+ loans
   - 'GOOD' if no unpaid fines
   - 'SUSPENDED' if unpaid fines > $10
   - 'NEW' if 0 loans

**Hints:**
- Use `DELIMITER //` before creating procedures/functions, then `DELIMITER ;` after
- Functions must RETURN a value; procedures use OUT parameters or SELECT to return data
- Function syntax: `CREATE FUNCTION name(params) RETURNS type BEGIN ... RETURN value; END`
- Procedure syntax: `CREATE PROCEDURE name(params) BEGIN ... END`
- Use `DECLARE` to create variables: `DECLARE v_count INT;`
- Use `SELECT ... INTO variable` to assign query results
- Use `IF ... THEN ... ELSEIF ... ELSE ... END IF` for conditions
- Use `SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error message'` to raise errors
- Transactions in procedures: `START TRANSACTION; ... COMMIT;` with error handling

**Common Pitfalls:**
- Forgetting DELIMITER change (procedure body has semicolons)
- Using SELECT to return values in functions (use RETURN instead)
- Not handling NULL cases in calculations
- Not declaring variables before using them
- Forgetting to use INTO when selecting values into variables

---

### **Goal 10: Implement Triggers for Data Integrity**
**Module Focus:** Triggers (Module 14)

**Task:** Create automatic data validation and logging.

**10a)** Create a BEFORE INSERT trigger on `loans` that:
   - Validates member status is 'active' (reject if suspended/expired)
   - Checks if member already has 5 active loans (reject if at limit)
   - Sets due_date automatically to 14 days after loan_date

**10b)** Create an AFTER UPDATE trigger on `loans` that:
   - When a book is returned (return_date changes from NULL to a date)
   - Logs the return to audit_log table
   - If book copy condition is 'poor', create a damage fine of $5.00

**10c)** Create a BEFORE INSERT/UPDATE trigger on `fines` that:
   - Validates fine_amount is not negative
   - If paid = 1, ensures payment_date is not NULL

**10d)** Create an AFTER INSERT trigger on `event_registrations` that:
   - Logs registration to audit_log
   - If this registration makes the event full, update event status (if you add that column)

**10e)** Create a BEFORE DELETE trigger on `members` that:
   - Prevents deletion if member has any active loans
   - Prevents deletion if member has unpaid fines

**Hints:**
- Trigger syntax: `CREATE TRIGGER name BEFORE/AFTER INSERT/UPDATE/DELETE ON table FOR EACH ROW BEGIN ... END`
- Use `NEW.column` to access new values (in INSERT and UPDATE)
- Use `OLD.column` to access old values (in UPDATE and DELETE)
- Use SIGNAL to prevent operation: `SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error'`
- For "check if exists": `SELECT COUNT(*) INTO v_count FROM table WHERE condition; IF v_count > 0 THEN ...`
- Setting values: `SET NEW.due_date = DATE_ADD(NEW.loan_date, INTERVAL 14 DAY);`
- Triggers fire automatically; you don't CALL them

**Common Pitfalls:**
- Using OLD in INSERT (doesn't exist) or NEW in DELETE (doesn't exist)
- Forgetting DELIMITER changes
- Creating infinite trigger loops (trigger A updates table B, trigger B updates table A)
- Not handling NULL values properly
- Trying to modify values in AFTER triggers (too late; use BEFORE)

---

### **Goal 11: Optimize Query Performance**
**Module Focus:** Indexes & Optimization (Module 11)

**Task:** Improve database performance through indexing and query optimization.

**11a)** Run EXPLAIN on a query that finds members by email. Analyze the results (is it doing a full table scan?).

**11b)** Create an index on `members(email)` and re-run EXPLAIN. Document the performance improvement.

**11c)** Identify and create 5 useful indexes based on common query patterns:
   - Hint: Consider columns used in WHERE, JOIN, and ORDER BY clauses
   - Examples: loans(member_id), loans(copy_id), books(genre), fines(paid), loans(status, return_date)

**11d)** Create a composite index on `loans(member_id, status, return_date)` for the common query: "find active loans for a specific member".

**11e)** Analyze a slow query with multiple joins. Rewrite it to be more efficient:
   - Avoid SELECT *
   - Filter early with WHERE
   - Use appropriate index hints if needed

**11f)** Document your indexing strategy: Which indexes did you create and why? What queries do they optimize?

**Hints:**
- EXPLAIN shows: `type` (ALL=bad full scan, ref=good index use), `key` (which index used), `rows` (estimated rows scanned)
- Create index syntax: `CREATE INDEX index_name ON table(column)`
- Composite indexes: `CREATE INDEX idx_name ON table(col1, col2, col3)`
- Index selectivity: put most selective column first in composite index
- Don't over-index: indexes speed up SELECT but slow down INSERT/UPDATE
- Use `SHOW INDEXES FROM table` to see existing indexes
- Good candidates for indexes: foreign keys, columns in WHERE clauses, columns in JOIN conditions
- Poor candidates: columns with low cardinality (few distinct values), columns rarely used in queries

**Common Pitfalls:**
- Creating redundant indexes (single-column index when composite index exists)
- Indexing every column (slows down writes, wastes space)
- Wrong column order in composite indexes
- Not considering query patterns when choosing indexes

---

### **Goal 12: Transaction Management for Critical Operations**
**Module Focus:** Transactions (Module 12)

**Task:** Implement safe multi-step operations.

**12a)** Write a transaction that processes a book loan:
   - INSERT into loans table
   - UPDATE book_copies to mark copy as checked out (if you add an availability status)
   - Validate member has fewer than 5 active loans
   - If any step fails, ROLLBACK; if all succeed, COMMIT

**12b)** Write a transaction that processes a fine payment:
   - UPDATE fines SET paid = 1, payment_date = CURDATE()
   - If member now has no unpaid fines and status is 'suspended', UPDATE members SET status = 'active'
   - Use COMMIT or ROLLBACK appropriately

**12c)** Create a procedure `sp_transfer_book_copy(old_copy_id INT, new_copy_id INT)` that:
   - In a transaction, updates all active loans from one copy to another
   - Updates book_copies status
   - Commits if successful, rolls back on error

**12d)** Demonstrate SAVEPOINT usage:
   - Start a transaction
   - Insert a member
   - Create SAVEPOINT after insert
   - Insert a loan for that member
   - If loan insert fails, ROLLBACK TO SAVEPOINT (keep the member, discard the loan)
   - COMMIT the successful parts

**Hints:**
- Transaction syntax: `START TRANSACTION; ... COMMIT;` or `... ROLLBACK;`
- Use DECLARE CONTINUE/EXIT HANDLER for error handling in procedures
- Test rollback scenarios by deliberately causing errors (e.g., violating constraints)
- Savepoint syntax: `SAVEPOINT savepoint_name; ... ROLLBACK TO SAVEPOINT savepoint_name;`
- Transactions ensure ACID properties: Atomicity (all or nothing), Consistency, Isolation, Durability
- For testing: `START TRANSACTION; ... SELECT * FROM table; ROLLBACK;` (safe preview)

**Common Pitfalls:**
- Forgetting COMMIT (transaction stays open, locks remain)
- Not handling errors (transaction commits even after errors)
- Long-running transactions (hold locks, block other users)
- Not testing rollback scenarios

---

## 📊 Deliverables & Submission

Organize your work into these SQL files:

1. **`schema.sql`** - All CREATE TABLE statements
2. **`sample_data.sql`** - All INSERT statements
3. **`queries_basic.sql`** - Solutions for Goals 3-4
4. **`queries_intermediate.sql`** - Solutions for Goals 5-8
5. **`procedures_functions.sql`** - Solutions for Goal 9
6. **`triggers.sql`** - Solutions for Goal 10
7. **`indexes.sql`** - Solutions for Goal 11
8. **`transactions.sql`** - Solutions for Goal 12
9. **`README.md`** - Brief documentation of your design decisions and any challenges faced

---

## ✅ Self-Assessment Checklist

Before submitting, verify:

- ✅ All 9 tables created with proper constraints and relationships
- ✅ Realistic sample data with at least the minimum required records
- ✅ All 12 goals completed with working SQL code
- ✅ Code is well-formatted with comments explaining complex logic
- ✅ Tested all queries and procedures (they execute without errors)
- ✅ EXPLAIN analysis performed on key queries
- ✅ At least 5 useful indexes created
- ✅ At least 4 triggers functioning correctly
- ✅ At least 3 procedures and 2 functions implemented
- ✅ Transaction examples with both COMMIT and ROLLBACK scenarios

---

## 💡 General Tips for Success

### Approach Strategy:
1. **Read all goals first** to understand the full scope
2. **Complete in order** - each goal builds on previous concepts
3. **Test incrementally** - don't write everything then test
4. **Use transactions for testing** - easily rollback test data

### When Stuck:
- Review the relevant module materials
- Break complex problems into smaller sub-queries
- Use SELECT to verify intermediate steps
- Check for typos in table/column names
- Read error messages carefully - they often point to the issue

### Best Practices:
- Comment your code to explain intent
- Use meaningful aliases (m for members, b for books, not a, b, c)
- Format SQL for readability (one clause per line, consistent indentation)
- Always use WHERE with UPDATE/DELETE unless you truly mean to affect all rows
- Test edge cases (NULL values, empty results, boundary conditions)

### Common SQL Patterns:
```sql
-- Finding records without relationships (anti-join)
SELECT m.* FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
WHERE l.loan_id IS NULL;

-- Top N per group (window function)
WITH ranked AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY genre ORDER BY borrow_count DESC) as rn
  FROM book_stats
)
SELECT * FROM ranked WHERE rn <= 3;

-- Safe updates with validation
UPDATE table SET column = value
WHERE id = specific_id
  AND current_status = 'expected_status';
```

---

## 🎓 Learning Outcomes

Upon completion, you will have demonstrated mastery of:

- **Database Design**: Creating normalized schemas with appropriate relationships
- **Data Manipulation**: Safely inserting, updating, and deleting data
- **Query Writing**: From simple SELECT to complex multi-table joins
- **Analytical Skills**: Using aggregates, window functions, and CTEs
- **Code Reusability**: Building functions and procedures for common operations
- **Data Integrity**: Implementing triggers and constraints
- **Performance**: Optimizing queries with indexes
- **Transaction Safety**: Handling multi-step operations reliably
- **Professional Practices**: Writing clean, maintainable SQL code

---

**You're now ready to build a real-world database system! Take your time, experiment, learn from errors, and most importantly - have fun with SQL!** 🚀

Good luck! 📚
