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







-- Create table with all relevant information for R analysis

CREATE TABLE all_student_data AS ( 
	SELECT
		g.student_id,
		g.grade,
		g.grade_point_dec,
		g.grade_point_used,
		g.course_subject,
		g.course_title,
		
		-- Retrieve absences by period; default to 0 to account for students with no absences
		COALESCE(CASE g.period
			    WHEN 1 THEN a.period_1
	   			WHEN 2 THEN a.period_2
				WHEN 3 THEN a.period_3
	    		WHEN 4 THEN a.period_4
	    		WHEN 5 THEN a.period_5
	    		WHEN 6 THEN a.period_6 
	    		WHEN 7 THEN a.period_7
	    		WHEN 8 THEN a.period_8
	    		ELSE NULL
	  	END, 0) AS absences,
	  		  	
	  	-- Retrieve tardies by period; default to 0 to account for students with no tardies
	  	COALESCE(CASE g.period
			    WHEN 1 THEN tar.period_1 
	   			WHEN 2 THEN tar.period_2
				WHEN 3 THEN tar.period_3
	    		WHEN 4 THEN tar.period_4
	    		WHEN 5 THEN tar.period_5
	    		WHEN 6 THEN tar.period_6 
	    		WHEN 7 THEN tar.period_7
	    		WHEN 8 THEN tar.period_8
	    		ELSE 0
	  	END, 0) AS tardies,
	  	COALESCE(a.support_seminar, 0) AS ss_absences,
	  	gpa.gpa,
	  	gpa.credits_attempted,
	  	gpa.credits_completed,
	  	s.gender,
	  	s.grade_level,
	  	
	  	-- Demographic fields; default to 0 for Boolean logic (if unlisted, not part of program)
	  	COALESCE(e.ell, 0) AS ell,
	    COALESCE(s504.sec_504, 0) AS sec_504,
	    COALESCE(sped.sped, 0) AS sped,
	    COALESCE(tag.tag, 0) AS tag
	FROM grades AS g
	LEFT JOIN absences AS a USING(student_id)
	LEFT JOIN tardies as tar USING(student_id)
	LEFT JOIN ell as e USING(student_id)
	LEFT JOIN gpa USING(student_id)
	LEFT JOIN sec_504 as s504 USING(student_id)
	LEFT JOIN sped USING(student_id)
	LEFT JOIN students as s USING(student_id)
	LEFT JOIN tag as tag USING(student_id)
	LEFT JOIN transfer as tr USING(student_id)
);
