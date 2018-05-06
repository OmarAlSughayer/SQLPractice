-- CSE 344, HW07
-- Omar Adel AlSughayer, 1337255
-- Section AA

-- Task 1
-- create table costumer
CREATE TABLE Customers
	(cid INTEGER PRIMARY KEY,
	login Varchar(64),
	lname Varchar(64),
	fname Varchar(64),
	zip INTEGER,
	pass Varchar(64));

-- fill table costumer
INSERT INTO Customers VALUES (1, 'Jay', 'Jay', 'Jack', 1234, 'Jay1234'); -- 01
INSERT INTO Customers VALUES (2, 'May', 'May', 'Mari', 3210, 'May1234'); -- 02
INSERT INTO Customers VALUES (3, 'Day', 'Day', 'Donald', 0000, 'Day1234'); -- 03
INSERT INTO Customers VALUES (4, 'Bay', 'Bay', 'Black', 1111, 'Bay1234'); -- 04
INSERT INTO Customers VALUES (5, 'Fay', 'Fay', 'Fiona', 6548, 'Fay1234'); -- 05
INSERT INTO Customers VALUES (6, 'Hay', 'Hay', 'Hannah', 1234, 'Jay1234'); -- 06
INSERT INTO Customers VALUES (7, 'Kay', 'Kay', 'Kim', 0123, 'Kay1234'); -- 07
INSERT INTO Customers VALUES (8, 'Nay', 'Nay', 'Nick', 9999, 'Nay1234'); -- 08

-- create table reservations
CREATE TABLE Reservations
	(rid INTEGER PRIMARY KEY,
	cid INTEGER,
	fid INTEGER,
	year INTEGER,
	month_id INTEGER,
	day_of_month INTEGER,
	FOREIGN KEY (cid) REFERENCES Customers(cid),
	FOREIGN KEY (fid) REFERENCES Flights(fid));

INSERT INTO Reservations VALUES (566, 1, 798539, 2015, 7, 20); -- 01
INSERT INTO Reservations VALUES (577, 2, 798539, 2015, 7, 20); -- 02
INSERT INTO Reservations VALUES (588, 3, 798539, 2015, 7, 20); -- 03
INSERT INTO Reservations VALUES (599, 4, 300821, 2005, 7, 14); -- 04
