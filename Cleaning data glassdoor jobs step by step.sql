/*
This is an example of how to clean data in SQL.

The data set is on a csv file that I have previously uploaded and inserted into my scheme data_cleaning 
and into my table dbo.glassdoor_jobs


There are many ways of doing the cleaning. This is an example of how to do it using only select sentences
to build the last cleaned table. 

*/

/* Making sure I'm using the correct database.
Im working on database called data_cleaning 
and a table called glassdoor_jobs, 
where I imported the file glasdoor_jobs.csv
*/
USE data_cleaning;


/*
Examining the data, you can notice that in several columns there's the value -1. 
This means that the actual information is not available. 
We have to decide what to do with those values. -1 will probably represent nothing for the users,
so we should either exclude it or change it to a more significant value. 


Regarding Column Salary Estimate, let's say that we still want to analyse the job posting 
even if it doesn' have a salary value

First
Excluding (Glassdoor est.) and (Employer est.) from Salary_Estimate
*/

SELECT REPLACE(REPLACE(Salary_Estimate,'(Glassdoor est.)',''),'(Employer est.)','') salary
FROM data_cleaning..glassdoor_jobs


/*
Second: 
Removing $ and K from Salary Estimate
*/
SELECT REPLACE(REPLACE(REPLACE(REPLACE(Salary_Estimate,'(Glassdoor est.)',''),'(Employer est.)',''),'$',''),'K','') salary
FROM data_cleaning..glassdoor_jobs

/*
Third:
Create a new column for the rows that have 'per hour' in Salary Estimate column.
For the moment we will just create the select sentence that we will use later for our new table
*/
SELECT CASE WHEN CHARINDEX('per hour',LOWER(Salary_Estimate)) = 0 THEN 0
		ELSE 1 END AS salary_per_hour
FROM data_cleaning..glassdoor_jobs


/*Fourth:
And then delete 'per hour' from Salary_Estimate*/
SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Salary_Estimate,'(Glassdoor est.)',''),'(Employer est.)',''),'$',''),'K',''),'Per Hour','') salary
FROM data_cleaning..glassdoor_jobs

/*
Fifth:
Create a new column for the rows that have 'Employer Provided Salary' in Salary Estimate column.
For the moment we will just create the select sentence that we will use later for our new table
*/
SELECT CASE WHEN LEFT(LOWER(Salary_Estimate), 25) = 'employer provided salary:' THEN 1
		ELSE 0 END AS Employer_provided_salary
FROM data_cleaning..glassdoor_jobs


/*
Sixt:
And then delete 'Employer Provided Salary:' from Salary_Estimate*/
SELECT REPLACE(
			REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(Salary_Estimate,'(Glassdoor est.)',''),
						'(Employer est.)',''),
					'$',''),
				'K',''),
			'Per Hour',''),
		'Employer Provided Salary:', '') salary
FROM data_cleaning..glassdoor_jobs


/*
## Seventh:
Because Salary Estimate is a range, we will divide the column into min salary 
and max salary columns. Keep into consideration that we still have the rows 
with value -1. Let's substitute this value for 0
*/
SELECT CASE WHEN CHARINDEX('-', Salary_Estimate) = 0 THEN 0
	WHEN Salary_Estimate = '-1' THEN 0
	ELSE PARSENAME(
			REPLACE(REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(Salary_Estimate,'(Glassdoor est.)',''),
								'(Employer est.)',''),
							'$',''),
						'K',''),
					'Per Hour',''),
				'Employer Provided Salary:', ''),
		'-','.'),2)
	END AS Min_Salary,
	CASE WHEN CHARINDEX('-', Salary_Estimate) = 0 THEN 0
	WHEN Salary_Estimate = '-1' THEN 0
	ELSE PARSENAME(
			REPLACE(REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(Salary_Estimate,'(Glassdoor est.)',''),
								'(Employer est.)',''),
							'$',''),
						'K',''),
					'Per Hour',''),
				'Employer Provided Salary:', ''),
		'-','.'),1)
	END AS Max_Salary
FROM data_cleaning..glassdoor_jobs
 

/*
and we will add a column Avg_Salary
*/
SELECT CASE WHEN CHARINDEX('-', Salary_Estimate) = 0 THEN 0
	WHEN Salary_Estimate = '-1' THEN 0
	ELSE PARSENAME(
			REPLACE(REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(Salary_Estimate,'(Glassdoor est.)',''),
								'(Employer est.)',''),
							'$',''),
						'K',''),
					'Per Hour',''),
				'Employer Provided Salary:', ''),
		'-','.'),2)
	END AS Min_Salary,
	CASE WHEN CHARINDEX('-', Salary_Estimate) = 0 THEN 0
	WHEN Salary_Estimate = '-1' THEN 0
	ELSE PARSENAME(
			REPLACE(REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(Salary_Estimate,'(Glassdoor est.)',''),
								'(Employer est.)',''),
							'$',''),
						'K',''),
					'Per Hour',''),
				'Employer Provided Salary:', ''),
		'-','.'),1)
	END AS Max_Salary,
	((CASE WHEN CHARINDEX('-', Salary_Estimate) = 0 THEN 0
	WHEN Salary_Estimate = '-1' THEN 0
	ELSE PARSENAME(
			REPLACE(REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(Salary_Estimate,'(Glassdoor est.)',''),
								'(Employer est.)',''),
							'$',''),
						'K',''),
					'Per Hour',''),
				'Employer Provided Salary:', ''),
		'-','.'),2)
	END ) + 
	(CASE WHEN CHARINDEX('-', Salary_Estimate) = 0 THEN 0
	WHEN Salary_Estimate = '-1' THEN 0
	ELSE PARSENAME(
			REPLACE(REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(Salary_Estimate,'(Glassdoor est.)',''),
								'(Employer est.)',''),
							'$',''),
						'K',''),
					'Per Hour',''),
				'Employer Provided Salary:', ''),
		'-','.'),1)
	END)
	) / 2 AS Avg_Salary
FROM data_cleaning..glassdoor_jobs




/*
## Eight:
Create a new column for the company name where the last four characters are excluded 
(three for the rating + one for the new line character).
Examinig the data you can notice that the column Company Name includes some numbers at the end.
This seems to correspond to the rating. However, we don't need that information in the name.

For the moment we will just create the select sentence that we will use later for our new table
*/
SELECT 
	CASE WHEN Rating <0 THEN Company_Name
	ELSE LEFT(Company_Name,LEN(Company_name)-4) END AS 'Company_text'
FROM data_cleaning..glassdoor_jobs


/*
Take out the state from the Location column.
*/

SELECT RIGHT(Location,3) as Job_State
FROM data_cleaning..glassdoor_jobs


/*
Tenth:

Take out the state from the Headquarters column. 
When Headquarters = -1 consider the Location as the Headquarters.
When there's no state but a country, leave it Blank
*/
SELECT CASE WHEN Headquarters= '-1' THEN RIGHT(Location,2) 
		WHEN LEN(TRIM(PARSENAME(REPLACE(Headquarters,',','.'),1))) > 2 THEN ''
		ELSE RIGHT(Headquarters,2)
		END as Hq_Usa_State		
FROM data_cleaning..glassdoor_jobs




/*
Eleventh:
Take the country from the Headquarters.
*/

SELECT CASE WHEN Headquarters= '-1'  OR 
		LEN(TRIM(PARSENAME(REPLACE(Headquarters,',','.'),1))) = 2 
		THEN 'United States' 
		ELSE TRIM(PARSENAME(REPLACE(Headquarters,',','.'),1))
		END as Hq_Country		
FROM data_cleaning..glassdoor_jobs



/*
Calculate how old is the company, based on the Foundation year.
Since we know company age in reality cannot be <0,
we could define that in case we don't have this data Company_Age would be 0. 
However, since we are counting years, we could as well get 0 if the company
was founded this same year. To avoid confusing those scenarios, 
we will just leave it like that.
*/
SELECT CASE WHEN Founded <0 THEN Founded
		ELSE YEAR(GETDATE()) - Founded
		END AS Company_Age
FROM data_cleaning..glassdoor_jobs


/*
Twelve:
Remove 'employees' from the size and replace size = -1 and size = 'Unknown' with 0 
*/
SELECT REPLACE(REPLACE(REPLACE(SIZE,' employees',''),-1,0),'Unknown',0) Num_Employees
FROM data_cleaning..glassdoor_jobs

/*
Thirdteen
Divide Type of Ownership into Type of organization and type of ownership
*/

SELECT CASE WHEN Type_of_ownership = '-1' THEN 'Unknown'
	WHEN CHARINDEX('-',Type_of_ownership) = 0 THEN	PARSENAME(REPLACE(Type_of_ownership,'-','.'),1)
	ELSE PARSENAME(REPLACE(Type_of_ownership,'-','.'),2) 
	END Organization_Type,
	CASE WHEN Type_of_ownership = '-1' THEN 'Unknown'
	WHEN CHARINDEX('-',Type_of_ownership) = 0 THEN	'Unknown'
	ELSE PARSENAME(REPLACE(Type_of_ownership,'-','.'),1)
	END Ownership_Type
FROM data_cleaning..glassdoor_jobs



/*
Fourtheen:
Remove the currency from Revenue (Both the symbol and word in parenthesis)
and replace the value -1 with  'Unknown/Non-Applicable'
*/
SELECT CASE WHEN Revenue = '-1' THEN 'Unknown/Non-Applicable'
		ELSE REPLACE(REPLACE(Revenue,' (USD)',''),'$','') 
		END AS Usd_Revenue
FROM data_cleaning..glassdoor_jobs


/*
Fiftheen:
Replace the -1 from the Columns: Industry, Sector and Competitors value with 'Unknown'
*/
SELECT REPLACE(Industry,'-1','Unknown') as Industry,
	REPLACE(Sector,'-1','Unknown') as Sector,
	REPLACE(Competitors, '-1','Unknown') as Competitors
FROM data_cleaning..glassdoor_jobs




/*
Combining all of the transformed data
*/

SELECT CASE WHEN CHARINDEX('-', Salary_Estimate) = 0 THEN 0
	WHEN Salary_Estimate = '-1' THEN 0
	ELSE PARSENAME(
			REPLACE(REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(Salary_Estimate,'(Glassdoor est.)',''),
								'(Employer est.)',''),
							'$',''),
						'K',''),
					'Per Hour',''),
				'Employer Provided Salary:', ''),
		'-','.'),2)
	END AS Min_Salary,
	CASE WHEN CHARINDEX('-', Salary_Estimate) = 0 THEN 0
	WHEN Salary_Estimate = '-1' THEN 0
	ELSE PARSENAME(
			REPLACE(REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(Salary_Estimate,'(Glassdoor est.)',''),
								'(Employer est.)',''),
							'$',''),
						'K',''),
					'Per Hour',''),
				'Employer Provided Salary:', ''),
		'-','.'),1)
	END AS Max_Salary,
	((CASE WHEN CHARINDEX('-', Salary_Estimate) = 0 THEN 0
	WHEN Salary_Estimate = '-1' THEN 0
	ELSE PARSENAME(
			REPLACE(REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(Salary_Estimate,'(Glassdoor est.)',''),
								'(Employer est.)',''),
							'$',''),
						'K',''),
					'Per Hour',''),
				'Employer Provided Salary:', ''),
		'-','.'),2)
	END ) + 
	(CASE WHEN CHARINDEX('-', Salary_Estimate) = 0 THEN 0
	WHEN Salary_Estimate = '-1' THEN 0
	ELSE PARSENAME(
			REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(Salary_Estimate,'(Glassdoor est.)',''),
								'(Employer est.)',''),
							'$',''),
						'K',''),
					'Per Hour',''),
				'Employer Provided Salary:', ''),
		'-','.'),1)
	END)
	) / 2 AS Avg_Salary,
	CASE WHEN CHARINDEX('per hour',LOWER(Salary_Estimate)) = 0 THEN 0
		ELSE 1 
		END AS salary_per_hour,
	CASE WHEN LEFT(LOWER(Salary_Estimate), 25) = 'employer provided salary:' THEN 1
		ELSE 0 
		END AS Employer_provided_salary,
	CASE WHEN Rating <0 THEN Company_Name
		ELSE LEFT(Company_Name,LEN(Company_name)-4) 
		END AS Company_text,
	RIGHT(Location,3) as Job_State,
	CASE WHEN Headquarters= '-1' THEN RIGHT(Location,2) 
		WHEN LEN(TRIM(PARSENAME(REPLACE(Headquarters,',','.'),1))) > 2 THEN ''
		ELSE RIGHT(Headquarters,2)
		END as Hq_Usa_State,
	CASE WHEN Headquarters= '-1'  OR 
		LEN(TRIM(PARSENAME(REPLACE(Headquarters,',','.'),1))) = 2 
		THEN 'United States' 
		ELSE TRIM(PARSENAME(REPLACE(Headquarters,',','.'),1))
		END as Hq_Country,
	CASE WHEN Rating <0 THEN 0 ELSE Rating END AS Rating,
	CASE WHEN Founded <0 THEN Founded
		ELSE YEAR(GETDATE()) - Founded
		END AS Company_Age,
	REPLACE(REPLACE(REPLACE(SIZE,' employees',''),-1,0),'Unknown',0) AS Num_Employees,
	CASE WHEN Type_of_ownership = '-1' THEN 'Unknown'
		WHEN CHARINDEX('-',Type_of_ownership) = 0 THEN	PARSENAME(REPLACE(Type_of_ownership,'-','.'),1)
		ELSE PARSENAME(REPLACE(Type_of_ownership,'-','.'),2) 
		END Organization_Type,
	CASE WHEN Type_of_ownership = '-1' THEN 'Unknown'
		WHEN CHARINDEX('-',Type_of_ownership) = 0 THEN	'Unknown'
		ELSE PARSENAME(REPLACE(Type_of_ownership,'-','.'),1)
		END Ownership_Type,
	REPLACE(Industry,'-1','Unknown') as Industry,
	REPLACE(Sector,'-1','Unknown') as Sector,
	CASE WHEN Revenue = '-1' THEN 'Unknown/Non-Applicable'
		ELSE REPLACE(REPLACE(Revenue,' (USD)',''),'$','') 
		END AS Usd_Revenue,
	REPLACE(Competitors, '-1','Unknown') as Competitors
FROM data_cleaning..glassdoor_jobs



/*
Combining our transformed data with the rest of the columns*/
SELECT [Index], 
	CASE WHEN Rating <0 THEN Company_Name
	ELSE LEFT(Company_Name,LEN(Company_name)-4) END AS 'Company_text',
	Job_Title,
	CASE WHEN CHARINDEX('-', Salary_Estimate) = 0 THEN 0
	WHEN Salary_Estimate = '-1' THEN 0
	ELSE PARSENAME(
			REPLACE(REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(Salary_Estimate,'(Glassdoor est.)',''),
								'(Employer est.)',''),
							'$',''),
						'K',''),
					'Per Hour',''),
				'Employer Provided Salary:', ''),
		'-','.'),2)
	END AS Min_Salary,
	CASE WHEN CHARINDEX('-', Salary_Estimate) = 0 THEN 0
	WHEN Salary_Estimate = '-1' THEN 0
	ELSE PARSENAME(
			REPLACE(REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(Salary_Estimate,'(Glassdoor est.)',''),
								'(Employer est.)',''),
							'$',''),
						'K',''),
					'Per Hour',''),
				'Employer Provided Salary:', ''),
		'-','.'),1)
	END AS Max_Salary,
	((CASE WHEN CHARINDEX('-', Salary_Estimate) = 0 THEN 0
	WHEN Salary_Estimate = '-1' THEN 0
	ELSE PARSENAME(
			REPLACE(REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(Salary_Estimate,'(Glassdoor est.)',''),
								'(Employer est.)',''),
							'$',''),
						'K',''),
					'Per Hour',''),
				'Employer Provided Salary:', ''),
		'-','.'),2)
	END ) + 
	(CASE WHEN CHARINDEX('-', Salary_Estimate) = 0 THEN 0
	WHEN Salary_Estimate = '-1' THEN 0
	ELSE PARSENAME(
			REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(Salary_Estimate,'(Glassdoor est.)',''),
								'(Employer est.)',''),
							'$',''),
						'K',''),
					'Per Hour',''),
				'Employer Provided Salary:', ''),
		'-','.'),1)
	END)
	) / 2 AS Avg_Salary,
	Job_Description,
	RIGHT(Location,3) as Job_State,
	CASE WHEN Headquarters= '-1' THEN RIGHT(Location,2) 
		WHEN LEN(TRIM(PARSENAME(REPLACE(Headquarters,',','.'),1))) > 2 THEN ''
		ELSE RIGHT(Headquarters,2)
		END as Hq_Usa_State,
	CASE WHEN Headquarters= '-1'  OR 
		LEN(TRIM(PARSENAME(REPLACE(Headquarters,',','.'),1))) = 2 
		THEN 'United States' 
		ELSE TRIM(PARSENAME(REPLACE(Headquarters,',','.'),1))
		END as Hq_Country,
	CASE WHEN Rating <0 THEN 0 ELSE Rating END AS Rating,
	REPLACE(REPLACE(REPLACE(SIZE,' employees',''),-1,0),'Unknown',0) AS Num_Employees,
	CASE WHEN Founded <0 THEN Founded
		ELSE YEAR(GETDATE()) - Founded
		END AS Company_Age,
	CASE WHEN Type_of_ownership = '-1' THEN 'Unknown'
		WHEN CHARINDEX('-',Type_of_ownership) = 0 THEN	PARSENAME(REPLACE(Type_of_ownership,'-','.'),1)
		ELSE PARSENAME(REPLACE(Type_of_ownership,'-','.'),2) 
		END Organization_Type,
	CASE WHEN Type_of_ownership = '-1' THEN 'Unknown'
		WHEN CHARINDEX('-',Type_of_ownership) = 0 THEN	'Unknown'
		ELSE PARSENAME(REPLACE(Type_of_ownership,'-','.'),1)
		END Ownership_Type,
	REPLACE(Industry,'-1','Unknown') as Industry,
	REPLACE(Sector,'-1','Unknown') as Sector,
	CASE WHEN Revenue = '-1' THEN 'Unknown/Non-Applicable'
		ELSE REPLACE(REPLACE(Revenue,' (USD)',''),'$','') 
		END AS Usd_Revenue,
	REPLACE(Competitors, '-1','Unknown') as Competitors
FROM data_cleaning..glassdoor_jobs
ORDER BY 2,3,4,5


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


/*
 Examining the records you will see that there are a lot of records that are exactly the same, except for 
 column Index. This column is only indicating that certain position for certain company was posted multiple
 times. 

 Let's create a new column with the number of times that a position was posted and delete the duplicated rows
*/

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
SELECT Company_text as Company_Name, Job_Title, Min_salary,Max_Salary, Avg_Salary,
		Job_Description, Job_State, Hq_Usa_State, Hq_Country, Rating, Num_Employees as Number_Of_Employees, 
		Company_Age, Organization_Type,Ownership_Type, 
		Industry,Sector,Usd_Revenue,Competitors,Times_Posted
FROM Max_Duplicates
WHERE row_num = 1
ORDER BY Company_text,
		Job_Title,
		Min_Salary,
		Max_Salary,
		Job_State;


/*Now we are ready to create a new table with the cleaned information*/

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
