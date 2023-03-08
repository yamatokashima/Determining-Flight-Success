# Determining Flight Success
## Developed a success rate system using SQL, Python, Tableau, and Excel to determine flight reliability for major airlines and domestic airports in the United States

### The Objective:
Develop a success rate system to determine on-time flights for major international airports in the United States.
Steps:
* Define what is considered an "on-time" flight
* Determine the criteria for an "on-time" flight
* Collect flight data
* Calculate the success rate
* Create the weighted scoring system

### The Purpose:
The purpose of the analysis is to look into the on-time performance across multiple major airlines and to create a success rate scoring system that can be used to compare and contrast the on-time performance of the airlines. The analysis seeks to provide airline customers with a transparent and objective way to assess airlines' performance of on-time flights, which is an important component in customer satisfaction and retention.

### Focus:
The focus will be on pointing out the factors that contribute to on-time performance and developing a consistent definition of "on-time" performance. It will also attempt to identify any trends in on-time performance over time and any differences in performance among airlines.

### Goal:
The scoring system will be designed to provide a clear and easy to understand way for customers to compare the on-time performance of different airlines, while also motivating airlines to improve their on-time performance and providing customers with the information they need to make informed decisions about which airline to choose when planning their travels.

### Data:
Data was retrieved from [The Department of Transportation’s Kaggle page](https://www.kaggle.com/datasets/usdot/flight-delays)
The publisher gathered data collected and published directly from [The U.S. Department of Transportation’s Bureau of Transportation Statistics](https://www.bts.dot.gov/browse-statistical-products-and-data/bts-publications/airline-service-quality-performance-234-time)
The reason this data was not taken directly from the DOT’s site was due to the data being in an encrypted binary file type (ascii). Used the semi-structured data from Kaggle due to time constraints. This data tracks the on-time performance of domestic flights operated by large air carriers.

### Key Insights for Analysis:
The columns that I plan to use for the analysis will be:
* From Flights Table:
	- Year
	- Month
	- Day
	- Airline
	- Origin Airport
	- Destination Airport
	- Scheduled Departure
	- Departure Time
	- Departure Delay
	- Taxi Out
	- Wheels Off
	- Scheduled Time
	- Elapsed Time
	- Air Time
	- Wheels On
	- Taxi In
	- Scheduled Arrival
 	- Arrival Time
	- Arrival Delay
	- Canceled
	- Cancellation Reason
	- Airline Delay
* From Airlines Table:
	- Airline
	- Airline Code
* From Airports Table
	- Airport Code
	- Airline

*The Data and Data Dictionaries can all be found [here](https://drive.google.com/drive/folders/1U8cgtaWsyIMDfDYTjrQH40dUIacq840E?usp=share_link)*

### Analysis:
Success Rate: The scoring system will be determined based on its perceived importance in relation to other factors adding up to a total of 100 points, where the higher the number, the higher the reliability. The idea is to have a relative scoring system broken down by the following:
* On-time performance
* Delay time
* Cancellations
* Quantity of flights
* Quantity of airports serviced
* Quantity of airlines serviced (Only pertains to the airport score)

### On-Time Performance and Delay Time Differences:
For this project, anything within 15 minutes of the scheduled departure and scheduled arrival will be considered as an "on-time" flight. Everything thereafter will be counted under the delay time category. 
On-time performance measures the percentage of flights that arrive at their destination within a certain amount of time of their scheduled arrival time. For example, a flight that arrives within 15 minutes of its scheduled arrival time may be considered "on-time". On-time performance takes into account the time that the flight is in the air as well as the time it spends on the ground, including taxiing.
Delay time, measures the average amount of time that flights are delayed. This metric can be calculated by subtracting the scheduled arrival time from the actual arrival time for each flight, and then calculating the average of these differences. Delay time only takes into account the time that the flight is in the air and does not include any time spent on the ground.
In short, on-time performance measures the percentage of flights that arrive on time, while delay time measures the average amount of time that flights are delayed.

### Questions for Analysis:
* Some questions for analysis that come to mind prior to EDA: 
* How do different airlines and airports compare in reliability and timeliness?
* Which airlines and airports have the highest on-time performance?
* Which airlines and airports have the shortest delay times?
* Which airlines and airports have the lowest rates of cancellations?
* Are there any trends in flight delays or cancellations? ie: are certain times of day or days of the week more prone to delays or cancellations? 
* Are there weather patterns or other factors that are related to increased delays or cancellations?
* Do larger and/or more established airlines seem to have better on-time performance?

### Assumptions:
* Causality: External factors such as weather, air traffic control, or mechanical issues may also contribute to delays and cancellations, which I will also be taking into consideration.
* Metrics: The chosen metrics for each factor may not be the best indicators of reliability. For example, on-time performance may not be the best indicator of reliability if an airline is constantly rescheduling flights.

### Limitations:
* Limited timeline: Data set only includes flights from 2015, so this may not be indicative of the reliability of the same airlines and airports in present day, since factors such as technology and airline management practices may have changed since then.
* Incomplete data: Columns missing data may cause general skewness.
* Data is only looking at domestic flights, so this may not be representative of the global air travel industry
* Only looking at airports with > 100 flights

### Making an interactive dashboard

First, I created a new table in SQL with the relevant columns

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

I then imported the table into Tableau and joined it to the existing data. Both the origin longitude/latitude and the destination longitude/latitude had to be made into point which were done using the following calculated fields:

	MAKEPOINT([destination_latitude],[destination_longitude])
	MAKEPOINT([origin_latitude],[origin_longitude])

Once done, those points would need to be combined by the following calculated field to be made into routes:

	MAKELINE([Origin Airport Points], [Destination Airport Points])

The route would then be used in a COLLECT function using the map visual along with a generated longitude and dual axis latitude. Once done, I added a destination state, destination city, origin state, origin city, and airline filter that would apply to all items on the worksheet so that anytime anything on the map is interacted with, it would update all other items on the dashboard.
