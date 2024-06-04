-- EDA

SELECT 
    *
FROM
    layoffs_staging2;

-- What is the maximum layoff
SELECT 
    MAX(total_laid_off), max(percentage_laid_off)
FROM
    layoffs_staging2;


SELECT 
    *
FROM
    layoffs_staging2
WHERE
    percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- Total layoffs by a company 

SELECT 
    company, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Period of the data
SELECT 
    MIN(`date`), MAX(`date`)
FROM
    layoffs_staging2;
    
    
-- Total layoffs in an industry

SELECT 
    industry, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

select * from layoffs_staging2;

-- Total layoffs in an country
SELECT 
    country, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Yearwise layoffs

SELECT 
    year(`date`), SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY year(`date`)
ORDER BY 1 DESC;

-- Stagewise layoffs
SELECT 
    stage, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Monthwise layoffs for each year
SELECT 
    SUBSTRING(`date`, 1, 7) AS 'MONTH', SUM(total_laid_off) AS total_off
FROM
    layoffs_staging2
    WHERE SUBSTRING(`date`, 1, 7) IS not null
GROUP BY SUBSTRING(`date`, 1, 7)
ORDER BY 1 ASC;

-- Rolling total of layoffs monthwsie

WITH Rolling_total AS
(
SELECT 
    SUBSTRING(`date`, 1, 7) AS 'MONTH', SUM(total_laid_off) AS total_off
FROM
    layoffs_staging2
    WHERE SUBSTRING(`date`, 1, 7) IS not null
GROUP BY SUBSTRING(`date`, 1, 7)
ORDER BY SUBSTRING(`date`, 1, 7) ASC
)
SELECT 'MONTH', total_off, SUM(total_off) OVER(order BY 'MONTH') AS rolling_total
FROM Rolling_total;



SELECT 
    company, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Layoffs in each year by companies
SELECT 
    company,year(`date`), SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY company,year(`date`)
order by 3 desc;

-- Ranking companies on their layoffs for each years

with company_year(company, years, total_laid_off) as (
SELECT 
    company,year(`date`), SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY company,year(`date`)), company_year_rank as (
select *, dense_rank() over (partition by years order by total_laid_off desc) as ranking
from company_year
where years is not null)
select * from company_year_rank
where ranking <= 5;


-- Total Number of Layoffs:
SELECT 
    COUNT(total_laid_off)
FROM
    layoffs_staging2;


-- Top 5 Industries with Most Layoffs:
SELECT 
    industry, COUNT(*) AS total_layoffs
FROM
    layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC
LIMIT 5;


-- Average Layoffs per Company:
SELECT 
    AVG(total_laid_off) as avg_total_layoffs
FROM
    layoffs_staging2;


-- Layoffs by Country:
SELECT 
    country, COUNT(*) AS total_layoffs
FROM
    layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC
LIMIT 10;


-- Find companies with layoffs exceeding a specific amount (e.g., 100).
SELECT 
    company, total_laid_off
FROM
    layoffs_staging2
WHERE
    total_laid_off > 5000;


-- Calculate the monthly trend of layoffs for the past year.

SELECT 
    SUBSTRING(`date`, 1, 7) AS 'month',
    COUNT(*) AS total_layoffs
FROM
    layoffs_staging2
WHERE
    `date` >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
GROUP BY SUBSTRING(`date`, 1, 7)
ORDER BY SUBSTRING(`date`, 1, 7);


-- Identify companies with layoffs in a specific country and industry.

SELECT 
    company, total_laid_off
FROM
    layoffs_staging2
WHERE
    country = 'United States'
        AND industry = 'Finance'
ORDER BY total_laid_off DESC
LIMIT 5;


-- Compare average layoffs between companies that received funding and those that didn't.

WITH funded_companies as (
select company, total_laid_off
from layoffs_staging2
where funds_raised_millions > 0
),
unfunded_companies as (
select company, total_laid_off
from layoffs_staging2
where funds_raised_millions = 0 or funds_raised_millions is null
)
select 'funded companies', AVG(total_laid_off) AS AVG_LAYOFFS FROM funded_companies
UNION ALL
select 'unfunded_companies', AVG(total_laid_off) AS AVG_LAYOFFS FROM unfunded_companies;


-- Find companies with layoffs in a specific date range.
SELECT 
    company, total_laid_off, `date`
FROM
    layoffs_staging2
WHERE
    `date` BETWEEN '2023-01-01' AND '2023-03-01'
        AND total_laid_off IS NOT NULL
        AND total_laid_off >= 1000
ORDER BY `date` ASC;


--  Group layoffs by industry and stage, then calculate the percentage of layoffs for each combination.

 select industry, stage, count(*) as total_layoffs, 
 count(*) *1.0/sum(count(*)) over (partition by industry) as pct_layoffs_industry
 from layoffs_staging2
 where industry is not null
 group by industry, stage
 order by industry, total_layoffs desc;
 
 
 --  Find companies with a history of layoffs (e.g., multiple layoffs in the past year).
 with company_layoffs as (
select company, count(*) as layoffs_count, `date`
from layoffs_staging2
group by company,`date`
)
select company, sum(layoffs_count) as total_layoff_events
from company_layoffs
group by company
having total_layoff_events > 1
order by total_layoff_events desc;
 
 
 
 
 
 
 
