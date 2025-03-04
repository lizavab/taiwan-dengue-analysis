DROP TABLE IF EXISTS 
    weather_reports,
    stations,
    counties,
    dengue_cases,
    townships
CASCADE;

CREATE TABLE dengue_cases(
	id INTEGER NOT NULL,
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

ALTER TABLE
	dengue_cases ADD PRIMARY KEY(id);
	
CREATE TABLE weather_reports(
	id SERIAL PRIMARY KEY,
	station TEXT NOT NULL,
	obs_date DATE NOT NULL,
	temp FLOAT,
	temp_max FLOAT,
	temp_min FLOAT,
	temp_dp FLOAT,
	rel_humidity FLOAT,
	wind_speed FLOAT,
	wind_dir FLOAT,
	precp FLOAT
);

CREATE TABLE counties(
	code INTEGER NOT NULL,
	id TEXT NOT NULL,
	name TEXT,
	orig_name TEXT,
	total_pop INTEGER,
	geom GEOMETRY NOT NULL
);

ALTER TABLE
	counties ADD PRIMARY KEY(code);
	
CREATE TABLE townships(
	code INTEGER NOT NULL,
	county INTEGER NOT NULL,
	id TEXT NOT NULL,
	name TEXT,
	orig_name TEXT,
	total_pop INTEGER,
	geom GEOMETRY NOT NULL
);

ALTER TABLE
	townships ADD PRIMARY KEY(code);
	
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
ALTER TABLE
	stations ADD PRIMARY KEY(code);

ALTER TABLE townships ADD CONSTRAINT townships_county_foreign FOREIGN KEY(county) REFERENCES counties(code);

ALTER TABLE weather_reports ADD CONSTRAINT weather_reports_station_foreign FOREIGN KEY(station) REFERENCES stations(code);

ALTER TABLE dengue_cases ADD CONSTRAINT dengue_cases_township_infected_foreign FOREIGN KEY(township_infected) REFERENCES townships(code);

ALTER TABLE dengue_cases ADD CONSTRAINT dengue_cases_township_living_foreign FOREIGN KEY(township_living) REFERENCES townships(code);

ALTER TABLE stations ADD CONSTRAINT stations_township_foreign FOREIGN KEY(township) REFERENCES townships(code);


