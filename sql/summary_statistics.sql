-- Calculate summary statistics of monthly weather observations for each township.
CREATE VIEW weather_by_township AS
SELECT 
    t.code AS township_code,
    t.name AS township_name,
    t.county AS county_code,
    EXTRACT(YEAR FROM w.obs_date) AS year,
    EXTRACT(MONTH FROM w.obs_date) AS month,
	COUNT(DISTINCT s.code) AS station_count,
    AVG(w.tavg) AS tavg,
    MAX(w.tmax) AS tmax,
    MIN(w.tmin) AS tmin,
    AVG(w.rel_humidity) AS rel_humidity,
    AVG(w.wind_speed) AS wind_speed,
    AVG(w.precip) AS precip
FROM 
    townships t
JOIN 
    stations s ON t.code = s.township
JOIN 
    weather_monthly w ON s.code = w.station
GROUP BY 
    t.code, t.name, t.county, year, month
ORDER BY 
    t.code, year, month;