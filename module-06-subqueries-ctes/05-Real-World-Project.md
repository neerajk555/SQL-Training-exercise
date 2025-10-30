# Real-World Project — Learning Platform Analytics (45–60 min)

Company background
- Acme Learning Hub offers online courses with prerequisites. Students enroll, complete lessons, and generate daily activity. Stakeholders want actionable analytics driven by subqueries and CTEs.

Business problem
- Provide course- and learner-level insights: completion rates, unmet prerequisites, monthly engagement, and a March calendar rollup using a recursive CTE.

Database (6 tables, 30+ rows overall)
```sql
-- Users
DROP TABLE IF EXISTS rwp6_users;
CREATE TABLE rwp6_users (user_id INT PRIMARY KEY, name VARCHAR(60), active TINYINT);
INSERT INTO rwp6_users VALUES
(1,'Ava',1),(2,'Noah',1),(3,'Mia',0),(4,'Leo',1),(5,'Zoe',1),(6,'Sam',1),
(7,'Ivy',1),(8,'Ethan',0),(9,'Olivia',1),(10,'Lucas',1),(11,'Emma',1),(12,'Will',1);

-- Courses
DROP TABLE IF EXISTS rwp6_courses;
CREATE TABLE rwp6_courses (course_id INT PRIMARY KEY, code VARCHAR(10), title VARCHAR(80));
INSERT INTO rwp6_courses VALUES
(101,'SQL1','SQL Foundations'),(102,'SQL2','Intermediate SQL'),(201,'DS1','Data Skills I'),
(202,'DS2','Data Skills II'),(301,'ETL','ETL Basics'),(401,'WIN','Window Functions');

-- Course prerequisites (edges)
DROP TABLE IF EXISTS rwp6_prereqs;
CREATE TABLE rwp6_prereqs (course_id INT, prereq_course_id INT);
INSERT INTO rwp6_prereqs VALUES
(102,101),(201,101),(202,201),(401,102);

-- Enrollments
DROP TABLE IF EXISTS rwp6_enrollments;
CREATE TABLE rwp6_enrollments (enrollment_id INT PRIMARY KEY, user_id INT, course_id INT, enrolled_on DATE);
INSERT INTO rwp6_enrollments VALUES
(1,1,101,'2025-02-20'),(2,1,102,'2025-03-02'),(3,2,101,'2025-03-01'),(4,2,201,'2025-03-03'),
(5,3,101,'2025-02-01'),(6,4,101,'2025-03-04'),(7,5,202,'2025-03-05'),(8,6,201,'2025-03-06'),
(9,7,401,'2025-03-07'),(10,8,101,'2025-01-15'),(11,9,102,'2025-03-08'),(12,10,101,'2025-03-08'),
(13,11,101,'2025-03-09'),(14,11,102,'2025-03-20'),(15,12,301,'2025-03-10');

-- Lessons per course
DROP TABLE IF EXISTS rwp6_lessons;
CREATE TABLE rwp6_lessons (lesson_id INT PRIMARY KEY, course_id INT, title VARCHAR(80));
INSERT INTO rwp6_lessons VALUES
(1,101,'Intro'),(2,101,'SELECT'),(3,101,'WHERE'),(4,102,'JOINs'),(5,102,'Aggregates'),
(6,201,'Data Types'),(7,201,'Cleaning'),(8,202,'Pipelines'),(9,301,'ETL Intro'),(10,401,'Windows');

-- Lesson completions
DROP TABLE IF EXISTS rwp6_completions;
CREATE TABLE rwp6_completions (completion_id INT PRIMARY KEY, user_id INT, lesson_id INT, completed_on DATE);
INSERT INTO rwp6_completions VALUES
(1,1,1,'2025-02-21'),(2,1,2,'2025-02-22'),(3,1,4,'2025-03-05'),(4,2,1,'2025-03-02'),
(5,2,6,'2025-03-04'),(6,4,1,'2025-03-04'),(7,5,8,'2025-03-06'),(8,6,6,'2025-03-07'),
(9,7,10,'2025-03-10'),(10,9,4,'2025-03-09'),(11,10,1,'2025-03-09'),(12,11,2,'2025-03-10'),
(13,11,4,'2025-03-22'),(14,12,9,'2025-03-12');
```

Deliverables and acceptance criteria
1) Completion rate per course
- Return course code, title, lessons_count, unique_learners, total_completions, completion_rate (completions/lessons_count per learner basis acceptable as proxy).
- Acceptance: One row per course with zero-safe denominators and clear rounding.

2) Learners enrolled without meeting prerequisites
- Return learner name, course code, and missing_prereq list using EXISTS/NOT EXISTS.
- Acceptance: Only learners with unmet prereqs; list distinct missing prereq codes.

3) March 2025 active learners (CTE pipeline)
- Return learner name and March-2025 completion_count, including zeros for active users.
- Acceptance: Active users present with 0+ counts; dates filtered to March in staging CTEs.

4) March calendar rollup (recursive CTE)
- Generate dates from 2025-03-01 to 2025-03-31 using a recursive CTE and join to daily completions.
- Acceptance: 31 rows, 0 counts allowed; chronological order.

Bonus objectives
- Top-2 courses by completion count per week (window function over derived weekly table).
- Learners who enrolled in a course and completed at least 2 lessons within 7 days (correlated subquery or window).

Evaluation rubric (10 pts total)
- Correctness (4)
- Readability (3)
- Robustness (2)
- Performance (1)

Model solutions
```sql
-- 1) Completion rate per course
WITH lesson_counts AS (
  SELECT course_id, COUNT(*) AS lessons_count
  FROM rwp6_lessons
  GROUP BY course_id
), course_completions AS (
  SELECT l.course_id, COUNT(*) AS total_completions,
         COUNT(DISTINCT c.user_id) AS unique_learners
  FROM rwp6_completions c
  JOIN rwp6_lessons l ON l.lesson_id = c.lesson_id
  GROUP BY l.course_id
)
SELECT co.code, co.title,
       COALESCE(lc.lessons_count,0) AS lessons_count,
       COALESCE(cc.unique_learners,0) AS unique_learners,
       COALESCE(cc.total_completions,0) AS total_completions,
       CASE WHEN COALESCE(lc.lessons_count,0) = 0 THEN 0
            ELSE ROUND(COALESCE(cc.total_completions,0) / lc.lessons_count, 2) END AS completion_rate
FROM rwp6_courses co
LEFT JOIN lesson_counts lc ON lc.course_id = co.course_id
LEFT JOIN course_completions cc ON cc.course_id = co.course_id
ORDER BY co.code;

-- 2) Learners enrolled without meeting prerequisites
-- For each enrollment, check for any prereq of that course that the user has NOT completed.
WITH prereq_codes AS (
  SELECT p.course_id, c2.code AS prereq_code
  FROM rwp6_prereqs p
  JOIN rwp6_courses c2 ON c2.course_id = p.prereq_course_id
), missing AS (
  SELECT e.user_id, e.course_id, pc.prereq_code
  FROM rwp6_enrollments e
  JOIN prereq_codes pc ON pc.course_id = e.course_id
  WHERE NOT EXISTS (
    SELECT 1
    FROM rwp6_completions comp
    JOIN rwp6_lessons l ON l.lesson_id = comp.lesson_id
    JOIN rwp6_courses cx ON cx.course_id = l.course_id
    WHERE comp.user_id = e.user_id AND cx.code = pc.prereq_code
  )
)
SELECT u.name, c.code AS course_code,
       GROUP_CONCAT(DISTINCT m.prereq_code ORDER BY m.prereq_code) AS missing_prereqs
FROM missing m
JOIN rwp6_users u ON u.user_id = m.user_id
JOIN rwp6_courses c ON c.course_id = m.course_id
GROUP BY u.name, c.code
ORDER BY u.name, c.code;

-- 3) March 2025 active learners (CTE pipeline)
WITH active_users AS (
  SELECT user_id, name FROM rwp6_users WHERE active = 1
), march_completions AS (
  SELECT comp.user_id
  FROM rwp6_completions comp
  WHERE comp.completed_on >= '2025-03-01' AND comp.completed_on < '2025-04-01'
)
SELECT au.name, COALESCE(mc.cnt,0) AS completion_count
FROM active_users au
LEFT JOIN (
  SELECT user_id, COUNT(*) AS cnt
  FROM march_completions
  GROUP BY user_id
) mc ON mc.user_id = au.user_id
ORDER BY completion_count DESC, au.name;

-- 4) March calendar rollup (recursive CTE)
WITH RECURSIVE calendar AS (
  SELECT DATE('2025-03-01') AS d
  UNION ALL
  SELECT DATE_ADD(d, INTERVAL 1 DAY)
  FROM calendar
  WHERE d < '2025-03-31'
), daily AS (
  SELECT comp.completed_on AS d, COUNT(*) AS cnt
  FROM rwp6_completions comp
  WHERE comp.completed_on >= '2025-03-01' AND comp.completed_on <= '2025-03-31'
  GROUP BY comp.completed_on
)
SELECT c.d AS day, COALESCE(dy.cnt,0) AS completions
FROM calendar c
LEFT JOIN daily dy ON dy.d = c.d
ORDER BY c.d;
```

Performance notes
- Stage aggregations in CTEs or derived tables to avoid row explosions.
- Index keys used in joins and filters: enrollments(user_id, course_id), completions(user_id, lesson_id, completed_on), lessons(course_id), prereqs(course_id, prereq_course_id).
- For heavy recursive calendars, pre-create a dates table and reuse it.
