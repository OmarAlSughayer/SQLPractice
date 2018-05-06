-- CSE 344, HW02
-- Omar Adel AlSughayer, 1337255
-- Section AA

-- Setup before any problem

-- load the database created from part A
.open hw02.db

-- Problem B

-- Part 01
-- List the distinct flight numbers of all
-- flights from Seattle to Boston by Alaska Airlines Inc. on mondays
SELECT flight_num
	FROM Flights f, Carriers c, Weekdays w
	WHERE f.carrier_id = c.cid
	AND c.name = "Alaska Airlines Inc."
	AND f.origin_city = "Seattle WA"
	AND f.dest_city = "Boston MA"
	AND f.day_of_week_id = w.did 
	AND w.day_of_week = "Monday"
	GROUP BY flight_num;

/* 
the returned answer is:

flight_num
----------
12
24
734
*/

-- Part 02
-- list the name of the carrier, the first and second flight number,
-- their origin, destination, flight time, and the total flight time.
-- of all flights from Seattle to Boston on July 15th 2015, has only one stop,
-- both legs (flights) occured on the same day with the same carrier, and with
-- total time < 7 hours. 

SELECT c.name,f1.flight_num, f1.origin_city, f1.dest_city, f1.actual_time,
		f2.flight_num, f2.origin_city, f2.dest_city, f2.actual_time,
		(f1.actual_time + f2.actual_time) as total
	
	FROM Flights f1, Flights f2, Carriers c, Months m 
	Where f1.year = f2.year AND f1.month_id = f2.month_id AND f1.day_of_week_id = f2.day_of_week_id
	AND f1.carrier_id = f2.carrier_id -- same carrier
	AND total/60 < 7 -- total time less than 7 hours
	AND f1.year = f2.year  -- flight on the 15th of a month in 2015
	AND f1.day_of_month = f2.day_of_month
	AND f1.month_id = f2.month_id
	AND f1.year = 2015  AND f1.day_of_month = 15
	AND f1.month_id = m.mid AND m.month = "July"
	AND f1.origin_city = "Seattle WA" AND f2.dest_city = "Boston MA" -- from Seattle to Boston
	AND f1.dest_city = f2.origin_city
	GROUP BY f1.flight_num, f2.flight_num
	LIMIT 20;


/* 
the first 20 lines of the returned answer is:

 name                  flight_num  origin_city  dest_city   actual_time  flight_num  origin_city  dest_city   actual_time  total
 --------------------  ----------  -----------  ----------  -----------  ----------  -----------  ----------  -----------  ----------
 Skyway Aviation Inc.  42          Seattle WA   Chicago IL  228          26          Chicago IL   Boston MA   150          378
 Skyway Aviation Inc.  42          Seattle WA   Chicago IL  228          186         Chicago IL   Boston MA   137          365
 Skyway Aviation Inc.  42          Seattle WA   Chicago IL  228          288         Chicago IL   Boston MA   137          365
 Skyway Aviation Inc.  42          Seattle WA   Chicago IL  228          366         Chicago IL   Boston MA   150          378
 Skyway Aviation Inc.  42          Seattle WA   Chicago IL  228          1205        Chicago IL   Boston MA   128          356
 Skyway Aviation Inc.  42          Seattle WA   Chicago IL  228          1240        Chicago IL   Boston MA   130          358
 Skyway Aviation Inc.  42          Seattle WA   Chicago IL  228          1299        Chicago IL   Boston MA   133          361
 Skyway Aviation Inc.  42          Seattle WA   Chicago IL  228          1435        Chicago IL   Boston MA   133          361
 Skyway Aviation Inc.  42          Seattle WA   Chicago IL  228          1557        Chicago IL   Boston MA   122          350
 Skyway Aviation Inc.  42          Seattle WA   Chicago IL  228          2503        Chicago IL   Boston MA   127          355
 Skyway Aviation Inc.  44          Seattle WA   New York N  322          84          New York NY  Boston MA   74           396
 Skyway Aviation Inc.  44          Seattle WA   New York N  322          199         New York NY  Boston MA   80           402
 Skyway Aviation Inc.  44          Seattle WA   New York N  322          235         New York NY  Boston MA   91           413
 Skyway Aviation Inc.  44          Seattle WA   New York N  322          1443        New York NY  Boston MA   80           402
 Skyway Aviation Inc.  44          Seattle WA   New York N  322          2118        New York NY  Boston MA                322
 Skyway Aviation Inc.  44          Seattle WA   New York N  322          2121        New York NY  Boston MA   74           396
 Skyway Aviation Inc.  44          Seattle WA   New York N  322          2122        New York NY  Boston MA   65           387
 Skyway Aviation Inc.  44          Seattle WA   New York N  322          2126        New York NY  Boston MA   60           382
 Skyway Aviation Inc.  44          Seattle WA   New York N  322          2128        New York NY  Boston MA   83           405
 Skyway Aviation Inc.  44          Seattle WA   New York N  322          2131        New York NY  Boston MA   70           392
*/

-- Part 03
-- find the day of the week with the longest average arrival delay
SELECT w.day_of_week, AVG(f.arrival_delay) AS average
	FROM Flights f, Weekdays w
	WHERE w.did = f.day_of_week_id
	GROUP BY w.day_of_week
	ORDER BY average DESC
	LIMIT 1;

/*
 The answer returned is:
 day_of_week  average
 -----------  ----------------
 Wednesday    13.0125428064529
*/

-- Part 04
-- find the names of all airlines that ever flew over 1000 flights in one day
SELECT DISTINCT c.name
	FROM Carriers c, Flights f
	WHERE c.cid = f.carrier_id
	GROUP BY f.carrier_id, f.day_of_month, f.month_id, f.year
	HAVING COUNT(f.fid) > 1000;


/*
The Answer returned is:

name
----------------------
American Airlines Inc.
Delta Air Lines Inc.
ExpressJet Airlines Inc.
Envoy Air
Northwest Airlines Inc
Comair Inc.
SkyWest Airlines Inc.
United Air Lines Inc.
US Airways Inc.
Southwest Airlines Co.
ExpressJet Airlines Inc. (1)

*/

-- Part 05
-- Find the names of the airlines who had more than 0.5% of their flights from
-- Seattle be canceled and arrange them in ascending order of failure
SELECT c.name, 100.0*COUNT(CASE WHEN f.canceled THEN 1 END)/COUNT(f.fid) as percent
	FROM Flights f INNER JOIN Carriers c
	ON f.carrier_id = c.cid
	WHERE f.origin_city = "Seattle WA"
	GROUP BY f.carrier_id
	HAVING percent > 0.5
	ORDER BY percent ASC;

/*
The answer returned is:

name                   percent
---------------------  -----------------
SkyWest Airlines Inc.  0.728291316526611
Frontier Airlines Inc  0.840336134453782
United Air Lines Inc.  0.983767830791933
JetBlue Airways        1.00250626566416
Northwest Airlines In  1.4336917562724
ExpressJet Airlines I  3.2258064516129
*/

