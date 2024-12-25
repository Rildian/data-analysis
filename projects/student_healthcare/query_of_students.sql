#1 
-- IS THERE ANY RELATION BETWEEN STRESS AND ATTENDANCE STATUS?
SELECT
	Attendance_Status,
	ROUND(AVG(Stress), 2) as avg_stress
FROM 
	students
GROUP BY 
	Attendance_Status
ORDER BY
	AVG_STRESS DESC;

#2
SELECT 
	Attendance_Status,
    ROUND(AVG(Anxiety_Level), 2) AS avg_anxiety,
    ROUND(AVG(Sleep_Hours), 2) AS avg_sleep
FROM 
	students
GROUP BY 
	Attendance_Status
ORDER BY 
	avg_sleep;

#3
-- DOES MOOD AFFECT THE ATTENDANCE?  
SELECT
	Attendance_Status,
    AVG(Mood_Score)  AS avg_mood
FROM 
	students
GROUP BY	
	Attendance_Status
ORDER BY avg_mood DESC;

#6
-- DOES THE ANXIETY AFFECT THE PROBABILITY OF DROP?
SELECT
	Risk_Level,
	REPLACE(ROUND(AVG(Anxiety_Level), 2), '.', ',') AS avg_anxiety
FROM 
	students
GROUP BY
	Risk_Level
ORDER BY
	avg_anxiety;

#7
-- THE STUDENTS WITH HIGH RISK HAVE MORE PROBABILITY TO BE LATE THAN THE LOW RISK?
SELECT
	Risk_Level,
    SUM(
		CASE WHEN Attendance_Status = 'Late'  THEN 1
        ELSE 0 END) AS risk_count
FROM
	students
GROUP BY 
	Risk_Level
ORDER BY
	Risk_Level;

-- stress_class_time
SELECT
	REPLACE(ROUND(AVG(Stress), 2), '.', ',') as avg_stress,
    Date_Students, Class_Time
FROM
	students
GROUP BY
	Date_Students, Class_Time
HAVING 
	Date_Students BETWEEN '2024-12-02' AND '2024-12-06'
ORDER BY
	avg_stress DESC;

#9
-- CREATE VIEW Distribution_Per_Time_Classes AS
-- DIFFERENT SCHEDULES
SELECT
	Class_Time,
    (SUM(CASE WHEN Attendance_Status = 'Late' THEN 1 ELSE 0 END)) AS qnt_late,
    (SUM(CASE WHEN Attendance_Status = 'Absent' THEN 1 ELSE 0 END)) AS qnt_Absent,
    (SUM(CASE WHEN Attendance_Status = 'Present' THEN 1 ELSE 0 END)) AS qnt_present,
    ROUND(AVG(Sleep_Hours), 2) AS Avg_Sleep
FROM 
	students
GROUP BY 
	Class_Time
ORDER BY Class_Time DESC;

#10
-- DOES THE QUANTITY OF SLEEP IMPACT THE PROBABILITY OF DROP?
SELECT
	Risk_Level,
	SUM(
		CASE WHEN Sleep_Hours >= 7.0 THEN 1 ELSE 0 END) AS sono_bom,
	SUM(
		CASE WHEN Sleep_Hours <= 6.0 THEN 1 ELSE 0 END) AS sono_ruim
FROM 
	students
GROUP BY
	Risk_Level
ORDER BY
	Risk_Level;

#12
-- LOOKING FOR PATTERNS OF SCHEDULE, SLEEPING HOURS AND ATTENDANCE
SELECT
	Date_Students,
    ROUND(AVG(Sleep_Hours), 2) AS avg_sleep
FROM
	students
GROUP BY
	Date_Students
HAVING 
	Date_Students BETWEEN '2024-12-02' AND '2024-12-06'
ORDER BY
	Date_Students;

-- distribution_of_risk
SELECT
    (SUM(CASE WHEN Risk_Level = 'High' THEN 1 ELSE 0 END)) AS qnt_high,
    (SUM(CASE WHEN Risk_Level = 'Medium' THEN 1 ELSE 0 END)) AS qnt_medium,
    (SUM(CASE WHEN Risk_Level = 'Low' THEN 1 ELSE 0 END)) AS qnt_low
FROM 
	students;
-- stress_and_risk_level
SELECT
	REPLACE(ROUND(AVG(Stress), 2), '.', ',') AS avg_stress,
	Risk_Level
FROM 
	students
GROUP BY
	Risk_Level
ORDER BY
	Risk_Level;
    
-- stress and days
SELECT
	ROUND(AVG(Stress), 2) as avg_stress,
    Date_Students
FROM
	students
GROUP BY
	Date_Students
HAVING 
	Date_Students BETWEEN '2024-12-02' AND '2024-12-06'
ORDER BY
	avg_stress DESC;

SELECT
	Attendance_Status,
    ROUND(AVG(Mood_Score), 2) AS avg_mood,
    ROUND(AVG(Stress), 2) AS avg_stress
FROM
	students
GROUP BY
	Attendance_Status
ORDER BY
	Attendance_Status;

-- mood_and_risk_level
SELECT
	Risk_Level,
    REPLACE(ROUND(AVG(Mood_Score), 2), '.', ',') as avg_mood
FROM
	students
GROUP BY 
	Risk_Level
ORDER BY 
	avg_mood;

-- MOOD SCORE AND SCHEDUELE
-- HOW DOES MOOD VARY BASED ON ATTENDANCE AND DATE?
SELECT
    Date_Students,
    Attendance_Status,
    ROUND(AVG(Mood_Score), 2) AS avg_mood
FROM 
    students
GROUP BY
    Date_Students, Attendance_Status
ORDER BY
    avg_mood asc;

-- COMBINING MOOD, ANXIETY, AND STRESS WITH ATTENDANCE
SELECT
    Attendance_Status,
    ROUND(AVG(Mood_Score), 2) AS avg_mood,
    ROUND(AVG(Anxiety_Level), 2) AS avg_anxiety,
    ROUND(AVG(Stress), 2) AS avg_stress
FROM 
    students
GROUP BY
    Attendance_Status
ORDER BY
    avg_mood DESC;

-- anxiety_class_time
SELECT
    REPLACE(ROUND(AVG(Anxiety_Level), 2), '.', ',') as avg_anxiety,
    Date_Students, Class_Time
FROM
	students
GROUP BY
	Date_Students, Class_Time
HAVING 
	Date_Students BETWEEN '2024-12-02' AND '2024-12-06'
ORDER BY
	avg_anxiety DESC;

-- classes_high_anxiety_quantity
SELECT
    Class_Time,
	(SUM(CASE WHEN Anxiety_Level >= 7 THEN 1 ELSE 0 END)) AS high_anxiety
FROM 
	students
GROUP BY
	Class_Time
ORDER BY 
	high_anxiety DESC;
 
 -- high_stress_quantity_time_class
SELECT
	Class_Time,
    (SUM(CASE WHEN Stress >= 3.5 THEN 1 ELSE 0 END)) AS high_stress
FROM
	students
GROUP BY
	Class_Time
ORDER BY
	high_stress DESC;

SELECT
	MIN(Anxiety_Level)
FROM
	students;
    

SELECT
    Date_Students,
    Attendance_Status,
    ROUND(AVG(Anxiety_Level), 2) AS avg_anxiety
FROM 
    students
GROUP BY
    Date_Students, Attendance_Status
ORDER BY
    avg_anxiety desc;
    
-- distribution_of_attendance_per_class_time
SELECT
	Class_Time,
    (SUM(CASE WHEN Attendance_Status = 'Late' THEN 1 ELSE 0 END)) AS qnt_late,
    (SUM(CASE WHEN Attendance_Status = 'Absent' THEN 1 ELSE 0 END)) AS qnt_Absent,
    (SUM(CASE WHEN Attendance_Status = 'Present' THEN 1 ELSE 0 END)) AS qnt_present
FROM 
	students
GROUP BY 
	Class_Time
ORDER BY Class_Time DESC;