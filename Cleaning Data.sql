/*After creating Table "Layoffs, I will procede to clean the raw data from layoffs.csv*/

CREATE TABLE layoffs_staging;

/*Create another staging table where we are going to delete the duplicates using a row_number()*/
CREATE TABLE layoffs_staging2;

insert into layoffs_staging2
select *,
    row_number() over( partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
    from layoffs_staging
;

/*delete all the duplicates*/
DELETE FROM layoffs_staging2 
WHERE
    row_num > 1;
 
/*Now in layoff_staging2 you have no duplicates*/