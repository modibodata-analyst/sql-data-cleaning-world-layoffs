#SQL-Data-cleaning

select *
from layoffs;

## we are going to create a staging table. This is the one we will work in and clean the data. keep the raw data safe
create table layoff_stagging
like layoffs;

insert into layoff_stagging
select*
from layoffs;

#data cleaning usually follow a few steps.
# 1. check for duplicates and remove any
# 2. standardize data and fix errors
# 3. Look at null values and see what 
# 4. remove any columns and rows that are not necessary 


                             #1. Remove Duplicates

# First let's check for duplicates

# Since dont have unique id in this data set we run a window function partitioning by every column to create an independant new column counting the number of time a row appear

select*,
row_number() over(partition by company, location,industry, total_laid_off, percentage_laid_off, 
'date',stage, country, funds_raised_millions) as row_num
from layoff_stagging;

## WE create a temporary table and run the bellow out of it

with cte_duplicate as(
select*,
row_number() over(partition by company, location,industry, total_laid_off, percentage_laid_off, 
'date',stage, country, funds_raised_millions) as row_num
from layoff_stagging)
select*
from  cte_duplicate
where row_num > 1;

## We want to delete where the row number is > 1 

## Create a stagging2 table with a new column and add those row numbers in. Then delete where row numbers are > 1 , then delete that column

 CREATE TABLE `layoff_stagging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoff_stagging2
select*,
row_number() over(partition by company, location,industry, total_laid_off, percentage_laid_off, 
'date',stage, country, funds_raised_millions) as row_num
from layoff_stagging;

select *
from layoff_stagging2
where row_num > 1;


delete 
from layoff_stagging2
where row_num > 1;

select *
from layoff_stagging2;


						##2Standardazing the data
select *
from layoff_stagging2;

## fix the spacing in the column

Select distinct company, trim(company)
from layoff_stagging2;

update layoff_stagging2
set company = trim(company);

## if we look at industry it looks like we have some typo

SELECT DISTINCT location
FROM layoff_stagging2
WHERE location LIKE BINARY '%Ã%';

UPDATE layoff_stagging2
SET location = 'Düsseldorf'
WHERE location LIKE 'D%sseldorf';

UPDATE layoff_stagging2
SET location = 'Florianópolis'
WHERE location LIKE 'Florian%polis';

UPDATE layoff_stagging2
SET location = 'Malmö'
WHERE location LIKE 'Malm%';

select*
from layoff_stagging2
where industry like 'Crypto%';

update layoff_stagging2
set industry = 'Crpto'
where industry like 'Crypto%';

select distinct country
from layoff_stagging2
order by 1;

## We have some "United States" and some "United States." with a period at the end. Let's standardize this.

select distinct country,  trim(trailing '.' from country)
from layoff_stagging2
order by 1;

update layoff_stagging2
set country = trim(trailing '.' from country)
where country like 'United States%';


#we can use str to date to update this field

SELECT `date`,
       STR_TO_DATE(`date`, '%m/%d/%Y') AS new_date
FROM layoff_stagging2;


UPDATE layoff_stagging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoff_stagging2;

# now we can convert the data type properly

ALTER TABLE layoff_stagging2
MODIFY COLUMN `date` DATE;

## checking
DESCRIBE layoff_stagging2;

				#3null and blank values

#the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. 
#I like having them null because it makes it easier for calculations during the EDA phase.

# Now let's take a look at the null values in industry and set the blanks values to  Null.

SELECT *
FROM layoffs
WHERE industry IS NULL
   OR industry = '';
   
   Update layoff_stagging2
   set industry = Null
   WHERE industry = 'Null'
   OR industry = '';
   
#Checking

SELECT *
FROM layoff_stagging2
WHERE industry IS NULL;

# it looks like airbnb is a travel, but this one just isn't populated.
# I'm sure it's the same for the others. What we can do is
# write a query that if there is another row with the same company name, it will update it to the non-null industry values
# makes it easy so if there were thousands we wouldn't have to manually check them 

Select t1.company, t1.industry, t2.industry
from layoff_stagging2 t1
join layoff_stagging2 t2
	on t1.company = t2.company
    where t1.industry is null
    and t2.industry is not null;
    
    Update layoff_stagging2 t1
    join layoff_stagging2 t2
		on t1.company = t2.company
	set t1.industry = t2.industry
	where t1.industry is null
    and t2.industry is not null;
    
    ##Checking
select*
from layoff_stagging2
where industry is null;

#let's take a look at these two column and the number of row missing
select *
from layoff_stagging2
where total_laid_off is null;

#SELECT *
#FROM layoff_stagging2
#WHERE percentage_laid_off IS NULL
   #OR percentage_laid_off = ''
   #OR percentage_laid_off = 'Null';    
   
   select count(*)
   FROM layoff_stagging2
WHERE percentage_laid_off IS NULL; 

select count(*)                                   ##348 rows
from layoff_stagging2
where total_laid_off is null 
and percentage_laid_off is null;

select count(*)                                 ##2339 rows 
from layoff_stagging2;

SELECT *
FROM layoff_stagging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL
LIMIT 10;

				#dropr rows
# I deleted those rows because i really want to work the total_laid_off when i am exploring the data and having null will just make think  more complicated
# And we cam't really do much with percentage_laid_off without the total percentage

delete 
FROM layoff_stagging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;
  
  SELECT COUNT(*) ##1991
  FROM layoff_stagging2;
  
  select*
  from layoff_stagging2;
  
               #4 drop the column
  alter table layoff_stagging2
  drop column row_num




















































