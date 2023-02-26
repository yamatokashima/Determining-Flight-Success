-- seeing count of flights per airline --

SELECT 
	a.airline
	,COUNT(f.airline) AS count
	,ROUND((COUNT(f.airline)*100.0 / (SELECT COUNT(*) FROM flights)),2)||'%' AS percentage
FROM 
	flights f
JOIN
	airlines a
ON
	f.airline = a.airline_code
GROUP BY 
	1
ORDER BY
	2 DESC

-- most common flight route --

SELECT
    a.airport AS origin_airport,
    aa.airport AS destination_airport,
    COUNT(*) AS total_flights
FROM
    flights f
JOIN
    airports a
ON
    a.airport_code = f.origin_airport
JOIN
    airports aa
ON
    aa.airport_code = f.destination_airport
GROUP BY
    1,2
ORDER BY
	3 DESC

-- most common flight routes with percent canceled --

SELECT
    a.airport AS origin_airport
    ,aa.airport AS destination_airport
	,COUNT(*) FILTER (WHERE cancelled = 1) AS cancelled_flights
	,COUNT(*) AS total_flights
	,ROUND(CAST(COUNT(*) FILTER (WHERE cancelled = 1) AS DECIMAL) / COUNT(*),4) * 100 || '%' AS percent_canceled
FROM
    flights f
JOIN
    airports a
ON
    a.airport_code = f.origin_airport
JOIN
    airports aa
ON
    aa.airport_code = f.destination_airport
GROUP BY
    1,2
HAVING
	COUNT(*) FILTER (WHERE cancelled = 1) < COUNT(*)
	AND COUNT(*) >= 100
ORDER BY
	5 DESC

-- total number of flights by airport --

SELECT
	a.airport
	,COUNT(f.*)
FROM
	flights f
JOIN
	airports a
ON
	a.airport_code = f.origin_airport
GROUP BY
	1
ORDER BY
	2 DESC

-- finding count of canceled flights by airline --

SELECT
	a.airline,
	COUNT(f.scheduled_time) FILTER (WHERE cancelled = 1)
FROM 
	flights f
JOIN
	airlines a
ON
	f.airline = a.airline_code
GROUP BY 
	1
ORDER BY
	2 DESC

-- finding count of flights within 15 minutes of scheduled arrival --

WITH t1 AS (
	SELECT 
		airline
		,count(airline) AS "count_on_time"
	FROM 
		flights
	WHERE
		scheduled_arrival - arrival_time <= 15
	GROUP BY
		1
),
t2 AS (
SELECT 
	airline
	,COUNT(airline) AS "total_count"
FROM 
	flights
GROUP BY
	1
)
SELECT 
	a.airline
	,t1.count_on_time
	,t2.total_count
FROM
	t1
JOIN
	t2
USING
	(airline)
JOIN
	airlines a
ON
	t1.airline = a.airline_code
ORDER BY 
	2

-- finding count of flights out of 15 minutes of scheduled arrival --

WITH t1 AS (
	SELECT 
		airline
		,count(airline) AS "count_on_time"
	FROM 
		flights
	WHERE
		scheduled_arrival - arrival_time > 15
	GROUP BY
		1
),
t2 AS (
	SELECT 
		airline
		,count(airline) AS "total_count"
	FROM 
		flights
	GROUP BY
		1
)
SELECT 
	a.airline
	,t1.count_on_time
	,t2.total_count
FROM
	t1
JOIN
	t2
USING
	(airline)
JOIN
	airlines a
ON
	t1.airline = a.airline_code
ORDER BY 
	2

-- checking average time of arrival compared to scheduled arrival --

SELECT
	a.airline
	,AVG(f.scheduled_arrival - f.arrival_time)
FROM
	flights f
JOIN
	airlines a
ON
	f.airline = a.airline_code
GROUP BY
	1
ORDER BY
	2 DESC

-- checking average time of departure compared to scheduled departure --

SELECT
	a.airline
	,AVG(f.scheduled_departure - f.departure_time)
FROM
	flights f
JOIN
	airlines a
ON
	f.airline = a.airline_code
GROUP BY
	1
ORDER BY
	2 DESC

-- percent of cancelled flights compared to total --

SELECT
	a.airline
	,COUNT(f.cancelled) FILTER (WHERE cancelled = 1) AS cancelled
	,COUNT(*) AS total
	,(CAST(COUNT(f.cancelled) FILTER (WHERE cancelled = 1) AS FLOAT) / COUNT(*)) * 100 AS cancellation_rate
FROM
	flights f
JOIN
	airlines a
ON
	f.airline = a.airline_code
GROUP BY
	1
ORDER BY
	4 DESC

-- most canceled by destination airport due to airline with at least 1000 flights --

WITH t1 AS(
	SELECT
		f.destination_airport
		,CAST(COUNT(cancelled) AS DECIMAL) canceled_flights
	FROM
		flights f
	JOIN
		airports a
	ON
		f.destination_airport = a.airport_code
	WHERE
		cancelled = 1
		AND cancellation_reason like 'A'
	GROUP BY
		1
	ORDER BY
		2 DESC
),
t2 as(
	SELECT
		f.destination_airport
		,CAST(COUNT(*) AS DECIMAL) total_flights
	FROM
		flights f
	JOIN
		airports a
	ON
		f.destination_airport = a.airport_code
	GROUP BY
		1
	ORDER BY
		2 DESC
)
SELECT
	t1.*
	,t2.total_flights
	,ROUND(canceled_flights / total_flights * 100,2) || '%' as percent_canceled
FROM
	t1
JOIN
	t2
USING
	(destination_airport)
WHERE
	total_flights > 1000
GROUP BY
	destination_airport, canceled_flights, total_flights
ORDER BY
	4 DESC

-- most canceled by origin airport due to airline with at least 1000 flights --

WITH t1 AS(
	SELECT
		a.airport as origin_airport
		,CAST(COUNT(cancelled) AS DECIMAL) canceled_flights_origin
	FROM
		flights f
	JOIN
		airports a
	ON
		f.origin_airport = a.airport_code
	WHERE
		cancelled = 1
		AND cancellation_reason like 'A'
	GROUP BY
		1
	ORDER BY
		2 DESC
),
t2 as(
	SELECT
		a.airport as origin_airport
		,CAST(COUNT(*) AS DECIMAL) total_flights_origin
	FROM
		flights f
	JOIN
		airports a
	ON
		f.origin_airport = a.airport_code
	GROUP BY
		1
	ORDER BY
		2 DESC
)
SELECT
	t1.*
	,t2.total_flights_origin
	,ROUND(canceled_flights_origin / total_flights_origin * 100,2) || '%' as percent_canceled_origin
FROM
	t1
JOIN
	t2
USING
	(origin_airport)
WHERE
	total_flights_origin > 1000
GROUP BY
	origin_airport, canceled_flights_origin, total_flights_origin
ORDER BY
	4 DESC

-- 