-- In the original station list only coordinates (longitude, latitude) are available. 
-- Create 2D point geometry for each station using the degree coordinates.
-- Transform CRS to EPSG:3826 (TWD97).
UPDATE stations
SET geom = ST_Transform(ST_SetSRID(ST_MakePoint(longitude, latitude), 4326), 3826);

-- Find in which townships the stations are located and save the township code in the table.
UPDATE stations
SET township = townships.code
FROM townships
WHERE ST_Contains(townships.geom, stations.geom);

-- Count how many stations there is in every township.
SELECT township, COUNT(*) AS station_count FROM stations 
GROUP BY township
ORDER BY station_count DESC;

-- Find which townships have 0 stations.
SELECT townships.code FROM townships
WHERE townships.code NOT IN (SELECT stations.township FROM stations);
