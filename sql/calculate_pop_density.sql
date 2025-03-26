-- Calculate population density (persons/km2) in counties.
SELECT name, total_pop / (ST_Area(geom) / 1000000) AS pop_density
FROM counties
ORDER BY pop_density DESC;

UPDATE counties
SET pop_density = total_pop / (ST_Area(geom) / 1000000);

-- Calculate population density (persons/km2) in townships.
SELECT name, total_pop / (ST_Area(geom) / 1000000) AS pop_density
FROM townships
ORDER BY pop_density DESC;

UPDATE townships
SET pop_density = total_pop / (ST_Area(geom) / 1000000);