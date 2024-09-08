# Optimising Employee Wellness with Data


![project-flow-design](assets/images/absenteeism.png)


## Table of Contents
- [Objective](#objective)
- [User Story](#user-story)
- [Data Source](#data-source)
- [Stages](#stages)
- [Design](#design)
  - [Dashboard Mockup](#dashboard-mockup)
  - [Tools](#tools)
- [Development](#development)
  - [Data Analysis Pipeline](#data-analysis-pipeline)
  - [Initial Data Observations](#initial-data-observations)
  - [SQL View Creation](#sql-view-creation)
- [Testing](#testing)
  - [Data Quality Checks](#data-quality-checks)
- [Visualisation](#visualisation)
  - [Dashboard](#dashboard)
  - [DAX Measures](#dax-measures)


## Objective
Enhance employee wellness and reduce absenteeism through data-driven incentive programs and cost-effective insurance strategies.

### Challenge
HR lacks a quantitative approach to identifying healthy employees and those with low absence for reward programs. Furthermore, there is no systematic way to optimising insurance costs based on employee health considerations.

### Solution
Develop a data analysis framework to:
- Provide a list of employees who meet the criteria for good health and low absenteeism for a health bonus program, with a total budget of $1,000 USD.
- Determine the wage increase or annual compensation for non-smokers using an insurance budget of $983,221 allocated for all non-smoking employees.
- Create a Dashboard for HR to understand absenteeism at work based on approved wireframe.

### Benefits
Improved employee health and morale through targeted incentives, reduced absenteeism rates, reduced healthcare costs through optimised insurance premiums, and data-driven insights to inform future wellness strategies.


## User Story
As an HR manager, I want to identify and reward healthy employees with low absenteeism to improve overall workforce well-being and reduce costs associated with absenteeism. I also want to understand the cost implications of offering wage increases to non-smokers so that I can optimise our insurance budget. To achieve this, I require a visual representation of absenteeism trends to evaluate the effectiveness of our wellness initiatives.


## Data Source
To achieve our objective, we need HR data on employees that include:
- Employee records
- Tracked absences
- Compensation
The data is sourced from [Absent Data](https://absentdata.com/data-analysis/where-to-find-data/) (csv extract).

### Data Elements
The data needed to achieve the objective includes:
- Employee ID
- Social drinker
- Social smoker
- Body mass index
- Reason for absence
- Absenteeism time in hours
- Number of children
- Education
- Number of pet 


## Stages
1. Design
2. Development & Implementation
3. Testing


## Design
Required Dashboard Components

To determine the necessary components for the dashboard, we must identify the questions it will need to answer. 

**Overall Absenteeism Trends:**
- What is the overall absenteeism rate over time?
- Are there seasonal trends or patterns in absenteeism?

**Reasons for Absenteeism:**
- What are the most common reasons for absenteeism?
- Are there any emerging trends in the reasons for absence?

**Employee Absenteeism:**
- Which employees have the highest absenteeism rates?
- Are there any factors (e.g. age, workload, number of children) correlated with employee absenteeism?

### Dashboard Mockup
The dashboard will consist of several visual elements to answer the questions listed above:
1.	Pie chart
2.	Line chart
3.	Bar chart
4.	Scorecards
5.	Table 

![Dashboard-Mockup](assets/images/dashboard_mockup.png)


### Tools
The project utilises a combination of the following tools:
- **Excel**: Initial data exploration.
- **SQL Server**: For data cleaning, data quality tests, and analysis.
- **Power BI**: Primary tool for creating interactive visualisations and the final dashboard.
- **GitHub**: Hosting project documentation, code, and version control.
- **Mokkup AI**: Designing a wireframe/mockup for the dashboard layout.


## Development
### Data Analysis Pipeline

1.	Get the data
2.	Import data into SQL Server.
3.	Explore the data.
4.	Test the data to ensure accuracy and completeness.
5.	Calculate the eligible employees for health bonus and annual compensation increase for non-smokers.
6.	Connect Power BI to database for visualisation
7.	Create DAX measures to calculate additional metrics relevant for analysis.
8.	Build interactive data visualisations.


### Initial Data Observations

The initial exploration reveals several key observations:
- The data comes with 3 tables needed for analysis.
- The data has no null or missing values.
- The HR department may be helpful in providing relevant data that can be useful for analysis like dates, gender.

### SQL View Creation

```sql
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
```


## Testing
### Data Quality Checks
Here are some of the key checks performed:

1. Row count validation
2. Column count validation
3. Data type validation 
4. Uniqueness validation



**SQL Query**
```sql
/*
# DATA QUALITY CHECKS
	1. Row Count Validation: the total number of records in the dataset must be 740.
	2. Column Count Validation: the number of columns in the dataset must be 18 fields.
	3. Data Type Validation: the columns must have appropriate fields.
	4. Uniqueness Validation: each record must be unique in the dataset.
*/

-- 1. Row Count Validation
SELECT
	COUNT(*) AS row_count
FROM
	work_db..view_work;


-- 2. Column Count Validation
SELECT
	COUNT(*) AS column_count
FROM
	INFORMATION_SCHEMA.COLUMNS
WHERE
	TABLE_NAME = 'view_work';


-- 3. Data Type Validation
SELECT
	COLUMN_NAME,
	DATA_TYPE
FROM
	INFORMATION_SCHEMA.COLUMNS
WHERE
	TABLE_NAME = 'view_work';


-- 4. Uniqueness Validation
SELECT *
FROM (
    SELECT
        ID,
        ROW_NUMBER() OVER (PARTITION BY ID ORDER BY ID) AS row_num
    FROM
        work_db..view_work
) AS Duplicates
WHERE row_num > 1;

```


**Results**

![Row count validation](assets/images/1_row_count_validation.png)
![Count count validation](assets/images/2_column_count_validation.png)
![Data type validation](assets/images/3_data_type_validation.png)
![Uniqueness validation](assets/images/4_uniqueness_validation.png)


## Visualisation
### Dashboard

![Power BI Dashboard GIF](assets/images/powerbi_dashhboard.gif)
