-- Looking at grades overall to create familiarity


-- Count of grades received (A=4, B=3, etc.)

SELECT
	grade_point_used,
	count(student_id) AS count,
	round(count(student_id)/(
		SELECT count(g.student_id)
		FROM grades AS g 
	)*100, 2) AS perc
FROM grades
GROUP BY 
	grade_point_used
ORDER BY grade_point_used DESC;

-- Count of grades received using +/- grades (e.g., B+ is 3.3, not 3)

SELECT
	grade_point_dec,
	count(student_id) AS count,
	round(count(student_id)/(
		SELECT count(g.student_id)
		FROM grades AS g 
	)*100, 2) AS perc
FROM grades
GROUP BY 
	grade_point_dec
ORDER BY grade_point_dec DESC;

-- Count of grades received (A=4, B=3, etc.) in core classes

SELECT
	grade_point_used,
	count(student_id) AS count,
	round(count(student_id)/(
		SELECT count(g.student_id)
		FROM grades AS g 
		LEFT JOIN courses AS c USING(course_id, course_subject, course_title)
		WHERE core_req=1
	)*100, 2) AS perc
FROM grades AS g 
LEFT JOIN courses AS c USING(course_id, course_subject, course_title)
WHERE core_req=1
GROUP BY 
	grade_point_used
ORDER BY grade_point_used DESC;

-- Count of grades received (A=4, B=3, etc.) in non-core classes

SELECT
	grade_point_used,
	count(student_id) AS count,
	round(count(student_id)/(
		SELECT count(g.student_id)
		FROM grades AS g 
		LEFT JOIN courses AS c USING(course_id, course_subject, course_title)
		WHERE core_req != 1
	)*100, 2) AS perc
FROM grades AS g 
LEFT JOIN courses AS c USING(course_id, course_subject, course_title)
WHERE core_req != 1
GROUP BY 
	grade_point_used
ORDER BY grade_point_used DESC;



-- Average grade (using +/-) by department

SELECT 
	course_subject,
	round(avg(grade_point_dec), 2) AS average
FROM grades
GROUP BY course_subject
ORDER BY average DESC;


-- Average grade (using +/-) in only core classes by department

SELECT 
	course_subject,
	round(avg(grade_point_dec), 2) AS average
FROM grades
LEFT JOIN courses AS c USING(course_id, course_title, course_subject)
WHERE 
	c.core_req=1
GROUP BY course_subject
ORDER BY average DESC;

-- Average grade (using +/-) in only core classes by department(but not including ACS in English)

SELECT 
	course_subject,
	round(avg(grade_point_dec), 2) AS average
FROM grades
LEFT JOIN courses AS c USING(course_id, course_title, course_subject)
WHERE 
	c.core_req=1
	AND course_title != 'Adv Comm Skills'
GROUP BY course_subject
ORDER BY average DESC;

-- Average grade by course, identifying the 20 hardest courses (only including courses with at least 20 students)
SELECT 
	course_title,
	round(avg(grade_point_dec), 2) AS average,
	count(course_title) AS count
FROM grades
GROUP BY course_title
HAVING count(course_title)>=20
ORDER BY average ASC
LIMIT 20;







/* English department analytics 
Unless otherwise stated, queries are considering these conditions:
	- Querying only core English classes (not electives/ACS)
	- Using a +/- grade scale (e.g., a B+ is a 3.3, not a 3) -- more specific, but not used to calculate GPA */




-- English department average grade by course (including electives/ACS)
SELECT 
	course_title,
	round(avg(grade_point_dec), 2) AS average
FROM grades
WHERE 
	course_subject='English'
GROUP BY course_title
ORDER BY average DESC;

-- English department average grade by teacher

SELECT 
	teacher_id,
	round(avg(grade_point_dec), 2) AS average
FROM grades AS g
LEFT JOIN courses AS c USING(course_id, course_title, course_subject)
WHERE 
	course_subject='English' 
	AND c.core_req=1
	AND course_title !='Adv Comm Skills'
GROUP BY teacher_id
ORDER BY average DESC;

-- English department average grade for non-honors/AP English classes by teacher

SELECT 
	teacher_id,
	round(avg(grade_point_dec), 2) AS average
FROM grades AS g
LEFT JOIN courses AS c USING(course_id, course_title, course_subject)
WHERE 
	course_subject='English'
	AND c.core_req=1
	AND course_title !='Adv Comm Skills'
	AND c.weighted=0
GROUP BY teacher_id
ORDER BY average DESC;

-- English department average grade (no +/-; grades used for GPA) for non-honors/AP English classes by teacher
SELECT 
	teacher_id,
	round(avg(grade_point_used), 2) AS average
FROM grades AS g
LEFT JOIN courses AS c USING(course_id, course_title, course_subject)
WHERE 
	course_subject='English'
	AND c.core_req=1
	AND course_title !='Adv Comm Skills'
	AND c.weighted=0
GROUP BY teacher_id
ORDER BY average DESC;

-- English department average grade for honors/AP classes by teacher
SELECT 
	teacher_id,
	round(avg(grade_point_dec), 2) AS average
FROM grades AS g
LEFT JOIN courses AS c USING(course_id, course_title, course_subject)
WHERE 
	course_subject='English'
	AND c.weighted=1
GROUP BY teacher_id
ORDER BY average DESC;

-- English department average grade by course and teacher

SELECT 
	teacher_id,
	course_title,
	round(avg(grade_point_dec), 2) AS average
FROM grades AS g
LEFT JOIN courses AS c USING(course_id, course_title, course_subject)
WHERE 
	course_subject='English'
	AND c.core_req=1
	AND course_title !='Adv Comm Skills'
GROUP BY course_title, teacher_id
ORDER BY average DESC;

-- English department average grade by course (including electives/ACS) and teacher

SELECT 
	teacher_id,
	course_title,
	round(avg(grade_point_dec), 2) AS average
FROM grades AS g
LEFT JOIN courses AS c USING(course_id, course_title, course_subject)
WHERE 
	course_subject='English'
GROUP BY course_title, teacher_id
ORDER BY average DESC;


