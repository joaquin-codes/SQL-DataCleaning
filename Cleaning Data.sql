-- After creating Table "Layoffs, I will procede to clean the raw data from layoffs.csv 

-- create another table called "layoffs_staging" so we don't mess up the original data, we can store in this one the changes we feel happy with form layoffs_staging2
-- Add a column called row_num, it's an int
CREATE TABLE `layoffs_staging` (
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

-- Create another staging table where we are going to delete the duplicates using a row_number()
CREATE TABLE `layoffs_staging2` (
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

-- populate the new table with all the data and the new column row_num
insert into layoffs_staging2
select *, row_number() over
( partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
;

-- delete all the duplicates
DELETE FROM layoffs_staging2 
WHERE row_num > 1;


-- Scout the diferent colums to find any errors and fix them.

-- Trim the names of the companys
update layoffs_staging2 set company = trim(company);

-- Make sure there aren't any industries meant to be the same with different names (crypto and crypto currencie)
update layoffs_staging2 set industry ='Crypto' where industry like 'Crypto%';

-- Remove any dots or simbols at the end
update layoffs_staging2 set country = trim(trailing '.' from country);

-- Change the column date to be date format
update layoffs_staging2 set `date` = str_to_date(`date`,'%m/%d/%Y');
alter table layoffs_staging2 modify column `date` date;

-- Some rows have missing industry values for certain companies.
-- This query will update those rows by filling in the missing industry values with the existing industry values from other rows of the same company.

UPDATE layoffs_staging2 t1
SET t1.industry = (
    SELECT t2.industry
    FROM layoffs_staging t2
    WHERE t2.company = t1.company AND t2.industry <> '' AND t2.industry IS NOT NULL
    LIMIT 1
)
WHERE t1.industry IS NULL OR t1.industry = '';


-- delete the companies that have no layoff data in total_laid_off & percentage_laid_off
-- we need at least one of these values but if both are missing they are useless
delete from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;

-- Delete the Row_num colum at the end, as we no longuer need it
alter table layoffs_staging2 drop row_num;


-- Everytime you feel confident in the work you have done, save it to layoffs_staging
/*
TRUNCATE TABLE layoffs_staging1;

INSERT INTO layoffs_staging1 (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num)
SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
FROM layoffs_staging2;

 select * from layoffs_staging2;
 */


-- in case you messed up, copy from layoffs_staging into layoffs_staging2
/*
TRUNCATE TABLE layoffs_staging2;

INSERT INTO layoffs_staging2 (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num)
SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
FROM layoffs_staging1;

 select * from layoffs_staging2;
 */
 



