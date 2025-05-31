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
	grade_point_used AS grade_for_core,
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
	grade_point_used AS grade_non_core,
	count(student_id) AS count,
	round(count(student_id)/(
		-- Subquery to find percentage of students receiving that grade (only for core classes)
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

-- Average grade by course, identifying the 15 hardest courses (only including courses with at least 20 students)
SELECT 
	course_title,
	round(avg(grade_point_dec), 2) AS average,
	count(course_title) AS count
FROM grades
GROUP BY course_title
HAVING count(course_title)>=20
ORDER BY average ASC
LIMIT 15;







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
	teacher_name,
	round(avg(grade_point_dec), 2) AS average
FROM grades AS g
LEFT JOIN courses AS c USING(course_id, course_title, course_subject)
LEFT JOIN teachers USING(teacher_id)
WHERE 
	course_subject='English' 
	AND c.core_req=1
	AND course_title !='Adv Comm Skills'
GROUP BY teacher_name
ORDER BY average DESC;

-- English department average grade for non-honors/AP English classes by teacher

SELECT 
	teacher_name,
	round(avg(grade_point_dec), 2) AS average
FROM grades AS g
LEFT JOIN courses AS c USING(course_id, course_title, course_subject)
LEFT JOIN teachers USING(teacher_id)
WHERE 
	course_subject='English'
	AND c.core_req=1
	AND course_title !='Adv Comm Skills'
	AND c.weighted=0
GROUP BY teacher_name
ORDER BY average DESC;

-- English department average grade (no +/-; grades used for GPA) for non-honors/AP English classes by teacher
SELECT 
	teacher_name,
	round(avg(grade_point_used), 2) AS average
FROM grades AS g
LEFT JOIN courses AS c USING(course_id, course_title, course_subject)
LEFT JOIN teachers USING(teacher_id)
WHERE 
	course_subject='English'
	AND c.core_req=1
	AND course_title !='Adv Comm Skills'
	AND c.weighted=0
GROUP BY teacher_name
ORDER BY average DESC;

-- English department average grade for honors/AP classes by teacher
SELECT 
	teacher_name,
	round(avg(grade_point_dec), 2) AS average
FROM grades AS g
LEFT JOIN courses AS c USING(course_id, course_title, course_subject)
LEFT JOIN teachers USING(teacher_id)
WHERE 
	course_subject='English'
	AND c.weighted=1
GROUP BY teacher_name
ORDER BY average DESC;

-- English department average grade by course and teacher

SELECT 
	teacher_name,
	course_title,
	round(avg(grade_point_dec), 2) AS average
FROM grades AS g
LEFT JOIN courses AS c USING(course_id, course_title, course_subject)
LEFT JOIN teachers USING(teacher_id)
WHERE 
	course_subject='English'
	AND c.core_req=1
	AND course_title !='Adv Comm Skills'
GROUP BY course_title, teacher_name
ORDER BY average DESC;

-- English department average grade by course (including electives/ACS) and teacher

SELECT 
	teacher_name,
	course_title,
	round(avg(grade_point_dec), 2) AS average
FROM grades AS g
LEFT JOIN courses AS c USING(course_id, course_title, course_subject)
LEFT JOIN teachers USING(teacher_id)
WHERE 
	course_subject='English'
GROUP BY course_title, teacher_name
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
	  	s.gender_male,
	  	s.gender_female,
	  	s.gender_nonbinary,
	  	s.grade_level,
	  	
	  	-- Demographic fields; default to 0 for Boolean logic (if unlisted, not part of program)
	  	COALESCE(e.ell, 0) AS ell,
	    COALESCE(s504.sec_504, 0) AS sec_504,
	    COALESCE(sped.sped, 0) AS sped,
	    COALESCE(tag.tag, 0) AS tag,
	    COALESCE(tr.transfer, 0) AS transfer
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

-- Adding columns for percentages of absences, tardies, and credit completion; adding pass/fail and A-C/D-F

ALTER TABLE all_student_data
ADD COLUMN absence_perc DECIMAL(3,0) 
	GENERATED ALWAYS AS ((absences/20)*100) STORED,
ADD COLUMN tardy_perc DECIMAL (3,0)
	GENERATED ALWAYS AS ((tardies/20)*100) STORED,
ADD COLUMN ss_abs_perc DECIMAL(4,1)
	GENERATED ALWAYS AS ((ss_absences/18)*100) STORED,
ADD COLUMN credit_perc DECIMAL(4,1)
	GENERATED ALWAYS AS ((credits_completed/credits_attempted)*100) STORED,
ADD COLUMN pass_or_fail INTEGER 
	GENERATED ALWAYS AS 
	(CASE
		WHEN grade_point_used>=1 THEN 1
		ELSE 0
	END) STORED,
ADD COLUMN c_or_higher INTEGER 
	GENERATED ALWAYS AS 
	(CASE
		WHEN grade_point_used>=2 THEN 1
		ELSE 0
	END) STORED,
ADD COLUMN absence_rate VARCHAR(10) 
	GENERATED ALWAYS AS 
	(CASE
		WHEN absence_perc BETWEEN 0 AND 9.9 THEN 'low'
		WHEN absence_perc BETWEEN 10 AND 19.9 THEN 'medium'
		WHEN absence_perc BETWEEN 20 AND 39.9 THEN 'high'
		WHEN absence_perc >=40 THEN 'very high'
		ELSE 'error'
	END) STORED;


-- Avgerage grade/pass percent by absence percentage
SELECT 
	absence_perc,
	round(avg(grade_point_dec), 2) AS avg_grade,
	round(avg(pass_or_fail), 2) AS pass_perc,
	count(absence_perc) AS count
FROM all_student_data
GROUP BY absences
ORDER BY absences ASC;

-- Grades/pass percentage as grouped by absence rates
SELECT 
	absence_rate,
	round(avg(absence_perc), 2) AS avg_absence_perc,
	round(avg(grade_point_dec), 2) AS avg_grade,
	round(avg(pass_or_fail), 2) AS pass_perc,
	count(absence_rate) AS count
FROM all_student_data
GROUP BY absence_rate
ORDER BY avg_absence_perc ASC;


-- Grades/pass percentage as grouped by absence rates for core classes
SELECT 
	absence_rate,
	round(avg(absence_perc), 2) AS avg_absence_perc,
	round(avg(absences), 2) AS avg_absences,
	round(avg(grade_point_dec), 2) AS avg_grade,
	round(avg(pass_or_fail), 2) AS pass_perc,
FROM all_student_data AS a 
LEFT JOIN courses AS c USING(course_title)
WHERE core_req=1
GROUP BY absence_rate
ORDER BY avg_absence_perc ASC;



/*Findings
	- Attendance is the single largest factor in a students' grade, both individually and when controlling for other variables
	- While ELL students do have noticeably lower grades/pass rates than their non-ELL peers, the difference is not statistically significant (to a p>.01 level) when controlling for attendance and SPED status
	- There is no statistically significant different between transfer and non-transfer students

*/

-- Miscellaneous

-- Identifying students who aren't listed on the GPA table -- possible non-diploma seeking students?

SELECT 
	DISTINCT s.student_id,
	s.first_name,
	s.last_name,
	s.grade_level
FROM grades AS g
LEFT JOIN gpa USING(student_id)
LEFT JOIN students AS s USING(student_id)
WHERE gpa.student_id IS NULL;

-- Future ideas: count AP classes taken per student
