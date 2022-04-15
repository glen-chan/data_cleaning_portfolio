/*
THIS IS THE PORTION OF QUERY THAT YOU SHOULD RUN TO GENERATE THE CLEANED TABLE DATA.
If you want to see the process step by step see file: Cleaning data glassdoor jobs step by step.sql
*/

/*
Creating a temporary table with the combined data
*/

SELECT
	[Index], 
	CASE WHEN Rating <0 THEN Company_Name
	ELSE LEFT(Company_Name,LEN(Company_name)-4) END AS 'Company_text',
	Job_Title,
	LEFT(REPLACE(REPLACE(REPLACE(REPLACE(Salary_Estimate,'(Glassdoor est.)',''),'(Employer est.)',''),'$',''),'K',''), 
	CHARINDEX('-',REPLACE(REPLACE(REPLACE(REPLACE(Salary_Estimate,'(Glassdoor est.)',''),'(Employer est.)',''),'$',''),'K',''))-1) Min_Salary,
	SUBSTRING(REPLACE(REPLACE(REPLACE(REPLACE(Salary_Estimate,'(Glassdoor est.)',''),'(Employer est.)',''),'$',''),'K',''), 
	CHARINDEX('-',REPLACE(REPLACE(REPLACE(REPLACE(Salary_Estimate,'(Glassdoor est.)',''),'(Employer est.)',''),'$',''),'K',''))+1,
	LEN(REPLACE(REPLACE(REPLACE(REPLACE(Salary_Estimate,'(Glassdoor est.)',''),'(Employer est.)',''),'$',''),'K',''))) Max_Salary,
	(CAST(LEFT(REPLACE(REPLACE(REPLACE(REPLACE(Salary_Estimate,'(Glassdoor est.)',''),'(Employer est.)',''),'$',''),'K',''), 
	CHARINDEX('-',REPLACE(REPLACE(REPLACE(REPLACE(Salary_Estimate,'(Glassdoor est.)',''),'(Employer est.)',''),'$',''),'K',''))-1) AS int) +
	(CAST (SUBSTRING(REPLACE(REPLACE(REPLACE(REPLACE(Salary_Estimate,'(Glassdoor est.)',''),'(Employer est.)',''),'$',''),'K',''), 
	CHARINDEX('-',REPLACE(REPLACE(REPLACE(REPLACE(Salary_Estimate,'(Glassdoor est.)',''),'(Employer est.)',''),'$',''),'K',''))+1,
	LEN(REPLACE(REPLACE(REPLACE(REPLACE(Salary_Estimate,'(Glassdoor est.)',''),'(Employer est.)',''),'$',''),'K','')))AS int))) / 2 AS Avg_Salary,
	Job_Description,
	RIGHT(Location,3) as Job_State,
	CASE WHEN Headquarters= '-1' THEN RIGHT(Location,3) 
		WHEN LEN(SUBSTRING(Headquarters,CHARINDEX(',',Headquarters)+2, LEN(Headquarters) - CHARINDEX(',',Headquarters)+1)) > 2 THEN ''
		ELSE RIGHT(Headquarters,3)
		END as Hq_Usa_State,
	CASE WHEN Headquarters= '-1'  OR 
		LEN(SUBSTRING(Headquarters,CHARINDEX(',',Headquarters)+2, LEN(Headquarters) - CHARINDEX(',',Headquarters)+1)) = 2 
		THEN 'United States' 
		ELSE SUBSTRING(Headquarters,CHARINDEX(',',Headquarters)+2, LEN(Headquarters) - CHARINDEX(',',Headquarters)+1)
		END as Hq_Country,
	Rating,
	CASE WHEN SIZE = 'Unknown' THEN SIZE
		ELSE REPLACE(SIZE,' employees','')
		END AS Num_Employees,
	CASE WHEN Founded <0 THEN Founded
		ELSE YEAR(GETDATE()) - Founded
		END AS Company_Age,
	CASE WHEN CHARINDEX('-',Type_of_ownership) != 0 THEN LEFT(Type_of_ownership, CHARINDEX('-',Type_of_ownership)-1)
		ELSE Type_of_ownership
		END AS Organization_Type,
	CASE WHEN CHARINDEX('-',Type_of_ownership) != 0 THEN RIGHT(Type_of_ownership, LEN(Type_of_ownership) - CHARINDEX('-',Type_of_ownership))
		ELSE 'Unknown'
		END AS Ownership_Type,
	Industry,
	Sector,
	REPLACE(REPLACE(Revenue,' (USD)',''),'$','') AS Usd_Revenue,
	REPLACE(Competitors, '-1','Unknown') as Competitors
INTO ##temp_glassdoor_jobs
FROM data_cleaning..glassdoor_jobs
WHERE Salary_Estimate != '-1'
AND CHARINDEX('per hour',LOWER(Salary_Estimate)) = 0
AND LEFT(LOWER(Salary_Estimate), 25) != 'employer provided salary:';


/*Create a new table with transformed data and without duplicates */

WITH Max_Duplicates AS(
	SELECT *,
	COUNT([Index]) OVER(
	PARTITION BY
		Company_text,
		Job_Title,
		Min_Salary,
		Max_Salary,
		Job_State	
	) Times_Posted,
	ROW_NUMBER() OVER(
	PARTITION BY
		Company_text,
		Job_Title,
		Min_Salary,
		Max_Salary,
		Job_State
	ORDER BY [Index]
	) row_num
FROM ##temp_glassdoor_jobs
)
SELECT Company_text as Company_Name, Job_Title, Min_Salary as Min_Salary, Max_Salary as Max_Salary, Avg_Salary as Avg_Salary,
		Job_Description, Job_State, Hq_Usa_State, Hq_Country, Rating, Num_Employees as Number_Of_Employees, 
		Company_Age as Company_Age, Organization_Type as Organization_Type,Ownership_Type as Ownership_Type, 
		Industry,Sector,Usd_Revenue as Usd_Revenue,Competitors, Times_Posted as Times_Posted
INTO cleaned_glassdoor_jobs
FROM Max_Duplicates
WHERE row_num = 1
ORDER BY Company_text,
		Job_Title,
		Min_Salary,
		Max_Salary,
		Job_State;


/* Now we just need to delete the temporary table that we created before.  */
DROP TABLE ##temp_glassdoor_jobs;