/* Run in command line:
/path/to/shp2pgsql -s 4326 -W "UTF-8" TOWN_MOI_1120317.shp temporary_table | psql -d database_name -U username

Parameters:
-s 4326: Specifies the coordinate system. 4326 is for WGS84.
-W "UTF-8": Sets the encoding for text attributes. */

-- Upload township geometries to a temporary table.
ALTER TABLE temporary_table
  ALTER COLUMN towncode TYPE INTEGER USING (towncode::integer),
  ALTER COLUMN countycode TYPE INTEGER USING (countycode::integer);
  
-- Transfer to the predefined table.
INSERT INTO townships (code, county, id, name, orig_name, total_pop, geom)
SELECT towncode, countycode, townid, towneng, townname, NULL, geom
FROM temporary_table;

-- Delete the temporary table.
DROP TABLE IF EXISTS temporary_table;

-- Transform CRS to EPSG:3826 (TWD97).
UPDATE townships
SET geom = ST_Transform(geom, 3826);

-- Create view with townships on main island.
CREATE VIEW main_island_townships AS
SELECT * FROM townships
WHERE code NOT IN (
    '9020060', '10014110', '10014160', '9007020', '9007040', 
    '9007010', '9007030', '10016060', '10016030', '10016040', 
    '10016010', '10016050', '10016020', '9020010', '9020020', 
    '9020030', '9020040', '9020050', '10013220');