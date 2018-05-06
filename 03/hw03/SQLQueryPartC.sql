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

origin_city						dest_city				flight_time
-------------------------------------------------------------------
Aberdeen SD						Minneapolis MN			106
Abilene TX						Dallas/Fort Worth TX	111
Adak Island AK					Anchorage AK			165
Aguadilla PR					Newark NJ				272
Akron OH						Denver CO				224	
Albany GA						Atlanta GA				111
Albany NY						Las Vegas NV			360
Albuquerque NM					Baltimore MD			297
Alexandria LA					Atlanta GA				179
Allentown/Bethlehem/Easton PA	Atlanta GA				199
Alpena MI						Detroit MI				80
Amarillo TX						Houston TX				176
Anchorage AK					Houston TX				448
Appleton WI						Atlanta GA				180
Arcata/Eureka CA				San Francisco CA		136
Asheville NC					Newark NJ				189
Ashland WV						Cincinnati OH			84
Aspen CO						Chicago IL				183
Atlanta GA						Honolulu HI				649
Atlantic City NJ				Fort Lauderdale FL		212
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

origin_city				perc
-----------------------------
Guam TT					NULL
Pago Pago TT			NULL
Kahului HI				11.461455691338
Anchorage AK			12.473756138418
Honolulu HI				12.594462007603
Kona HI					18.441014509922
Lihue HI				18.686859393114
Fairbanks AK			20.276189597934
Aguadilla PR			22.121606545184
San Juan PR				24.361713784790
Charlotte Amalie VI		24.399445393867
Los Angeles CA			28.700926778549
San Francisco CA		29.175967503958
Ponce PR				34.297133069613
Long Beach CA			36.290376778655
Seattle WA				41.295529808589
New York NY				41.573484777186
Las Vegas NV			42.153430392938
San Diego CA			42.952546713022
Newark NJ				45.205656321717
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
