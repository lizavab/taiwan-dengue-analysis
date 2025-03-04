/* Run in command line:
/path/to/shp2pgsql -s 4326 -W "UTF-8" COUNTY_MOI_1090820.shp temporary_table | psql -d database_name -U username

Parameters:
-s 4326: Specifies the coordinate system. 4326 is for WGS84.
-W "UTF-8": Sets the encoding for text attributes. */

-- Upload township geometries to a temporary table.
ALTER TABLE temporary_table
  ALTER COLUMN countycode TYPE INTEGER USING (countycode::integer);
  
-- Transfer to the predefined table.
INSERT INTO counties (code, id, name, orig_name, total_pop, geom)
SELECT countycode, countyid, countyeng, countyname, NULL, geom
FROM temporary_table;

-- Delete the temporary table.
DROP TABLE IF EXISTS temporary_table;