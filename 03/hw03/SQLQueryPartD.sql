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
With Index:		CPU time = 391 ms,  elapsed time = 2683 ms
Witout Index:	CPU time = 766 ms,  elapsed time = 2816 ms

C.2
With Index:		CPU time = 1375 ms,  elapsed time = 6971 ms
Witout Index:	CPU time = 1531 ms,  elapsed time = 6827 ms

C.3
With Index:		CPU time = 766 ms,  elapsed time = 2696 ms
Witout Index:	CPU time = 625 ms,  elapsed time = 3094 ms

C.4 
With Index:		CPU time = 500 ms,  elapsed time = 4530 ms
Witout Index:	CPU time = 828 ms,  elapsed time = 3351 ms

C.5
With Index:		CPU time = 6141 ms,  elapsed time = 52598 ms
Witout Index:	CPU time = 6812 ms,  elapsed time = 54836 ms
*/