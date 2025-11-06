# Paired Programming — Procedures & Functions

## 📋 Before You Start

### Learning Objectives
Through paired programming, you will:
- Experience collaborative stored procedure development
- Learn to communicate parameter choices (IN, OUT, INOUT) clearly
- Practice deciding when to use procedures vs functions
- Build teamwork skills for building reusable SQL logic
- Apply DELIMITER syntax and error handling collaboratively

### Paired Programming Roles
**🚗 Driver (Controls Keyboard):**
- Types all SQL code with DELIMITER management
- Verbalizes parameter choices ("Using OUT for return value...")
- Asks navigator about validation logic
- Focuses on syntax

**🧭 Navigator (Reviews & Guides):**
- Keeps requirements visible
- Spots missing DELIMITERs or syntax errors
- Suggests testing with CALL and SELECT
- Discusses procedure vs function trade-offs
- **Does NOT touch the keyboard**

### Execution Flow
1. **Setup**: Driver runs schema (CREATE + INSERT)
2. **Task 1**: Partner A as Driver → create procedure → test → **SWITCH ROLES**
3. **Task 2**: Partner B as Driver → create function → test → **SWITCH ROLES**
4. **Tasks 3-4**: Alternate roles for remaining tasks
5. **Review**: Compare solutions, discuss design choices

**Tip:** Always use DELIMITER // before creating procedures/functions, and DELIMITER ; after!

---

## Challenge: Build User Management Library

**Tasks:**
1. Partner A: Create `register_user()` procedure with validation
2. Partner B: Create `authenticate_user()` function
3. Together: Create `update_user_profile()` procedure
4. Together: Create `get_user_stats()` procedure with multiple OUT parameters

**Discuss:** When to use procedure vs function, parameter types, error handling strategies.

