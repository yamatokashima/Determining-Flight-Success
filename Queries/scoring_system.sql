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
	,NTILE(10) OVER (ORDER BY (CAST(COUNT(f.cancelled) FILTER (WHERE cancelled = 1) AS FLOAT) / COUNT(*)) * 100 DESC) 
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