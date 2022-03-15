#Importing Library
library(DBI)
library(dplyr)


#Connect the database file
conn <- dbConnect(RSQLite::SQLite(), "Airlines.db")

#---Solving using DBI---
#Question 1:
#Which of the following companies has the highest number of cancelled flights, relative to their number of total flights??
#Options: United Air Lines Inc, American Airlines Inc, Pinnacle Airlines Inc, Delta Air Lines Inc.

q1_DBI <- dbGetQuery(conn, "SELECT carriers.Description, CAST(cancel AS FLOAT)/CAST(total AS FLOAT) as cancelled_proportion
                     FROM carriers 
                     INnER JOIN (
                     SELECT UniqueCarrier, count(*) as cancel 
                     FROM ontime
                     WHERE cancelled = 1
                     GROUP BY UniqueCarrier) as q1
                     ON carriers.Code = q1.UniqueCarrier
                     INNER JOIN(
                     SELECT UniqueCarrier, count(*) as total
                     FROM ontime
                     GROUP BY UniqueCarrier) as q2
                     ON carriers.Code = q2.UniqueCarrier
                     ORDER BY cancelled_proportion DESC")

write.csv(q1_DBI, file = "r_q1_DBI.csv")
#From the Query United Air Lines Inc. has the highest proportion.


#Question 2: 
#Which of the following airplanes has the lowest associated average departure delay (excluding cancelled and diverted flights)?
#Options: 737-230, ERJ190-100IGW, A330-223, 737-282

q2_DBI <- dbGetQuery(conn, "SELECT plane.model, AVG(DepDelay) as counts
FROM plane
INNER JOIN ontime
ON plane.tailnum = ontime.tailnum
WHERE ontime.Cancelled = 0 AND ontime.Diverted = 0 AND ontime.DepDelay > 0
GROUP BY plane.model
ORDER BY counts")

write.csv(q2_DBI, file = 'r_q2_DBI.csv')

#Among the options 737-282 had the lowest average departure dealy among four.



#Question 3: Which of the following companies has the highest number of cancelled flights?
#Options: United Air Lines Inc., American Airlines Inc, Pinnacle Airlines Inc., Delta Air Lines Inc.

q3_DBI <- dbGetQuery(conn, "SELECT carriers.Description, Count(*) as counts
                     from carriers 
                     INnER JOIN ontime 
                     ON carriers.code = ontime.UniqueCarrier
                     WHERE ontime.Cancelled = 1
                     GROUP BY carriers.Description
                     ORDER BY counts desc")

write.csv(q3_DBI, file = 'r_q3_DBI.csv')

#From the table produced Delta Air Lines was at the top of cancelled flights.

#Question 4: Which of the following cities has the highest number of inbound flights (excluding cancelled flights)?
#Options: Chicago, Atlanta, New York, Houston

q4_DBI <- dbGetQuery(conn, "SELECT airports.city, count(*) AS counts
                     FROM airports
                     INNER JOIN ontime
                     ON airports.iata = ontime.Dest
                     WHERE ontime.cancelled = 0
                     GROUP BY airports.city
                     ORDER BY counts DESC")

write.csv(q4_DBI, file = 'r_q4_DBI.csv')

#From results, Chicago has the highest number of inbound flights



#-----Solving Using dplyr-----

#Creating a Reference to Table
airports <- tbl(conn, "airports")
carriers <- tbl(conn, "carriers")
ontime <- tbl(conn, "ontime")
plane <- tbl(conn, "plane")

#Question 1:
#Which of the following companies has the highest number of cancelled flights, relative to their number of total flights??
#Options: United Air Lines Inc, American Airlines Inc, Pinnacle Airlines Inc, Delta Air Lines Inc.

q1_dplyr <- inner_join(ontime, carriers, by = c('UniqueCarrier' = 'Code')) %>% select(c(Description, Cancelled)) %>% group_by(Description) %>% summarize(cancel_total_ratio = mean(Cancelled)) %>% arrange(desc(cancel_total_ratio))

write.csv(q1_dplyr, file = 'r_q1_dplyr.csv')

#From the Query United Air Lines Inc. has the highest proportion.


#Question 2:
#Which of the following airplanes has the lowest associated average departure delay (excluding cancelled and diverted flights)?
#Options: 737-230, ERJ190-100IGW, A330-223, 737-282

q2_dplyr <- ontime %>% filter(Cancelled == 0 & Diverted == 0 & DepDelay > 0) %>% select(TailNum, DepDelay) %>% rename(tailnum = TailNum) %>% inner_join(plane, by = c("tailnum" = 'tailnum')) %>% group_by(model) %>% summarize(average_depdelay = mean(DepDelay)) %>% arrange(average_depdelay)

write.csv(q2_dplyr, file = 'r_q2_dplyr.csv')

#Among the options 737-282 had the lowest average departure dealy among four.

#Question 3: Which of the following companies has the highest number of cancelled flights?
#Options: United Air Lines Inc., American Airlines Inc, Pinnacle Airlines Inc., Delta Air Lines Inc.

q3_dplyr <- ontime %>% filter (Cancelled == 1) %>% select(UniqueCarrier, Cancelled) %>% inner_join(carriers, by = c('UniqueCarrier' = 'Code')) %>% select(Description, Cancelled) %>% group_by(Description) %>% summarize(Cancelled_counts = sum(Cancelled)) %>% arrange(desc(Cancelled_counts))

write.csv(q3_dplyr, file = 'r_q3_dplyr.csv')

#From the table produced Delta Air Lines was at the top of cancelled flights.

#Question 4: Which of the following cities has the highest number of inbound flights (excluding cancelled flights)?
#Options: Chicago, Atlanta, New York, Houston

q4_dplyr <- ontime %>% filter(Cancelled == 0) %>% select (Dest) %>% inner_join(airports, by = c('Dest' = 'iata')) %>% select (city) %>% group_by(city) %>% summarize(inbound_count = n()) %>% arrange(desc(inbound_count))

write.csv(q4_dplyr, file = 'r_q4_dplyr.csv')

#From results, Chicago has the highest number of inbound flights.

#Disconnect database
dbDisconnect(conn)
