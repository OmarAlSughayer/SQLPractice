-- CSE 344, HW03 - Extra credit
-- Omar Adel AlSughayer, 1337255
-- Section AA

-- Create a new Flight Table to injest the larger data set into it

CREATE TABLE Flights_Large 
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
