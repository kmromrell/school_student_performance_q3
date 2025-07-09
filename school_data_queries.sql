-- School Quarter 3 Analysis


-- Explore grades overall to create familiarity


-- Count of grades received (A=4, B=3, etc.)
SELECT
	grade_point_used,
	count(*) AS count,
	round(count(*)/(
		SELECT count(*)
		FROM grades AS g 
	)*100, 2) AS perc
FROM grades
GROUP BY 
	grade_point_used
ORDER BY grade_point_used DESC;

-- Count of grades received using +/- grades (e.g., B+ is 3.3, not 3)
SELECT
	grade_point_dec,
	count(*) AS count,
	round(count(*)/(
		SELECT count(*)
		FROM grades AS g 
	)*100, 2) AS perc
FROM grades
GROUP BY 
	grade_point_dec
ORDER BY grade_point_dec DESC;

-- Count of grades received (A=4, B=3, etc.) in core classes
SELECT
	grade_point_used AS grade_for_core,
	count(*) AS count,
	round(count(*)/(
		SELECT count(*)
		FROM grades AS g 
		JOIN courses AS c USING(course_id, course_subject, course_title)
		WHERE core_req=1
	)*100, 2) AS perc
FROM grades AS g 
JOIN courses AS c USING(course_id, course_subject, course_title)
WHERE core_req=1
GROUP BY 
	grade_point_used
ORDER BY grade_point_used DESC;

-- Count of grades received (A=4, B=3, etc.) in non-core classes
SELECT
	grade_point_used AS grade_non_core,
	count(*) AS count,
	round(count(*)/(
		-- Subquery to find percentage of students receiving that grade (only for core classes)
		SELECT count(*)
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

-- Average grade by course, identifying the 15 hardest courses (only including courses with at least 20 students) -- included in tables at end of report
SELECT 
	course_title,
 	COUNT(*) AS student_count,
	ROUND(AVG(absence_perc), 2) AS avg_absence,
	ROUND(AVG((ss_absences)*100/18), 2) AS avg_ss_abs,  
	ROUND(AVG(grade_point_dec), 2) AS avg_grade,
	ROUND(AVG(pass_or_fail), 2) AS pass_rate,
	ROUND(AVG(c_or_higher), 2) AS c_or_higher_rate
FROM all_student_data
GROUP BY course_title 
HAVING student_count>=20
ORDER BY avg_grade ASC
LIMIT 15;

-- Identifying students who aren't listed on the GPA table -- possible non-diploma seeking students?
SELECT 
	DISTINCT student_id,
	first_name,
	last_name,
	grade_level
FROM grades
LEFT JOIN gpa USING(student_id)
LEFT JOIN students USING(student_id)
WHERE gpa.student_id IS NULL;




-- Create table with all relevant information for R analysis

CREATE TABLE all_student_data AS ( 
	SELECT
		g.student_id,
		g.teacher_id,
		g.grade,
		g.grade_point_dec,
		g.grade_point_used,
		g.course_subject,
		g.course_title,
		g.period,
		
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

-- Creating table that includes data indicating core/non-core for R analysis
CREATE TABLE all_with_core AS (
	SELECT *
	FROM all_student_data
	LEFT JOIN courses USING(course_title, course_subject)
);




-- Using newly generated table for further exploration prior to R analysis

-- Average grade/pass percent by absence percentage
SELECT 
	absence_perc,
	round(avg(grade_point_dec), 2) AS avg_grade,
	round(avg(pass_or_fail), 2) AS pass_perc,
	count(*) AS count
FROM all_student_data
GROUP BY absence_perc
ORDER BY absence_perc ASC;

-- Grades/pass percentage as grouped by absence rates for all classes (with ROLLUP)
SELECT 
	absence_rate,
	round(avg(absences), 2) as avg_classes_missed,
	count(*) AS count,
	round(count(*)/(
		-- subquery to tally total number of rows to calculate percentage
		SELECT count(*) FROM all_student_data
	)*100, 1) AS perc_of_students,
	round(avg(absence_perc), 2) AS avg_absence_perc,
	round(avg(grade_point_dec), 2) AS avg_grade,
	round(avg(pass_or_fail)* 100, 1) AS pass_perc
FROM all_student_data
GROUP BY absence_rate WITH ROLLUP
ORDER BY perc_of_students DESC; 


-- Grades/pass percentage as grouped by absence rates for core classes (with ROLLUP)
SELECT 
	absence_rate,
	round(avg(absences), 2) as avg_classes_missed,
	count(*) AS count,
	round(count(*)/(
		-- subquery to tally total number of rows in core classes to calculate percentage
		SELECT count(*) 
		FROM all_student_data 
		LEFT JOIN courses USING(course_title) 
		WHERE core_req=1
	)*100, 1) AS perc_of_students,
	round(avg(absence_perc), 2) AS avg_absence_perc,
	round(avg(grade_point_dec), 2) AS avg_grade,
	round(avg(pass_or_fail)* 100, 1) AS pass_perc,
	round(avg(c_or_higher)* 100, 1) AS c_or_higher_perc
FROM all_student_data
LEFT JOIN courses USING(course_title)
WHERE core_req=1
GROUP BY absence_rate WITH ROLLUP
ORDER BY perc_of_students DESC; 


-- Grades/pass percentage as grouped by absence rates for non-core classes (with ROLLUP)
SELECT 
	absence_rate,
	round(avg(absences), 2) as avg_classes_missed,
	count(*) AS count,
	round(count(*)/(
		-- subquery to tally total number of rows in non-core classes to calculate percentage
		SELECT count(*) 
		FROM all_student_data 
		LEFT JOIN courses USING(course_title) 
		WHERE core_req=0
	)*100, 1) AS perc_of_students,
	round(avg(absence_perc), 2) AS avg_absence_perc,
	round(avg(grade_point_dec), 2) AS avg_grade,
	round(avg(pass_or_fail)* 100, 1) AS pass_perc,
	round(avg(c_or_higher)* 100, 1) AS c_or_higher_perc
FROM all_student_data
LEFT JOIN courses USING(course_title)
WHERE core_req=0
GROUP BY absence_rate WITH ROLLUP
ORDER BY perc_of_students DESC; 

-- GPA as correlated with support seminar absences
SELECT
	ss_abs_rate,
	count(*) AS count,
	round(avg(gpa), 2) AS avg_gpa
FROM (
	SELECT 
		gpa,
		student_id,
		CASE 
			WHEN support_seminar<=1 THEN 'low'
			WHEN support_seminar<=3 THEN 'middle'
			WHEN support_seminar<=7 THEN 'high'
			ELSE 'very high'
	END AS ss_abs_rate
	FROM gpa
	LEFT JOIN absences USING(student_id)
) AS ss_abs_cat
GROUP BY ss_abs_rate
ORDER BY count DESC;



-- Absences/grades as grouped by demographic factors (for table "Summary of Demographic Factors")

-- Utilizing stored procedure in order to reduce unnecessary repetition

DROP PROCEDURE IF EXISTS demographics;

DELIMITER $$

CREATE PROCEDURE demographics(IN demographic_column VARCHAR(20))
BEGIN 
	SET @demog_query = CONCAT(
		'SELECT ',
			demographic_column, ', ',
			'COUNT(*) AS count, ',
			'ROUND(COUNT(*) / 8350.0, 2) AS perc_of_students, ',
			'ROUND(AVG(absence_perc), 2) AS avg_absence, ',
			'ROUND(AVG((ss_absences)*100/18), 2) AS avg_ss_abs, ',  
			'ROUND(AVG(grade_point_dec), 2) AS avg_grade, ',
			'ROUND(AVG(pass_or_fail), 2) AS pass_rate, ',
			'ROUND(AVG(c_or_higher), 2) AS c_or_higher_rate ',
		'FROM all_student_data ',
		'GROUP BY ', demographic_column
);
	PREPARE demog_stmt FROM @demog_query;
	EXECUTE demog_stmt;
	DEALLOCATE PREPARE demog_stmt;
END $$

DELIMITER ;

CALL demographics('sped');
CALL demographics('sec_504');
CALL demographics('ell');
CALL demographics('tag');
CALL demographics('transfer');
CALL demographics('gender');



-- Absences/grades as grouped by school goupings (for tables at the end of the report)

-- Grade Level
CALL demographics('grade_level');

-- Department for all classes (with ROLLUP)
SELECT
	course_subject,
	COUNT(*) AS count,
	ROUND(COUNT(*) / 8350.0, 2) AS perc_of_students,
	ROUND(AVG(absence_perc), 2) AS avg_absence,
	ROUND(AVG(tardy_perc), 2) AS avg_tardies,
	ROUND(AVG((ss_absences)*100/18), 2) AS avg_ss_abs,  
	ROUND(AVG(grade_point_dec), 2) AS avg_grade,
	ROUND(AVG(pass_or_fail), 2) AS pass_rate,
	ROUND(AVG(c_or_higher), 2) AS c_or_higher_rate
FROM all_student_data 
GROUP BY course_subject WITH ROLLUP;

-- Department for core classes (with ROLLUP)
SELECT
	course_subject,
	COUNT(*) AS count,
	ROUND(COUNT(*)/(
		-- subquery to tally total number of rows in core classes to calculate percentage
		SELECT count(*) 
		FROM all_student_data 
		LEFT JOIN courses USING(course_title) 
		WHERE core_req=1
	), 2) AS perc_of_students,
	ROUND(AVG(absence_perc), 2) AS avg_absence,
	ROUND(AVG((ss_absences)*100/18), 2) AS avg_ss_abs,  
	ROUND(AVG(grade_point_dec), 2) AS avg_grade,
	ROUND(AVG(pass_or_fail), 2) AS pass_rate,
	ROUND(AVG(c_or_higher), 2) AS c_or_higher_rate
FROM all_student_data
LEFT JOIN courses USING(course_title, course_subject)
WHERE core_req=1
GROUP BY course_subject WITH ROLLUP
ORDER BY avg_grade;