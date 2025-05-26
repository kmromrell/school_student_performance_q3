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
