DROP TABLE IF EXISTS 
    weather_daily,
	weather_monthly,
    stations,
    counties,
    dengue_cases,
    townships
CASCADE;

CREATE TABLE dengue_cases(
	id SERIAL PRIMARY KEY,
	date_onset DATE,
	date_confirmation DATE,
	date_notification DATE,
	sex TEXT,
	age_group TEXT,
	imported TEXT,
	country_infected TEXT,
	confirmed_cases INTEGER,
	serotype TEXT,
	township_living INTEGER,
	township_infected INTEGER
);
	
CREATE TABLE weather_daily(
	id SERIAL PRIMARY KEY,
	station TEXT NOT NULL,
	obs_date DATE NOT NULL,
	tavg FLOAT,
	tmax FLOAT,
	tmin FLOAT,
	tdp FLOAT,
	rel_humidity FLOAT,
	wind_speed FLOAT,
	precip FLOAT
);

CREATE TABLE weather_monthly(
	id SERIAL PRIMARY KEY,
	station TEXT NOT NULL,
	obs_date DATE NOT NULL,
	tavg FLOAT,
	tmax FLOAT,
	tmin FLOAT,
	tdp FLOAT,
	rel_humidity FLOAT,
	wind_speed FLOAT,
	precip FLOAT
);

CREATE TABLE counties(
	code INTEGER NOT NULL,
	id TEXT NOT NULL,
	name TEXT,
	orig_name TEXT,
	total_pop INTEGER,
	pop_density FLOAT,
	geom GEOMETRY NOT NULL
);
ALTER TABLE counties ADD PRIMARY KEY(code);
	
CREATE TABLE townships(
	code INTEGER NOT NULL,
	county INTEGER NOT NULL,
	id TEXT NOT NULL,
	name TEXT,
	orig_name TEXT,
	total_pop INTEGER,
	pop_density FLOAT,
	elevation FLOAT,
	main_climate TEXT,
	built_up_area FLOAT,
	geom GEOMETRY NOT NULL
);
ALTER TABLE townships ADD PRIMARY KEY(code);
	
CREATE TABLE stations(
	code TEXT NOT NULL,
	township INTEGER,
	name TEXT,
	orig_name TEXT,
	type TEXT,
	longitude FLOAT,
	latitude FLOAT,
	altitude FLOAT,
	data_start_date DATE,
	data_end_date DATE,
	geom GEOMETRY
);
ALTER TABLE stations ADD PRIMARY KEY(code);

ALTER TABLE townships ADD CONSTRAINT townships_county_foreign FOREIGN KEY(county) REFERENCES counties(code);

ALTER TABLE weather_daily ADD CONSTRAINT weather_daily_station_foreign FOREIGN KEY(station) REFERENCES stations(code);

ALTER TABLE weather_monthly ADD CONSTRAINT weather_monthly_station_foreign FOREIGN KEY(station) REFERENCES stations(code);

ALTER TABLE dengue_cases ADD CONSTRAINT dengue_cases_township_infected_foreign FOREIGN KEY(township_infected) REFERENCES townships(code);

ALTER TABLE dengue_cases ADD CONSTRAINT dengue_cases_township_living_foreign FOREIGN KEY(township_living) REFERENCES townships(code);

ALTER TABLE stations ADD CONSTRAINT stations_township_foreign FOREIGN KEY(township) REFERENCES townships(code);


