-- CSE 344, HW03 - PART B
-- Omar Adel AlSughayer, 1337255
-- Section AA

-- Problem B Ingesting Data

-- create table Carriers
CREATE TABLE Carriers
	(cid VARCHAR(10) PRIMARY KEY,
	name VARCHAR(64));

-- create table Months
CREATE TABLE Months
	(mid INTEGER PRIMARY KEY,
	month VARCHAR(16));

-- create table Weekdays
CREATE TABLE Weekdays
	(did INTEGER PRIMARY KEY,
	day_of_week VARCHAR(16));

-- create table Flights
CREATE TABLE Flights 
	(fid INTEGER PRIMARY KEY,
	year INTEGER,
	month_id INTEGER,
	day_of_month INTEGER,
	day_of_week_id INTEGER,
	carrier_id VARCHAR(10),
    flight_num INTEGER,
    origin_city VARCHAR(64),
    origin_state VARCHAR(64),
    dest_city VARCHAR(64),
    dest_state VARCHAR(64),
    departure_delay INTEGER,
    taxi_out INTEGER,
    arrival_delay INTEGER,
    canceled INTEGER,
    actual_time INTEGER,
    distance INTEGER,
    FOREIGN KEY (month_id) REFERENCES Months(mid),
    FOREIGN KEY (day_of_week_id) REFERENCES Weekdays(did),
    FOREIGN KEY (carrier_id) REFERENCES Carriers(cid));