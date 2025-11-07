# 🎓 MySQL Capstone Project: CityLibrary Management System

> **🎯 Difficulty Level:** Beginner to Intermediate  
> **⏱️ Estimated Time:** 8-12 hours (2-3 days recommended)  
> **📊 Minimum for Passing:** Complete Goals 1-8 (Core Requirements = 100%)  
> **⭐ Bonus to Excel:** Complete Goals 9-12 (Advanced Features = +20%)

---

## � QUICK START CARD - Everything You Need to Know

### What Am I Building?
A complete library management database with 9 tables tracking books, members, loans, fines, and events.

### What Do I Need to Pass? (100%)
✅ Goals 1-2: Create database schema + insert sample data (20%)  
✅ Goals 3-4: Write basic SELECT and aggregation queries (20%)  
✅ Goals 5-6: Write JOIN and subquery queries (20%)  
✅ Goals 7-8: Write set operations and window function queries (20%)  
✅ Documentation: Screenshots + clean code (20%)  

**Total: 10-14 hours over 2-3 days**

### The 9 Tables I Need to Create
1. **authors** - Book authors
2. **members** - Library members  
3. **books** - Book catalog
4. **book_copies** - Physical copies
5. **loans** - Borrowing records
6. **fines** - Late fees
7. **events** - Library events
8. **event_registrations** - Event signups
9. **audit_log** - Change tracking

### Order Matters! (Dependencies)
```
1st: authors, members, events, audit_log (no dependencies)
2nd: books (needs authors)
3rd: book_copies (needs books)
4th: loans (needs members + book_copies)
5th: fines (needs loans), event_registrations (needs events + members)
```

### Minimum Data to Insert
- 20 members, 10 authors, 25 books, 40 copies, 30 loans, 10 fines, 8 events, 25 registrations

### Quick File Structure
```
project_folder/
├── sql/01_schema.sql, 02_data.sql, 03-12_queries.sql
├── screenshots/ (one folder per goal)
└── README.md
```

### What If I'm Stuck?
1. Read error message (line number + problem)
2. Check: Did I `USE city_library;`?
3. Check: Tables created in correct order?
4. See [Troubleshooting Guide](#-beginner-troubleshooting-guide)

### Bonus Goals (Optional +20%)
Goal 9: Procedures (+5%) | Goal 10: Triggers (+5%)  
Goal 11: Indexes (+5%) | Goal 12: Transactions (+5%)

**Ready? Let's go! 🚀 Start with [Day 0 Setup](#-prerequisites)**

---

## �📑 TABLE OF CONTENTS - Your Roadmap to Success!

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

### 🛠️ Day 0: Environment Setup (Do This First!)

Complete these setup tasks before beginning the actual project:

**Software Installation Checklist:**
- [ ] Install MySQL 5.7+ or MySQL 8.0
- [ ] Install MySQL Workbench OR VS Code with MySQL extension
- [ ] Test MySQL connection (can you log in?)
- [ ] Create a test database and run a simple query
- [ ] Set up screenshot tool (Snipping Tool, Greenshot, or built-in)
- [ ] Create project folder structure (see below)
- [ ] Have a text editor ready for documentation

**Project Folder Structure:**
```
city_library_project/
├── sql/
│   ├── 01_schema.sql              (All CREATE TABLE statements)
│   ├── 02_sample_data.sql         (All INSERT statements)
│   ├── 03_goal3_basic_queries.sql
│   ├── 04_goal4_aggregations.sql
│   ├── 05_goal5_joins.sql
│   ├── 06_goal6_subqueries.sql
│   ├── 07_goal7_set_operations.sql
│   ├── 08_goal8_window_functions.sql
│   ├── 09_goal9_procedures.sql    (Optional)
│   ├── 10_goal10_triggers.sql     (Optional)
│   ├── 11_goal11_indexes.sql      (Optional)
│   └── 12_goal12_transactions.sql (Optional)
├── screenshots/
│   ├── goal1/
│   ├── goal2/
│   └── ... (one folder per goal)
└── README.md                      (Project documentation)
```

**Quick MySQL Connection Test:**
```sql
-- Run these commands to verify your setup:
CREATE DATABASE test_connection;
USE test_connection;
CREATE TABLE test_table (id INT, name VARCHAR(50));
INSERT INTO test_table VALUES (1, 'Test');
SELECT * FROM test_table;
DROP DATABASE test_connection;
-- If all commands work, you're ready! ✅
```

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

### Progress Tracker - Track Your Journey! 🎯

Use this to track your completion percentage and stay motivated:

```
CORE REQUIREMENTS (100% Total)
├─ Phase 1: Foundation
│  ├─ [  ] Goal 1: Database Schema (10%) ⏱️ 2-3 hours
│  ├─ [  ] Goal 2: Sample Data (10%) ⏱️ 2-3 hours
│  ├─ [  ] Goal 3: Basic Queries (10%) ⏱️ 1-2 hours
│  └─ [  ] Goal 4: Aggregation (10%) ⏱️ 1-2 hours
│      └─ CHECKPOINT: 40% Complete! 🎉
│
├─ Phase 2: Intermediate
│  ├─ [  ] Goal 5: Joins (10%) ⏱️ 2-3 hours
│  ├─ [  ] Goal 6: Subqueries/CTEs (10%) ⏱️ 2-3 hours
│  ├─ [  ] Goal 7: Set Operations (10%) ⏱️ 1-2 hours
│  └─ [  ] Goal 8: Window Functions (10%) ⏱️ 2-3 hours
│      └─ CHECKPOINT: 80% Complete! 🎉
│
├─ Phase 3: Documentation
│  ├─ [  ] Documentation & Screenshots (10%)
│  └─ [  ] Code Quality & Comments (10%)
│      └─ CHECKPOINT: 100% Complete! 🎉🎉🎉

BONUS GOALS (Optional - Up to +20%)
├─ [  ] Goal 9: Procedures & Functions (+5%) ⏱️ 1-2 hours
├─ [  ] Goal 10: Triggers (+5%) ⏱️ 2-3 hours
├─ [  ] Goal 11: Indexes & Optimization (+5%) ⏱️ 2-3 hours
└─ [  ] Goal 12: Transactions (+5%) ⏱️ 1 hour
    └─ MAXIMUM: 120% Complete! ⭐⭐⭐⭐

Current Progress: ___% | Hours Invested: ___
```

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

Insert test data that represents realistic library operations. Your data should be diverse enough to properly test all queries in later goals.

### 📊 Minimum Data Requirements

| Table | Minimum Rows | What to Include | Why This Matters |
|-------|--------------|-----------------|------------------|
| **members** | 20 | • Mix of all membership types (standard/premium/student)<br>• Different statuses (active/suspended/expired)<br>• Various join dates (spread over 2 years) | Tests aggregation by type, filtering by status |
| **authors** | 10 | • Authors from different countries<br>• Various birth years | Tests multi-table joins, author popularity queries |
| **books** | 25 | • Multiple genres (at least 5 different)<br>• Various publication years<br>• Different total_copies values | Tests genre analysis, availability calculations |
| **book_copies** | 40 | • Some books with multiple copies<br>• All conditions (excellent/good/fair/poor)<br>• Various acquisition dates | Tests availability, condition reporting |
| **loans** | 30 | • Mix of statuses (active/returned/lost)<br>• Some overdue (due_date in past)<br>• Some on time returns | Tests overdue calculations, loan history |
| **fines** | 10 | • Both paid (TRUE) and unpaid (FALSE)<br>• Different reasons (overdue/damage/lost)<br>• Various amounts | Tests fine revenue, outstanding balance queries |
| **events** | 8 | • All event types (book_club/workshop/reading_program/author_visit)<br>• Some past, some future dates | Tests event filtering, registration analysis |
| **event_registrations** | 25 | • Multiple members per event<br>• Multiple events per member<br>• Various registration dates | Tests many-to-many relationships |
| **audit_log** | 5 | • Different table names<br>• Different actions (INSERT/UPDATE/DELETE) | Tests trigger functionality later |

**📝 Data Quality Checklist:**
- [ ] All membership types represented (standard, premium, student)
- [ ] At least 3 members with status = 'suspended' or 'expired'
- [ ] At least 5 different book genres
- [ ] At least 10 active loans (status = 'active')
- [ ] At least 5 overdue loans (due_date < CURDATE() and status = 'active')
- [ ] At least 3 books with multiple copies
- [ ] At least 5 returned loans (status = 'returned' with return_date filled)
- [ ] At least 4 unpaid fines (paid = FALSE)
- [ ] At least 2 future events (event_date > CURDATE())
- [ ] Foreign key relationships all valid (no orphaned records)

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

### ✅ Validation Queries - Verify Your Data

Run these queries to confirm your data is properly inserted:

```sql
-- Check row counts (should meet minimum requirements)
SELECT 'members' as table_name, COUNT(*) as row_count FROM members
UNION ALL SELECT 'authors', COUNT(*) FROM authors
UNION ALL SELECT 'books', COUNT(*) FROM books
UNION ALL SELECT 'book_copies', COUNT(*) FROM book_copies
UNION ALL SELECT 'loans', COUNT(*) FROM loans
UNION ALL SELECT 'fines', COUNT(*) FROM fines
UNION ALL SELECT 'events', COUNT(*) FROM events
UNION ALL SELECT 'event_registrations', COUNT(*) FROM event_registrations
UNION ALL SELECT 'audit_log', COUNT(*) FROM audit_log;

-- Verify membership type distribution
SELECT membership_type, COUNT(*) as count
FROM members
GROUP BY membership_type;
-- Expected: All three types (standard, premium, student) present

-- Verify loan status distribution
SELECT status, COUNT(*) as count
FROM loans
GROUP BY status;
-- Expected: Mix of active, returned, and possibly lost

-- Check for overdue loans (should have some)
SELECT COUNT(*) as overdue_count
FROM loans
WHERE status = 'active' AND due_date < CURDATE();
-- Expected: At least 5

-- Verify foreign key relationships work
SELECT 
    (SELECT COUNT(*) FROM books WHERE author_id NOT IN (SELECT author_id FROM authors)) as orphaned_books,
    (SELECT COUNT(*) FROM book_copies WHERE book_id NOT IN (SELECT book_id FROM books)) as orphaned_copies,
    (SELECT COUNT(*) FROM loans WHERE member_id NOT IN (SELECT member_id FROM members)) as orphaned_loans;
-- Expected: All zeros (no orphaned records)

-- Check genre diversity
SELECT genre, COUNT(*) as book_count
FROM books
GROUP BY genre;
-- Expected: At least 5 different genres
```

**✅ Success Indicators:**
- All row counts meet or exceed minimums
- All three membership types present
- Mix of active and returned loans
- At least 5 overdue loans for testing
- No orphaned records (foreign key validation)
- At least 5 different book genres

**❌ If Validation Fails:**
- Add more data to tables with insufficient rows
- Ensure variety in categorical fields (membership_type, genre, status)
- Create more overdue loans by setting due_date in the past
- Fix any foreign key issues before proceeding

---

**🎉 Checkpoint: You're 25% Complete!**

**What You've Accomplished:**
- ✅ Created a complete 9-table database schema
- ✅ Inserted comprehensive, realistic sample data
- ✅ Validated data quality and relationships

**Quick Celebration Check:**
```sql
-- See your complete library system!
SELECT 
    (SELECT COUNT(*) FROM members) as total_members,
    (SELECT COUNT(*) FROM books) as total_books,
    (SELECT COUNT(*) FROM loans) as total_loans,
    (SELECT SUM(fine_amount) FROM fines WHERE paid = FALSE) as outstanding_fines;
```

**What's Next:** Goals 3-4 will teach you to extract insights from this data using SELECT queries and aggregations. Take a 10-minute break! ☕

---

## 🟢 PHASE 1: BASIC QUERIES (Required - Continued)

# Goal 3: Basic Information Retrieval Queries

**📌 Module Focus:** SELECT Fundamentals (Module 2)  
**⏱️ Estimated Time:** 1-2 hours  
**🎯 What You'll Learn:** SELECT, WHERE, ORDER BY, LIMIT, LIKE, IN, BETWEEN

### What You Need to Do

Write 8 queries that retrieve and filter data from single tables. These queries help librarians find specific information quickly.

### 📝 Query Requirements

Write queries for the following scenarios:

#### Query 3.1: List All Active Members
**Business Need:** Get a contact list of all active library members.

```sql
-- Display: first name, last name, email, membership type
-- Filter: Only active members
-- Sort: By last name, then first name alphabetically
```

**Expected Result Format:**
```
first_name | last_name | email              | membership_type
-----------+-----------+--------------------+----------------
Henry      | Anderson  | henry.a@email.com  | standard
Emma       | Brown     | emma.b@email.com   | premium
...        | ...       | ...                | ...
```
*Your result should show all members where status = 'active'*

---

#### Query 3.2: Find Books Published After 2000
**Business Need:** Librarians want to promote newer books.

```sql
-- Display: title, author name, publication year, genre
-- Filter: Published in 2001 or later
-- Sort: By publication year (newest first)
```

**Hint:** You'll need to JOIN books with authors table.

**Expected Result Format:**
```
title                              | author_name | pub_year | genre
-----------------------------------+-------------+----------+-----------
Educated                           | (NULL)      | 2018     | Biography
Sapiens: A Brief History...        | (NULL)      | 2011     | History
...
```

---

#### Query 3.3: Search Books by Genre
**Business Need:** A patron asks "What fiction books do you have?"

```sql
-- Display: title, author name, genre, total copies
-- Filter: Genre is 'Fiction'
-- Sort: By title alphabetically
```

---

#### Query 3.4: Find Overdue Loans
**Business Need:** Identify which books are overdue right now.

```sql
-- Display: member name, book title, loan date, due date, days overdue
-- Filter: Due date has passed AND not yet returned (status = 'active')
-- Sort: By days overdue (most overdue first)
-- Hint: Use DATEDIFF(CURDATE(), due_date) to calculate days overdue
```

---

#### Query 3.5: Members Who Joined in the Last 6 Months
**Business Need:** Track new member growth.

```sql
-- Display: first name, last name, join date, membership type
-- Filter: Joined within last 180 days
-- Sort: By join date (newest first)
```

**Hint:** Use DATE_SUB(CURDATE(), INTERVAL 180 DAY)

---

#### Query 3.6: Books in Poor Condition
**Business Need:** Identify books that need replacement.

```sql
-- Display: book title, copy number, condition, acquisition date
-- Filter: Condition is 'poor' or 'fair'
-- Sort: By condition (poor first), then by acquisition date (oldest first)
```

---

#### Query 3.7: Top 10 Most Expensive Unpaid Fines
**Business Need:** Follow up on members with high unpaid fines.

```sql
-- Display: member name, fine amount, fine reason, loan date
-- Filter: Fines that are NOT paid (paid = FALSE)
-- Sort: By fine amount (highest first)
-- Limit: Top 10 only
```

---

#### Query 3.8: Upcoming Events This Month
**Business Need:** Promote events happening soon.

```sql
-- Display: event name, event date, event type, max attendees
-- Filter: Event date is in the future AND within 30 days
-- Sort: By event date (soonest first)
```

---

### ✅ Testing Your Queries

For each query, verify:
- Results match the filter criteria
- Sorting is correct
- Column names are descriptive
- No errors or warnings

### 🎯 Success Criteria

- [ ] All 8 queries run without errors
- [ ] Results are filtered correctly
- [ ] Data is sorted as specified
- [ ] Column aliases are used for calculated fields
- [ ] Screenshots show query + results for each

---

# Goal 4: Statistical Summaries and Aggregation

**📌 Module Focus:** Aggregates and Grouping (Module 4)  
**⏱️ Estimated Time:** 1-2 hours  
**🎯 What You'll Learn:** COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING

### What You Need to Do

Write 8 queries that calculate statistics and summaries. These help library management understand trends and patterns.

### 📝 Query Requirements

#### Query 4.1: Count Members by Membership Type
**Business Need:** How many members of each type do we have?

```sql
-- Group by: membership_type
-- Calculate: COUNT of members, percentage of total
-- Display: membership type, member count, percentage
-- Sort: By count (highest first)
```

**Expected Output:**
```
membership_type | member_count | percentage
premium         | 8            | 40%
standard        | 7            | 35%
student         | 5            | 25%
```

---

#### Query 4.2: Total Fines Collected vs Outstanding
**Business Need:** What's our fine revenue and how much is owed?

```sql
-- Calculate:
--   - Total fines collected (paid = TRUE)
--   - Total fines outstanding (paid = FALSE)
--   - Overall total
-- Display: payment status, total amount, count of fines
```

---

#### Query 4.3: Most Popular Genres
**Business Need:** Which genres should we buy more of?

```sql
-- Group by: genre
-- Calculate: 
--   - COUNT of distinct books
--   - SUM of total_copies
-- Display: genre, number of titles, total copies
-- Sort: By total copies (most popular first)
-- Limit: Top 5 genres
```

---

#### Query 4.4: Average Loan Duration by Member Type
**Business Need:** Do premium members keep books longer?

```sql
-- Group by: membership_type
-- Calculate: AVG days between loan_date and return_date
-- Filter: Only returned books (status = 'returned')
-- Display: membership type, average days, count of loans
-- Sort: By average days (longest first)
```

**Hint:** Use DATEDIFF(return_date, loan_date)

---

#### Query 4.5: Books Never Borrowed
**Business Need:** Identify unpopular books for removal.

```sql
-- Find: book_copies that have ZERO loans
-- Display: book title, author, genre, acquisition date
-- Sort: By acquisition date (oldest first)
-- Hint: Use LEFT JOIN and WHERE loans.loan_id IS NULL
```

---

#### Query 4.6: Member Borrowing Activity
**Business Need:** Who are our most active borrowers?

```sql
-- Group by: member
-- Calculate:
--   - COUNT of total loans (all time)
--   - COUNT of active loans (currently borrowed)
--   - SUM of unpaid fines
-- Display: member name, total loans, active loans, unpaid fines
-- Filter: Members with at least 1 loan
-- Sort: By total loans (most active first)
-- Limit: Top 10 members
```

---

#### Query 4.7: Monthly Loan Statistics
**Business Need:** Track circulation trends over time.

```sql
-- Group by: Year and Month of loan_date
-- Calculate:
--   - COUNT of loans
--   - COUNT of distinct members
--   - COUNT of distinct books
-- Display: year, month, total loans, unique borrowers, unique books
-- Sort: By year and month (most recent first)
-- Limit: Last 6 months
```

**Hint:** Use YEAR(loan_date) and MONTH(loan_date) or DATE_FORMAT(loan_date, '%Y-%m')

---

#### Query 4.8: Event Registration Summary
**Business Need:** Which events are most popular?

```sql
-- Group by: event
-- Calculate:
--   - COUNT of registrations
--   - Percentage of max capacity filled
-- Display: event name, event date, registrations, max attendees, capacity percentage
-- Filter: Only future events
-- Sort: By capacity percentage (fullest first)
```

---

### ✅ Testing Your Queries

For each query, verify:
- Aggregations calculate correctly
- GROUP BY groups data properly
- HAVING filters work (if used)
- Results are sorted as specified

### 🎯 Success Criteria

- [ ] All 8 queries run without errors
- [ ] Aggregations (COUNT, SUM, AVG) are correct
- [ ] GROUP BY groups data appropriately
- [ ] Results are sorted and limited as specified
- [ ] Screenshots show query + results

---

**🎉 Congratulations! You've completed Phase 1!**

You now have a working database with basic queries. Take a break before starting Phase 2 (Intermediate Queries).

---

## 🟡 PHASE 2: INTERMEDIATE QUERIES (Required)

# Goal 5: Multi-Table Joins and Analysis

**📌 Module Focus:** Joins (Module 5)  
**⏱️ Estimated Time:** 2-3 hours  
**🎯 What You'll Learn:** INNER JOIN, LEFT JOIN, RIGHT JOIN, self-joins, multiple joins

### What You Need to Do

Write 8 queries that combine data from multiple tables. Real-world reporting requires joining related tables.

### 📝 Query Requirements

#### Query 5.1: Complete Loan History with Details
**Business Need:** Full report of all loans with member and book information.

```sql
-- Join: loans + members + book_copies + books + authors
-- Display: 
--   - Member name and email
--   - Book title and author
--   - Loan date, due date, return date, status
-- Sort: By loan date (most recent first)
-- Limit: 20 rows
```

---

#### Query 5.2: Books Currently On Loan
**Business Need:** Which books are checked out right now?

```sql
-- Join: loans + book_copies + books + authors + members
-- Filter: status = 'active' (not returned)
-- Display:
--   - Book title and author
--   - Copy number
--   - Member name
--   - Loan date and due date
--   - Days until due (negative if overdue)
-- Sort: By due date (soonest first)
```

---

#### Query 5.3: Members with Overdue Books and Fines
**Business Need:** Who owes us money?

```sql
-- Join: members + loans + fines
-- Filter: fines.paid = FALSE
-- Display:
--   - Member name, email, phone
--   - Number of overdue books
--   - Total unpaid fines
-- Group by: member
-- Sort: By total unpaid fines (highest first)
```

---

#### Query 5.4: Book Availability Report
**Business Need:** For each book, show total copies vs copies on loan.

```sql
-- Join: books + book_copies + loans (LEFT JOIN for availability)
-- Calculate:
--   - Total copies (COUNT of book_copies)
--   - Copies on loan (COUNT of active loans)
--   - Available copies (total - on loan)
-- Display: title, author, total copies, on loan, available
-- Group by: book
-- Filter: Show all books (even those with 0 loans)
-- Sort: By available copies (least available first)
```

---

#### Query 5.5: Event Attendance List
**Business Need:** Who's registered for each event?

```sql
-- Join: events + event_registrations + members
-- Display:
--   - Event name and date
--   - Member name and email
--   - Registration date
-- Filter: Only future events (event_date >= CURDATE())
-- Sort: By event date, then member last name
```

---

#### Query 5.6: Author Popularity Report
**Business Need:** Which authors have the most loans?

```sql
-- Join: authors + books + book_copies + loans
-- Group by: author
-- Calculate:
--   - COUNT of distinct books by author
--   - COUNT of total loans
--   - AVG loans per book
-- Display: author name, book count, total loans, avg loans per book
-- Filter: Only authors with at least 1 loan
-- Sort: By total loans (most popular first)
-- Limit: Top 10 authors
```

---

#### Query 5.7: Members Who Never Borrowed
**Business Need:** Inactive members who might need outreach.

```sql
-- Join: members LEFT JOIN loans
-- Filter: loans.loan_id IS NULL
-- Display: member name, email, join date, membership type
-- Sort: By join date (oldest first)
```

---

#### Query 5.8: Self-Join - Members from Same Address
**Business Need:** Identify family accounts or duplicates.

```sql
-- Self-join: members as m1 JOIN members as m2
-- Filter: 
--   - Same address
--   - Different member_id (m1.member_id < m2.member_id to avoid duplicates)
-- Display: 
--   - Member 1 name
--   - Member 2 name
--   - Shared address
-- Sort: By address
```

---

### ✅ Testing Your Queries

For each query:
- Verify all joins connect properly (no missing data)
- Check that LEFT JOINs preserve all left table rows
- Ensure filters work correctly with joined data

### 🎯 Success Criteria

- [ ] All 8 queries run without errors
- [ ] Joins connect tables correctly
- [ ] LEFT JOINs preserve unmatched rows where needed
- [ ] Filters and sorts work with joined data
- [ ] Screenshots show query + results

---

# Goal 6: Subqueries and Common Table Expressions

**📌 Module Focus:** Subqueries and CTEs (Module 6)  
**⏱️ Estimated Time:** 2-3 hours  
**🎯 What You'll Learn:** Subqueries in WHERE, FROM, SELECT; WITH clauses (CTEs)

### What You Need to Do

Write 8 queries using subqueries or CTEs to solve complex problems. These are powerful tools for breaking down complex logic.

### 📝 Query Requirements

#### Query 6.1: Members with Above-Average Fines
**Business Need:** Find members with unusually high fines.

```sql
-- Use subquery to calculate average fine amount
-- Filter: Members whose total unpaid fines > average
-- Display: member name, total unpaid fines, number of fines
-- Sort: By total fines (highest first)
```

**Example Structure:**
```sql
SELECT ...
FROM members m
WHERE (SELECT SUM(...) FROM fines ...) > (SELECT AVG(...) FROM fines ...)
```

---

#### Query 6.2: Books More Popular Than Average
**Business Need:** Which books should we buy more copies of?

```sql
-- Subquery: Calculate average loans per book
-- Main query: Find books with more loans than average
-- Display: title, author, total loans, average loans (for comparison)
-- Sort: By total loans (most popular first)
```

---

#### Query 6.3: CTE - Member Borrowing Summary
**Business Need:** Complex member activity report.

```sql
-- CTE 1: Calculate total loans per member
-- CTE 2: Calculate total fines per member
-- CTE 3: Calculate active loans per member
-- Main query: Combine all CTEs
-- Display: member name, total loans, active loans, total fines, status
-- Sort: By total loans (most active first)
```

**Example Structure:**
```sql
WITH loan_counts AS (
  SELECT member_id, COUNT(*) as total_loans FROM loans GROUP BY member_id
),
fine_totals AS (
  SELECT member_id, SUM(fine_amount) as total_fines FROM fines ... GROUP BY member_id
),
active_counts AS (
  SELECT member_id, COUNT(*) as active_loans FROM loans WHERE status='active' GROUP BY member_id
)
SELECT m.first_name, ...
FROM members m
LEFT JOIN loan_counts lc ON ...
LEFT JOIN fine_totals ft ON ...
LEFT JOIN active_counts ac ON ...
```

---

#### Query 6.4: Find Books Never Loaned (Subquery Method)
**Business Need:** Alternative approach to finding unpopular books.

```sql
-- Use NOT IN or NOT EXISTS subquery
-- Main query: books table
-- Subquery: book_ids that have been loaned
-- Display: title, author, genre, total copies
-- Sort: By publication year (oldest first)
```

---

#### Query 6.5: Members Who Attended All Book Club Events
**Business Need:** Identify super engaged members.

```sql
-- Subquery 1: Count total book club events
-- Subquery 2: Count events each member attended
-- Filter: Members where attended count = total count
-- Display: member name, events attended
-- Sort: By member name
```

**Hint:** Use HAVING COUNT(*) = (SELECT COUNT(*) FROM events WHERE event_type = 'book_club')

---

#### Query 6.6: CTE - Monthly Revenue Report
**Business Need:** Complex financial report.

```sql
-- CTE 1: Fines collected per month
-- CTE 2: New memberships per month (estimated revenue)
-- Main query: Combine revenue sources by month
-- Display: year-month, fine revenue, membership revenue, total revenue
-- Sort: By month (most recent first)
-- Limit: Last 12 months
```

---

#### Query 6.7: Correlated Subquery - Loan History
**Business Need:** For each book, show most recent loan.

```sql
-- Use correlated subquery to find MAX(loan_date) per book
-- Display: book title, author, most recent loan date, borrower name
-- Filter: Only books that have been loaned at least once
-- Sort: By most recent loan date (newest first)
```

**Example Structure:**
```sql
SELECT b.title, ...
FROM books b
WHERE EXISTS (
  SELECT 1 FROM loans l
  JOIN book_copies bc ON l.copy_id = bc.copy_id
  WHERE bc.book_id = b.book_id
)
```

---

#### Query 6.8: CTE - Book Recommendation Engine
**Business Need:** Recommend books to members based on genre preferences.

```sql
-- CTE 1: Determine each member's favorite genre (most borrowed)
-- CTE 2: Find highly-rated books in those genres
-- Main query: Match members with recommended books
-- Display: member name, favorite genre, recommended book title
-- Filter: Don't recommend books they've already borrowed
-- Limit: Top 5 recommendations per member
```

---

### ✅ Testing Your Queries

For each query:
- Verify subqueries return expected results when run alone
- Check CTEs can be queried independently
- Ensure correlated subqueries reference correct tables

### 🎯 Success Criteria

- [ ] All 8 queries run without errors
- [ ] Subqueries filter/calculate correctly
- [ ] CTEs make complex queries readable
- [ ] Results match business requirements
- [ ] Screenshots show query + results

---

# Goal 7: Set Operations and Combined Results

**📌 Module Focus:** Set Operations (Module 7)  
**⏱️ Estimated Time:** 1-2 hours  
**🎯 What You'll Learn:** UNION, UNION ALL, INTERSECT (simulated), EXCEPT (simulated)

### What You Need to Do

Write 5 queries that combine result sets from multiple queries. Useful for creating comprehensive reports.

### 📝 Query Requirements

#### Query 7.1: All People in the System
**Business Need:** Master contact list (members + authors for events).

```sql
-- UNION query combining:
--   - Members: name, email, 'Member' as type
--   - Authors: name, null as email, 'Author' as type
-- Display: full name, email, type
-- Sort: By type, then name
-- Remove duplicates: Use UNION (not UNION ALL)
```

---

#### Query 7.2: Comprehensive Activity Log
**Business Need:** Timeline of all library activities.

```sql
-- UNION ALL of:
--   - Loans: 'Loan' as activity, loan_date, member name, book title
--   - Events: 'Event' as activity, event_date, event name, null as person
--   - Registrations: 'Registration' as activity, registration_date, member name, event name
-- Display: activity type, date, description
-- Sort: By date (most recent first)
-- Limit: Last 50 activities
```

---

#### Query 7.3: Books Available vs Currently Loaned
**Business Need:** Two-part inventory report.

```sql
-- Part 1 (UNION): Available books
--   - Books with copies where NO active loan exists
-- Part 2 (UNION): Books on loan
--   - Books with active loans
-- Display: book title, status ('Available' or 'On Loan'), count
-- Sort: By title
```

---

#### Query 7.4: Members with Issues
**Business Need:** Combine different member problems for follow-up.

```sql
-- UNION of:
--   - Members with overdue books: 'Overdue' as issue
--   - Members with unpaid fines: 'Unpaid Fines' as issue
--   - Suspended members: 'Suspended' as issue
-- Display: member name, email, issue type, count of issues
-- Sort: By member name
```

---

#### Query 7.5: Popular vs Unpopular Books
**Business Need:** Acquisition decision report.

```sql
-- UNION of:
--   - Top 10 most borrowed books: 'Popular' as category
--   - 10 least borrowed books: 'Unpopular' as category
-- Display: book title, author, category, loan count
-- Sort: By category, then loan count
```

---

### ✅ Testing Your Queries

For each query:
- Verify UNION removes duplicates where intended
- Check column counts and types match across queries
- Ensure UNION ALL preserves all rows when needed

### 🎯 Success Criteria

- [ ] All 5 queries run without errors
- [ ] UNION combines result sets correctly
- [ ] Column types match across combined queries
- [ ] Duplicates handled appropriately
- [ ] Screenshots show query + results

---

# Goal 8: Window Functions for Ranking and Analytics

**📌 Module Focus:** Window Functions (Module 8)  
**⏱️ Estimated Time:** 2-3 hours  
**🎯 What You'll Learn:** ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, running totals

### What You Need to Do

Write 8 queries using window functions for advanced analytics. These are powerful for ranking, running totals, and comparisons.

### 📝 Query Requirements

#### Query 8.1: Rank Members by Borrowing Activity
**Business Need:** Leaderboard of most active borrowers.

```sql
-- Use: ROW_NUMBER() and RANK()
-- Partition: Not needed (global ranking)
-- Order by: Total loans (descending)
-- Display: rank, member name, total loans, dense_rank
-- Show difference between RANK() and DENSE_RANK()
```

**Example:**
```sql
SELECT 
  ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) as row_num,
  RANK() OVER (ORDER BY COUNT(*) DESC) as rank,
  DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) as dense_rank,
  m.first_name, m.last_name,
  COUNT(*) as total_loans
FROM members m
JOIN loans l ON m.member_id = l.member_id
GROUP BY m.member_id
ORDER BY total_loans DESC;
```

---

#### Query 8.2: Running Total of Fines Collected
**Business Need:** Track cumulative fine revenue over time.

```sql
-- Use: SUM() OVER (ORDER BY date)
-- Calculate running total of fines paid
-- Display: payment date, fine amount, running total
-- Filter: Only paid fines
-- Sort: By payment date
```

---

#### Query 8.3: Rank Books by Genre
**Business Need:** Best books within each category.

```sql
-- Use: RANK() OVER (PARTITION BY genre ORDER BY loan_count)
-- Partition: By genre
-- Order by: Total loans within genre
-- Display: genre, book title, loans, rank within genre
-- Filter: Show top 3 books per genre
```

**Hint:** Use subquery or CTE to filter WHERE rank <= 3

---

#### Query 8.4: Loan Frequency Comparison
**Business Need:** Compare each member's loans to previous month.

```sql
-- Use: LAG() OVER (PARTITION BY member_id ORDER BY month)
-- Calculate loans per member per month
-- Compare to previous month using LAG()
-- Display: member, month, loans this month, loans last month, difference
-- Sort: By member, then month
```

---

#### Query 8.5: Next Event for Each Member
**Business Need:** What's the next event each registered member will attend?

```sql
-- Use: ROW_NUMBER() OVER (PARTITION BY member_id ORDER BY event_date)
-- Partition: By member
-- Order by: Event date
-- Filter: Only future events (event_date >= CURDATE())
-- Display: member name, next event name, event date
-- Show only the FIRST (ROW_NUMBER = 1) upcoming event per member
```

---

#### Query 8.6: Moving Average of Loans
**Business Need:** Smooth out loan trends over time.

```sql
-- Use: AVG() OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
-- Calculate 7-day moving average of daily loans
-- Display: date, loans that day, 7-day moving average
-- Group by: day (DATE(loan_date))
-- Sort: By date (most recent first)
-- Limit: Last 30 days
```

---

#### Query 8.7: Percentile Ranking of Fines
**Business Need:** Where does each fine fall in the distribution?

```sql
-- Use: PERCENT_RANK() OVER (ORDER BY fine_amount)
-- Calculate percentile for each fine
-- Display: member name, fine amount, percentile (as percentage)
-- Filter: Unpaid fines only
-- Sort: By percentile (highest first)
```

---

#### Query 8.8: Gap Analysis - Days Between Loans
**Business Need:** How often does each member borrow?

```sql
-- Use: LAG() OVER (PARTITION BY member_id ORDER BY loan_date)
-- Calculate days between consecutive loans for each member
-- Display: member name, loan date, previous loan date, days gap
-- Filter: Members with at least 2 loans
-- Sort: By member, then loan date
```

**Example:**
```sql
SELECT 
  m.first_name, m.last_name,
  l.loan_date,
  LAG(l.loan_date) OVER (PARTITION BY m.member_id ORDER BY l.loan_date) as prev_loan,
  DATEDIFF(l.loan_date, LAG(l.loan_date) OVER (PARTITION BY m.member_id ORDER BY l.loan_date)) as days_gap
FROM members m
JOIN loans l ON m.member_id = l.member_id
ORDER BY m.member_id, l.loan_date;
```

---

### ✅ Testing Your Queries

For each query:
- Verify window function calculations are correct
- Check PARTITION BY groups data properly
- Ensure ORDER BY within window is appropriate
- Test edge cases (NULL values, ties)

### 🎯 Success Criteria

- [ ] All 8 queries run without errors
- [ ] Window functions calculate correctly
- [ ] PARTITION BY groups data appropriately
- [ ] Rankings and running totals are accurate
- [ ] Screenshots show query + results

---

**🎉 Congratulations! You've completed Phase 2 - Intermediate Queries!**

You now have all required skills (Goals 1-8 = 100%). The following goals are optional bonus challenges.

---

## 🔵 PHASE 3: ADVANCED FEATURES (Optional Bonus)

# Goal 9: Create Stored Procedures and Functions (BONUS)

**📌 Module Focus:** Stored Procedures and Functions (Module 13)  
**⏱️ Estimated Time:** 2-3 hours  
**🎯 What You'll Learn:** CREATE PROCEDURE, CREATE FUNCTION, parameters, CALL statement  
**💰 Bonus Points:** +5%

### What You Need to Do

Create 4 reusable stored procedures or functions that encapsulate common library operations.

### 📝 Requirements

#### Procedure 9.1: CheckoutBook
**Business Need:** Automate the book checkout process.

```sql
DELIMITER //
CREATE PROCEDURE CheckoutBook(
  IN p_member_id INT,
  IN p_copy_id INT,
  OUT p_due_date DATE,
  OUT p_message VARCHAR(200)
)
BEGIN
  -- Check if member is active
  -- Check if book copy is available
  -- Insert loan record
  -- Calculate due date (14 days from now)
  -- Return due date and success message
END //
DELIMITER ;

-- Test it:
CALL CheckoutBook(1, 5, @due, @msg);
SELECT @due, @msg;
```

---

#### Procedure 9.2: ReturnBook
**Business Need:** Process book returns and calculate fines.

```sql
DELIMITER //
CREATE PROCEDURE ReturnBook(
  IN p_loan_id INT,
  OUT p_fine_amount DECIMAL(10,2),
  OUT p_message VARCHAR(200)
)
BEGIN
  -- Update loan record with return_date = CURDATE()
  -- Calculate days overdue
  -- If overdue, create fine record ($0.25 per day)
  -- Return fine amount and message
END //
DELIMITER ;
```

---

#### Function 9.3: CalculateFineDays
**Business Need:** Reusable function to calculate overdue days.

```sql
DELIMITER //
CREATE FUNCTION CalculateFineDays(
  p_due_date DATE,
  p_return_date DATE
) RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE days_late INT;
  -- Calculate days between due date and return date
  -- Return 0 if not late, otherwise return days
  SET days_late = DATEDIFF(p_return_date, p_due_date);
  IF days_late < 0 THEN
    RETURN 0;
  ELSE
    RETURN days_late;
  END IF;
END //
DELIMITER ;

-- Test it:
SELECT title, CalculateFineDays(due_date, CURDATE()) as days_overdue
FROM loans l
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id
WHERE l.status = 'active';
```

---

#### Procedure 9.4: GenerateMemberReport
**Business Need:** Comprehensive member activity report.

```sql
DELIMITER //
CREATE PROCEDURE GenerateMemberReport(IN p_member_id INT)
BEGIN
  -- Return multiple result sets:
  
  -- Result Set 1: Member info
  SELECT first_name, last_name, email, membership_type, status
  FROM members WHERE member_id = p_member_id;
  
  -- Result Set 2: Current loans
  SELECT b.title, l.loan_date, l.due_date
  FROM loans l
  JOIN book_copies bc ON l.copy_id = bc.copy_id
  JOIN books b ON bc.book_id = b.book_id
  WHERE l.member_id = p_member_id AND l.status = 'active';
  
  -- Result Set 3: Unpaid fines
  SELECT SUM(fine_amount) as total_unpaid
  FROM fines f
  JOIN loans l ON f.loan_id = l.loan_id
  WHERE l.member_id = p_member_id AND f.paid = FALSE;
  
  -- Result Set 4: Registered events
  SELECT e.event_name, e.event_date
  FROM event_registrations er
  JOIN events e ON er.event_id = e.event_id
  WHERE er.member_id = p_member_id AND e.event_date >= CURDATE();
END //
DELIMITER ;
```

---

### ✅ Testing Your Work

```sql
-- Test CheckoutBook
CALL CheckoutBook(1, 10, @due, @msg);
SELECT @due, @msg;

-- Test ReturnBook
CALL ReturnBook(1, @fine, @msg);
SELECT @fine, @msg;

-- Test CalculateFineDays
SELECT CalculateFineDays('2024-01-01', '2024-01-15') as days;

-- Test GenerateMemberReport
CALL GenerateMemberReport(1);
```

### 🎯 Success Criteria

- [ ] All 4 procedures/functions created successfully
- [ ] Parameters work correctly (IN, OUT)
- [ ] Functions return correct values
- [ ] Procedures handle edge cases (invalid IDs, etc.)
- [ ] Test calls produce expected results
- [ ] Screenshots show CREATE statements + test results

---

# Goal 10: Implement Triggers for Data Integrity (BONUS)

**📌 Module Focus:** Triggers (Module 14)  
**⏱️ Estimated Time:** 2-3 hours  
**🎯 What You'll Learn:** CREATE TRIGGER, BEFORE/AFTER, INSERT/UPDATE/DELETE, NEW/OLD  
**💰 Bonus Points:** +5%

### What You Need to Do

Create 5 triggers that automatically enforce business rules and maintain data integrity.

### 📝 Requirements

#### Trigger 10.1: Audit Log for Member Changes
**Business Need:** Track all member updates for security.

```sql
DELIMITER //
CREATE TRIGGER after_member_update
AFTER UPDATE ON members
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (table_name, action, record_id, description)
  VALUES (
    'members',
    'UPDATE',
    NEW.member_id,
    CONCAT('Member ', OLD.first_name, ' ', OLD.last_name, 
           ' updated. Status: ', OLD.status, ' -> ', NEW.status)
  );
END //
DELIMITER ;
```

---

#### Trigger 10.2: Prevent Loan if Member Suspended
**Business Need:** Don't allow suspended members to borrow.

```sql
DELIMITER //
CREATE TRIGGER before_loan_insert
BEFORE INSERT ON loans
FOR EACH ROW
BEGIN
  DECLARE member_status VARCHAR(20);
  
  SELECT status INTO member_status
  FROM members
  WHERE member_id = NEW.member_id;
  
  IF member_status != 'active' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot create loan: Member is not active';
  END IF;
END //
DELIMITER ;
```

---

#### Trigger 10.3: Auto-Calculate Due Date
**Business Need:** Automatically set due_date when loan is created.

```sql
DELIMITER //
CREATE TRIGGER before_loan_insert_due_date
BEFORE INSERT ON loans
FOR EACH ROW
BEGIN
  -- Set due_date to 14 days from loan_date if not provided
  IF NEW.due_date IS NULL THEN
    SET NEW.due_date = DATE_ADD(NEW.loan_date, INTERVAL 14 DAY);
  END IF;
END //
DELIMITER ;
```

---

#### Trigger 10.4: Auto-Create Fine for Overdue Returns
**Business Need:** Automatically create fine when overdue book is returned.

```sql
DELIMITER //
CREATE TRIGGER after_loan_return
AFTER UPDATE ON loans
FOR EACH ROW
BEGIN
  DECLARE days_late INT;
  DECLARE fine_amt DECIMAL(10,2);
  
  -- Only if status changed to 'returned' and was not already returned
  IF NEW.status = 'returned' AND OLD.status = 'active' THEN
    -- Calculate days late
    SET days_late = DATEDIFF(NEW.return_date, NEW.due_date);
    
    -- If late, create fine
    IF days_late > 0 THEN
      SET fine_amt = days_late * 0.25;
      
      INSERT INTO fines (loan_id, fine_amount, fine_reason, paid)
      VALUES (NEW.loan_id, fine_amt, 'overdue', FALSE);
    END IF;
  END IF;
END //
DELIMITER ;
```

---

#### Trigger 10.5: Prevent Deleting Books with Active Loans
**Business Need:** Can't delete a book that's currently borrowed.

```sql
DELIMITER //
CREATE TRIGGER before_book_delete
BEFORE DELETE ON books
FOR EACH ROW
BEGIN
  DECLARE active_loan_count INT;
  
  SELECT COUNT(*) INTO active_loan_count
  FROM loans l
  JOIN book_copies bc ON l.copy_id = bc.copy_id
  WHERE bc.book_id = OLD.book_id AND l.status = 'active';
  
  IF active_loan_count > 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot delete book: Active loans exist';
  END IF;
END //
DELIMITER ;
```

---

### ✅ Testing Your Triggers

```sql
-- Test Trigger 10.1 (Audit log)
UPDATE members SET status = 'suspended' WHERE member_id = 1;
SELECT * FROM audit_log ORDER BY log_id DESC LIMIT 1;

-- Test Trigger 10.2 (Prevent suspended member loan)
-- Should fail:
INSERT INTO loans (member_id, copy_id, loan_date, due_date, status)
VALUES (4, 15, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'active');

-- Test Trigger 10.3 (Auto due date)
INSERT INTO loans (member_id, copy_id, loan_date, status)
VALUES (1, 20, CURDATE(), 'active');
-- Check that due_date was set automatically

-- Test Trigger 10.4 (Auto fine)
UPDATE loans SET status = 'returned', return_date = DATE_ADD(due_date, INTERVAL 10 DAY)
WHERE loan_id = 1;
SELECT * FROM fines WHERE loan_id = 1;

-- Test Trigger 10.5 (Prevent delete)
-- Should fail if book has active loans:
DELETE FROM books WHERE book_id = 1;
```

### 🎯 Success Criteria

- [ ] All 5 triggers created successfully
- [ ] BEFORE triggers prevent invalid operations
- [ ] AFTER triggers perform automated actions
- [ ] Error messages are clear and helpful
- [ ] Test cases demonstrate trigger behavior
- [ ] Screenshots show CREATE statements + tests

---

# Goal 11: Optimize Query Performance (BONUS)

**📌 Module Focus:** Indexes and Optimization (Module 11)  
**⏱️ Estimated Time:** 2-3 hours  
**🎯 What You'll Learn:** CREATE INDEX, EXPLAIN, query optimization  
**💰 Bonus Points:** +5%

### What You Need to Do

Analyze query performance and add indexes to improve speed. Demonstrate understanding of when and where indexes help.

### 📝 Requirements

#### Task 11.1: Analyze Query Performance
**Use EXPLAIN to analyze slow queries:**

```sql
-- Analyze this query:
EXPLAIN
SELECT b.title, a.author_name, COUNT(*) as loan_count
FROM loans l
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id
JOIN authors a ON b.author_id = a.author_id
GROUP BY b.book_id
ORDER BY loan_count DESC;

-- Look for:
-- - type: ALL (full table scan - bad)
-- - rows: high numbers
-- - Using temporary, Using filesort
```

---

#### Task 11.2: Create Performance-Boosting Indexes

```sql
-- Index 1: Speed up loan lookups by member
CREATE INDEX idx_loans_member_id ON loans(member_id);

-- Index 2: Speed up loan lookups by copy
CREATE INDEX idx_loans_copy_id ON loans(copy_id);

-- Index 3: Speed up active loan searches
CREATE INDEX idx_loans_status ON loans(status);

-- Index 4: Composite index for overdue loan queries
CREATE INDEX idx_loans_status_due ON loans(status, due_date);

-- Index 5: Speed up book searches by genre
CREATE INDEX idx_books_genre ON books(genre);

-- Index 6: Speed up foreign key lookups
CREATE INDEX idx_book_copies_book_id ON book_copies(book_id);

-- Index 7: Speed up fine searches
CREATE INDEX idx_fines_paid ON fines(paid);

-- Index 8: Email lookups (already unique, but explicit index)
-- Already exists due to UNIQUE constraint

-- Index 9: Event date searches
CREATE INDEX idx_events_date ON events(event_date);

-- Index 10: Composite for event registrations
CREATE INDEX idx_registrations_event_member ON event_registrations(event_id, member_id);
```

---

#### Task 11.3: Before and After Comparison

```sql
-- Document performance improvement:

-- BEFORE indexes:
EXPLAIN
SELECT m.first_name, m.last_name, COUNT(*) as loan_count
FROM members m
JOIN loans l ON m.member_id = l.member_id
WHERE l.status = 'active'
GROUP BY m.member_id;
-- Note: rows examined, execution time

-- CREATE indexes (from 11.2)

-- AFTER indexes:
EXPLAIN
SELECT m.first_name, m.last_name, COUNT(*) as loan_count
FROM members m
JOIN loans l ON m.member_id = l.member_id
WHERE l.status = 'active'
GROUP BY m.member_id;
-- Note: improvement in rows examined
```

---

#### Task 11.4: Query Optimization Without Indexes

Rewrite this inefficient query:

```sql
-- BEFORE (inefficient - multiple subqueries):
SELECT b.title,
  (SELECT COUNT(*) FROM loans l JOIN book_copies bc ON l.copy_id = bc.copy_id 
   WHERE bc.book_id = b.book_id) as total_loans,
  (SELECT COUNT(*) FROM loans l JOIN book_copies bc ON l.copy_id = bc.copy_id 
   WHERE bc.book_id = b.book_id AND l.status = 'active') as active_loans
FROM books b;

-- AFTER (optimized - single pass with LEFT JOINs):
SELECT b.title,
  COUNT(l.loan_id) as total_loans,
  SUM(CASE WHEN l.status = 'active' THEN 1 ELSE 0 END) as active_loans
FROM books b
LEFT JOIN book_copies bc ON b.book_id = bc.book_id
LEFT JOIN loans l ON bc.copy_id = l.copy_id
GROUP BY b.book_id;
```

---

#### Task 11.5: Demonstrate Index Usage

```sql
-- Show that indexes are being used:
SHOW INDEXES FROM loans;
SHOW INDEXES FROM books;
SHOW INDEXES FROM members;

-- Verify index improves query plan:
EXPLAIN
SELECT * FROM loans
WHERE status = 'active' AND due_date < CURDATE();
-- Should show "Using index condition" or similar
```

---

### 🎯 Success Criteria

- [ ] Created at least 8 appropriate indexes
- [ ] Used EXPLAIN to analyze queries
- [ ] Documented before/after performance
- [ ] Rewrote at least 1 inefficient query
- [ ] Explained why each index was chosen
- [ ] Screenshots show EXPLAIN output + index creation

---

# Goal 12: Transaction Management (BONUS)

**📌 Module Focus:** Transactions (Module 12)  
**⏱️ Estimated Time:** 1-2 hours  
**🎯 What You'll Learn:** START TRANSACTION, COMMIT, ROLLBACK, ACID properties  
**💰 Bonus Points:** +5%

### What You Need to Do

Demonstrate safe multi-step operations using transactions. Show how to handle errors and maintain data consistency.

### 📝 Requirements

#### Transaction 12.1: Safe Book Checkout
**Business Need:** Checkout must be all-or-nothing.

```sql
START TRANSACTION;

-- Step 1: Check book availability
SELECT copy_id INTO @available_copy
FROM book_copies bc
WHERE book_id = 1
  AND copy_id NOT IN (
    SELECT copy_id FROM loans WHERE status = 'active'
  )
LIMIT 1;

-- Step 2: Create loan record
INSERT INTO loans (member_id, copy_id, loan_date, due_date, status)
VALUES (1, @available_copy, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'active');

-- Step 3: Log the action
INSERT INTO audit_log (table_name, action, record_id, description)
VALUES ('loans', 'INSERT', LAST_INSERT_ID(), 'Book checked out');

-- If all succeeded:
COMMIT;

-- If error occurred:
-- ROLLBACK;
```

---

#### Transaction 12.2: Process Fine Payment
**Business Need:** Payment must update fine and create audit trail atomically.

```sql
START TRANSACTION;

-- Step 1: Mark fine as paid
UPDATE fines
SET paid = TRUE, payment_date = CURDATE()
WHERE fine_id = 1;

-- Step 2: Log payment
INSERT INTO audit_log (table_name, action, record_id, description)
VALUES ('fines', 'UPDATE', 1, CONCAT('Fine paid: $', (SELECT fine_amount FROM fines WHERE fine_id = 1)));

-- Step 3: Check if member should be reactivated
UPDATE members
SET status = 'active'
WHERE member_id = (
  SELECT l.member_id FROM fines f
  JOIN loans l ON f.loan_id = l.loan_id
  WHERE f.fine_id = 1
)
AND status = 'suspended'
AND NOT EXISTS (
  SELECT 1 FROM fines f2
  JOIN loans l2 ON f2.loan_id = l2.loan_id
  WHERE l2.member_id = members.member_id
    AND f2.paid = FALSE
    AND f2.fine_id != 1
);

COMMIT;
```

---

#### Transaction 12.3: Rollback Example (Error Handling)
**Business Need:** Demonstrate how rollback prevents partial updates.

```sql
START TRANSACTION;

-- Attempt to checkout book
INSERT INTO loans (member_id, copy_id, loan_date, due_date, status)
VALUES (1, 5, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'active');

-- Simulate error check: member has too many active loans
SET @active_count = (
  SELECT COUNT(*) FROM loans
  WHERE member_id = 1 AND status = 'active'
);

IF @active_count > 5 THEN
  -- Too many books! Undo the insert
  ROLLBACK;
  SELECT 'Transaction rolled back: Member has too many active loans' as message;
ELSE
  COMMIT;
  SELECT 'Transaction committed successfully' as message;
END IF;
```

---

#### Transaction 12.4: Batch Book Return
**Business Need:** Return multiple books for a member at once.

```sql
START TRANSACTION;

-- Return all active loans for member 1
UPDATE loans
SET status = 'returned', return_date = CURDATE()
WHERE member_id = 1 AND status = 'active';

-- Calculate and create fines for any overdue
INSERT INTO fines (loan_id, fine_amount, fine_reason, paid)
SELECT 
  loan_id,
  GREATEST(0, DATEDIFF(CURDATE(), due_date)) * 0.25 as fine_amount,
  'overdue',
  FALSE
FROM loans
WHERE member_id = 1 
  AND status = 'returned'
  AND return_date > due_date
  AND loan_id NOT IN (SELECT loan_id FROM fines);

-- Log the batch return
INSERT INTO audit_log (table_name, action, record_id, description)
VALUES ('loans', 'UPDATE', 1, CONCAT('Batch return for member 1: ', ROW_COUNT(), ' books'));

COMMIT;
```

---

### ✅ Testing Your Transactions

```sql
-- Test successful transaction
START TRANSACTION;
INSERT INTO members (first_name, last_name, email, membership_type)
VALUES ('Test', 'User', 'test@example.com', 'standard');
SELECT * FROM members WHERE email = 'test@example.com';
COMMIT;
SELECT * FROM members WHERE email = 'test@example.com'; -- Should exist

-- Test rollback
START TRANSACTION;
INSERT INTO members (first_name, last_name, email, membership_type)
VALUES ('Rollback', 'Test', 'rollback@example.com', 'standard');
SELECT * FROM members WHERE email = 'rollback@example.com'; -- Should exist
ROLLBACK;
SELECT * FROM members WHERE email = 'rollback@example.com'; -- Should NOT exist
```

---

### 🎯 Success Criteria

- [ ] Demonstrated at least 4 transaction scenarios
- [ ] Used COMMIT for successful operations
- [ ] Used ROLLBACK to undo partial changes
- [ ] Showed error handling with transactions
- [ ] Explained ACID properties (in comments)
- [ ] Screenshots show transaction execution

---

**🎉 Congratulations! You've completed ALL GOALS (1-12)!**

If you completed all bonus goals, you've achieved 120% - outstanding work!

---

## 📤 Deliverables & Submission

### What to Submit

Create a ZIP file containing:

#### 1. SQL Script Files (Required)
- `01_schema.sql` - Goal 1 (CREATE TABLE statements)
- `02_data.sql` - Goal 2 (INSERT statements)
- `03_basic_queries.sql` - Goal 3 (8 queries)
- `04_aggregation.sql` - Goal 4 (8 queries)
- `05_joins.sql` - Goal 5 (8 queries)
- `06_subqueries.sql` - Goal 6 (8 queries)
- `07_set_operations.sql` - Goal 7 (5 queries)
- `08_window_functions.sql` - Goal 8 (8 queries)
- `09_procedures.sql` - Goal 9 (BONUS - 4 procedures/functions)
- `10_triggers.sql` - Goal 10 (BONUS - 5 triggers)
- `11_indexes.sql` - Goal 11 (BONUS - index creation + EXPLAIN)
- `12_transactions.sql` - Goal 12 (BONUS - 4 transactions)

#### 2. Documentation (Required)
- `README.md` or `PROJECT_REPORT.pdf` containing:
  - Your name and date
  - Brief project description
  - List of completed goals (1-8 required, 9-12 optional)
  - Screenshots for each goal (see requirements below)
  - Challenges faced and solutions
  - What you learned

#### 3. Screenshots (Required)
- At least ONE screenshot per goal showing:
  - The SQL query
  - The query results
  - Proof it works (row counts, successful execution)

---

## 📸 Screenshot Requirements

### What to Capture

For **each goal**, provide screenshots showing:

1. **The SQL Code** - Your query or CREATE statement
2. **The Results** - Output data or success messages
3. **Verification** - Row counts, DESCRIBE output, or test results

### Screenshot Checklist by Goal

- **Goal 1 (Schema):**
  - Screenshot: `SHOW TABLES;` output
  - Screenshot: `DESCRIBE` for 2-3 key tables
  - Screenshot: One CREATE TABLE statement

- **Goal 2 (Data):**
  - Screenshot: Row count verification query
  - Screenshot: Sample data from 2-3 tables

- **Goals 3-8 (Queries):**
  - Screenshot: 2-3 example queries with results
  - Or: One screenshot per goal showing multiple queries

- **Goals 9-12 (Bonus):**
  - Screenshot: CREATE statement
  - Screenshot: Test execution and results

### How to Take Good Screenshots

✅ **DO:**
- Include both query and results
- Show timestamps or dates to prove recency
- Capture error messages if troubleshooting
- Use clear, readable font sizes
- Label screenshots (e.g., "Goal_3_Query_1.png")

❌ **DON'T:**
- Submit blurry or unreadable screenshots
- Cut off important parts of results
- Forget to show the actual query code
- Submit screenshots from old projects

---

## 🌐 How to Submit

### Option 1: GitHub (Recommended)

1. **Create a new repository:**
   ```bash
   git init city-library-project
   cd city-library-project
   ```

2. **Organize your files:**
   ```
   city-library-project/
   ├── README.md
   ├── sql/
   │   ├── 01_schema.sql
   │   ├── 02_data.sql
   │   ├── 03_basic_queries.sql
   │   └── ... (all SQL files)
   ├── screenshots/
   │   ├── goal1_schema.png
   │   ├── goal2_data.png
   │   └── ... (all screenshots)
   └── documentation/
       └── project_report.md
   ```

3. **Commit and push:**
   ```bash
   git add .
   git commit -m "Complete CityLibrary capstone project"
   git remote add origin https://github.com/yourusername/city-library-project.git
   git push -u origin main
   ```

4. **Submit the GitHub URL** to your instructor

---

### Option 2: ZIP File Submission

1. Create folder structure (same as above)
2. Add all SQL files, screenshots, and documentation
3. Compress to ZIP: `city-library-project.zip`
4. Upload to your course platform or email to instructor

---

## 🆘 Beginner Troubleshooting Guide

### 🔍 Debugging Flowchart - "I'm Stuck! What Do I Do?"

```
START: Something's not working
         ↓
    ┌────────────────────────┐
    │ What type of error?    │
    └────────────────────────┘
         ↓
    ┌────┴────┬─────────┬──────────┬──────────┐
    ↓         ↓         ↓          ↓          ↓
 CREATE    INSERT    SELECT    JOIN     OTHER
 TABLE     ERROR     ERROR     ERROR    ERROR
    ↓         ↓         ↓          ↓          ↓
    
CREATE TABLE Issues:
├─ "Table exists"? → DROP TABLE first (or use IF NOT EXISTS)
├─ "No database selected"? → Run: USE city_library;
├─ "Foreign key constraint"? → Create parent table first
└─ "Syntax error"? → Check commas, data types, parentheses

INSERT Issues:
├─ "Duplicate entry"? → Value already exists (email, ISBN)
├─ "Column count mismatch"? → Count columns = count values
├─ "Foreign key fails"? → Ensure parent record exists
├─ "Data too long"? → Check VARCHAR length limits
└─ "Out of range"? → Value too large for data type

SELECT Issues:
├─ "Table doesn't exist"? → Check spelling, run SHOW TABLES;
├─ "Unknown column"? → Check spelling, run DESCRIBE table_name;
├─ "No results"? → Remove WHERE filters one by one to debug
└─ "Too many results"? → Add WHERE filters, use LIMIT

JOIN Issues:
├─ "Cartesian product"? → Missing ON clause
├─ "Duplicate rows"? → Check join conditions, use DISTINCT
├─ "No results"? → Try LEFT JOIN instead of INNER JOIN
└─ "Wrong column"? → Ambiguous column, use table.column

Still Stuck?
├─ Step 1: Read the error message carefully (it tells you the problem!)
├─ Step 2: Check the specific line number in error
├─ Step 3: Copy your code to a new file and test in isolation
├─ Step 4: Search error message online: "MySQL [error code]"
└─ Step 5: Ask for help (instructor, classmate, online forum)
```

### Common Errors and Solutions

#### Error: "Table doesn't exist"
```
ERROR 1146 (42S02): Table 'city_library.books' doesn't exist
```
**Solution:** Create tables in order. Parent tables (authors, members) before child tables (books, loans).

---

#### Error: "Duplicate entry for key"
```
ERROR 1062 (23000): Duplicate entry 'alice.j@email.com' for key 'email'
```
**Solution:** Email addresses must be unique. Use different emails or delete existing row.

---

#### Error: "Cannot add foreign key constraint"
```
ERROR 1215 (HY000): Cannot add foreign key constraint
```
**Solution:** 
- Ensure referenced table exists
- Referenced column must be PRIMARY KEY or have UNIQUE index
- Data types must match exactly (both INT, same size)

---

#### Error: "Column count doesn't match"
```
ERROR 1136 (21S01): Column count doesn't match value count
```
**Solution:** Number of columns in INSERT must match number of values.
```sql
-- Wrong:
INSERT INTO members (first_name, last_name) VALUES ('John', 'Doe', 'john@email.com');

-- Right:
INSERT INTO members (first_name, last_name, email) VALUES ('John', 'Doe', 'john@email.com');
```

---

#### Error: "Syntax error near..."
```
ERROR 1064 (42000): You have an error in your SQL syntax
```
**Solution:**
- Check for missing commas
- Verify all keywords spelled correctly
- Ensure quotes match (' or ")
- Check for missing semicolons

---

#### Error: "Out of range value"
```
ERROR 1264 (22003): Out of range value for column
```
**Solution:** Value is too large for data type. Use bigger type (INT -> BIGINT) or smaller value.

---

### Performance Issues

#### "Query is too slow"
**Solution:**
1. Add indexes on columns used in WHERE, JOIN, and ORDER BY
2. Use EXPLAIN to see query plan
3. Avoid SELECT * - specify only needed columns
4. Use LIMIT to test with smaller result sets

---

### Data Issues

#### "Wrong number of rows returned"
**Solution:**
- Check JOIN conditions (missing ON clause?)
- Verify filter logic in WHERE clause
- Watch for NULL values (use IS NULL, not = NULL)
- Check for duplicate data

---

## 📚 Quick Reference Guide

### Essential SQL Syntax

#### Basic SELECT
```sql
SELECT column1, column2
FROM table_name
WHERE condition
ORDER BY column1 DESC
LIMIT 10;
```

#### Aggregation
```sql
SELECT category, COUNT(*), AVG(price)
FROM products
GROUP BY category
HAVING COUNT(*) > 5
ORDER BY COUNT(*) DESC;
```

#### Joins
```sql
-- Inner join
SELECT a.*, b.*
FROM table_a a
INNER JOIN table_b b ON a.id = b.a_id;

-- Left join (preserve all left table rows)
SELECT a.*, b.*
FROM table_a a
LEFT JOIN table_b b ON a.id = b.a_id;
```

#### Subquery
```sql
SELECT name
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
```

#### CTE (Common Table Expression)
```sql
WITH high_earners AS (
  SELECT * FROM employees WHERE salary > 100000
)
SELECT department, COUNT(*)
FROM high_earners
GROUP BY department;
```

#### Window Function
```sql
SELECT name, department, salary,
  RANK() OVER (PARTITION BY department ORDER BY salary DESC) as dept_rank
FROM employees;
```

#### Stored Procedure
```sql
DELIMITER //
CREATE PROCEDURE procedure_name(IN param1 INT, OUT param2 VARCHAR(100))
BEGIN
  -- procedure logic
END //
DELIMITER ;

CALL procedure_name(10, @result);
SELECT @result;
```

#### Trigger
```sql
DELIMITER //
CREATE TRIGGER trigger_name
AFTER INSERT ON table_name
FOR EACH ROW
BEGIN
  -- trigger logic using NEW.column_name
END //
DELIMITER ;
```

#### Transaction
```sql
START TRANSACTION;
-- multiple SQL statements
COMMIT;  -- or ROLLBACK; if error
```

---

### Date Functions
```sql
CURDATE()                          -- Current date
NOW()                              -- Current datetime
DATE_ADD(date, INTERVAL 14 DAY)    -- Add days
DATE_SUB(date, INTERVAL 1 MONTH)   -- Subtract months
DATEDIFF(date1, date2)             -- Days between dates
YEAR(date), MONTH(date), DAY(date) -- Extract parts
```

### String Functions
```sql
CONCAT(str1, str2)          -- Combine strings
UPPER(str), LOWER(str)      -- Change case
LENGTH(str)                 -- String length
SUBSTRING(str, start, len)  -- Extract substring
```

### Aggregate Functions
```sql
COUNT(*)              -- Count rows
COUNT(DISTINCT col)   -- Count unique values
SUM(col)              -- Total
AVG(col)              -- Average
MIN(col), MAX(col)    -- Minimum, Maximum
GROUP_CONCAT(col)     -- Concatenate grouped values
```

---

## 🎓 Final Checklist

Before submitting, verify:

### Completeness
- [ ] All required goals (1-8) completed
- [ ] Optional goals (9-12) attempted if desired
- [ ] All SQL files included and properly named
- [ ] Documentation/README exists
- [ ] Screenshots for every goal

### Quality
- [ ] All queries run without errors
- [ ] Code is well-formatted and commented
- [ ] Results match expected outcomes
- [ ] Screenshots are clear and readable
- [ ] README explains what you built

### Organization
- [ ] Files organized in logical folders
- [ ] Consistent naming conventions
- [ ] README has table of contents
- [ ] Easy for grader to navigate

### Testing
- [ ] Tested all queries with sample data
- [ ] Verified edge cases (empty results, NULL values)
- [ ] Checked that foreign keys work
- [ ] Confirmed triggers and procedures execute

---

## 🎉 Congratulations!

You've completed the **CityLibrary Management System** capstone project! This comprehensive project demonstrates your mastery of:

✅ Database design and normalization  
✅ SQL fundamentals (SELECT, WHERE, JOIN, GROUP BY)  
✅ Advanced queries (subqueries, CTEs, window functions)  
✅ Database programming (procedures, triggers)  
✅ Performance optimization (indexes, query tuning)  
✅ Transaction management and data integrity  

**You're now ready to:**
- Build real-world database applications
- Work with existing databases in professional settings
- Optimize queries for performance
- Design schemas for new projects
- Explain database concepts to others

**What's Next?**
- Add this project to your portfolio/GitHub
- Expand the system with new features (reservations, e-books, etc.)
- Apply these skills to your own project ideas
- Continue learning advanced topics (replication, sharding, NoSQL)

---

**Good luck, and happy querying! 🚀📚**

