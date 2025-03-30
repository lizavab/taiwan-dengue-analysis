-- Some CSV files duplicate January observations, which were inserted as unique observations.
-- Find all duplicates.
WITH duplicates AS (
    SELECT station, obs_date, MIN(id) AS min_id
    FROM weather_monthly
    GROUP BY station, obs_date 
    HAVING COUNT(*) > 1
)
SELECT * FROM duplicates;

-- Delete all duplicates (1068 in total).
DELETE FROM weather_monthly
WHERE id NOT IN (
    SELECT MAX(id)
    FROM weather_monthly
    GROUP BY 
        station, 
        obs_date
);

-- Create a view with filtered out incorrect or NULL values.
-- Exclude all temperature values that are likely incorrect, specifically: 
	-- max temperature can't be lower than average;
	-- minimum temperature can't be higher than average;
	-- the difference between average temperature and minimum or maximum can't be larger than 30 degrees Celsius;
	-- maximum temperature can't be higher than 41.6°C, which is Taiwan's record high temperature from 2022.
CREATE VIEW weather_monthly_clean AS
SELECT * FROM weather_monthly
WHERE 
	(tavg < tmax AND tavg > tmin) AND
	(tavg - tmin) <= 30 AND
	(tmax - tavg) <= 30 AND 
	tmax <= 41.6 AND
    wind_speed IS NOT NULL AND 
    precip IS NOT NULL;

-- Create a view for 2011-2024 period with specific variables and from main island stations only.	
CREATE VIEW weather_2011_2024 AS
SELECT 
    wm.station,
	s.township,
    EXTRACT(YEAR FROM wm.obs_date) AS year, 
    EXTRACT(MONTH FROM wm.obs_date) AS month, 
    wm.tavg, 
    wm.tmax, 
    wm.tmin, 
    wm.wind_speed, 
    wm.precip
FROM weather_monthly_clean wm
JOIN main_island_stations s ON wm.station = s.code
WHERE 
	EXTRACT(YEAR FROM wm.obs_date) BETWEEN 2011 AND 2024
ORDER BY wm.station, wm.obs_date;
	
SELECT * FROM weather_2011_2024;
