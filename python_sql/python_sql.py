# -*- coding: utf-8 -*-
"""
Created on Mon Mar 14 16:40:09 2022

@author: ASUS
"""
#Import SQLite and Pandas. OS is for change working directory to database file.
import sqlite3
import os
import pandas as pd

#Change directory
os.chdir(r"C:\Users\ASUS\Desktop\Programming")

#Connect server
conn = sqlite3.connect('Airlines.db')
c = conn.cursor()

#Question 1:
#Which of the following companies has the highest number of cancelled flights, relative to their number of total flights??
#Options: United Air Lines Inc, American Airlines Inc, Pinnacle Airlines Inc, Delta Air Lines Inc.

q1 = c.execute('''SELECT carriers.Description, CAST(cancel AS FLOAT)/CAST(total AS FLOAT) as cancelled_proportion
                     FROM carriers 
                     INNER JOIN (
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
                     ORDER BY cancelled_proportion DESC''').fetchall()

pd.DataFrame(q1, columns = ['Description',	'cancelled_proportion']).to_csv("python_q1.csv")

#From the Query United Air Lines Inc. has the highest proportion.

#Question 2: 
#Which of the following airplanes has the lowest associated average departure delay (excluding cancelled and diverted flights)?
#Options: 737-230, ERJ190-100IGW, A330-223, 737-282

q2 = c.execute('''SELECT plane.model, AVG(DepDelay) as counts
FROM plane
INNER JOIN ontime
ON plane.tailnum = ontime.tailnum
WHERE ontime.Cancelled = 0 AND ontime.Diverted = 0 AND ontime.DepDelay > 0
GROUP BY plane.model
ORDER BY counts''').fetchall()

pd.DataFrame(q2, columns = ['Model', 'Average Departure Delay']).to_csv("python_q2.csv")

#Among the options 737-282 had the lowest average departure dealy among four.

#Question 3: Which of the following companies has the highest number of cancelled flights?
#Options: United Air Lines Inc., American Airlines Inc, Pinnacle Airlines Inc., Delta Air Lines Inc.
q3 = c.execute('''SELECT carriers.Description, Count(*) as counts
                     from carriers 
                     INnER JOIN ontime 
                     ON carriers.code = ontime.UniqueCarrier
                     WHERE ontime.Cancelled = 1
                     GROUP BY carriers.Description
                     ORDER BY counts desc''').fetchall()

pd.DataFrame(q3, columns = ['Carrier', 'No of cancelled flights']).to_csv("python_q3.csv")

#From the table produced Delta Air Lines was at the top of cancelled flights.

#Question 4: Which of the following cities has the highest number of inbound flights (excluding cancelled flights)?
#Options: Chicago, Atlanta, New York, Houston
q4 = c.execute('''SELECT airports.city, count(*) AS counts
                     FROM airports
                     INNER JOIN ontime
                     ON airports.iata = ontime.Dest
                     WHERE ontime.cancelled = 0
                     GROUP BY airports.city
                     ORDER BY counts DESC''').fetchall()

pd.DataFrame(q4, columns = ['City', 'Inbound flight No']).to_csv("python_q4.csv")

#Disconnect server
conn.close()
