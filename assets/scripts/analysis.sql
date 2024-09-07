-- Create a JOIN table

SELECT *
FROM 
	work_db..Absenteeism_at_work aw
LEFT JOIN work_db..compensation c ON
	aw.ID = c.ID
LEFT JOIN work_db..Reasons r ON
	aw.Reason_for_absence = r.Number;


/* 
# DATA PREP AND VIEW CREATION STEPS 
1. Clean up the Data: remove irrelevant columns by only keeping the ones needed from the original tables.
2. Create categorical data from Body_mass_index and Seasons columns.
3. Create a view of the relevant columns and rows.
*/

CREATE VIEW view_work AS 
SELECT
	aw.ID,
	r.Reason,
	Month_of_absence, 
	Body_mass_index,
	Seasons,
	CASE
		WHEN Body_mass_index < 18.5 THEN 'Underweight'
		WHEN Body_mass_index BETWEEN 18.5 AND 24.9 THEN 'Healthy weight'
		WHEN Body_mass_index BETWEEN 25 AND 29.9 THEN 'Overweight'
		WHEN Body_mass_index >= 30 THEN 'Obese'
		ELSE 'Unknown'
	END AS BMI_Category,
	CASE
		WHEN Month_of_absence IN (12,1,2) THEN 'Winter'
		WHEN Month_of_absence IN (3,4,5) THEN 'Spring'
		WHEN Month_of_absence IN (6,7,8) THEN 'Summer'
		WHEN Month_of_absence IN (9,10,11) THEN 'Autumn'
		ELSE 'Unknown'
	END AS Season_Names,
	Service_time,
	Day_of_the_week,
	Transportation_expense,
	Education,
	Son,
	Social_drinker,
	Social_smoker,
	Pet,
	Disciplinary_failure,
	Age,
	Work_load_Average_day,
	Absenteeism_time_in_hours
FROM 
	work_db..Absenteeism_at_work aw
LEFT JOIN work_db..compensation c ON
	aw.ID = c.ID
LEFT JOIN work_db..Reasons r ON
	aw.Reason_for_absence = r.Number;



/* Eligible Employees for Health Bonus

NOTE: HR did not give criteria for what they consider as 'good health'
Direct health indicators include:
	- Body mass index (BMI): A common measure of weight in relation to height that is usually used as an indicator for general health.
	- Social smoker: Smoking is linked to various health issues.
	- Social drinker: Excessive alcohol consumption can impact health.

Indirect health indicators (lifestyle and behaviours) include:
	- Absenteeism time in hours: Lower absenteeism rates generally correlate with better health.
	- Reason for absence: Frequent absences due to illness might indicate poorer health.
*/

SELECT *
FROM
	work_db..view_work
WHERE
	Body_mass_index BETWEEN 18.5 AND 24.9
	AND Social_smoker = 0
	AND Social_drinker = 0
	AND Absenteeism_time_in_hours < (
		SELECT AVG(Absenteeism_time_in_hours)
		FROM work_db..view_work
	);


/* Annual Compensation Increase for Non-Smokers (Budget = $983,221)
1. Define any variables needed for calculations
2. Create a Common Table Expression (CTE) to calculate the number of non smokers
3. Create calculated columns
*/

DECLARE @insuranceBudget MONEY = 983221.0;	-- insurance budget allocated for all non-smokers
DECLARE @hoursPerYear INT = 2080;			-- 8 hours x 5 days x 52 weeks

WITH nonSmokers AS (
	SELECT 
		COUNT(*) AS non_smokers
	FROM
		work_db..view_work
	WHERE
		Social_smoker = 0
)

SELECT
	non_smokers,
	non_smokers * @hoursPerYear AS hours_by_non_smokers_per_year,
	@insuranceBudget / (non_smokers * @hoursPerYear) AS increment_per_hour,
	(@insuranceBudget / (non_smokers * @hoursPerYear)) * @hoursPerYear AS annual_compensation_increase
FROM
	nonSmokers;
