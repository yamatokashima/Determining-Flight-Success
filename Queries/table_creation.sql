-- airline table --

CREATE TABLE airlines (
	airline_code TEXT,
	airline TEXT
)

-- airport table --

CREATE TABLE airports (
	airport_code TEXT,
	airline TEXT,
	city TEXT,
	state TEXT,
	country TEXT,
	latitude DECIMAL,
	longitude DECIMAL
)

-- flight table --

CREATE TABLE flights (
	year INT,
	month INT,
	day	INT,
	day_of_week INT,
	airline TEXT,
	flight_number INT,
	tail_number	TEXT,
	origin_airport TEXT,
	destination_airport TEXT,
	scheduled_departure INT,
	departure_time INT,
	departure_delay INT,
	taxi_out INT,
	wheels_off INT,
	scheduled_time INT,
	elapsed_time INT,
	air_time INT,
	distance INT,
	wheels_on INT,
	taxi_in INT,
	scheduled_arrival INT,
	arrival_time INT,
	arrival_delay INT,
	diverted INT,
	cancelled INT,
	cancellation_reason	TEXT,
	air_system_delay INT,
	security_delay INT,
	airline_delay INT,
	late_aircraft_delay INT,
	weather_delay INT
)

-- canceled flight by airline table -

CREATE TABLE percent_canceled_flights AS (
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
)

-- routes taken by airline with duration and count --

SELECT
		a.airline
		,o.city AS origin_city
		,o.state AS origin_state
		,d.city AS destination_city
		,d.state AS destination_state
		,o.longitude AS origin_longitude
		,o.latitude AS origin_latitude
		,d.longitude AS destination_longitude
		,d.latitude AS destination_latitude
		,o.airport_code||' - '||d.airport_code AS route
		,COUNT(*) AS number_of_flights
		,ROUND(ROUND(AVG(elapsed_time),0)/60,0)||' hours, '||ROUND(ROUND(AVG(elapsed_time),0)%60,0)||' minutes' AS avg_duration
	FROM
		flights f
	JOIN
		airports o
	ON
		o.airport_code = f.origin_airport
	JOIN
		airports d
	ON
		d.airport_code = f.destination_airport
	JOIN
		airlines a
	ON
		a.airline_code = f.airline
	WHERE
		f.cancelled = 0
	GROUP BY
		1,2,3,4,5,6,7,8,9,10
	ORDER BY
		2,3,4,5