-- Sort townships by the number of confirmed indigenous cases.
SELECT 
	township_infected,
	COUNT(confirmed_cases) AS case_count 
FROM dengue_cases
WHERE township_infected IS NOT NULL AND imported = 'N' 
	--AND EXTRACT(YEAR FROM date_onset) BETWEEN 2012 AND 2024 -- check study period only
GROUP BY township_infected
ORDER BY case_count DESC;

-- Count confirmed indigenous cases by year.
SELECT 
	COUNT(confirmed_cases) AS case_count,
	EXTRACT(YEAR FROM date_onset)::INTEGER as year
FROM dengue_cases
WHERE township_infected IS NOT NULL AND imported = 'N'
GROUP BY year
ORDER BY year;

-- Create view for mothly dengue cases by township.
-- Calculate dengue incidence rate (per 100,000 population).
CREATE VIEW dengue_monthly AS
SELECT 
    t.code,
    t.name,
	t.county,
	t.total_pop,
    EXTRACT(YEAR FROM d.date_onset)::INTEGER AS year,
    EXTRACT(MONTH FROM d.date_onset)::INTEGER AS month,
	COUNT(d.confirmed_cases) AS case_count,
	(COUNT(d.confirmed_cases)::FLOAT / t.total_pop) * 100000 AS dir -- change integer to float for division
FROM main_island_townships t
JOIN dengue_cases d ON t.code = d.township_infected
WHERE d.imported = 'N'
GROUP BY t.code, t.name, t.county, t.total_pop, year, month
ORDER BY year, month;

select sum(case_count) from dengue_monthly where year between 2012 and 2024
select sum(confirmed_cases) from dengue_cases where imported = 'N' and township_infected is not null

-- Calculate minimum, maximum, average and standard deviation of monthly case count.
SELECT MIN(case_count), MAX(case_count), AVG(case_count), STDDEV(case_count)
FROM dengue_monthly;
	
-- Create view for annual dengue cases by township.
--CREATE VIEW dengue_yearly AS
SELECT 
    t.code,
    t.name,
	t.county,
	t.total_pop,
    EXTRACT(YEAR FROM d.date_onset) AS year,
    COUNT(d.confirmed_cases) AS case_count,
	(COUNT(d.confirmed_cases)::FLOAT / t.total_pop) * 100000 AS dir
FROM main_island_townships t
JOIN dengue_cases d ON t.code = d.township_infected
WHERE d.imported = 'N'
GROUP BY t.code, t.name, t.county, t.total_pop, year
ORDER BY year;

-- Calculate minimum, maximum, average and standard deviation of yearly case count.
SELECT MIN(case_count), MAX(case_count), AVG(case_count), STDDEV(case_count)
FROM dengue_yearly;
	
-- Create view for total dengue cases by township for 2012-2024.
-- Join townships with 0 dengue cases.
CREATE VIEW dengue_total_2012_2024 AS
SELECT 
    t.code,
    t.name,
	t.county,
	t.total_pop,
    COUNT(d.confirmed_cases) AS case_count,
	(COUNT(d.confirmed_cases)::FLOAT / t.total_pop) * 100000 AS dir
FROM main_island_townships t
LEFT JOIN dengue_cases d ON t.code = d.township_infected AND 
	d.imported = 'N' AND
	EXTRACT(YEAR FROM d.date_onset) BETWEEN 2012 AND 2024
GROUP BY t.code, t.name, t.county, t.total_pop
ORDER BY t.code;

-- Create view for total dengue cases by township for 2012-2024 with geometries.
CREATE VIEW dengue_total_2012_2024_geom AS
SELECT 
    t.code,
    t.name,
    t.county,
    t.total_pop,
    COUNT(d.confirmed_cases) AS case_count,
    (COUNT(d.confirmed_cases)::FLOAT / t.total_pop) * 100000 AS dir,
	t.geom
FROM main_island_townships t
JOIN dengue_cases d ON t.code = d.township_infected
WHERE 
    d.imported = 'N' AND
    EXTRACT(YEAR FROM d.date_onset) BETWEEN 2012 AND 2024
GROUP BY t.code, t.name, t.county, t.total_pop, t.geom
ORDER BY t.code;

-- Create view for total dengue cases by township for 2012-2024 with all township geometries.
CREATE VIEW dengue_2012_2024 AS
SELECT 
    t.code,
    t.name,
    t.county,
    t.total_pop,
    COUNT(d.confirmed_cases) AS case_count,
    (COUNT(d.confirmed_cases)::FLOAT / t.total_pop) * 100000 AS dir,
	t.geom
FROM main_island_townships t
LEFT JOIN dengue_cases d ON t.code = d.township_infected AND 
	d.imported = 'N' AND
	EXTRACT(YEAR FROM d.date_onset) BETWEEN 2012 AND 2024
GROUP BY t.code, t.name, t.county, t.total_pop, t.geom
ORDER BY t.code;

-- Create views for major outbreak years (2014, 2015, 2023)
CREATE VIEW dengue_2014 AS
SELECT 
    t.code,
	t.pop_density,
	t.elevation,
	t.built_up_area,
    (COUNT(d.confirmed_cases)::FLOAT / t.total_pop) * 100000 AS dir,
	t.geom
FROM main_island_townships t
LEFT JOIN dengue_cases d ON t.code = d.township_infected AND 
	d.imported = 'N' AND
	EXTRACT(YEAR FROM d.date_onset) = 2014
GROUP BY t.code, t.total_pop, t.pop_density, t.elevation, t.built_up_area,t.geom;

CREATE VIEW dengue_2015 AS
SELECT 
    t.code,
	t.pop_density,
	t.elevation,
	t.built_up_area,
	COUNT(d.confirmed_cases) as case_count,
    (COUNT(d.confirmed_cases)::FLOAT / t.total_pop) * 100000 AS dir,
	t.geom
FROM main_island_townships t
LEFT JOIN dengue_cases d ON t.code = d.township_infected AND 
	d.imported = 'N' AND
	EXTRACT(YEAR FROM d.date_onset) = 2015
GROUP BY t.code, t.total_pop, t.pop_density, t.elevation, t.built_up_area,t.geom;

CREATE VIEW dengue_2023 AS
SELECT 
    t.code,
	t.pop_density,
	t.elevation,
	t.built_up_area,
    (COUNT(d.confirmed_cases)::FLOAT / t.total_pop) * 100000 AS dir,
	t.geom
FROM main_island_townships t
LEFT JOIN dengue_cases d ON t.code = d.township_infected AND 
	d.imported = 'N' AND
	EXTRACT(YEAR FROM d.date_onset) = 2023
GROUP BY t.code, t.total_pop, t.pop_density, t.elevation, t.built_up_area,t.geom;














