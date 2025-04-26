import pandas as pd
import geopandas as gpd
import sqlalchemy
from sqlalchemy import create_engine
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
env.workspace = ".."

# Create a SQLAlchemy engine
conn_string = "postgresql://postgres:password@localhost:5433/tw" # database connection string
engine = create_engine(conn_string)

# Specify path for observations subset and raster
shp_path = "obs.shp"
raster_path = "nn_raster.tif"

# Create an empty dataframe to store all interpolated data for 2011-2024
interpolated_data = pd.DataFrame(columns=['county', 'code', 'name', 'year', 'month', 'tavg', 'tmax', 'tmin', 'wind_speed', 'precip'])

years = list(range(2011, 2025))
months = list(range(1, 13))

for year in years:
    for month in months:
        print(f"Processing {year}/{month}.")

        # Use placeholders for year and month
        query = "SELECT w.*, s.geom FROM weather_2011_2024 w JOIN stations s ON s.code = w.station WHERE year = %s AND month = %s"

        # Insert weather observations and station geometries into geodataframe
        obs = gpd.read_postgis(
            query,
            engine,
            params=(year, month),
            geom_col="geom"
        )

        print(obs.head(5))

        obs.to_file(shp_path, driver='ESRI Shapefile')

        # Insert township geom into geodataframe
        townships = gpd.read_postgis(
            "SELECT county, code, name, geom FROM main_island_townships",
            engine,
            geom_col="geom"
        )

        variables = ['tavg', 'tmax', 'tmin', 'wind_speed', 'precip']

        for variable in variables:
            print(f"Interpolating {variable}.")
            raster = NaturalNeighbor(shp_path, variable, 2500)
            raster.save(raster_path)

            # Calculate zonal statistics
            print(f"Calculating zonal statistics for {variable}.")
            if variable == 'tmax':
                zs = zonal_stats(townships, raster_path, stats=['max'], all_touched=True)

                stats = pd.DataFrame(zs)
                stats.rename(columns={'max':'tmax'}, inplace=True)

            elif variable == 'tmin':
                zs = zonal_stats(townships, raster_path, stats=['min'], all_touched=True)

                stats = pd.DataFrame(zs)
                stats.rename(columns={'min':'tmin'}, inplace=True)
            else:
                zs = zonal_stats(townships, raster_path, stats=['mean'], all_touched=True)

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

        # Remove geometry
        subset = townships.drop(columns=['geom'])

        # Add year and month
        subset['year'] = year
        subset['month'] = month

        # Insert subset into main dataframe
        interpolated_data = pd.concat([interpolated_data, subset[interpolated_data.columns]], ignore_index=True)
        print(interpolated_data.tail(5))

interpolated_data.to_csv("interpolated_data.csv", index=False)

total_time = time.time() - start_time
print(f"Processing time: {total_time:.2f} seconds")