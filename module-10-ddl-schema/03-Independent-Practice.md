# Independent Practice — DDL & Schema Design

Work through these exercises independently. Each includes difficulty, scenario, requirements, success criteria, hints, and solution.

## 📋 Before You Start

### Learning Objectives
Through independent practice, you will:
- Design complete database schemas from requirements
- Implement multi-table relationships
- Choose appropriate data types and constraints
- Create normalized table structures
- Test schema integrity

### Difficulty Progression
- ⭐ **Easy (1-2)**: 2-3 tables, simple relationships
- ⭐⭐ **Medium (3-5)**: 3-4 tables, multiple FKs, junction tables
- ⭐⭐⭐ **Challenge (6-7)**: Complex schemas, many-to-many, advanced constraints

### Problem-Solving Strategy
1. **READ** requirements thoroughly
2. **SKETCH** schema on paper:
   - What entities (tables)?
   - What attributes (columns)?
   - What relationships (FKs)?
   - What constraints?
3. **PLAN** creation order:
   - Parent tables first (no FK dependencies)
   - Child tables next (reference parents)
   - Junction tables last (many-to-many)
4. **CREATE** tables with constraints
5. **TEST** with sample data
6. **VERIFY** constraints work (try invalid inserts)
7. **REVIEW** solution

**Common Pitfalls:**
- ❌ Creating child table before parent (FK fails)
- ❌ Wrong data types (VARCHAR(10) for email is too small)
- ❌ Missing NOT NULL on required fields
- ❌ No PRIMARY KEY (every table needs one!)
- ❌ Forgetting to test constraints
- ✅ Always verify with DESCRIBE and test inserts!

**Schema Design Checklist:**
- [ ] Every table has PRIMARY KEY
- [ ] Foreign keys defined for relationships
- [ ] NOT NULL on required fields
- [ ] Appropriate data types and sizes
- [ ] UNIQUE constraints where needed
- [ ] CHECK constraints for business rules
- [ ] DEFAULT values where appropriate

**Beginner Tip:** Start with Easy exercises. Plan your schema on paper first! Think about relationships, constraints, and data types before writing DDL.

---

## Exercise 1: Library Book Catalog (Easy)

**Difficulty:** ⭐ Easy

### Scenario
Create a simple library database with books and authors. Each book has one author (simplified model).

### Requirements
1. Create `authors` table with:
   - author_id (PK, auto-increment)
   - author_name (VARCHAR 100, NOT NULL)
   - country (VARCHAR 50)
   
2. Create `books` table with:
   - book_id (PK, auto-increment)
   - title (VARCHAR 200, NOT NULL)
   - author_id (FK to authors)
   - isbn (VARCHAR 13, UNIQUE)
   - published_year (INT)
   - pages (INT, CHECK > 0)

3. Insert 2 authors and 3 books

### Success Criteria
- Both tables created with constraints
- FK relationship enforced
- Cannot insert book with non-existent author_id
- ISBN must be unique
- Pages must be positive

### Hints
<details>
<summary>Hint 1 - Table Order</summary>
Create authors table first (parent), then books (child with FK).
</details>

<details>
<summary>Hint 2 - Foreign Key Syntax</summary>
```sql
FOREIGN KEY (author_id) REFERENCES authors(author_id)
```
</details>

<details>
<summary>Hint 3 - CHECK Constraint</summary>
```sql
CHECK (pages > 0)
```
</details>

### Solution

**Step-by-Step Approach:**
1. Drop tables in correct order (child first, parent second)
2. Create parent table (authors) - has no dependencies
3. Create child table (books) - references authors
4. Insert data (parent first, then child)
5. Verify with a JOIN query

```sql
-- STEP 1: Clean slate - drop in reverse dependency order
-- Drop child table first (has foreign key)
DROP TABLE IF EXISTS ip10_books;
-- Drop parent table second (referenced by foreign key)
DROP TABLE IF EXISTS ip10_authors;

-- STEP 2: Create parent table (authors) first - no dependencies
CREATE TABLE ip10_authors (
  author_id INT AUTO_INCREMENT PRIMARY KEY,     -- Auto-generates 1, 2, 3...
  author_name VARCHAR(100) NOT NULL,            -- Required field
  country VARCHAR(50)                           -- Optional field (can be NULL)
);

-- STEP 3: Create child table (books) - references authors
CREATE TABLE ip10_books (
  book_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  author_id INT,                                -- Foreign key column
  isbn VARCHAR(13) UNIQUE,                      -- ISBN must be unique across all books
  published_year INT,
  pages INT CHECK (pages > 0),                  -- Must be positive (MySQL 8.0.16+)
  CONSTRAINT fk_author FOREIGN KEY (author_id)  -- Named constraint for clarity
    REFERENCES ip10_authors(author_id)          -- Links to authors table
);

-- Verify table structures
DESCRIBE ip10_authors;
DESCRIBE ip10_books;

-- STEP 4: Insert sample data - parent first!
INSERT INTO ip10_authors (author_name, country) VALUES
('George Orwell', 'United Kingdom'),
('J.K. Rowling', 'United Kingdom');

-- View authors with their IDs
SELECT * FROM ip10_authors;

-- Now insert books referencing valid author_ids
INSERT INTO ip10_books (title, author_id, isbn, published_year, pages) VALUES
('1984', 1, '9780451524935', 1949, 328),
('Animal Farm', 1, '9780451526342', 1945, 112),
('Harry Potter and the Philosopher''s Stone', 2, '9780439708180', 1997, 309);
-- Note: Two single quotes ('') escape a single quote in SQL strings

-- STEP 5: Verify relationships with JOIN query
SELECT 
  b.title,
  a.author_name,
  b.published_year,
  b.pages,
  b.isbn
FROM ip10_books b
JOIN ip10_authors a ON b.author_id = a.author_id
ORDER BY b.published_year;

-- Test constraints
-- ❌ This should fail (author_id 99 doesn't exist):
-- INSERT INTO ip10_books (title, author_id, isbn, published_year, pages) 
-- VALUES ('Test Book', 99, '1234567890123', 2025, 200);

-- ❌ This should fail (duplicate ISBN):
-- INSERT INTO ip10_books (title, author_id, isbn, published_year, pages) 
-- VALUES ('Another Book', 1, '9780451524935', 2025, 250);

-- ❌ This should fail (pages = 0, not > 0):
-- INSERT INTO ip10_books (title, author_id, isbn, published_year, pages) 
-- VALUES ('Empty Book', 1, '1111111111111', 2025, 0);
```

**Key Learning Points:**
1. **Order matters**: Create parent tables before child tables
2. **Named constraints** (`fk_author`) make it easier to manage constraints later
3. **Test your constraints** to ensure they work as expected
4. **VARCHAR(13)** for ISBN is appropriate (ISBNs are 10 or 13 characters)
5. **CHECK constraints** require MySQL 8.0.16+ (older versions ignore them)
6. **Two single quotes** ('') escape a quote in a string: `'Harry Potter and the Philosopher''s Stone'`

---

## Exercise 2: Blog Platform Schema (Medium)

**Difficulty:** ⭐⭐ Medium

### Scenario
Design a blog platform with users, posts, and comments. Users write posts, and any user can comment on any post.

### Requirements
1. Create `users` table:
   - user_id (PK, auto-increment)
   - username (VARCHAR 50, UNIQUE, NOT NULL)
   - email (VARCHAR 100, UNIQUE, NOT NULL)
   - created_at (TIMESTAMP, default CURRENT_TIMESTAMP)

2. Create `posts` table:
   - post_id (PK, auto-increment)
   - user_id (FK to users)
   - title (VARCHAR 200, NOT NULL)
   - content (TEXT)
   - published_at (TIMESTAMP, default CURRENT_TIMESTAMP)
   - views (INT, default 0)
   - INDEX on user_id for faster queries

3. Create `comments` table:
   - comment_id (PK, auto-increment)
   - post_id (FK to posts)
   - user_id (FK to users)
   - comment_text (TEXT, NOT NULL)
   - created_at (TIMESTAMP, default CURRENT_TIMESTAMP)
   - INDEXes on both post_id and user_id

4. Insert 2 users, 3 posts, 5 comments

### Success Criteria
- All foreign keys enforced
- Cannot comment on non-existent post
- Usernames and emails are unique
- Indexes created for performance
- Query works: "Show all comments on a post with user details"

### Hints
<details>
<summary>Hint 1 - Multiple Foreign Keys</summary>
Comments table needs TWO foreign keys (post_id and user_id).
</details>

<details>
<summary>Hint 2 - Default Values</summary>
```sql
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
```
</details>

<details>
<summary>Hint 3 - Create Index</summary>
```sql
INDEX idx_post (post_id)
```
Or add after table creation with ALTER TABLE.
</details>

### Solution

**Planning Your Schema:**
1. **users** - base table (no dependencies)
2. **posts** - depends on users (author)
3. **comments** - depends on both posts and users (commenter)

**Relationship Diagram:**
```
users (1) ----< posts (many)     "One user writes many posts"
  |
  |
users (1) ----< comments (many)  "One user writes many comments"
posts (1) ----< comments (many)  "One post has many comments"
```

```sql
-- STEP 1: Clean slate - drop in dependency order (deepest first)
DROP TABLE IF EXISTS ip10_comments;  -- Depends on posts AND users
DROP TABLE IF EXISTS ip10_posts;     -- Depends on users
DROP TABLE IF EXISTS ip10_users;     -- No dependencies

-- STEP 2: Create base table (users) - no dependencies
CREATE TABLE ip10_users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,         -- Must be unique and required
  email VARCHAR(100) UNIQUE NOT NULL,           -- Must be unique and required
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- STEP 3: Create posts table - depends on users
CREATE TABLE ip10_posts (
  post_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,                                  -- Foreign key to users
  title VARCHAR(200) NOT NULL,
  content TEXT,                                 -- TEXT for long content
  published_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  views INT DEFAULT 0,                          -- Track view count
  CONSTRAINT fk_post_user FOREIGN KEY (user_id) 
    REFERENCES ip10_users(user_id),             -- Link to author
  INDEX idx_user (user_id)                      -- Speed up "posts by user" queries
);

-- STEP 4: Create comments table - depends on posts AND users
CREATE TABLE ip10_comments (
  comment_id INT AUTO_INCREMENT PRIMARY KEY,
  post_id INT,                                  -- Foreign key to posts
  user_id INT,                                  -- Foreign key to users (commenter)
  comment_text TEXT NOT NULL,                   -- Comment content required
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_comment_post FOREIGN KEY (post_id) 
    REFERENCES ip10_posts(post_id),             -- Which post is commented on
  CONSTRAINT fk_comment_user FOREIGN KEY (user_id) 
    REFERENCES ip10_users(user_id),             -- Who wrote the comment
  INDEX idx_post (post_id),                     -- Speed up "comments on post X"
  INDEX idx_user (user_id)                      -- Speed up "comments by user Y"
);

-- Verify table structures
DESCRIBE ip10_users;
DESCRIBE ip10_posts;
DESCRIBE ip10_comments;

-- STEP 5: Insert sample data (parent to child order)
INSERT INTO ip10_users (username, email) VALUES
('alice_writer', 'alice@blog.com'),
('bob_reader', 'bob@blog.com');

-- Verify users
SELECT * FROM ip10_users;

INSERT INTO ip10_posts (user_id, title, content, views) VALUES
(1, 'Introduction to SQL', 'SQL is a powerful language for managing data...', 150),
(1, 'Database Design Tips', 'Good schema design is crucial for performance...', 89),
(2, 'My First Post', 'Hello blogging world! Excited to share my journey.', 45);

-- Verify posts with author names
SELECT p.post_id, p.title, u.username AS author, p.views
FROM ip10_posts p
JOIN ip10_users u ON p.user_id = u.user_id;

INSERT INTO ip10_comments (post_id, user_id, comment_text) VALUES
(1, 2, 'Great article! Very helpful for beginners.'),
(1, 2, 'Can you write more about joins?'),
(2, 2, 'Schema design is underrated!'),
(3, 1, 'Welcome to blogging, Bob!'),
(3, 1, 'Looking forward to more posts.');

-- STEP 6: Verify with complex queries

-- Query 1: All comments on post 1 with details
SELECT 
  p.title AS post_title,
  c.comment_text,
  u.username AS commenter,
  c.created_at AS comment_time
FROM ip10_comments c
JOIN ip10_posts p ON c.post_id = p.post_id
JOIN ip10_users u ON c.user_id = u.user_id
WHERE p.post_id = 1
ORDER BY c.created_at;

-- Query 2: Post summary with comment count
SELECT 
  p.title,
  u.username AS author,
  p.views,
  COUNT(c.comment_id) AS comment_count
FROM ip10_posts p
JOIN ip10_users u ON p.user_id = u.user_id
LEFT JOIN ip10_comments c ON p.post_id = c.post_id
GROUP BY p.post_id, p.title, u.username, p.views
ORDER BY p.views DESC;

-- Query 3: Most active commenters
SELECT 
  u.username,
  COUNT(c.comment_id) AS total_comments
FROM ip10_users u
LEFT JOIN ip10_comments c ON u.user_id = c.user_id
GROUP BY u.user_id, u.username
ORDER BY total_comments DESC;
```

**Key Learning Points:**
1. **Multiple foreign keys**: Comments table has TWO foreign keys (post_id and user_id)
2. **Indexes on FKs**: Always index foreign key columns for better JOIN performance
3. **TEXT vs VARCHAR**: Use TEXT for long content, VARCHAR for limited length
4. **Dependency chain**: users → posts → comments (create in this order)
5. **Named constraints**: Makes debugging and maintenance easier
6. **LEFT JOIN vs JOIN**: Use LEFT JOIN when you want all rows even if no match exists

---

## Exercise 3: E-Learning Platform (Hard)

**Difficulty:** ⭐⭐⭐ Hard

### Scenario
Build a schema for an online learning platform. Instructors create courses, students enroll, and we track progress.

### Requirements
1. Create `instructors` table:
   - instructor_id (PK, auto-increment)
   - name (VARCHAR 100, NOT NULL)
   - email (VARCHAR 100, UNIQUE, NOT NULL)
   - bio (TEXT)

2. Create `students` table:
   - student_id (PK, auto-increment)
   - name (VARCHAR 100, NOT NULL)
   - email (VARCHAR 100, UNIQUE, NOT NULL)
   - enrollment_date (DATE, default CURDATE())

3. Create `courses` table:
   - course_id (PK, auto-increment)
   - instructor_id (FK to instructors)
   - course_name (VARCHAR 200, NOT NULL)
   - description (TEXT)
   - price (DECIMAL(10,2), CHECK >= 0)
   - duration_hours (INT, CHECK > 0)
   - created_at (TIMESTAMP, default CURRENT_TIMESTAMP)

4. Create `enrollments` table (many-to-many):
   - enrollment_id (PK, auto-increment)
   - student_id (FK to students)
   - course_id (FK to courses)
   - enrolled_at (TIMESTAMP, default CURRENT_TIMESTAMP)
   - progress_percent (INT, CHECK between 0 and 100)
   - completed (BOOLEAN, default FALSE)
   - UNIQUE constraint on (student_id, course_id) - can't enroll twice

5. Create `course_reviews` table:
   - review_id (PK, auto-increment)
   - course_id (FK to courses)
   - student_id (FK to students)
   - rating (INT, CHECK between 1 and 5)
   - review_text (TEXT)
   - created_at (TIMESTAMP, default CURRENT_TIMESTAMP)

6. Add indexes on all FK columns
7. Insert 2 instructors, 3 students, 4 courses, 6 enrollments, 4 reviews

### Success Criteria
- All relationships enforced
- Student cannot enroll in same course twice
- Rating must be 1-5
- Progress must be 0-100
- Price cannot be negative
- Complex query works: "Find average rating for each course with instructor name"

### Hints
<details>
<summary>Hint 1 - Composite Unique</summary>
```sql
UNIQUE KEY uk_student_course (student_id, course_id)
```
</details>

<details>
<summary>Hint 2 - CHECK with Range</summary>
```sql
CHECK (progress_percent BETWEEN 0 AND 100)
```
</details>

<details>
<summary>Hint 3 - Drop Order</summary>
Drop child tables first (those with FKs), then parent tables.
</details>

### Solution
```sql
-- Clean slate (drop in correct order)
DROP TABLE IF EXISTS ip10_course_reviews;
DROP TABLE IF EXISTS ip10_enrollments;
DROP TABLE IF EXISTS ip10_courses;
DROP TABLE IF EXISTS ip10_students;
DROP TABLE IF EXISTS ip10_instructors;

-- Instructors table
CREATE TABLE ip10_instructors (
  instructor_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  bio TEXT
);

-- Students table
CREATE TABLE ip10_students (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  enrollment_date DATE DEFAULT (CURDATE())
);

-- Courses table
CREATE TABLE ip10_courses (
  course_id INT AUTO_INCREMENT PRIMARY KEY,
  instructor_id INT,
  course_name VARCHAR(200) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) CHECK (price >= 0),
  duration_hours INT CHECK (duration_hours > 0),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_course_instructor FOREIGN KEY (instructor_id) 
    REFERENCES ip10_instructors(instructor_id),
  INDEX idx_instructor (instructor_id)
);

-- Enrollments table (many-to-many)
CREATE TABLE ip10_enrollments (
  enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT,
  course_id INT,
  enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  progress_percent INT CHECK (progress_percent BETWEEN 0 AND 100),
  completed BOOLEAN DEFAULT FALSE,
  CONSTRAINT fk_enroll_student FOREIGN KEY (student_id) 
    REFERENCES ip10_students(student_id),
  CONSTRAINT fk_enroll_course FOREIGN KEY (course_id) 
    REFERENCES ip10_courses(course_id),
  UNIQUE KEY uk_student_course (student_id, course_id),
  INDEX idx_student (student_id),
  INDEX idx_course (course_id)
);

-- Course reviews table
CREATE TABLE ip10_course_reviews (
  review_id INT AUTO_INCREMENT PRIMARY KEY,
  course_id INT,
  student_id INT,
  rating INT CHECK (rating BETWEEN 1 AND 5),
  review_text TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_review_course FOREIGN KEY (course_id) 
    REFERENCES ip10_courses(course_id),
  CONSTRAINT fk_review_student FOREIGN KEY (student_id) 
    REFERENCES ip10_students(student_id),
  INDEX idx_course_review (course_id),
  INDEX idx_student_review (student_id)
);

-- Insert sample data
INSERT INTO ip10_instructors (name, email, bio) VALUES
('Dr. Sarah Johnson', 'sarah@academy.com', 'Database expert with 15 years experience'),
('Prof. Mike Chen', 'mike@academy.com', 'Software engineering professor');

INSERT INTO ip10_students (name, email) VALUES
('Alice Smith', 'alice@student.com'),
('Bob Jones', 'bob@student.com'),
('Carol White', 'carol@student.com');

INSERT INTO ip10_courses (instructor_id, course_name, description, price, duration_hours) VALUES
(1, 'SQL Fundamentals', 'Learn SQL from scratch', 49.99, 10),
(1, 'Advanced Database Design', 'Master schema design', 79.99, 15),
(2, 'Python for Beginners', 'Introduction to Python', 39.99, 12),
(2, 'Web Development Bootcamp', 'Full stack development', 199.99, 40);

INSERT INTO ip10_enrollments (student_id, course_id, progress_percent, completed) VALUES
(1, 1, 100, TRUE),
(1, 2, 45, FALSE),
(2, 1, 80, FALSE),
(2, 3, 100, TRUE),
(3, 1, 30, FALSE),
(3, 4, 60, FALSE);

INSERT INTO ip10_course_reviews (course_id, student_id, rating, review_text) VALUES
(1, 1, 5, 'Excellent course! Very clear explanations.'),
(1, 2, 4, 'Great content, but could use more examples.'),
(3, 2, 5, 'Perfect for beginners!'),
(2, 1, 4, 'Advanced topics covered well.');

-- Complex query: Average rating per course with instructor
SELECT 
  c.course_name,
  i.name AS instructor_name,
  COUNT(DISTINCT e.student_id) AS total_students,
  AVG(r.rating) AS avg_rating,
  COUNT(r.review_id) AS review_count
FROM ip10_courses c
JOIN ip10_instructors i ON c.instructor_id = i.instructor_id
LEFT JOIN ip10_enrollments e ON c.course_id = e.course_id
LEFT JOIN ip10_course_reviews r ON c.course_id = r.course_id
GROUP BY c.course_id, c.course_name, i.name
ORDER BY avg_rating DESC, total_students DESC;

-- Query: Student progress across all courses
SELECT 
  s.name AS student_name,
  c.course_name,
  e.progress_percent,
  e.completed,
  e.enrolled_at
FROM ip10_students s
JOIN ip10_enrollments e ON s.student_id = e.student_id
JOIN ip10_courses c ON e.course_id = c.course_id
ORDER BY s.name, e.enrolled_at;
```

---

## Exercise 4: Hospital Management System (Expert)

**Difficulty:** ⭐⭐⭐ Expert

### Scenario
Design a hospital database tracking patients, doctors, appointments, and medical records.

### Requirements
1. Create `departments` table:
   - dept_id (PK, auto-increment)
   - dept_name (VARCHAR 100, UNIQUE, NOT NULL)
   - location (VARCHAR 100)

2. Create `doctors` table:
   - doctor_id (PK, auto-increment)
   - dept_id (FK to departments)
   - name (VARCHAR 100, NOT NULL)
   - specialization (VARCHAR 100)
   - phone (VARCHAR 20)
   - email (VARCHAR 100, UNIQUE)

3. Create `patients` table:
   - patient_id (PK, auto-increment)
   - name (VARCHAR 100, NOT NULL)
   - date_of_birth (DATE, NOT NULL)
   - phone (VARCHAR 20)
   - email (VARCHAR 100)
   - address (TEXT)
   - registered_at (TIMESTAMP, default CURRENT_TIMESTAMP)

4. Create `appointments` table:
   - appointment_id (PK, auto-increment)
   - patient_id (FK to patients)
   - doctor_id (FK to doctors)
   - appointment_date (DATE, NOT NULL)
   - appointment_time (TIME, NOT NULL)
   - status (ENUM: 'scheduled', 'completed', 'cancelled')
   - notes (TEXT)
   - UNIQUE constraint on (doctor_id, appointment_date, appointment_time)

5. Create `medical_records` table:
   - record_id (PK, auto-increment)
   - patient_id (FK to patients)
   - doctor_id (FK to doctors)
   - appointment_id (FK to appointments, nullable)
   - diagnosis (TEXT)
   - prescription (TEXT)
   - record_date (DATE, default CURDATE())
   - created_at (TIMESTAMP, default CURRENT_TIMESTAMP)

6. Add appropriate indexes on all FK columns
7. Insert comprehensive sample data

### Success Criteria
- All relationships properly defined
- Doctor cannot have two appointments at same time
- Complex queries work for:
  - Patient appointment history with doctor names
  - Doctor schedule for a given date
  - Department-wise patient count

### Solution
```sql
-- Clean slate
DROP TABLE IF EXISTS ip10_medical_records;
DROP TABLE IF EXISTS ip10_appointments;
DROP TABLE IF EXISTS ip10_patients;
DROP TABLE IF EXISTS ip10_doctors;
DROP TABLE IF EXISTS ip10_departments;

-- Departments
CREATE TABLE ip10_departments (
  dept_id INT AUTO_INCREMENT PRIMARY KEY,
  dept_name VARCHAR(100) UNIQUE NOT NULL,
  location VARCHAR(100)
);

-- Doctors
CREATE TABLE ip10_doctors (
  doctor_id INT AUTO_INCREMENT PRIMARY KEY,
  dept_id INT,
  name VARCHAR(100) NOT NULL,
  specialization VARCHAR(100),
  phone VARCHAR(20),
  email VARCHAR(100) UNIQUE,
  CONSTRAINT fk_doctor_dept FOREIGN KEY (dept_id) 
    REFERENCES ip10_departments(dept_id),
  INDEX idx_dept (dept_id)
);

-- Patients
CREATE TABLE ip10_patients (
  patient_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  date_of_birth DATE NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(100),
  address TEXT,
  registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Appointments
CREATE TABLE ip10_appointments (
  appointment_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT,
  doctor_id INT,
  appointment_date DATE NOT NULL,
  appointment_time TIME NOT NULL,
  status ENUM('scheduled', 'completed', 'cancelled') DEFAULT 'scheduled',
  notes TEXT,
  CONSTRAINT fk_appt_patient FOREIGN KEY (patient_id) 
    REFERENCES ip10_patients(patient_id),
  CONSTRAINT fk_appt_doctor FOREIGN KEY (doctor_id) 
    REFERENCES ip10_doctors(doctor_id),
  UNIQUE KEY uk_doctor_datetime (doctor_id, appointment_date, appointment_time),
  INDEX idx_patient_appt (patient_id),
  INDEX idx_doctor_appt (doctor_id),
  INDEX idx_appt_date (appointment_date)
);

-- Medical Records
CREATE TABLE ip10_medical_records (
  record_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT,
  doctor_id INT,
  appointment_id INT,
  diagnosis TEXT,
  prescription TEXT,
  record_date DATE DEFAULT (CURDATE()),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_record_patient FOREIGN KEY (patient_id) 
    REFERENCES ip10_patients(patient_id),
  CONSTRAINT fk_record_doctor FOREIGN KEY (doctor_id) 
    REFERENCES ip10_doctors(doctor_id),
  CONSTRAINT fk_record_appt FOREIGN KEY (appointment_id) 
    REFERENCES ip10_appointments(appointment_id),
  INDEX idx_patient_record (patient_id),
  INDEX idx_doctor_record (doctor_id),
  INDEX idx_record_date (record_date)
);

-- Sample data
INSERT INTO ip10_departments (dept_name, location) VALUES
('Cardiology', 'Building A, Floor 3'),
('Neurology', 'Building B, Floor 2'),
('Pediatrics', 'Building C, Floor 1');

INSERT INTO ip10_doctors (dept_id, name, specialization, phone, email) VALUES
(1, 'Dr. Emily Carter', 'Cardiologist', '555-0101', 'emily.carter@hospital.com'),
(1, 'Dr. James Wilson', 'Cardiac Surgeon', '555-0102', 'james.wilson@hospital.com'),
(2, 'Dr. Lisa Martinez', 'Neurologist', '555-0103', 'lisa.martinez@hospital.com'),
(3, 'Dr. Robert Brown', 'Pediatrician', '555-0104', 'robert.brown@hospital.com');

INSERT INTO ip10_patients (name, date_of_birth, phone, email, address) VALUES
('John Smith', '1985-03-15', '555-1001', 'john.smith@email.com', '123 Main St'),
('Mary Johnson', '1990-07-22', '555-1002', 'mary.johnson@email.com', '456 Oak Ave'),
('David Lee', '1978-11-08', '555-1003', 'david.lee@email.com', '789 Pine Rd'),
('Sarah Davis', '2010-05-30', '555-1004', 'parent@email.com', '321 Elm St');

INSERT INTO ip10_appointments (patient_id, doctor_id, appointment_date, appointment_time, status, notes) VALUES
(1, 1, '2025-11-05', '09:00:00', 'scheduled', 'Regular checkup'),
(1, 1, '2025-10-15', '09:00:00', 'completed', 'Follow-up'),
(2, 3, '2025-11-06', '10:30:00', 'scheduled', 'Headache consultation'),
(3, 2, '2025-11-07', '14:00:00', 'scheduled', 'Pre-surgery consultation'),
(4, 4, '2025-11-08', '11:00:00', 'scheduled', 'Annual checkup');

INSERT INTO ip10_medical_records (patient_id, doctor_id, appointment_id, diagnosis, prescription, record_date) VALUES
(1, 1, 2, 'Mild hypertension', 'Lisinopril 10mg daily', '2025-10-15'),
(2, 3, NULL, 'Migraine', 'Sumatriptan as needed', '2025-10-20');

-- Query: Patient appointment history
SELECT 
  p.name AS patient_name,
  d.name AS doctor_name,
  dept.dept_name,
  a.appointment_date,
  a.appointment_time,
  a.status
FROM ip10_appointments a
JOIN ip10_patients p ON a.patient_id = p.patient_id
JOIN ip10_doctors d ON a.doctor_id = d.doctor_id
JOIN ip10_departments dept ON d.dept_id = dept.dept_id
WHERE p.patient_id = 1
ORDER BY a.appointment_date DESC, a.appointment_time DESC;

-- Query: Doctor schedule for a specific date
SELECT 
  d.name AS doctor_name,
  d.specialization,
  a.appointment_time,
  p.name AS patient_name,
  a.status,
  a.notes
FROM ip10_appointments a
JOIN ip10_doctors d ON a.doctor_id = d.doctor_id
JOIN ip10_patients p ON a.patient_id = p.patient_id
WHERE a.appointment_date = '2025-11-05'
ORDER BY d.name, a.appointment_time;

-- Query: Department-wise patient count
SELECT 
  dept.dept_name,
  dept.location,
  COUNT(DISTINCT a.patient_id) AS unique_patients,
  COUNT(a.appointment_id) AS total_appointments
FROM ip10_departments dept
JOIN ip10_doctors d ON dept.dept_id = d.dept_id
JOIN ip10_appointments a ON d.doctor_id = a.doctor_id
GROUP BY dept.dept_id, dept.dept_name, dept.location
ORDER BY unique_patients DESC;
```

---

**Key Takeaways:**
- Always design schema on paper first—visualize relationships
- Create parent tables before child tables (FK references must exist)
- Use appropriate data types (ENUM for fixed values, DECIMAL for money)
- Composite UNIQUE constraints prevent duplicate business-level combinations
- Indexes on FK columns improve JOIN performance dramatically
- CHECK constraints enforce business rules at database level
- Test constraints by trying to violate them—validates your design
- Many-to-many relationships need junction tables
- Nullable FKs allow optional relationships (e.g., appointment_id in medical_records)