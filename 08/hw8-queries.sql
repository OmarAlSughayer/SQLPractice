-- CSE 344, HW08
-- Omar Adel AlSughayer, 1337255
-- Section AA

-- TASK ONE, RUNNING QUERIES

-- Query 1
-- What is the total number of RDF rows in the data?
%sql 
SELECT COUNT(*)
FROM fbFacts

/*
Answer to Query
563,980,447
*/

-- Query 2
-- What is the number of distinct predicates in the data?
%sql
SELECT COUNT(DISTINCT predicate)
FROM fbFacts

/*
Answer to Query
18,944
*/

-- Query 3
-- In the example described in assignment details, we showed
-- some tuples with the subject of mid /m/0284r5q. What are
-- all the tuples with the subject of mid /m/0284r5q?
%sql
SELECT *
FROM fbFacts
WHERE subject = '/m/0284r5q'

/*
Answer to Query
ubject		predicate						obj						context
--------------------------------------------------------------------------------------------------
/m/0284r5q	/type/object/key				/wikipedia/en_id		9,327,603
/m/0284r5q	/type/object/key				/wikipedia/en			Flyte_$0028chocolate_bar$0029
/m/0284r5q	/type/object/key				/wikipedia/en_title		Flyte_$0028chocolate_bar$0029
/m/0284r5q	/common/topic/article			/m/0284r5t	
/m/0284r5q	/type/object/type				/common/topic	
/m/0284r5q	/type/object/type				/food/candy_bar	
/m/0284r5q	/type/object/type				/business/brand	
/m/0284r5q	/type/object/type				/base/tagit/concept	
/m/0284r5q	/food/candy_bar/manufacturer	/m/01kh5q	
*/

-- Query 4
-- How many travel destinations does Freebase have? To do this, we'll
-- use the type /travel/travel_destination. In particular, we want to
-- find the number of subjects that have a /type/object/type predicate
-- with the object equal to /travel/travel_destination.
%sql 
SELECT COUNT(*)
FROM fbFacts
WHERE predicate = '/type/object/type'
AND obj = '/travel/travel_destination'

/*
Answer to Query
295
*/

-- Query 5
-- Building off the previous query, what 20 travel destination have the
-- most tourist attractions? Return the location name and count. Use 
-- the /travel/travel_destination/tourist_attractions predicate to find 
-- the tourist attractions for each destination. Use the /type/object/name 
-- predicate and /lang/en object to get the name of each location (the name 
-- will be the context of the tuple with predicate /type/object/name and object /lang/en). 
-- Sort your result by the number of tourist attractions from largest
-- to smallest and then on the destination name alphabetically and only return the top 20.
%sql
SELECT f1.context AS name, COUNT(f3.subject) AS num
FROM fbFacts f1, fbFacts f2, fbFacts f3
WHERE f2.predicate = '/type/object/type' -- all f2's are travel destinations
AND f2.obj = '/travel/travel_destination'
AND f2.subject = f1.subject -- all f1's are related to traveling destinations
AND f1.predicate = '/type/object/name' -- all f1's are travel destinations' names
AND f1.obj = '/lang/en'
AND f1.subject = f3.subject -- all f3's are related to trveling destinations
AND f3.predicate = '/travel/travel_destination/tourist_attractions'
GROUP BY f1.context
ORDER BY num DESC, name ASC 
LIMIT 20

/*
Answer to Query

name			num
--------------------
London			109
Norway			74
Finland			59
Burlington		41
Rome			40
Toronto			36
Beijing			32
Buenos Aires	28
San Francisco	26
Bangkok			20
Munich			19
Sierra Leone	19
Vienna			19
Montpelier		18
Athens			17
Atlanta			17
Tanzania		17
Berlin			16
Laos			16
Portland		15
*/

-- Query 6
-- Generate a histogram of the number of distinct predicates per subject. 
-- This is more than a count of the number of distinct predicates per subject. 
-- This is asking for computing a distribution of the number of distinct 
-- predicates. For your answer, put the query in hw8-queries.sql, but instead 
-- of copying the result as a comment, make a chart of your results in Zeppelin 
-- (the little icons below the query allow you to toggle output modes). Take a 
-- screenshot of a barchart of your histogram and submit it as
-- hw8-histogram.[pdf/jpg/png] The x-axis should show the number of distinct
-- predicates, and the y-axis should show the count of subjects with that number
-- of distinct predicates in the dataset. Don’t worry if the y-axis labels are cut off. 
%sql
SELECT c.num, COUNT(c.sub)
FROM    (SELECT subject AS sub, COUNT(DISTINCT predicate) AS num
        FROM fbFacts
        GROUP BY subject) c
GROUP BY c.num

/*
Answer to Query

_c0	num
-----------------
1,623	31
1,348	32
1,222	33
1,348	34
1,674	35
1,596	36
1,100	37
662	38
466	39
423	40
337	41
300	42
264	43
197	44
150	45
117	46
101	47
76	48
59	49
47	50
37	51
43	52
40	53
23	54
23	55
36	56
19	57
16	58
29	59
9	60
18	61
14	62
9	63
9	64
12	65
6	66
9	67
6	68
4	69
4	70
4	71
5	72
4	73
2	74
2	75
4	76
3	77
2	80
3	81
2	82
2	83
1	85
1	86
1	87
1	88
2	89
1	92
1	93
2	94
1	95
3	96
1	132
808,765	1
6,554,400	2
7,345,803	3
6,385,005	4
2,188,259	5
3,434,082	6
4,310,912	7
8,405,233	8
2,695,094	9
1,957,004	10
1,975,631	11
1,232,451	12
658,384	13
231,314	14
112,232	15
67,063	16
49,916	17
45,812	18
97,440	19
34,710	20
29,585	21
20,549	22
70,707	23
17,305	24
7,728	25
5,314	26
3,694	27
4,310	28
5,406	29
11,476	30

*/

-- TASK TWO MULTIPLE QUESTIONS

-- Question 01
-- Q: In the setup code, you ran the command:-
-- 		hadoop fs -put /data/freebase-datadump-quadruples.tsv /data/spark_data.tsv
-- to put data in HDFS for Spark to read. By default, Spark looks in HDFS for data, but
-- you can actually tell Spark to read files locally, rather than from HDFS. For this to work,
-- what additional preprocessing step would I need to take before even opening my
-- Zeppelin notebook to prepare the data?
-- A: d) Move the data into memory so it can be read by Spark.

-- Question 02
-- Q: How is Spark different from Hadoop MapReduce?
-- A: b) Spark writes intermediate results (after Map-Reduce phases) to memory while Hadoop writes to disk.

-- Question 03
-- Q: Which of the following is NOT a good use case of Map-Reduce?
-- A: b) Running a large number of transactions for a major bank.

-- Question 04
-- Q: In a simple Map-Reduce job with m mapper tasks and r reducer tasks, how many output files do you get?
-- A: c) r

-- Question 05
-- Q: One of the key features of Map-Reduce and Spark is their ability
-- to cope with server failure. For each statement below indicate whether it is true or false.
-- A: 	a) False
--		b) True
--		c) True
--		d) True