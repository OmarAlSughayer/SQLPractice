-- CSE 344, HW05
-- Omar Adel AlSughayer, 1337255
-- Section AA


-- Question 06

-- allowing foreign keys 
PRAGMA foreign_keys=ON;
-- setting the right separator for sqlite to look for
.separator "\t"

-- Problem 6.1

-- create table Sales
CREATE TABLE Sales
	(name VARCHAR(64),
	discount VARCHAR(64),
    month VARCHAR(10),
    price INTEGER,
    PRIMARY KEY(name, discount, month, price));
-- load data into the table Sales
.import mrFrumbleData.txt Sales

-- Problem 6.2 

-- The FDs found and the code to find them
-- month -> discount
SELECT s1.*
    FROM Sales s1, Sales s2
    WHERE s1.month = s2.month 
    AND s1.discount != s2.discount;
-- returns no rows which means that the FD (month -> discount) holds

-- name -> price
SELECT s1.*
    FROM Sales s1, Sales s2
    WHERE s1.name = s2.name 
    AND s1.price != s2.price;
-- returns no rows which means that the FD (name -> price) holds

-- the original relationship R(name, discount, month, price) = R(ndmp)
-- After decomposing into BCNF form we get R1(md), R2(np), R3(nm)

-- detailed decomposition
/*
R(ndmp)
 .check (m -> d)
 .compose into: R1(md), R2(nmp)
 .check (n -> p)
 .compose into: R1(md), R2(np), R3(nm)
*/

-- Problem 6.3
-- Create tables for normalized relations from part 6.2
CREATE TABLE MD
    (month VARCHAR(10) PRIMARY KEY,
    discount VARCHAR(64));

CREATE TABLE NP
    (name VARCHAR(64) PRIMARY KEY,
    price INTEGER);

CREATE TABLE NM 
    (name VARCHAR(64),
    month VARCHAR(10),
    FOREIGN KEY (name) REFERENCES NP(name),
    FOREIGN KEY (month) REFERENCES MD(month));

-- Problem 6.4
-- populate tables from 6.3 with data from table from 6.1

-- populate MD
INSERT INTO MD SELECT DISTINCT month, discount FROM Sales;
-- the size of table MD is 12

-- populate NP
INSERT INTO NP SELECT DISTINCT name, price FROM Sales;
-- the size of table NP is 36

-- populate NM
INSERT INTO NM SELECT name, month FROM Sales;
-- the size of table NM is 426

