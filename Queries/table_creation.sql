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