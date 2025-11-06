# Paired Programming — Joins (30 min)

## 📋 Before You Start

### Learning Objectives
Through paired programming, you will:
- Experience collaborative SQL problem-solving with joins
- Learn to communicate join logic and relationships clearly
- Practice identifying INNER vs LEFT JOIN scenarios together
- Build teamwork skills essential for professional development
- Apply multi-table queries in a collaborative setting

### Paired Programming Roles
**🚗 Driver (Controls Keyboard):**
- Types all SQL code
- Verbalizes thought process ("Using LEFT JOIN because...")
- Asks navigator for confirmation
- Focuses on syntax and join conditions

**🧭 Navigator (Reviews & Guides):**
- Keeps requirements visible
- Spots errors before execution (watch for cartesian products!)
- Suggests tests and edge cases
- **Does NOT touch the keyboard**

### Execution Flow
1. **Setup**: Driver runs schema (CREATE + INSERT)
2. **Part A**: Navigator reads requirements → discuss approach → Driver codes → verify → **SWITCH ROLES**
3. **Part B**: Repeat with reversed roles → **SWITCH ROLES**
4. **Part C**: Repeat with reversed roles
5. **Review**: Compare solutions together

**Beginner Tip:** Joins are easier to learn together! The driver thinks aloud while building queries. The navigator watches for row count surprises (too many = accidental cartesian product). Switch roles to practice both perspectives. Celebrate progress!

---

## Activity: Music Streaming Platform

Roles
- Driver: types the queries and explains each clause aloud.
- Navigator: reviews logic, asks "why," spots edge cases, and suggests tests.

Collaboration tips
- Switch roles after each part.
- Verbalize assumptions and confirm with small checks (SELECT COUNT(*), DISTINCT checks).

Schema (Music streaming)
```sql
DROP TABLE IF EXISTS pp5_users;
CREATE TABLE pp5_users (user_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO pp5_users VALUES (1,'Ava'),(2,'Noah'),(3,'Mia');

DROP TABLE IF EXISTS pp5_artists;
CREATE TABLE pp5_artists (artist_id INT PRIMARY KEY, name VARCHAR(60));
INSERT INTO pp5_artists VALUES (10,'ALPHA'),(20,'BETA');

DROP TABLE IF EXISTS pp5_tracks;
CREATE TABLE pp5_tracks (track_id INT PRIMARY KEY, title VARCHAR(80), artist_id INT);
INSERT INTO pp5_tracks VALUES (100,'Sunrise',10),(101,'Noon',10),(102,'Moon',20);

DROP TABLE IF EXISTS pp5_plays;
CREATE TABLE pp5_plays (play_id INT PRIMARY KEY, user_id INT, track_id INT, played_at DATETIME);
INSERT INTO pp5_plays VALUES
(1,1,100,'2025-03-01 08:01:00'),(2,1,101,'2025-03-01 10:00:00'),(3,2,102,'2025-03-02 11:30:00');
```

Parts
A) Plays by artist: return artist name and total plays.
B) Top 2 artists by plays per user.
C) Users with no plays (anti-join) and a friendly message.

Role-switching points
- Switch after finishing Part A and again after B.

Solutions
```sql
-- A) Plays by artist
SELECT a.name AS artist, COUNT(p.play_id) AS plays
FROM pp5_artists a
JOIN pp5_tracks t ON t.artist_id = a.artist_id
LEFT JOIN pp5_plays p ON p.track_id = t.track_id
GROUP BY a.name
ORDER BY plays DESC, artist;

-- B) Top 2 artists per user
-- Simplified approach: Show all user-artist combinations with play counts
-- For "top N per group" filtering, see Module 8 (Window Functions)
SELECT u.name AS user_name, a.name AS artist,
       COUNT(p.play_id) AS plays
FROM pp5_users u
LEFT JOIN pp5_plays p ON p.user_id = u.user_id
LEFT JOIN pp5_tracks t ON t.track_id = p.track_id
LEFT JOIN pp5_artists a ON a.artist_id = t.artist_id
GROUP BY u.user_id, u.name, a.name
ORDER BY user_name, plays DESC;

-- 📚 PREVIEW (Modules 6 & 8): For limiting to top 2 per user with Window Functions
/*
WITH user_artist AS (
  SELECT u.name AS user_name, a.name AS artist,
         COUNT(p.play_id) AS plays,
         ROW_NUMBER() OVER (PARTITION BY u.user_id ORDER BY COUNT(p.play_id) DESC) AS rn
  FROM pp5_users u
  LEFT JOIN pp5_plays p ON p.user_id = u.user_id
  LEFT JOIN pp5_tracks t ON t.track_id = p.track_id
  LEFT JOIN pp5_artists a ON a.artist_id = t.artist_id
  GROUP BY u.user_id, u.name, a.name
)
SELECT user_name, artist, plays
FROM user_artist
WHERE rn <= 2
ORDER BY user_name, rn;
*/

-- C) Users with no plays
SELECT u.name, 'No plays yet' AS note
FROM pp5_users u
LEFT JOIN pp5_plays p ON p.user_id = u.user_id
WHERE p.play_id IS NULL
ORDER BY u.name;
```
