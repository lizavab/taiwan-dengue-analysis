-- Find how many station have no data start and end dates.

SELECT * 
FROM stations 
WHERE data_start_date IS NULL;

SELECT * 
FROM stations 
WHERE data_end_date IS NULL;

-- In the original station list only coordinates (longitude, latitude) are available. 
-- Create 2D point geometry for each station using the coordinates.

UPDATE stations
SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326);

-- Find in which townships the stations are located and save the township code in the table.

UPDATE stations
SET township = townships.code
FROM townships
WHERE ST_Contains(townships.geom, stations.geom);