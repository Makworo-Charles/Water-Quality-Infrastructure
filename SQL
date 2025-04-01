-- 1. Add Employees' Email Addresses (first_name.last_name@ndogowater.gov.

/*- select the employee_name column
- replace the space with a full-stop
- make it lowercase
- stitch it all together*/

-- a)Replace the space with a full stop

SELECT
REPLACE(employee_name, ' ','.') 
FROM
employee;

-- b)Make it all lowercase

SELECT
LOWER(REPLACE(employee_name, ' ','.'))
FROM
employee;

-- use CONCAT() to add the rest of the email address:(stitch it all together)

SELECT
	CONCAT(
		LOWER(REPLACE(employee_name, ' ','.')),'@ndogowater.gov') AS new_email
FROM
employee;

-- UPDATE the email column this time with the email addresses.

UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),
'@ndogowater.gov');

-- 2. TRIM space from phone number

SELECT
	TRIM(TRAILING ' ' FROM phone_number) AS Trim_phone_number
FROM employee;

 UPDATE employee
 SET phone_number= TRIM(TRAILING ' ' FROM phone_number);

-- 3. Use the employee table to count how many of our employees live in each town.

SELECT
	town_name,
    COUNT(town_name) AS num_employees
FROM employee
GROUP BY town_name;

-- 4. number of records each employee collected

/* -find the correct table, 
   -figure out what function to use and how to group, order
   -limit the results to only see the top 3 employee_ids with the highest number of locations visited.*/

SELECT
	assigned_employee_id,
	position
FROM md_water_services.employee
WHERE position='Field Surveyor';

SELECT 
    e.assigned_employee_id AS employee_id,
    COUNT(v.location_id) AS visit_count
FROM 
    visits v
JOIN 
    employee e
ON 
    v.assigned_employee_id = e.assigned_employee_id
WHERE 
    e.position = 'Field Surveyor'
GROUP BY 
    e.assigned_employee_id
ORDER BY 
    visit_count DESC
LIMIT 3;


-- create a query that looks up the employee's info.
-- You should have a column of names, email addresses and phone numbers for our top dogs

SELECT 
    e.assigned_employee_id AS employee_id,
    e.employee_name AS name,
    e.email,
    e.phone_number AS phone,
    COUNT(v.location_id) AS visit_count
FROM 
    visits v
JOIN 
    employee e
ON 
    v.assigned_employee_id = e.assigned_employee_id
WHERE 
    e.position = 'Field Surveyor'
GROUP BY 
    e.assigned_employee_id
ORDER BY 
    visit_count ASC
LIMIT 3;

-- Create a query that counts the number of records per town

SELECT
	town_name,
    COUNT(town_name) AS Records_per_town
FROM location
GROUP BY town_name;

-- Now count the records per province

SELECT
	province_name,
    COUNT(province_name) AS Records_per_province
FROM location
GROUP BY province_name;

/*1. Create a result set showing:
• province_name
• town_name
• An aggregated count of records for each town (consider naming this records_per_town).
• Ensure your data is grouped by both province_name and town_name.
2. Order your results primarily by province_name. Within each province, further sort the towns by their record counts in descending order.*/

SELECT
	province_name,
    town_name,
    COUNT(town_name) AS records_per_town
FROM
	location
GROUP BY 
	province_name,
    town_name
ORDER BY province_name DESC;

-- number of records for each location type

SELECT
	location_type,
    COUNT(location_type) AS num_of_records
FROM
	location
GROUP BY location_type;

-- From the water_source Table:
/*
1. How many people did we survey in total?
2. How many wells, taps and rivers are there?
3. How many people share particular types of water sources on average?
4. How many people are getting water from each type of source?
*/

-- 1. How many people did we survey in total?

SELECT
	SUM(number_of_people_served) AS No_of_ppl_surveyed
FROM
water_source;
	
-- 2. How many wells, taps and rivers are there?

SELECT
	type_of_water_source,
    COUNT(type_of_water_source) AS Num_of_sources
FROM
	water_source
GROUP BY type_of_water_source;

-- 3. How many people share particular types of water sources on average?

SELECT
	type_of_water_source,
    ROUND(AVG(number_of_people_served)) AS Avg_people_source
FROM
	water_source
GROUP BY type_of_water_source;

-- How many people are getting water from each type of source

SELECT
	type_of_water_source,
    SUM(number_of_people_served) AS No_people_served,
    (SUM(number_of_people_served) / 27628140) * 100 AS Pct_number_of_people_served
FROM
	water_source
GROUP BY type_of_water_source;

-- Let's round that off to 0 decimals, and order the results.

SELECT
	type_of_water_source,
    SUM(number_of_people_served) AS No_people_served,
    ROUND((SUM(number_of_people_served) / 27628140) * 100) AS Pct_number_of_people_served
FROM
	water_source
GROUP BY type_of_water_source;

-- Ranks of each type of source based on how many people in total use it.

/*
We will need the following columns:
- Type of sources -- Easy
- Total people served grouped by the types -- We did that earlier, so that's easy too.
- A rank based on the total people served, grouped by the types -- A little harder
*/

SELECT
	type_of_water_source,
    SUM(number_of_people_served) AS No_people_served,
    RANK () OVER (ORDER BY SUM(number_of_people_served) DESC) AS Rank_by_population
FROM water_source
WHERE
   type_of_water_source != 'tap_in_home'
GROUP BY
   type_of_water_source
ORDER BY Rank_by_population;

/*
1. How long did the survey take?
2. What is the average total queue time for water?
3. What is the average queue time on different days?
4. How can we communicate this information efficiently?
*/

-- 1. How long did the survey take?
-- To calculate how long the survey took, we need to get the first and last dates (which functions can find the largest/smallest value), and subtract them.

SELECT
	time_in_queue,
	(NULLIF(time_in_queue,0)) AS new_time_in_queue,
    AVG(time_in_queue) AS Avg_time_in_queue
from visits;
	
    
SELECT
  TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
  DAYNAME(time_of_record),
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END AS Sunday
FROM
  visits
WHERE
  time_in_queue != 0;


SELECT
  TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
  ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END
  ),0) AS Sunday,
-- Monday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
ELSE NULL
END
  ),0) AS Monday,
-- Tuesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
ELSE NULL
END
  ),0) AS Tuesday,
-- Wednesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
ELSE NULL
END
),0) AS Wednesday,
-- Saturday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
ELSE NULL
END
),0) AS Saturday
FROM
visits
WHERE
time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
hour_of_day
ORDER BY
hour_of_day;
