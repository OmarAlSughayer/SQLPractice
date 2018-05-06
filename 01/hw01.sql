-- CSE 344, HW01
-- Omar Adel AlSughayer, 1337255
-- Section AA

-- Problem 01
-- create table Edges(Source, Destination)
CREATE TABLE Edges 
	(Source INTEGER,
	Destination INTEGER,
	PRIMARY KEY (Source, Destination));

-- fill talbe Edges
INSERT INTO Edges VALUES (10, 5);
INSERT INTO Edges VALUES (6, 25);
INSERT INTO Edges VALUES (1, 3);
INSERT INTO Edges VALUES (4, 4);

-- return all tuples
SELECT * FROM Edges;

-- return only column Source from the tuples
SELECT Source FROM Edges;

-- return tuples where Source > Destination
SELECT * FROM Edges WHERE Source > Destination;

-- try to insert ('-1', '2000') and explain why it does not work
INSERT INTO Edges VALUES ('-1', '2000');
/* this works and the insertion takes place despite the quotations. The reason for this
is, and I quote from the documentation, "A string might look like a floating-point literal
with a decimal point and/or exponent notation but as long as the value can be expressed
as an integer, the NUMERIC affinity will convert it into an integer. Hence, the
string '3.0e+5' is stored in a column with NUMERIC affinity as the integer 300000, not
 as the floating point value 300000.0." */
------------------------------------
-- Problem 02
-- Create a MyRestaurants table
CREATE TABLE MyRestaurants
	(name VARCHAR(64),
	food VARCHAR(32),
	distance INTEGER,
	lastVisit VARCHAR(10),
	iLike INTEGER,
	PRIMARY KEY (name));

------------------------------------
-- Problem 03
-- populate the table MyRestaurants
INSERT INTO MyRestaurants VALUES ('Shawrma King', 'Mediterranean', 13, '2016-09-23', 1); -- 01
INSERT INTO MyRestaurants VALUES ('Chipotle', 'Mexican', 10, '2016-02-01', 1); -- 02
INSERT INTO MyRestaurants VALUES ('Memos', 'Mexican', 20, '2016-07-05', 0); -- 03
INSERT INTO MyRestaurants VALUES ('Morsel', 'Biscuits', 20, '2016-10-01', 1); -- 04
INSERT INTO MyRestaurants VALUES ('Ming China Pestro', 'Chinese', 25, '2016-10-02', 1); -- 05
INSERT INTO MyRestaurants VALUES ('iHOP', 'Breakfast', 40, '2016-04-12', 0); -- 06
INSERT INTO MyRestaurants VALUES ('Cafe on the Ave', 'Sandwiches', 5, '2016-09-16', 0); -- 07
INSERT INTO MyRestaurants VALUES ('Ichiran', 'Ramen', 4621, '2016-08-23', 1); -- 08
INSERT INTO MyRestaurants VALUES ('Halal Beef Noodles', 'Xian Noodles', 5944, '2016-09-16', NULL); -- 09
INSERT INTO MyRestaurants VALUES ('Musashi', 'Japanese', 43, '2016-09-30', 1); -- 10


------------------------------------
-- Problem 04
-- output all restaurants with different formats

-- a) comma-seperated
.mode csv
-- without headers
.headers off
SELECT * FROM MyRestaurants;
-- with headers
.headers on
SELECT * FROM MyRestaurants;

-- b) list delimited by '|'
.mode list
.separator |
-- without headers
.headers off
SELECT * FROM MyRestaurants;
-- with headers
.headers on
SELECT * FROM MyRestaurants;

-- c) column form, with every column with width 15
.mode column
.width 15 15 15 15 15
-- without headers
.headers off
SELECT * FROM MyRestaurants;
-- with headers
.headers on
SELECT * FROM MyRestaurants;

-------------------------------------

-- restoring prefered formatting
.mode columns
.headers on
.width 15 15 8 10 5
SELECT * FROM MyRestaurants;

-------------------------------------

-- Problem 05
-- return restaurans names and distances that are within 20 minutes in alphabetacal order
SELECT name, distance
	FROM MyRestaurants
	WHERE distance <= 20
	ORDER BY name ASC; 

------------------------------------
-- Problem 06
-- return all restaurants I like but visited last no earler than three months ago
SELECT *
	FROM MyRestaurants
	WHERE date('now', '-3 month') >= date(lastVisit)
	AND iLike = 1;

------------------------------------
-- Problem 07
-- return all restaurants that are within 10 minutes
SELECT * 
	FROM MyRestaurants
	WHERE distance <= 10;

