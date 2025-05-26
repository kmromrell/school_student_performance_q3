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






-- Create table with all relevant information for R analysis

CREATE TABLE all_data AS ( 
	SELECT
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

ALTER TABLE all_data
ADD COLUMN absence_perc DECIMAL(3,2) 
	GENERATED ALWAYS AS (absences/20) STORED,
ADD COLUMN tardy_perc DECIMAL (3,2)
	GENERATED ALWAYS AS (tardies/20) STORED,
ADD COLUMN credit_perc DECIMAL(3,2)
	GENERATED ALWAYS AS (credits_completed/credits_attempted);
