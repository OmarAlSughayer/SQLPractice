-- CSE 344, HW06
-- Omar Adel AlSughayer, 1337255
-- Section AA


-- Problem 2.1

-- create table InsuranceCo
CREATE TABLE InsuranceCo
	(insName VARCHAR(64) PRIMARY KEY,
	phone VARCHAR(10));

-- create table Vehicle
CREATE TABLE Vehicle
    (licencePlate VARCHAR(64) PRIMARY KEY,
    year INTEGER,
    maxLiability INTEGER,
    maxLossDamage INTEGER,
    insName VARCHAR(64),
    ownerSSN INTEGER, 
    FOREIGN KEY (insName) REFERENCES InsuranceCo(insName),
    FOREIGN KEY (ownerSSN) REFERENCES Person(ssn));

-- create table Person 
CREATE TABLE Person
    (ssn INTEGER PRIMARY KEY,
    name VARCHAR(64));

-- create Table Driver
CREATE TABLE Driver
    (licenceNo VARCHAR(64) PRIMARY KEY,
    driverSSN INTEGER,
    professional BOOLEAN,
    medicalHistory VARCHAR(64),
    FOREIGN KEY (driverSSN) REFERENCES Person(ssn));

-- create table Truck
CREATE TABLE Truck 
    (licencePlate VARCHAR(64) PRIMARY KEY,
    capacity INTEGER,
    operatorLicenceNo VARCHAR(64),
    FOREIGN KEY (licencePlate) REFERENCES Vehicle(licencePlate),
    FOREIGN KEY (operatorLicenceNo) REFERENCES Driver(licenceNo));

-- create table Car 
CREATE TABLE Car
    (licencePlate VARCHAR(64) PRIMARY KEY,
    make VARCHAR(64),
    FOREIGN KEY (licencePlate) REFERENCES Vehicle(licencePlate));


-- create table Drives
CREATE TABLE Drives
    (driverLicenceNo VARCHAR(64),
    carLicencePlate VARCHAR(64),
    PRIMARY KEY(driverLicenceNo, carLicencePlate),
    FOREIGN KEY (driverLicenceNo) REaFERENCES Driver(licenceNo),
    FOREIGN KEY (carLicencePlate) REFERENCES Vehicle(licencePlate));

-- Problem 2.2

/*
The relationship "insures" is represented as fields and a foreign key in the table Vehicle
because no separate relations (tables) are neededfor many-one relationship
*/

-- Problem 2.3

/*
"operates" is represented as a foreign key field in the Truck table, because every truck has
exactly one driver and only that driver. While "drives" is represented as its own table
since it has a many-many relationship with drivers, i.e. every car can have many drivers and
every driver can drive many cars.
*/