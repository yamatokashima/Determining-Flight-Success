-- scoring for number of flights by airport --

SELECT
	origin_airport AS airport
	,flights_out_of
	,NTILE(20) OVER (ORDER BY flights_out_of ASC) as flight_out_of_score
	,flights_into
	,NTILE(20) OVER (ORDER BY flights_into ASC) as flights_into_score
FROM
	public.airport_cancellations
ORDER BY
	2 DESC

-- scoring for count of flights per airline --

SELECT 
	a.airline
	,COUNT(f.airline) AS count
	,ROUND((COUNT(f.airline)*100.0 / (SELECT COUNT(*) FROM flights)),2)||'%' AS percentage
	,NTILE(15) OVER (ORDER BY COUNT(f.airline) ASC)
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

-- scoring for cancellation rate by airline --

SELECT
	a.airline
	,COUNT(f.cancelled) FILTER (WHERE cancelled = 1) AS cancelled
	,COUNT(*) AS total
	,(CAST(COUNT(f.cancelled) FILTER (WHERE cancelled = 1) AS FLOAT) / COUNT(*)) * 100 AS cancellation_rate
	,NTILE(100) OVER (ORDER BY (CAST(COUNT(f.cancelled) FILTER (WHERE cancelled = 1) AS FLOAT) / COUNT(*)) * 100 DESC) 
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

-- scoring for airport cancels (fix NULLS to get 20 points) --

SELECT
	origin_airport
	,flights_out_of
	,canceled_out_of
	,cancellation_rate_out_of 
	,NTILE(20) OVER (ORDER BY cancellation_rate_out_of DESC) AS cancel_out_of_score
	,flights_into
	,canceled_into
	,cancellation_rate_into
	,NTILE(20) OVER (ORDER BY cancellation_rate_into DESC) AS cancel_into_score
FROM 
	airport_cancellations

-- on-time score by airline (within 15 minutes of scheduled arrival) --

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
	,ROUND(CAST(count_on_time AS DECIMAL)/CAST(total_count AS DECIMAL) * 100,2) AS on_time_percent
	,NTILE(100) OVER (ORDER BY ROUND(CAST(count_on_time AS DECIMAL)/CAST(total_count AS DECIMAL) * 100,2) ASC) AS on_time_score
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
	4 DESC

-- scoring for number of airlines per airport --

SELECT
	a.airport
	,COUNT(DISTINCT f.airline)
	,NTILE(10) OVER (ORDER BY COUNT(DISTINCT airline) ASC)
FROM	
	flights f
JOIN
	airports a
ON
	f.origin_airport = a.airport_code
GROUP BY
	1
ORDER BY
	3 DESC,2 DESC

-- scoring for number of airports origin airport flies to --

SELECT 
	a.airport
	,COUNT(DISTINCT destination_airport) AS num_destinations
	,NTILE(100) OVER (ORDER BY COUNT(DISTINCT destination_airport)) AS total_airports_score
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