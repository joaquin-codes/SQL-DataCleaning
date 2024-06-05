-- How many layoff each company has had
SELECT company, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC
;

-- What country has had the most layoffs
select country, sum(total_laid_off) total_layoffs
from layoffs_staging2
group by country
order by total_layoffs desc;

-- Whata are some of the most recent layoffs by companys
select company,`date`, sum(total_laid_off)
from layoffs_staging2
group by `date`, company
order by `date` desc;

-- WHat year has had the most layoffs
select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;

-- Rolling Total of layoffs month to month
with Rolling_total as (
	select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off
	from layoffs_staging2
	where substring(`date`,1,7) is not null
	group by `month`
	order by 1 asc
) 
select `month`, total_off, sum(total_off) over (order by `month`) Rolling_Total_sum from rolling_total;

-- Ranks of companies by total layoffs within each year
with company_year (company, years, total_laid_off) as (
	select company, year(`date`), sum(total_laid_off)
	from layoffs_staging2
	group by year(`date`), company
	
)
select *, dense_rank() over ( partition by years order by total_laid_off desc) ranking
from company_year
where years is not null
order by ranking;

-- What industries had the most layoffs per year

SELECT 
    YEAR(`date`) AS year,
    industry,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY YEAR(`date`), industry
HAVING SUM(total_laid_off) = (
    SELECT MAX(layoffs_by_industry.total_layoffs)
    FROM (
        SELECT 
            YEAR(`date`) AS year,
            industry,
            SUM(total_laid_off) AS total_layoffs
        FROM layoffs_staging2


        GROUP BY YEAR(`date`), industry
    ) AS layoffs_by_industry
    WHERE layoffs_by_industry.year = YEAR(layoffs_staging2.date)
)
ORDER BY year;