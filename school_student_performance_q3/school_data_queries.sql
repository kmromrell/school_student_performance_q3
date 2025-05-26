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
