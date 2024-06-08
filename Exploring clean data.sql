-- How many layoffs each company has had
SELECT 
    company, 
    SUM(total_laid_off) AS total_layoffs
FROM 
    layoffs_staging2
GROUP BY 
    company
ORDER BY 
    total_layoffs DESC
;

-- What country has had the most layoffs
SELECT 
    country, 
    SUM(total_laid_off) AS total_layoffs
FROM 
    layoffs_staging2
GROUP BY 
    country
ORDER BY 
    total_layoffs DESC
;

-- What are some of the most recent layoffs by companies
SELECT 
    company,
    `date`, 
    SUM(total_laid_off) AS total_laid_off
FROM 
    layoffs_staging2
GROUP BY 
    `date`, 
    company
ORDER BY 
    `date` DESC
;

-- What year has had the most layoffs
SELECT 
    YEAR(`date`) AS year, 
    SUM(total_laid_off) AS total_layoffs
FROM 
    layoffs_staging2
GROUP BY 
    YEAR(`date`)
ORDER BY 
    year DESC
;

-- Rolling Total of layoffs month to month
WITH Rolling_total AS (
    SELECT 
        SUBSTRING(`date`, 1, 7) AS `month`, 
        SUM(total_laid_off) AS total_off
    FROM 
        layoffs_staging2
    WHERE 
        SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY 
        `month`
    ORDER BY 
        `month` ASC
) 
SELECT 
    `month`, 
    total_off, 
    SUM(total_off) OVER (ORDER BY `month`) AS Rolling_Total_sum 
FROM 
    Rolling_total
;

-- Ranks of companies by total layoffs within each year
WITH company_year AS (
    SELECT 
        company, 
        YEAR(`date`) AS years, 
        SUM(total_laid_off) AS total_laid_off
    FROM 
        layoffs_staging2
    GROUP BY 
        YEAR(`date`), 
        company
)
SELECT 
    *, 
    DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM 
    company_year
WHERE 
    years IS NOT NULL
ORDER BY 
    ranking
;

-- What industries had the most layoffs per year
WITH industry_year AS (
    SELECT 
        industry, 
        YEAR(`date`) AS years, 
        SUM(total_laid_off) AS total_laid_off
    FROM 
        layoffs_staging2
    GROUP BY 
        YEAR(`date`), 
        industry
)
SELECT 
    *, 
    DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM 
    industry_year
WHERE 
    years IS NOT NULL
ORDER BY 
    ranking
;

-- Rolling number of layoffs per year for each industry
WITH industry_month AS (
    SELECT 
        industry,
        SUBSTRING(`date`, 1, 7) AS `month`, 
        SUM(total_laid_off) AS monthly_layoffs
    FROM 
        layoffs_staging2
    WHERE 
        SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY 
        industry, 
        `month`
    ORDER BY 
        industry, 
        `month`
)
SELECT 
    industry,
    `month`,
    monthly_layoffs,
    SUM(monthly_layoffs) OVER (PARTITION BY industry ORDER BY `month`) AS rolling_total_sum
FROM 
    industry_month
    where industry is not null
ORDER BY 
    industry, 
    `month`
;