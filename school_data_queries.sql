-- What are the percentages at which each grade point is received (e.g., 3, not 3.3)
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


-- How many As, Bs, Cs, Ds, and Fs are given out in core subjects
SELECT
	grade_point_used,
	count(student_id) AS count,
	round(count(student_id)/(
		SELECT count(g.student_id)
		FROM grades AS g 
		WHERE course_subject IN ('English', 'Science', 'Mathematics', 'Social Studies')
	)*100, 2) AS perc
FROM grades
WHERE course_subject IN ('English', 'Science', 'Mathematics', 'Social Studies')
GROUP BY 
	grade_point_used
ORDER BY grade_point_used DESC;

-- How many As, Bs, Cs, Ds, and Fs are given out in non-core subjects
SELECT
	grade_point_used,
	count(student_id) AS count,
	round(count(student_id)/(
		SELECT count(g.student_id)
		FROM grades AS g 
		WHERE course_subject NOT IN ('English', 'Science', 'Mathematics', 'Social Studies')
	)*100, 2) AS perc
FROM grades
WHERE course_subject NOT IN ('English', 'Science', 'Mathematics', 'Social Studies')
GROUP BY 
	grade_point_used
ORDER BY grade_point_used DESC;

-- All department average grades
SELECT 
	round(avg(grade_point_dec), 2) AS average,
	course_subject
FROM grades
GROUP BY course_subject
ORDER BY average DESC;



-- English department analytics (looking only at core English classes)

-- English department average grade by teacher

SELECT 
	round(avg(grade_point_dec), 2) AS average,
	teacher_id
FROM grades
WHERE course_subject='English'
GROUP BY teacher_id
ORDER BY average DESC;

-- English department average grade (using +/-) by teacher (not including honors/AP)

SELECT 
	round(avg(grade_point_dec), 2) AS average,
	teacher_id
FROM grades
WHERE course_subject='English'
	AND course_title NOT LIKE '%Honors%'
	AND course_title NOT LIKE '%AP%'
GROUP BY teacher_id
ORDER BY average DESC;

-- English department average grade (no +/-; used for GPA) by teacher (not including honors/AP)
SELECT 
	round(avg(grade_point_used), 2) AS average,
	teacher_id
FROM grades
WHERE course_subject='English'
	AND course_title NOT LIKE '%Honors%'
	AND course_title NOT LIKE '%AP%'
GROUP BY teacher_id
ORDER BY average DESC;

-- English department honors average grade by teacher
SELECT 
	round(avg(grade_point_dec), 2) AS average,
	teacher_id
FROM grades
WHERE course_subject='English'
	AND (course_title LIKE '%Honors%'
	OR course_title LIKE '%AP%')
GROUP BY teacher_id
ORDER BY average DESC;

-- English department average grade by course and teacher

SELECT 
	round(avg(grade_point_dec), 2) AS average,
	course_title,
	teacher_id
FROM grades
WHERE course_subject='English'
GROUP BY course_title, teacher_id
ORDER BY average DESC;

-- English department average grade by course
SELECT 
	round(avg(grade_point_dec), 2) AS average,
	course_title
FROM grades
LEFT JOIN teachers USING(teacher_id)
WHERE course_subject='English'
GROUP BY course_title
ORDER BY average DESC;
