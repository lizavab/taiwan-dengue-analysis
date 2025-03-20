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

-- Filter out all stations located on small islands.
CREATE VIEW main_island_stations AS
SELECT * FROM stations
WHERE code NOT IN (
    '467990', '467620', '467350', '467300', 'C0W160', 'C0S730', 'C0W110', 
    'C0W150', 'C0S900', 'C0S910', 'C0W200', 'C0R270', 'C0W120', 'C2W230', 
    'C0W130', 'C0W190', 'C0W180', '466950', 'C0W170', 'C0W240', 'C0W220', 
    '467110', 'C0W140');
