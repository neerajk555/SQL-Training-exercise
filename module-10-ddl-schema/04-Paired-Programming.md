# Paired Programming — DDL & Schema Design

## 📋 Before You Start

### Learning Objectives
Through paired programming, you will:
- Experience collaborative database schema design
- Learn to communicate table relationships and constraints clearly
- Practice discussing data type choices and trade-offs
- Build teamwork skills for architectural decisions
- Apply DDL commands (CREATE, ALTER, DROP) collaboratively

### Paired Programming Roles
**🚗 Driver (Controls Keyboard):**
- Types all SQL code
- Verbalizes design decisions ("Using VARCHAR(100) because...")
- Asks navigator about constraint choices
- Focuses on syntax

**🧭 Navigator (Reviews & Guides):**
- Keeps requirements visible
- Spots missing constraints or relationships
- Suggests alternative data types
- Discusses normalization trade-offs
- **Does NOT touch the keyboard**

### Execution Flow
1. **Setup**: Both discuss schema requirements
2. **Challenge 1**: Navigator reads requirements → discuss design → Driver codes → verify → **SWITCH ROLES**
3. **Challenge 2**: Repeat with reversed roles
4. **Review**: Compare with solutions, discuss alternatives

**Goal:** Collaborate on schema design decisions, discuss trade-offs, and learn from each other's perspectives.

---

## Challenge 1: Movie Streaming Platform Schema

### Scenario
Design a database for a movie streaming service like Netflix. Track movies, users, watchlists, and viewing history.

### Requirements
1. **users** table: user_id, username (unique), email (unique), subscription_plan (ENUM), joined_date
2. **movies** table: movie_id, title, genre, release_year, duration_minutes, rating
3. **watchlist** table: Many-to-many between users and movies, added_date
4. **viewing_history** table: Track when users watch movies, watch_date, minutes_watched
5. Add appropriate constraints, indexes, and foreign keys

### Pair Discussion Points
- Should `genre` be a separate table or VARCHAR? (Normalization vs simplicity)
- How to handle movies with multiple genres?
- Should subscription_plan be ENUM or separate table?
- What indexes would improve "Recently watched" queries?

### Solution
```sql
-- Clean slate
DROP TABLE IF EXISTS pp10_viewing_history;
DROP TABLE IF EXISTS pp10_watchlist;
DROP TABLE IF EXISTS pp10_movies;
DROP TABLE IF EXISTS pp10_users;

-- Users table
CREATE TABLE pp10_users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  subscription_plan ENUM('free', 'basic', 'premium') DEFAULT 'free',
  joined_date DATE DEFAULT (CURDATE()),
  INDEX idx_username (username)
);

-- Movies table
CREATE TABLE pp10_movies (
  movie_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  genre VARCHAR(50),
  release_year INT CHECK (release_year >= 1800),
  duration_minutes INT CHECK (duration_minutes > 0),
  rating VARCHAR(10),
  INDEX idx_genre (genre),
  INDEX idx_year (release_year)
);

-- Watchlist (many-to-many)
CREATE TABLE pp10_watchlist (
  watchlist_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  movie_id INT,
  added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_watchlist_user FOREIGN KEY (user_id) 
    REFERENCES pp10_users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_watchlist_movie FOREIGN KEY (movie_id) 
    REFERENCES pp10_movies(movie_id) ON DELETE CASCADE,
  UNIQUE KEY uk_user_movie (user_id, movie_id),
  INDEX idx_user_watchlist (user_id)
);

-- Viewing history
CREATE TABLE pp10_viewing_history (
  history_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  movie_id INT,
  watch_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  minutes_watched INT CHECK (minutes_watched >= 0),
  CONSTRAINT fk_history_user FOREIGN KEY (user_id) 
    REFERENCES pp10_users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_history_movie FOREIGN KEY (movie_id) 
    REFERENCES pp10_movies(movie_id) ON DELETE CASCADE,
  INDEX idx_user_history (user_id, watch_date)
);

-- Sample data
INSERT INTO pp10_users (username, email, subscription_plan) VALUES
('movie_fan', 'fan@email.com', 'premium'),
('casual_viewer', 'casual@email.com', 'basic');

INSERT INTO pp10_movies (title, genre, release_year, duration_minutes, rating) VALUES
('The Matrix', 'Sci-Fi', 1999, 136, 'R'),
('Inception', 'Sci-Fi', 2010, 148, 'PG-13'),
('The Lion King', 'Animation', 1994, 88, 'G');

INSERT INTO pp10_watchlist (user_id, movie_id) VALUES (1, 2), (1, 3);
INSERT INTO pp10_viewing_history (user_id, movie_id, minutes_watched) VALUES (1, 1, 136);
```

### Discussion Questions
1. Why use ON DELETE CASCADE for watchlist and history?
2. How would you redesign to support multiple genres per movie?
3. What additional indexes would help "Trending movies" feature?

---

**Pair Programming Tips:**
- **Driver**: Explain your thought process as you code
- **Navigator**: Ask "what if" questions about edge cases  
- **Both**: Discuss trade-offs before committing to design decisions
- **Switch roles** halfway through!

**Key Learning Points:**
- Schema design involves trade-offs: normalization vs performance
- Constraints enforce business rules automatically
- Indexes are crucial for query performance
- Discuss with team before implementing!