# Module 3: Data Types & Functions

In this module, you’ll practice MySQL data types and core functions for text, numbers, and dates. You’ll clean messy inputs, convert types safely, and derive useful fields with expressions and CASE.

What you’ll practice
- Data types: `INT`, `DECIMAL`, `VARCHAR`/`CHAR`/`TEXT`, `DATE`/`DATETIME`/`TIME`, `TINYINT(1)` as boolean
- Conversions: `CAST()`, `CONVERT()`, `STR_TO_DATE()`, `DATE_FORMAT()`
- String functions: `TRIM`, `LTRIM`, `RTRIM`, `LOWER`/`UPPER`, `REPLACE`, `SUBSTRING`, `LEFT`, `RIGHT`, `SUBSTRING_INDEX`, `LENGTH`
- Numeric functions: `ROUND`, `TRUNCATE`, `CEIL`, `FLOOR`, `ABS`
- Date/time functions: `NOW`, `CURRENT_DATE`, `DATE_ADD`/`DATE_SUB`, `DATEDIFF`, `TIMESTAMPDIFF`
- NULL handling and safety: `COALESCE`, `IFNULL`, `NULLIF`, safe division patterns
- Conditional logic: `CASE`

Guidelines
- MySQL syntax only; use backticks for reserved identifiers.
- Include edge cases: NULLs, empty strings, zero, bad formats.
- Prefer sargable predicates; avoid wrapping filtered columns when possible.

Files in this module
- 01-Quick-Warm-Ups.md
- 02-Guided-Step-by-Step.md
- 03-Independent-Practice.md
- 04-Paired-Programming.md
- 05-Real-World-Project.md
- 06-Error-Detective.md
- 07-Speed-Drills.md
- 08-Take-Home-Challenges.md

Tip: When converting strings to numbers or dates, validate format with `REGEXP` or guard with `NULLIF` to avoid unexpected coercion.
