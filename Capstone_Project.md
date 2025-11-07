# 🎓 MySQL Capstone Project: CityLibrary Management System

> **🎯 Difficulty Level:** Beginner to Intermediate  
> **⏱️ Estimated Time:** 8-12 hours (2-3 days recommended)  
> **📊 Minimum for Passing:** Complete Goals 1-8 (Core Requirements = 100%)  
> **⭐ Bonus to Excel:** Complete Goals 9-12 (Advanced Features = +20%)

---

## 📑 TABLE OF CONTENTS - Your Roadmap to Success!

### 🚀 **Getting Started - READ FIRST!**
1. [Project Overview](#-project-overview) - What you're building
2. [Grading System](#-grading-system) - How you'll be scored
3. [Your Learning Path](#-your-learning-path) - Step-by-step guide
4. [Prerequisites & Setup](#-prerequisites) - What you need
5. [Quick Start Checklist](#-quick-start-checklist) - Are you ready?

### 📋 **Understanding the Project**
- [Problem Statement](#-problem-statement) - The business need
- [Database Overview](#%EF%B8%8F-database-requirements) - The 9 tables explained
- [Business Rules](#-business-requirements) - How the library works

### 🎯 **CORE PROJECT GOALS (Required - Goals 1-8)**

**Phase 1: Foundation (Goals 1-4)** ⭐ Beginner Level
- [Goal 1: Create Database Schema](#goal-1-create-the-database-schema) - Build all 9 tables
- [Goal 2: Insert Sample Data](#goal-2-populate-with-realistic-sample-data) - Add test data
- [Goal 3: Basic Queries](#goal-3-basic-information-retrieval-queries) - SELECT, WHERE, ORDER BY
- [Goal 4: Aggregation](#goal-4-statistical-summaries-and-aggregation) - COUNT, SUM, AVG, GROUP BY

**Phase 2: Intermediate (Goals 5-8)** ⭐⭐ Intermediate Level
- [Goal 5: Multi-Table Joins](#goal-5-multi-table-joins-and-analysis) - INNER, LEFT, self-joins
- [Goal 6: Subqueries & CTEs](#goal-6-subqueries-and-common-table-expressions) - Nested queries, WITH clauses
- [Goal 7: Set Operations](#goal-7-set-operations-and-combined-results) - UNION, combining results
- [Goal 8: Window Functions](#goal-8-window-functions-for-ranking-and-analytics) - ROW_NUMBER, RANK, LAG

### ⭐ **BONUS GOALS (Optional - Goals 9-12)** - Boost Your Score!

**Phase 3: Advanced Features** ⭐⭐⭐ Advanced Level
- [Goal 9: Procedures & Functions](#goal-9-create-stored-procedures-and-functions-bonus) - Reusable code (+5%)
- [Goal 10: Triggers](#goal-10-implement-triggers-for-data-integrity-bonus) - Automated actions (+5%)
- [Goal 11: Optimization](#goal-11-optimize-query-performance-bonus) - Indexes & speed (+5%)
- [Goal 12: Transactions](#goal-12-transaction-management-bonus) - Safe operations (+5%)

### 📤 **Submission & Help**
- [What to Submit](#-deliverables--submission) - Required files
- [Screenshot Requirements](#-screenshot-requirements) - Documentation guide
- [GitHub Upload Guide](#-how-to-submit) - Step-by-step upload
- [Troubleshooting](#-beginner-troubleshooting-guide) - Common errors
- [SQL Quick Reference](#-quick-reference-guide) - Syntax reminders

---

## 📖 Project Overview

Welcome to the **CityLibrary Management System** capstone project! You'll build a complete database system for a modern public library that serves thousands of patrons. This real-world scenario will test your MySQL skills across fundamental concepts while keeping complexity manageable for beginners.

**Real-World Context:** CityLibrary is a community library that has been using paper records and spreadsheets to manage their operations. They need a proper database system to track books, members, loans, fines, and events. Your job is to design and implement this system from scratch!

### What You'll Learn

By completing this project, you will practice:

- **Database Design**: Creating normalized schemas with relationships
- **Data Types & Constraints**: Choosing appropriate types and enforcing rules
- **Basic Queries**: SELECT, WHERE, ORDER BY, LIMIT
- **Aggregate Functions**: COUNT, SUM, AVG, MIN, MAX, GROUP BY
- **Joins**: Combining data from multiple tables
- **Subqueries & CTEs**: Complex nested queries
- **Set Operations**: UNION, combining result sets
- **Window Functions**: Ranking and analytical queries
- **Advanced Features (Optional)**: Procedures, triggers, indexes, transactions

---

## 📊 Grading System

### How Your Work Will Be Scored

| Component | Points | What's Required |
|-----------|--------|-----------------|
| **Goal 1: Schema** | 10% | Create all 9 tables with proper constraints |
| **Goal 2: Data** | 10% | Insert comprehensive sample data |
| **Goal 3: Basic Queries** | 10% | Complete all 8 SELECT queries |
| **Goal 4: Aggregation** | 10% | Complete all 8 GROUP BY queries |
| **Goal 5: Joins** | 10% | Complete all 8 JOIN queries |
| **Goal 6: Subqueries** | 10% | Complete all 8 subquery/CTE queries |
| **Goal 7: Set Operations** | 10% | Complete all 5 UNION queries |
| **Goal 8: Window Functions** | 10% | Complete all 8 window function queries |
| **Documentation** | 10% | Screenshots & explanations for all goals |
| **Code Quality** | 10% | Clean, commented, well-formatted SQL |
| **SUBTOTAL (Required)** | **100%** | **This gets you full credit!** |

### Bonus Points (Optional - Make Your Project Stand Out!)

| Bonus Goal | Extra Points | What You'll Build |
|------------|--------------|-------------------|
| **Goal 9: Procedures** | +5% | Create 4 stored procedures & functions |
| **Goal 10: Triggers** | +5% | Implement 5 database triggers |
| **Goal 11: Optimization** | +5% | Add indexes and analyze performance |
| **Goal 12: Transactions** | +5% | Demonstrate transaction management |
| **MAXIMUM POSSIBLE** | **120%** | **Outstanding achievement!** |

### What This Means for You

- ✅ **Complete Goals 1-8** = 100% (Full credit, excellent work!)
- ⭐ **Add Goal 9** = 105% (You're showing advanced skills!)
- ⭐⭐ **Add Goals 9-10** = 110% (You're going above and beyond!)
- ⭐⭐⭐ **Add Goals 9-11** = 115% (You're demonstrating mastery!)
- ⭐⭐⭐⭐ **Complete ALL Goals 1-12** = 120% (Outstanding achievement!)

### Grade Ranges

- **110-120%**: A++ (Outstanding - mastered advanced features)
- **100-109%**: A+ (Excellent - all requirements + some bonus)
- **90-99%**: A (Very Good - all core requirements, minor issues)
- **80-89%**: B (Good - most requirements completed)
- **70-79%**: C (Satisfactory - needs more work)
- **Below 70%**: Incomplete - Please revise and resubmit

> 💡 **Key Insight:** You can get a perfect score (100%) by completing just Goals 1-8. The bonus goals (9-12) are there to challenge yourself and demonstrate advanced database skills!

---

## 🗺️ Your Learning Path

### Visual Roadmap

```
┌─────────────────────────────────────────────────────────────┐
│  START HERE → Create Database → Add Data → Basic Queries    │
│   (Day 1)      Goal 1           Goal 2      Goals 3-4       │
└──────────────────────────┬──────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  Intermediate Queries → Advanced Queries → CHECKPOINT       │
│   (Day 2)    Goals 5-6      Goals 7-8      Test Everything  │
└──────────────────────────┬──────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  OPTIONAL BONUS: Advanced Features (Goals 9-12)             │
│   (Day 3)    Procedures → Triggers → Indexes → Transactions │
│              +5%          +5%        +5%       +5%           │
└─────────────────────────────────────────────────────────────┘
```

### Recommended Timeline

| Day | Phase | Goals | Time | What You'll Build |
|-----|-------|-------|------|-------------------|
| **Day 1** | Foundation | 1-2 | 3-4 hours | Database + Sample Data |
| **Day 1** | Basic Queries | 3-4 | 2-3 hours | SELECT, WHERE, GROUP BY |
| **Day 2** | Intermediate | 5-6 | 3-4 hours | JOINs, Subqueries, CTEs |
| **Day 2** | Advanced | 7-8 | 2-3 hours | UNION, Window Functions |
| **Day 3** | *Optional* | 9-12 | 3-4 hours | Procedures, Triggers, Indexes, Transactions |

**Total Required Time:** 10-14 hours (Days 1-2)  
**Optional Bonus Time:** +3-4 hours (Day 3)

### Three Paths to Success - Choose Your Journey!

#### 🥉 Path 1: Solid Foundation (Recommended for Beginners)
**Goal:** Complete Goals 1-8 and get 100%

- **Who:** First-time SQL project students, beginners
- **Time:** 2-3 days (10-14 hours)
- **Focus:** Understanding concepts deeply
- **Outcome:** Full credit, strong SQL foundation
- **Skip:** Goals 9-12 (come back to these later!)

#### 🥈 Path 2: Above and Beyond
**Goal:** Complete Goals 1-10 and get 110%

- **Who:** Students comfortable with SQL basics
- **Time:** 3-4 days (13-18 hours)
- **Focus:** Adding professional features
- **Outcome:** Excellent score, portfolio-ready project
- **Complete:** Goals 1-10 (procedures and triggers)

#### 🥇 Path 3: Mastery Challenge
**Goal:** Complete ALL Goals 1-12 and get 120%

- **Who:** Advanced students or those aiming for top scores
- **Time:** 4-5 days (16-22 hours)
- **Focus:** Full professional database system
- **Outcome:** Outstanding achievement, job-ready skills
- **Complete:** Everything including optimization and transactions

> 💡 **Beginner Tip:** Don't feel pressured to complete the bonus goals! Focusing on Goals 1-8 and doing them well is far better than rushing through everything. You can always come back and add the advanced features later.

---

## 🏁 Prerequisites

Before starting this project, make sure you have:

### Software Requirements
- ✅ **MySQL 5.7+** or **MySQL 8.0** installed
- ✅ **MySQL Workbench** OR command-line client OR VS Code with MySQL extension
- ✅ Basic text editor for documentation (Word, Google Docs, or Markdown editor)
- ✅ Screenshot tool (Snipping Tool on Windows, Screenshot on Mac)

### Knowledge Prerequisites
- ✅ **Module 1**: Understand databases, tables, rows, columns
- ✅ **Module 2**: Can write SELECT queries with WHERE and ORDER BY
- ✅ **Module 3**: Know basic data types (INT, VARCHAR, DATE)
- ✅ **Module 4**: Understand PRIMARY KEY and FOREIGN KEY concepts

### Skills Check - Can you do these?
- [ ] Create a table with CREATE TABLE
- [ ] Insert data with INSERT INTO
- [ ] Query data with SELECT FROM WHERE
- [ ] Join two tables with INNER JOIN
- [ ] Use COUNT() and GROUP BY

**If you answered "yes" to most of these, you're ready! If not, review Modules 1-4 first.**

---

## 🗺️ Quick Start Checklist

### Before You Begin

- [ ] I've read the entire project overview
- [ ] I understand I need to complete Goals 1-8 (Goals 9-12 are optional)
- [ ] I know the 9 tables I need to create
- [ ] I have MySQL installed and working
- [ ] I can create a database and run simple queries
- [ ] I've chosen my path (Foundation / Above and Beyond / Mastery)
- [ ] I have a plan for taking screenshots
- [ ] I have 2-3 days available to work on this project

### Your Action Plan

1. **Day 1 Morning:** Read entire project, create database schema (Goal 1)
2. **Day 1 Afternoon:** Insert sample data (Goal 2), start basic queries (Goal 3)
3. **Day 1 Evening:** Finish Goals 3-4
4. **Day 2 Morning:** Complete Goals 5-6 (joins and subqueries)
5. **Day 2 Afternoon:** Complete Goals 7-8 (set operations, window functions)
6. **Day 2 Evening:** Take screenshots, create documentation
7. **Day 3 (Optional):** Tackle Goals 9-12 for bonus points

**Ready? Let's build your library database! 🚀**

---

## 📚 Problem Statement

### The Challenge

CityLibrary has been struggling with manual record-keeping. Librarians spend hours searching through filing cabinets to find overdue books, calculating fines by hand, and manually tracking which books are available. Member information is scattered across different spreadsheets, and there's no easy way to see borrowing patterns or popular books.

The library director has approved funding for a digital transformation. They need a database that can:

- Track their entire book collection (15,000+ books)
- Manage 3,500 active library members
- Record book loans and returns
- Calculate and track overdue fines automatically
- Manage library events (book clubs, reading programs, workshops)
- Generate reports on popular books, active members, and revenue

### Your Mission

You've been hired as the database developer. Your job is to design a normalized database schema, populate it with realistic test data, and create queries that librarians can use for daily operations. The system must be reliable, efficient, and easy to maintain.

### 📋 Business Requirements

**Borrowing Rules:**
- Members can borrow up to 5 books at once
- Loan period is 14 days
- After 14 days, fines accrue at $0.25 per day
- Books can have multiple physical copies

**Member Types:**
- **Standard**: Free membership, 5-book limit
- **Premium**: $10/year, 10-book limit, no late fees for first 7 days
- **Student**: $5/year for students with ID

**Events:**
- The library hosts book clubs, workshops, reading programs, and author visits
- Events have maximum attendee limits
- Members can register for multiple events

**Reporting Needs:**
- Overdue books list
- Top 10 most borrowed books
- Members with unpaid fines
- Monthly revenue from fines and memberships
- Popular genres and authors

---

## 🗄️ Database Requirements

### The 9 Tables You'll Create

Here's an overview of all the tables. Don't worry - we'll guide you through creating each one!

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   members   │────→│    loans     │←────│ book_copies │
└─────────────┘     └──────────────┘     └─────────────┘
                           ↓                      ↓
                    ┌──────────┐           ┌──────────┐
                    │  fines   │           │  books   │
                    └──────────┘           └──────────┘
                                                  ↓
┌─────────────┐                           ┌──────────┐
│   events    │                           │ authors  │
└─────────────┘                           └──────────┘
       ↓
┌──────────────────┐
│event_registrations│
└──────────────────┘

┌──────────────┐
│  audit_log   │  (tracks changes)
└──────────────┘
```

### Table Descriptions

#### 1. **members** (Library patrons)
Stores information about library members.
- Who can borrow books
- Contact information
- Membership type (standard/premium/student)
- Status (active/suspended/expired)

#### 2. **authors** (Book authors)
Information about book authors.
- Author names
- Birth year and country
- Used to link books to their authors

#### 3. **books** (Book catalog)
Catalog of unique book titles (not individual copies).
- Book titles and ISBNs
- Publication year and genre
- Links to authors
- Total number of copies owned

#### 4. **book_copies** (Physical books)
Individual physical copies of books (the actual books on shelves).
- Each copy has a unique ID
- Tracks condition (excellent/good/fair/poor)
- Links to which book title it is

#### 5. **loans** (Borrowing transactions)
Records of who borrowed what and when.
- Who borrowed which copy
- When borrowed, when due, when returned
- Status (active/returned/lost)

#### 6. **fines** (Overdue and damage fines)
Financial penalties for late returns or damage.
- Amount owed
- Reason (overdue/damage/lost)
- Payment status

#### 7. **events** (Library events)
Library programs and events.
- Book clubs, workshops, reading programs
- Date, type, and attendance limit

#### 8. **event_registrations** (Who signed up)
Tracks which members registered for which events.
- Links members to events
- Registration date

#### 9. **audit_log** (Change tracking)
Tracks important database changes for security.
- What changed, when, and by whom

---

## 🎯 Project Goals - Your Step-by-Step Guide

---

## 🟢 PHASE 1: FOUNDATION (Required)

# Goal 1: Create the Database Schema

**📌 Module Focus:** DDL (Module 10), Database Design (Module 1)  
**⏱️ Estimated Time:** 2-3 hours  
**🎯 What You'll Learn:** CREATE TABLE, PRIMARY KEY, FOREIGN KEY, constraints

### What You Need to Do

Create the database and all 9 tables with:
- Appropriate data types for each column
- PRIMARY KEY with AUTO_INCREMENT
- FOREIGN KEY relationships
- CHECK constraints where needed
- UNIQUE constraints for emails and ISBNs
- DEFAULT values for dates and status fields
- ENUM types for status fields

### 📝 Step-by-Step Instructions

#### Step 1: Create the Database

```sql
-- Create the database
CREATE DATABASE IF NOT EXISTS city_library;
USE city_library;
```

#### Step 2: Create Tables WITHOUT Dependencies First

Start with tables that don't reference other tables:

```sql
-- Table 1: authors (no dependencies)
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    author_name VARCHAR(100) NOT NULL,
    birth_year INT,
    country VARCHAR(50)
);

-- Table 2: members (no dependencies)
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address VARCHAR(200),
    join_date DATE DEFAULT (CURRENT_DATE),
    membership_type ENUM('standard', 'premium', 'student') DEFAULT 'standard',
    status ENUM('active', 'suspended', 'expired') DEFAULT 'active'
);

-- Table 3: events (no dependencies)
CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    event_name VARCHAR(100) NOT NULL,
    event_date DATE NOT NULL,
    event_type ENUM('book_club', 'workshop', 'reading_program', 'author_visit') NOT NULL,
    max_attendees INT,
    description TEXT
);

-- Table 4: audit_log (no dependencies)
CREATE TABLE audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(50),
    action ENUM('INSERT', 'UPDATE', 'DELETE'),
    record_id INT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(50) DEFAULT 'SYSTEM',
    description TEXT
);
```

#### Step 3: Create Tables WITH Dependencies

Now create tables that reference the ones above:

```sql
-- Table 5: books (depends on authors)
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author_id INT NOT NULL,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    publication_year INT,
    genre VARCHAR(50) NOT NULL,
    total_copies INT DEFAULT 1 CHECK (total_copies > 0),
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE RESTRICT
);

-- Table 6: book_copies (depends on books)
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    copy_number INT NOT NULL,
    condition ENUM('excellent', 'good', 'fair', 'poor') DEFAULT 'good',
    acquisition_date DATE,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
);

-- Table 7: loans (depends on members and book_copies)
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    copy_id INT NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    status ENUM('active', 'returned', 'lost') DEFAULT 'active',
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE RESTRICT,
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE RESTRICT
);

-- Table 8: fines (depends on loans)
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    fine_amount DECIMAL(10, 2) NOT NULL CHECK (fine_amount >= 0),
    fine_reason ENUM('overdue', 'damage', 'lost') NOT NULL,
    paid BOOLEAN DEFAULT FALSE,
    payment_date DATE,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE
);

-- Table 9: event_registrations (depends on events and members)
CREATE TABLE event_registrations (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    member_id INT NOT NULL,
    registration_date DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    UNIQUE KEY unique_registration (event_id, member_id)
);
```

### ✅ Testing Your Work

After creating each table, verify it exists:

```sql
-- Check all tables were created
SHOW TABLES;

-- Check structure of specific tables
DESCRIBE members;
DESCRIBE books;
DESCRIBE loans;
```

### 🎯 Success Criteria

- [ ] All 9 tables created successfully
- [ ] SHOW TABLES returns 9 tables
- [ ] Each table has a PRIMARY KEY
- [ ] Foreign keys reference the correct parent tables
- [ ] ENUM fields have the correct options
- [ ] No error messages when creating tables

### 💡 Beginner Tips

- **Create in order!** Parent tables (authors, members) before child tables (books, loans)
- **Test each table** with DESCRIBE before moving to the next one
- **If you get errors**, drop the table and recreate: `DROP TABLE IF EXISTS table_name;`
- **Foreign key errors?** Make sure the parent table exists first
- **Use comments** to document what each table does

### ❌ Common Mistakes to Avoid

- Creating foreign keys before the referenced table exists
- Forgetting NOT NULL on required fields
- Using wrong data types (VARCHAR for dates, etc.)
- Not setting AUTO_INCREMENT on primary keys
- Misspelling ENUM values

---

# Goal 2: Populate with Realistic Sample Data

**📌 Module Focus:** DML Operations (Module 9)  
**⏱️ Estimated Time:** 2-3 hours  
**🎯 What You'll Learn:** INSERT INTO, date functions, multi-row inserts

### What You Need to Do

Insert test data that represents realistic library operations:

| Table | Minimum Rows | What to Include |
|-------|--------------|-----------------|
| **members** | 20 | Mix of all membership types and statuses |
| **authors** | 10 | Authors from different countries |
| **books** | 25 | Multiple genres, various publication years |
| **book_copies** | 40 | Some books with multiple copies, various conditions |
| **loans** | 30 | Mix of active, returned, and overdue loans |
| **fines** | 10 | Both paid and unpaid fines |
| **events** | 8 | All event types |
| **event_registrations** | 25 | Various members in events |
| **audit_log** | 5 | Sample audit entries |

### 📝 Complete Example Code

```sql
-- Step 1: Insert authors (no dependencies)
INSERT INTO authors (author_name, birth_year, country) VALUES
  ('J.K. Rowling', 1965, 'United Kingdom'),
  ('George Orwell', 1903, 'United Kingdom'),
  ('Jane Austen', 1775, 'United Kingdom'),
  ('Haruki Murakami', 1949, 'Japan'),
  ('Gabriel García Márquez', 1927, 'Colombia'),
  ('Toni Morrison', 1931, 'United States'),
  ('Chinua Achebe', 1930, 'Nigeria'),
  ('Isabel Allende', 1942, 'Chile'),
  ('Agatha Christie', 1890, 'United Kingdom'),
  ('Stephen King', 1947, 'United States');

-- Step 2: Insert members (no dependencies)
INSERT INTO members (first_name, last_name, email, phone, address, join_date, membership_type, status) VALUES
  ('Alice', 'Johnson', 'alice.j@email.com', '555-0101', '123 Main St', DATE_SUB(CURDATE(), INTERVAL 400 DAY), 'premium', 'active'),
  ('Bob', 'Smith', 'bob.smith@email.com', '555-0102', '456 Oak Ave', DATE_SUB(CURDATE(), INTERVAL 300 DAY), 'standard', 'active'),
  ('Carol', 'Davis', 'carol.d@email.com', '555-0103', '789 Pine Rd', DATE_SUB(CURDATE(), INTERVAL 200 DAY), 'student', 'active'),
  ('David', 'Wilson', 'david.w@email.com', '555-0104', '321 Elm St', DATE_SUB(CURDATE(), INTERVAL 500 DAY), 'standard', 'suspended'),
  ('Emma', 'Brown', 'emma.b@email.com', '555-0105', '654 Maple Dr', DATE_SUB(CURDATE(), INTERVAL 100 DAY), 'premium', 'active'),
  ('Frank', 'Miller', 'frank.m@email.com', '555-0106', '987 Cedar Ln', DATE_SUB(CURDATE(), INTERVAL 600 DAY), 'standard', 'expired'),
  ('Grace', 'Taylor', 'grace.t@email.com', '555-0107', '147 Birch Way', DATE_SUB(CURDATE(), INTERVAL 250 DAY), 'student', 'active'),
  ('Henry', 'Anderson', 'henry.a@email.com', '555-0108', '258 Spruce Ct', DATE_SUB(CURDATE(), INTERVAL 150 DAY), 'standard', 'active'),
  ('Isabel', 'Martinez', 'isabel.m@email.com', '555-0109', '369 Willow Pl', DATE_SUB(CURDATE(), INTERVAL 350 DAY), 'premium', 'active'),
  ('Jack', 'Garcia', 'jack.g@email.com', '555-0110', '741 Ash Blvd', CURDATE(), 'student', 'active'),
  ('Karen', 'Rodriguez', 'karen.r@email.com', '555-0111', '852 Poplar St', DATE_SUB(CURDATE(), INTERVAL 180 DAY), 'standard', 'active'),
  ('Leo', 'Lee', 'leo.lee@email.com', '555-0112', '963 Hickory Ave', DATE_SUB(CURDATE(), INTERVAL 270 DAY), 'premium', 'active'),
  ('Maria', 'Lopez', 'maria.l@email.com', '555-0113', '159 Magnolia Dr', DATE_SUB(CURDATE(), INTERVAL 90 DAY), 'student', 'active'),
  ('Nathan', 'White', 'nathan.w@email.com', '555-0114', '357 Dogwood Ln', DATE_SUB(CURDATE(), INTERVAL 420 DAY), 'standard', 'active'),
  ('Olivia', 'Harris', 'olivia.h@email.com', '555-0115', '486 Redwood Way', DATE_SUB(CURDATE(), INTERVAL 310 DAY), 'premium', 'active'),
  ('Paul', 'Clark', 'paul.c@email.com', '555-0116', '624 Sequoia Ct', DATE_SUB(CURDATE(), INTERVAL 220 DAY), 'student', 'active'),
  ('Quinn', 'Lewis', 'quinn.l@email.com', '555-0117', '735 Cypress Pl', DATE_SUB(CURDATE(), INTERVAL 130 DAY), 'standard', 'active'),
  ('Rachel', 'Walker', 'rachel.w@email.com', '555-0118', '846 Fir Blvd', DATE_SUB(CURDATE(), INTERVAL 440 DAY), 'premium', 'active'),
  ('Sam', 'Hall', 'sam.h@email.com', '555-0119', '957 Beech St', DATE_SUB(CURDATE(), INTERVAL 60 DAY), 'standard', 'active'),
  ('Tina', 'Young', 'tina.y@email.com', '555-0120', '168 Cherry Ave', DATE_SUB(CURDATE(), INTERVAL 510 DAY), 'student', 'expired');

-- Step 3: Insert books (depends on authors)
INSERT INTO books (title, author_id, isbn, publication_year, genre, total_copies) VALUES
  ('Harry Potter and the Philosopher''s Stone', 1, '9780747532699', 1997, 'Fiction', 3),
  ('1984', 2, '9780451524935', 1949, 'Fiction', 2),
  ('Pride and Prejudice', 3, '9780141439518', 1813, 'Fiction', 2),
  ('Norwegian Wood', 4, '9780375704024', 1987, 'Fiction', 1),
  ('One Hundred Years of Solitude', 5, '9780060883287', 1967, 'Fiction', 2),
  ('Beloved', 6, '9781400033416', 1987, 'Fiction', 1),
  ('Things Fall Apart', 7, '9780385474542', 1958, 'Fiction', 2),
  ('The House of the Spirits', 8, '9781501117015', 1982, 'Fiction', 1),
  ('Murder on the Orient Express', 9, '9780062693662', 1934, 'Fiction', 2),
  ('The Shining', 10, '9780307743657', 1977, 'Fiction', 2),
  ('Harry Potter and the Chamber of Secrets', 1, '9780439064873', 1998, 'Fiction', 2),
  ('Animal Farm', 2, '9780451526342', 1945, 'Fiction', 2),
  ('Emma', 3, '9780141439587', 1815, 'Fiction', 1),
  ('Kafka on the Shore', 4, '9781400079278', 2002, 'Fiction', 1),
  ('Love in the Time of Cholera', 5, '9780307389732', 1985, 'Fiction', 1),
  ('The Bluest Eye', 6, '9780307278449', 1970, 'Fiction', 1),
  ('No Longer at Ease', 7, '9780385474559', 1960, 'Fiction', 1),
  ('Paula', 8, '9780062564689', 1994, 'Biography', 1),
  ('And Then There Were None', 9, '9780062073488', 1939, 'Fiction', 2),
  ('The Stand', 10, '9780307743688', 1978, 'Fiction', 2),
  ('A Brief History of Time', NULL, '9780553380163', 1988, 'Science', 1),
  ('Sapiens: A Brief History of Humankind', NULL, '9780062316097', 2011, 'History', 2),
  ('Educated', NULL, '9780399590504', 2018, 'Biography', 2),
  ('The Very Hungry Caterpillar', NULL, '9780399226908', 1969, 'Children', 3),
  ('Where the Wild Things Are', NULL, '9780060254926', 1963, 'Children', 2);

-- Step 4: Insert book copies (depends on books)
INSERT INTO book_copies (book_id, copy_number, condition, acquisition_date) VALUES
  -- Harry Potter 1 (3 copies)
  (1, 1, 'good', '2020-01-15'),
  (1, 2, 'excellent', '2021-05-20'),
  (1, 3, 'fair', '2019-03-10'),
  -- 1984 (2 copies)
  (2, 1, 'excellent', '2020-06-01'),
  (2, 2, 'good', '2021-02-14'),
  -- Pride and Prejudice (2 copies)
  (3, 1, 'good', '2019-11-20'),
  (3, 2, 'fair', '2018-07-15'),
  -- Norwegian Wood (1 copy)
  (4, 1, 'excellent', '2021-03-22'),
  -- One Hundred Years (2 copies)
  (5, 1, 'good', '2020-08-10'),
  (5, 2, 'good', '2021-01-05'),
  -- Beloved (1 copy)
  (6, 1, 'excellent', '2020-10-12'),
  -- Things Fall Apart (2 copies)
  (7, 1, 'good', '2019-09-18'),
  (7, 2, 'fair', '2018-12-03'),
  -- House of Spirits (1 copy)
  (8, 1, 'good', '2021-04-07'),
  -- Murder on Orient Express (2 copies)
  (9, 1, 'excellent', '2020-02-28'),
  (9, 2, 'good', '2021-06-15'),
  -- The Shining (2 copies)
  (10, 1, 'good', '2019-08-22'),
  (10, 2, 'excellent', '2020-12-01'),
  -- Continue with remaining books...
  (11, 1, 'excellent', '2021-07-10'),
  (11, 2, 'good', '2020-05-18'),
  (12, 1, 'good', '2019-10-25'),
  (12, 2, 'fair', '2018-11-30'),
  (13, 1, 'excellent', '2021-01-20'),
  (14, 1, 'good', '2020-09-14'),
  (15, 1, 'excellent', '2021-02-28'),
  (16, 1, 'good', '2020-07-19'),
  (17, 1, 'fair', '2019-05-22'),
  (18, 1, 'excellent', '2021-03-15'),
  (19, 1, 'good', '2020-11-08'),
  (19, 2, 'excellent', '2021-05-25'),
  (20, 1, 'good', '2019-12-14'),
  (20, 2, 'fair', '2018-10-20'),
  (21, 1, 'excellent', '2021-08-05'),
  (22, 1, 'good', '2020-04-12'),
  (22, 2, 'excellent', '2021-09-30'),
  (23, 1, 'excellent', '2021-06-18'),
  (23, 2, 'good', '2020-03-22'),
  (24, 1, 'good', '2019-07-14'),
  (24, 2, 'excellent', '2020-08-26'),
  (24, 3, 'fair', '2018-09-08'),
  (25, 1, 'excellent', '2021-04-20'),
  (25, 2, 'good', '2020-10-15');

-- Step 5: Insert events (no dependencies)
INSERT INTO events (event_name, event_date, event_type, max_attendees, description) VALUES
  ('Mystery Book Club - November', DATE_ADD(CURDATE(), INTERVAL 10 DAY), 'book_club', 15, 'Monthly mystery book discussion'),
  ('Children''s Story Time', DATE_ADD(CURDATE(), INTERVAL 3 DAY), 'reading_program', 20, 'Weekly story time for kids aged 3-7'),
  ('Meet Author Stephen King', DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'author_visit', 50, 'Q&A session with famous author'),
  ('Digital Literacy Workshop', DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'workshop', 12, 'Learn basic computer skills'),
  ('Teen Summer Reading Program', DATE_ADD(CURDATE(), INTERVAL 15 DAY), 'reading_program', 25, 'Summer reading challenge for teens'),
  ('Classic Literature Book Club', DATE_ADD(CURDATE(), INTERVAL 20 DAY), 'book_club', 15, 'Discussing Jane Austen novels'),
  ('Poetry Writing Workshop', DATE_ADD(CURDATE(), INTERVAL 5 DAY), 'workshop', 10, 'Creative writing session'),
  ('Science Fiction Book Club', DATE_ADD(CURDATE(), INTERVAL 25 DAY), 'book_club', 15, 'Discussing 1984 by George Orwell');

-- Step 6: Insert loans (depends on members and book_copies)
INSERT INTO loans (member_id, copy_id, loan_date, due_date, return_date, status) VALUES
  -- Active loans (not returned yet)
  (1, 1, DATE_SUB(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 9 DAY), NULL, 'active'),
  (2, 4, DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 4 DAY), NULL, 'active'),
  (3, 8, DATE_SUB(CURDATE(), INTERVAL 3 DAY), DATE_ADD(CURDATE(), INTERVAL 11 DAY), NULL, 'active'),
  (5, 11, DATE_SUB(CURDATE(), INTERVAL 7 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), NULL, 'active'),
  (7, 15, DATE_SUB(CURDATE(), INTERVAL 2 DAY), DATE_ADD(CURDATE(), INTERVAL 12 DAY), NULL, 'active'),
  (9, 21, DATE_SUB(CURDATE(), INTERVAL 8 DAY), DATE_ADD(CURDATE(), INTERVAL 6 DAY), NULL, 'active'),
  (11, 25, DATE_SUB(CURDATE(), INTERVAL 4 DAY), DATE_ADD(CURDATE(), INTERVAL 10 DAY), NULL, 'active'),
  
  -- Overdue loans (past due date, not returned)
  (2, 6, DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_SUB(CURDATE(), INTERVAL 16 DAY), NULL, 'active'),
  (4, 9, DATE_SUB(CURDATE(), INTERVAL 25 DAY), DATE_SUB(CURDATE(), INTERVAL 11 DAY), NULL, 'active'),
  (6, 13, DATE_SUB(CURDATE(), INTERVAL 40 DAY), DATE_SUB(CURDATE(), INTERVAL 26 DAY), NULL, 'active'),
  (8, 17, DATE_SUB(CURDATE(), INTERVAL 35 DAY), DATE_SUB(CURDATE(), INTERVAL 21 DAY), NULL, 'active'),
  (10, 20, DATE_SUB(CURDATE(), INTERVAL 22 DAY), DATE_SUB(CURDATE(), INTERVAL 8 DAY), NULL, 'active'),
  
  -- Returned loans (completed)
  (1, 2, DATE_SUB(CURDATE(), INTERVAL 60 DAY), DATE_SUB(CURDATE(), INTERVAL 46 DAY), DATE_SUB(CURDATE(), INTERVAL 50 DAY), 'returned'),
  (3, 5, DATE_SUB(CURDATE(), INTERVAL 50 DAY), DATE_SUB(CURDATE(), INTERVAL 36 DAY), DATE_SUB(CURDATE(), INTERVAL 38 DAY), 'returned'),
  (5, 7, DATE_SUB(CURDATE(), INTERVAL 45 DAY), DATE_SUB(CURDATE(), INTERVAL 31 DAY), DATE_SUB(CURDATE(), INTERVAL 32 DAY), 'returned'),
  (7, 10, DATE_SUB(CURDATE(), INTERVAL 55 DAY), DATE_SUB(CURDATE(), INTERVAL 41 DAY), DATE_SUB(CURDATE(), INTERVAL 42 DAY), 'returned'),
  (9, 12, DATE_SUB(CURDATE(), INTERVAL 70 DAY), DATE_SUB(CURDATE(), INTERVAL 56 DAY), DATE_SUB(CURDATE(), INTERVAL 55 DAY), 'returned'),
  (11, 14, DATE_SUB(CURDATE(), INTERVAL 65 DAY), DATE_SUB(CURDATE(), INTERVAL 51 DAY), DATE_SUB(CURDATE(), INTERVAL 48 DAY), 'returned'),
  (13, 16, DATE_SUB(CURDATE(), INTERVAL 80 DAY), DATE_SUB(CURDATE(), INTERVAL 66 DAY), DATE_SUB(CURDATE(), INTERVAL 67 DAY), 'returned'),
  (15, 18, DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_SUB(CURDATE(), INTERVAL 76 DAY), DATE_SUB(CURDATE(), INTERVAL 75 DAY), 'returned'),
  (17, 22, DATE_SUB(CURDATE(), INTERVAL 100 DAY), DATE_SUB(CURDATE(), INTERVAL 86 DAY), DATE_SUB(CURDATE(), INTERVAL 84 DAY), 'returned'),
  (19, 24, DATE_SUB(CURDATE(), INTERVAL 110 DAY), DATE_SUB(CURDATE(), INTERVAL 96 DAY), DATE_SUB(CURDATE(), INTERVAL 95 DAY), 'returned'),
  
  -- Returned late (with fines)
  (2, 3, DATE_SUB(CURDATE(), INTERVAL 120 DAY), DATE_SUB(CURDATE(), INTERVAL 106 DAY), DATE_SUB(CURDATE(), INTERVAL 100 DAY), 'returned'),
  (4, 19, DATE_SUB(CURDATE(), INTERVAL 130 DAY), DATE_SUB(CURDATE(), INTERVAL 116 DAY), DATE_SUB(CURDATE(), INTERVAL 110 DAY), 'returned'),
  (6, 23, DATE_SUB(CURDATE(), INTERVAL 140 DAY), DATE_SUB(CURDATE(), INTERVAL 126 DAY), DATE_SUB(CURDATE(), INTERVAL 118 DAY), 'returned'),
  (8, 26, DATE_SUB(CURDATE(), INTERVAL 150 DAY), DATE_SUB(CURDATE(), INTERVAL 136 DAY), DATE_SUB(CURDATE(), INTERVAL 130 DAY), 'returned'),
  
  -- Lost book
  (12, 27, DATE_SUB(CURDATE(), INTERVAL 180 DAY), DATE_SUB(CURDATE(), INTERVAL 166 DAY), NULL, 'lost'),
  
  -- Additional recent loans
  (14, 28, DATE_SUB(CURDATE(), INTERVAL 6 DAY), DATE_ADD(CURDATE(), INTERVAL 8 DAY), NULL, 'active'),
  (16, 30, DATE_SUB(CURDATE(), INTERVAL 9 DAY), DATE_ADD(CURDATE(), INTERVAL 5 DAY), NULL, 'active'),
  (18, 32, DATE_SUB(CURDATE(), INTERVAL 1 DAY), DATE_ADD(CURDATE(), INTERVAL 13 DAY), NULL, 'active');

-- Step 7: Insert fines (depends on loans)
INSERT INTO fines (loan_id, fine_amount, fine_reason, paid, payment_date) VALUES
  -- Overdue fines (unpaid)
  (8, 4.00, 'overdue', FALSE, NULL),   -- 16 days late
  (9, 2.75, 'overdue', FALSE, NULL),   -- 11 days late
  (10, 6.50, 'overdue', FALSE, NULL),  -- 26 days late
  (11, 5.25, 'overdue', FALSE, NULL),  -- 21 days late
  (12, 2.00, 'overdue', FALSE, NULL),  -- 8 days late
  
  -- Late return fines (paid)
  (21, 1.50, 'overdue', TRUE, DATE_SUB(CURDATE(), INTERVAL 99 DAY)),  -- 6 days late, paid
  (22, 1.50, 'overdue', TRUE, DATE_SUB(CURDATE(), INTERVAL 109 DAY)), -- 6 days late, paid
  (23, 2.00, 'overdue', TRUE, DATE_SUB(CURDATE(), INTERVAL 117 DAY)), -- 8 days late, paid
  (24, 1.50, 'overdue', TRUE, DATE_SUB(CURDATE(), INTERVAL 129 DAY)), -- 6 days late, paid
  
  -- Lost book fine (unpaid)
  (25, 25.00, 'lost', FALSE, NULL);

-- Step 8: Insert event registrations (depends on events and members)
INSERT INTO event_registrations (event_id, member_id, registration_date) VALUES
  -- Mystery Book Club
  (1, 1, DATE_SUB(CURDATE(), INTERVAL 5 DAY)),
  (1, 2, DATE_SUB(CURDATE(), INTERVAL 4 DAY)),
  (1, 5, DATE_SUB(CURDATE(), INTERVAL 3 DAY)),
  (1, 9, DATE_SUB(CURDATE(), INTERVAL 2 DAY)),
  (1, 15, DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
  
  -- Children's Story Time
  (2, 3, DATE_SUB(CURDATE(), INTERVAL 7 DAY)),
  (2, 7, DATE_SUB(CURDATE(), INTERVAL 6 DAY)),
  (2, 13, DATE_SUB(CURDATE(), INTERVAL 5 DAY)),
  
  -- Stephen King Event
  (3, 1, DATE_SUB(CURDATE(), INTERVAL 10 DAY)),
  (3, 2, DATE_SUB(CURDATE(), INTERVAL 9 DAY)),
  (3, 5, DATE_SUB(CURDATE(), INTERVAL 8 DAY)),
  (3, 9, DATE_SUB(CURDATE(), INTERVAL 7 DAY)),
  (3, 11, DATE_SUB(CURDATE(), INTERVAL 6 DAY)),
  (3, 15, DATE_SUB(CURDATE(), INTERVAL 5 DAY)),
  (3, 18, DATE_SUB(CURDATE(), INTERVAL 4 DAY)),
  
  -- Digital Literacy Workshop
  (4, 3, DATE_SUB(CURDATE(), INTERVAL 3 DAY)),
  (4, 7, DATE_SUB(CURDATE(), INTERVAL 2 DAY)),
  (4, 10, DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
  
  -- Teen Summer Reading
  (5, 3, DATE_SUB(CURDATE(), INTERVAL 8 DAY)),
  (5, 7, DATE_SUB(CURDATE(), INTERVAL 7 DAY)),
  (5, 13, DATE_SUB(CURDATE(), INTERVAL 6 DAY)),
  (5, 16, DATE_SUB(CURDATE(), INTERVAL 5 DAY)),
  
  -- Classic Literature Club
  (6, 1, DATE_SUB(CURDATE(), INTERVAL 4 DAY)),
  (6, 5, DATE_SUB(CURDATE(), INTERVAL 3 DAY)),
  (6, 9, DATE_SUB(CURDATE(), INTERVAL 2 DAY));

-- Step 9: Insert audit log entries (no dependencies)
INSERT INTO audit_log (table_name, action, record_id, description) VALUES
  ('members', 'INSERT', 1, 'New member registration: Alice Johnson'),
  ('loans', 'UPDATE', 13, 'Book returned: Harry Potter copy 2'),
  ('fines', 'INSERT', 1, 'Overdue fine created for loan 8'),
  ('members', 'UPDATE', 4, 'Member status changed to suspended due to unpaid fines'),
  ('loans', 'UPDATE', 25, 'Book marked as lost after 180 days');
```

### ✅ Testing Your Data

After inserting data, verify it's correct:

```sql
-- Check row counts for each table
SELECT 'members' AS table_name, COUNT(*) AS row_count FROM members
UNION ALL SELECT 'authors', COUNT(*) FROM authors
UNION ALL SELECT 'books', COUNT(*) FROM books
UNION ALL SELECT 'book_copies', COUNT(*) FROM book_copies
UNION ALL SELECT 'loans', COUNT(*) FROM loans
UNION ALL SELECT 'fines', COUNT(*) FROM fines
UNION ALL SELECT 'events', COUNT(*) FROM events
UNION ALL SELECT 'event_registrations', COUNT(*) FROM event_registrations
UNION ALL SELECT 'audit_log', COUNT(*) FROM audit_log;

-- View sample data from key tables
SELECT * FROM members LIMIT 5;
SELECT * FROM books LIMIT 5;
SELECT * FROM loans WHERE status = 'active' LIMIT 5;
```

### 🎯 Success Criteria

- [ ] All 9 tables have data inserted
- [ ] Row counts meet minimum requirements
- [ ] Data is realistic and varied
- [ ] Dates make sense (loan dates before due dates, etc.)
- [ ] Foreign key relationships are correct
- [ ] No error messages during insertion

### 💡 Beginner Tips

- **Insert parent tables first** (authors before books, members before loans)
- **Use date functions** like DATE_SUB(CURDATE(), INTERVAL 30 DAY) for varied dates
- **Create edge cases** for testing (overdue loans, expired memberships)
- **Multi-row inserts are efficient**: INSERT INTO table VALUES (...), (...), (...)
- **Check data after each INSERT** to catch errors early

---

**🎉 Congratulations! You've completed Phase 1 - Foundation**

Take a break, then continue with Goals 3-4 (Basic Queries and Aggregation).

---

