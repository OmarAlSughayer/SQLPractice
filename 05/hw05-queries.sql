-- CSE 344, HW05
-- Omar Adel AlSughayer, 1337255
-- Section AA

-- Question B.1 
-- Return all cities in Peru
-- Order by the city name
SELECT c.name
FROM mondial x 
UNNEST x.mondial.country y 
UNNEST y.province p
UNNEST p.city c
WHERE y.name = "Peru"
ORDER BY c.name;

-- Questoin B.2 
-- Return the name, total population, and number of religions in each country
-- Order by the name of the country
SELECT c.name, c.population, IFNULL(ARRAY_LENGTH(c.religions), 1) AS number_of_religions
FROM mondial x
UNNEST x.mondial.country c
ORDER BY c.name;

-- Questoin B.3 
-- Return the names of the countries with provinces, the number of provinces, and the number of cities
-- Order by the name of the contry
SELECT c.name, ARRAY_LENGTH(MAX(c.province)) AS province_count, SUM(IFNULL(ARRAY_LENGTH(p.city), 1)) AS city_count
FROM mondial x
UNNEST x.mondial.country c
UNNEST c.province p
WHERE ARRAY_LENGTH(c.province) IS NOT NULL
GROUP BY c.name
ORDER BY c.name;

-- Question B.4
-- Return all contries with 20 provinces or more
-- Order descending by the number of provinces, then ascending by the name of the contry
SELECT y.name, ARRAY_LENGTH(y.province) AS province_count
FROM mondial x
UNNEST x.mondial.country y
WHERE ARRAY_LENGTH(y.province) IS NOT NULL
AND ARRAY_LENGTH(y.province) >= 20
ORDER BY province_count DESC, y.name ASC;

-- Question B.5 
-- Return the name of all States within the USA, and the ratio of its population to its area
-- Order by descending ratio
SELECT p.name, TONUMBER(p.population)/TONUMBER(p.area) AS density
FROM mondial x 
UNNEST x.mondial.country y 
UNNEST y.province p
WHERE y.name = "United States"
ORDER BY density DESC;

-- Question B.6 
-- Return the names of countries with mountains in them and the total number of mountains
-- Order by the name of the country
SELECT c.name AS country_name, COUNT(m.name) AS mountain_count
FROM mondial x
UNNEST x.mondial.country c
UNNEST x.mondial.mountain m
WHERE c.["-car_code"] = m.["-country"]
GROUP BY c.name
ORDER BY c.name;

-- Question B.7
-- Return the names of all mountain whom height is > 2000m, their heights, and the country they are in
-- Order by the name of the country then the name of the mountain
SELECT c.name AS country_name, m.name AS mountain_name, m.height AS mountain_height
FROM mondial x
UNNEST x.mondial.country c
UNNEST x.mondial.mountain m
WHERE c.["-car_code"] = m.["-country"] 
AND TONUMBER(m.height) > 2000
ORDER BY c.name, m.name;

-- Question B.8
-- Return the names of all rivers that pass by two or more countries and these coutnries' names
-- Order by the name of the river then the name of the country
SELECT r.name AS river_name, c.name AS country_name
FROM mondial x
UNNEST x.mondial.country c
UNNEST x.mondial.river r
UNNEST r.located l
WHERE IFNULL(ARRAY_LENGTH(r.located), 1) >= 2
AND c.["-car_code"] = l.["-country"]
ORDER BY r.name, c.name;

-- Questoin B.9 
-- Do questoin B.7 Using NEST operator and without using ARRAY_AGG
