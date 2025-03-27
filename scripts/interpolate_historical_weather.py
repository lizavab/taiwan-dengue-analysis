import pandas as pd
import geopandas as gpd
import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy import text
import rasterstats
from rasterstats import zonal_stats
import arcpy
from arcpy import env
from arcpy.sa import *
import time
print("Packages imported.")

start_time = time.time()

# Enable overwriting files
arcpy.env.overwriteOutput = True

# Set environment settings
env.workspace = "C:/Users/kgw721/Documents"

# Create a SQLAlchemy engine
conn_string = "postgresql://postgres:password@localhost:5433/tw" # database connection string
engine = create_engine(conn_string)

# Insert township geom into geodataframe
townships = gpd.read_postgis(
    "SELECT county, code, name, pop_density, geom FROM main_island_townships",
    engine,
    geom_col="geom"
)

query = "SELECT w.*, s.geom FROM weather_2011_2024 w JOIN stations s ON s.code = w.station WHERE year = 2012 AND month = 8"
subset = gpd.read_postgis(
    query,
    engine,
    geom_col="geom"
)

print(subset.head(5))

shp_path = "C:/Users/kgw721/Documents/subset.shp"
subset.to_file(shp_path, driver='ESRI Shapefile')
print(shp_path)


variables = ['tavg', 'tmax', 'tmin', 'wind_speed', 'precip']

for variable in variables:
    print(f"Interpolating {variable}.")
    raster = NaturalNeighbor(shp_path, variable, 2500)
    raster_path = "C:/Users/kgw721/Documents/nn_raster.tif"
    raster.save(raster_path)

    # Calculate zonal statistics
    print(f"Calculating zonal statistics for {variable}.")
    if variable == 'tmax':
        zs = zonal_stats(townships, raster_path, stats=['max'])
        print(zs)

        stats = pd.DataFrame(zs)
        stats.rename(columns={'max':'tmax'}, inplace=True)

    elif variable == 'tmin':
        zs = zonal_stats(townships, raster_path, stats=['min'])
        print(zs)

        stats = pd.DataFrame(zs)
        stats.rename(columns={'min':'tmin'}, inplace=True)
    else:
        zs = zonal_stats(townships, raster_path, stats=['mean'])
        print(zs)
        if variable == 'tavg':
            stats = pd.DataFrame(zs)
            stats.rename(columns={'mean':'tavg'}, inplace=True)

        elif variable == 'wind_speed':
            stats = pd.DataFrame(zs)
            stats.rename(columns={'mean':'wind_speed'}, inplace=True)

        else:
            stats = pd.DataFrame(zs)
            stats.rename(columns={'mean':'precip'}, inplace=True)

    # Merge with townships
    townships = pd.concat([townships, stats], axis=1)
    print(townships.head(5))

    subset_2012_8 = townships.drop(columns=['geom'])

    # Add year and month
    subset_2012_8['year'] = 2012
    subset_2012_8['month'] = 8

    subset_2012_8.to_csv("C:/Users/kgw721/Documents/subset_2012_8.csv", index=False)


total_time = time.time() - start_time
print(f"Processing time: {total_time:.2f} seconds")