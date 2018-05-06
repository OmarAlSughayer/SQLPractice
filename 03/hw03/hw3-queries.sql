-- CSE 344, HW03 - PART B
-- Omar Adel AlSughayer, 1337255
-- Section AA

-- Queries B for Creating Tables

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


----------------------------------------------------------------------------

-- CSE 344, HW03 - PART C
-- Omar Adel AlSughayer, 1337255
-- Section AA

-- Query C.1
-- For each origin city find the destination city with the longest direct flight
SELECT all_flights.origin_city, all_flights.dest_city, MAX(all_flights.actual_time) as flight_time
FROM Flights all_flights, (SELECT origin_city, MAX(actual_time) as longest
                    FROM Flights
                    GROUP BY origin_city) AS max_flights
WHERE all_flights.origin_city = max_flights.origin_city 
        AND all_flights.actual_time = max_flights.longest
GROUP BY all_flights.origin_city, all_flights.dest_city
ORDER BY all_flights.origin_city, all_flights.dest_city;

/*
First 20 rows of the returned answer: 

origin_city                     dest_city               flight_time
-------------------------------------------------------------------
Aberdeen SD                     Minneapolis MN          106
Abilene TX                      Dallas/Fort Worth TX    111
Adak Island AK                  Anchorage AK            165
Aguadilla PR                    Newark NJ               272
Akron OH                        Denver CO               224 
Albany GA                       Atlanta GA              111
Albany NY                       Las Vegas NV            360
Albuquerque NM                  Baltimore MD            297
Alexandria LA                   Atlanta GA              179
Allentown/Bethlehem/Easton PA   Atlanta GA              199
Alpena MI                       Detroit MI              80
Amarillo TX                     Houston TX              176
Anchorage AK                    Houston TX              448
Appleton WI                     Atlanta GA              180
Arcata/Eureka CA                San Francisco CA        136
Asheville NC                    Newark NJ               189
Ashland WV                      Cincinnati OH           84
Aspen CO                        Chicago IL              183
Atlanta GA                      Honolulu HI             649
Atlantic City NJ                Fort Lauderdale FL      212
*/

-- Query C.2
-- Find all origin cities that only serve flights that are shorter than 3 hours
SELECT DISTINCT f1.origin_city
FROM Flights f1
Where f1.origin_city NOT IN (SELECT f2.origin_city
                                FROM Flights f2
                                WHERE f2.actual_time/60 >= 3)
ORDER BY f1.origin_city;

/*
First 20 rows of the returned answer:

origin_city
-----------------
Aberdeen SD
Abilene TX
Adak Island AK
Albany GA
Alexandria LA
Alpena MI
Amarillo TX
Arcata/Eureka CA
Ashland WV
Augusta GA
Barrow AK
Beaumont/Port Arthur TX
Bemidji MN
Bethel AK
Binghamton NY
Bloomington/Normal IL
Brainerd MN
Bristol/Johnson City/Kingsport TN
Brownsville TX
Brunswick GA
Butte MT
*/

-- Query C.3
-- For each city, find the percentage of flights that are < 3 hours
SELECT all_f.origin_city, 100.0*(SELECT SUM(less_f.actual_time)
                            FROM Flights less_f
                            WHERE all_f.origin_city = less_f.origin_city
                            AND less_f.actual_time/60 < 3)/SUM(all_f.actual_time) as perc
FROM Flights all_f
GROUP BY all_f.origin_city
ORDER BY perc;

/*
First 20 rows of the returned answer:

origin_city             perc
-----------------------------
Guam TT                 NULL
Pago Pago TT            NULL
Kahului HI              11.461455691338
Anchorage AK            12.473756138418
Honolulu HI             12.594462007603
Kona HI                 18.441014509922
Lihue HI                18.686859393114
Fairbanks AK            20.276189597934
Aguadilla PR            22.121606545184
San Juan PR             24.361713784790
Charlotte Amalie VI     24.399445393867
Los Angeles CA          28.700926778549
San Francisco CA        29.175967503958
Ponce PR                34.297133069613
Long Beach CA           36.290376778655
Seattle WA              41.295529808589
New York NY             41.573484777186
Las Vegas NV            42.153430392938
San Diego CA            42.952546713022
Newark NJ               45.205656321717
*/


-- Query C.4
-- List all cities that cannot be reached from Seattle with a direct flight, but
-- can be reached with one city inbetween (i.e. two flights)
SELECT f2.dest_city
FROM Flights f1, Flights f2
WHERE f1.origin_city = 'Seattle WA' AND f1.dest_city = f2.origin_city
    AND f2.dest_city != 'Seattle WA'
    AND f2.dest_city NOT IN (SELECT f3.dest_city
                                FROM Flights f3
                                WHERE f3.origin_city = 'Seattle WA')
GROUP BY f2.dest_city
ORDER BY f2.dest_city;

/*
First 20 rows of the returned answer:

dest_city
-----------------
Aberdeen SD
Abilene TX
Adak Island AK
Aguadilla PR
Akron OH
Albany GA
Albany NY
Alexandria LA
Allentown/Bethlehem/Easton PA
Alpena MI
Amarillo TX
Appleton WI
Arcata/Eureka CA
Asheville NC
Ashland WV
Aspen CO
Atlantic City NJ
Augusta GA
Bakersfield CA
Bangor ME
*/

-- Query C.5
-- List all cities that cannot be reached from Seattle in one nor two trips
SELECT f1.origin_city
FROM Flights f1
WHERE f1.origin_city NOT IN (SELECT oneTrip.dest_city
                                FROM Flights oneTrip
                                WHERE oneTrip.origin_city = 'Seattle WA')
AND f1.origin_city NOT IN (SELECT twoTrips2.dest_city
                            FROM Flights twoTrips1, Flights twoTrips2
                            WHERE twoTrips1.origin_city = 'Seattle WA'
                            AND twoTrips1.dest_city = twoTrips2.origin_city
                            GROUP BY twoTrips2.dest_city)
GROUP BY f1.origin_city
ORDER BY f1.origin_city;

/*
The returned rows of the answer:

origin_city
----------------------
Devils Lake ND
Hattiesburg/Laurel MS
St. Augustine FL
Victoria TX

We can replace all instances of f1.origin_city with f1.dest_city in the previous query, which
will give a slightly different answer:

dest_city
-----------------------
Devils Lake ND
Hattiesburg/Laurel MS
St. Augustine FL

This is because "Victoria TX" is never listed as a destination city, hence some flights leave 
from there although no flights arrive there. The Reverse Bermuda of airports! Pretty strange but this 
is the way this database is structured so who am I to judge? But really, do they make the airplanes
there and send them off?
*/ 

----------------------------------------------------------------------------

-- CSE 344, HW03 - PART D
-- Omar Adel AlSughayer, 1337255
-- Section AA

-- Query D1.1
SELECT DISTINCT carrier_id
FROM Flights
WHERE origin_city = 'Seattle' AND actual_time <= 180;

-- Query D1.2
SELECT DISTINCT carrier_id
FROM Flights
WHERE origin_city = 'Gunnison CO' AND actual_time <= 180;

-- Query D1.3 
SELECT DISTINCT carrier_id
FROM Flights
WHERE origin_city = 'Seattle WA' AND actual_time <= 30;

-- Answer D2.1
-- Code to create the index
CREATE INDEX origin_city
ON Flights (origin_city);
-- code to drop the index after using it 
/*DROP INDEX origin_city
ON Flights;*/

/*
origin_city makes a good index to index on with the previous three queries because
the main clause in the search the origin city, meaning that if we indexed on carriers_id
then we will have to check the values that each index points to since it might have a row
we want, and similarly with actual_time as an index. While when we use origin_city as an
index we only need to check the values that the wanted city index points at, and ignore other
indecies.
*/

-- Answer D2.2
/*
Our creates index is used in query D1.2 but not in D1.1 nor in D1.3, this is because 
the city of Seattle has a significantly larger number of rows than Gunnison. Our creaed 
index, though, is unclustered, which means that accessing all the data rows of Seattle 
requires lots of reads over the memory, while Gunnison doesn't. Trying to avoid doing 
non-sequintal read into the memory, the compiler for SQL chooses to use the build-in clustered
index to search for rows that belong to Seattle. Similar results can be obtained when searching
for any other city with a large number of flights, like Boston MA, vs a city with a small number
of flights, like Victoria TX.
*/

-- Query D3
SELECT DISTINCT F2.origin_city
FROM Flights F1, Flights F2
WHERE F1.dest_city = F2.dest_city
    AND F1.origin_city = 'Gunnison CO'
    AND F1.actual_time <= 30;

-- Answer D4
-- Code to add the index 
CREATE INDEX flight_time
ON Flights (actual_time);
-- Code to drop the index 
/*DROP INDEX dest_city
ON Flights*/
/*
actual_time makes a good index to index on, especially with the previous query, because 
using B+Trees to divide the time of the flight should make finding flights with time greater 
than or smaller than a specific number a O(logn) task. 
*/

-- Answer D5
/*
SQL Azure does indeed uses the new added index, flight_time, created over actual_time
*/

-- Answer D6
/*
We run each query from C again and see how they perform with and without adding an index:

C.1
With Index:     CPU time = 391 ms,  elapsed time = 2683 ms
Witout Index:   CPU time = 766 ms,  elapsed time = 2816 ms

C.2
With Index:     CPU time = 1375 ms,  elapsed time = 6971 ms
Witout Index:   CPU time = 1531 ms,  elapsed time = 6827 ms

C.3
With Index:     CPU time = 766 ms,  elapsed time = 2696 ms
Witout Index:   CPU time = 625 ms,  elapsed time = 3094 ms

C.4 
With Index:     CPU time = 500 ms,  elapsed time = 4530 ms
Witout Index:   CPU time = 828 ms,  elapsed time = 3351 ms

C.5
With Index:     CPU time = 6141 ms,  elapsed time = 52598 ms
Witout Index:   CPU time = 6812 ms,  elapsed time = 54836 ms
*/
----------------------------------------------------------------------------

-- CSE 344, HW03 - PART E
-- Omar Adel AlSughayer, 1337255
-- Section AA

-- Answer E
/*
My experience with using this DBMS cloud service was initially a painful one, since 
setting up the environment and figuring out all the configurations issues took quite 
some time off my plate. However, eventually it pays off, since having a DBMS server allows 
you to access it from anywhere (home machine or the labs' machines) as well as providing extra
computing powers. 
*/
----------------------------------------------------------------------------
