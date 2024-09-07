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
