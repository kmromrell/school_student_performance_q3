# school_student_performance_q3
A SQL- and R-based correlational/descriptive analysis of schoolwide student performance and demographic data. See anonymized report [here](https://docs.google.com/presentation/d/1Ud1r2N88FRdj8OlvtDZVQp6WRiUPfX5vLzeP5yJZW00/edit?usp=sharing).

## Master List of Functions Used: 
*(Note: This list is compiled by ChatGPT and checked/reorganized by me)*

### SQL Basics
* Essentials: `SELECT`, `FROM`, `WHERE`
* Grouping: `GROUP BY`, `HAVING`
* Viewing/Aliases: `ORDER BY`, `LIMIT`, `DISTINCT`, `AS`
* Basic Operators: `=`, `<`, `>`, `<=`, `>=`, `!=`, `<>`
* Basic Arithmetic: `+`, `-`, `*`, `/`

### Aggregate Functions
* Basic Aggregation: `COUNT()`, `AVG()`
* Aggregation Support: `ROUND()`, `WITH ROLLUP`

### Joins & Other Combination Queries
* Joins: `INNER JOIN`, `LEFT JOIN`, `USING()`
* Subqueries: Used in `SELECT`, `FROM`, and `WHERE` clauses

### Conditional Expressions
* Conditional Logic: `CASE WHEN ... THEN ... ELSE ... END`
* Null Handling: `COALESCE()`, `IS NULL`, `IS NOT NULL`

### Table Design/Column Generation
* Table Creation and Alteration: `CREATE TABLE AS`, `ALTER TABLE ADD COLUMN`
* Generated Columns: `GENERATED ALWAYS AS () STORED`

