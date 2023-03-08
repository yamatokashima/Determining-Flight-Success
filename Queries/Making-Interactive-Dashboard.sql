-- First, I created a new table in SQL with the relevant columns --

CREATE TABLE routes AS(
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
)

-- I then imported the table into Tableau and joined it to the existing data. Both the origin longitude/latitude and the destination longitude/latitude had to be made into point which were done using the following calculated fields: --

MAKEPOINT([destination_latitude],[destination_longitude])
MAKEPOINT([origin_latitude],[origin_longitude])

-- once done, those points would need to be combined by the following calculated field to be made into routes: --

MAKELINE([Origin Airport Points], [Destination Airport Points])

-- The route would then be used in a COLLECT function using the map visual along with a generated longitude and dual axis latitude. Once done, I added a destination state, destination city, origin state, origin city, and airline filter that would apply to all items on the worksheet so that anytime anything on the map is interacted with, it would update all other items on the dashboard.