-- Data cleaning

SELECT * FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Null values
-- 4. Remove Columns


-- Creating a dummy table to work in it rather than working in raw data

create table layoffs_staging
like layoffs;
    
SELECT * FROM layoffs_staging;

-- transfer data from raw table to dummy table

insert layoffs_staging
select * from layoffs;

SELECT * FROM layoffs_staging;

SELECT *, row_number() OVER(PARTITION BY company, industry,total_laid_off,
percentage_laid_off,`date`) as row_num
FROM layoffs_staging;

with duplicate_cte as (SELECT *, row_number() OVER(
PARTITION BY company,location,industry,total_laid_off,
percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
FROM layoffs_staging)
select * from duplicate_cte
where row_num > 1;

SELECT * FROM layoffs_staging
where company = 'Casper';

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
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2;

INSERT into layoffs_staging2
SELECT *, row_number() OVER(
PARTITION BY company,location,industry,total_laid_off,
percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
FROM layoffs_staging;

SELECT * FROM layoffs_staging2
where row_num>1;

delete FROM layoffs_staging2
where row_num>1;

SELECT * FROM layoffs_staging2
where row_num>1;

-- 2. Standardize the data
SELECT 
    company, TRIM(company)
FROM
    layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT 
    DISTINCT industry
FROM
    layoffs_staging2
    ORDER BY 1;
    
SELECT * FROM layoffs_staging2
where industry like 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry like 'Crypto%';

SELECT DISTINCT industry
from layoffs_staging2;

SELECT DISTINCT location
from layoffs_staging2
order by 1;

SELECT *
from layoffs_staging2;

SELECT DISTINCT country
from layoffs_staging2
order by 1;

SELECT * FROM layoffs_staging2
where country like 'United States%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
from layoffs_staging2
order by 1;

UPDATE layoffs_staging2
set country = TRIM(TRAILING '.' FROM country)
where country like 'United States%';

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

ALTER table layoffs_staging2
modify column `date` DATE;

SELECT *
FROM layoffs_staging2;

-- 3. Null values

SELECT *
FROM layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

SELECT *
FROM layoffs_staging2
where industry is null
or industry = '';

SELECT *
FROM layoffs_staging2
where company = 'Airbnb';

UPDATE layoffs_staging2
SET industry = null
where industry = '';

SELECT 
    t1.industry, t2.industry
FROM
    layoffs_staging2 t1
        JOIN
    layoffs_staging2 t2 ON t1.company = t2.company
WHERE
    (t1.industry IS NULL OR t1.industry = '')
        AND t2.industry IS NOT NULL;
        

update layoffs_staging2 t1
join layoffs_staging2 t2 
on t1.company = t2.company
set t1.industry = t2.industry 
where t1.industry is null
and t2.industry is not null;

SELECT *
FROM layoffs_staging2
where company LIKE 'Bally%';

SELECT *
FROM layoffs_staging2;


## REMOVING THE ROWS AND COLUMNS

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


ALTER TABLE layoffs_staging2
DROP column row_num;




