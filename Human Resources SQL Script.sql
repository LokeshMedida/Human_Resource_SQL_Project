SELECT * FROM human_resource.`hr`;

-- Data cleaning and preprocessing --

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR (20) NULL;

DESCRIBE hr;

SET sql_safe_updates = 0;


-- change the datatype and data format of birthdate column --
UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
    END;
    
ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

-- change the datatype and data format of termdate column --
UPDATE hr
SET termdate = DATE(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate !='';

UPDATE hr
SET termdate = NULL
WHERE termdate = '';

-- change the datatype and data format of hire_date column --
UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
    END;
    
ALTER TABLE hr
MODIFY COLUMN hire_date DATE;
    
-- create age column --
ALTER TABLE hr
ADD COLUMN age INT;

UPDATE hr
SET age = timestampdiff(YEAR,birthdate,curdate());

-- 1. what is the gender breakdown of employees in company --
SELECT * FROM hr;

SELECT gender, COUNT(*) AS gndr_count
FROM hr
GROUP BY gender;

-- 2. What is the race breakdown of employees in company --
SELECT race, COUNT(*) AS race_count
FROM hr
WHERE termdate IS NULL
GROUP BY race;

-- 3. what is the age distribution of employees in company --
SELECT
	CASE
		WHEN age>=18 and age <= 24 THEN '18-24'
        WHEN age>=25 and age <= 34 THEN '25-34'
        WHEN age>=35 and age <= 44 THEN '35-44'
        WHEN age>=45 and age <= 54 THEN '45-54'
        WHEN age>=55 and age <= 64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
    COUNT(*) as COUNT
    FROM hr
    WHERE termdate IS NULL
    GROUP BY age_group
    ORDER BY age_group;

-- 4. how many employees work at HQ and remote --
SELECT location, COUNT(*) AS count
FROM hr
GROUP BY location;

-- 5. what is the average lenght of employement who have been terminated --
SELECT ROUND(AVG(YEAR(termdate) - YEAR (hire_date)),0) AS lenght_of_emp
FROM hr
WHERE termdate IS NOT NULL AND termdate <= curdate();

-- 6. How does gender distribution vary across dept and job_title 
SELECT * FROM hr;

SELECT department, jobtitle, gender, COUNT(*) as count
FROM hr
WHERE termdate IS NOT NULL
GROUP BY department, jobtitle, gender
ORDER BY department, jobtitle, gender;

-- 7. what is the distribution of job_titles across the company --
SELECT jobtitle, COUNT(*) as count
FROM hr
WHERE termdate IS NULL
GROUP BY jobtitle;

-- 8. which dept has higher turnover / tremination rate --
SELECT * FROM hr;

SELECT department,
		COUNT(*) as total_count,
        COUNT(CASE
				WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1
                END) as terminated_count,
		ROUND((COUNT(CASE
					WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1
                    END)/COUNT(*))*100,2) as termination_rate
		FROM hr
        GROUP BY department 
        ORDER BY termination_rate DESC;

-- 9. what is the distribution of employees across lotation_state --
SELECT location_state, COUNT(*) as count
FROM hr
WHERE termdate IS NULL
GROUP BY location_state;

-- 10. How the company employee count change over time based on hire and termination date. --
SELECT * FROM hr;

SELECT YEAR,
		hires,
		terminations,
        hires-terminations AS net_change,
        round((terminations/hires)*100,2) AS change_percent
	FROM(
			SELECT YEAR(hire_date) as YEAR,
            COUNT(*) AS hires,
            SUM(CASE
					WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1
				END)AS terminations
			FROM hr
            GROUP BY YEAR(hire_date)) AS subquery
GROUP BY YEAR
ORDER BY YEAR; 

-- 11. what is the tenure distribution for each dept --
SELECT department, ROUND(AVG(datediff(termdate,hire_date)/365),1) AS avg_tenure
FROM hr
WHERE termdate IS NOT NULL AND termdate<= curdate()
GROUP BY department;
