Create database uber;

use uber;

CREATE TABLE Vehicle (
    Vehicle_Type VARCHAR(50),
    Driver_Ratings DECIMAL(3,2),
    Driver_Rating_Bins VARCHAR(20)
);

CREATE TABLE Customer (
    Customer_ID VARCHAR(20),
    Customer_Rating DECIMAL(3,2),
    Payment_Method VARCHAR(50)
);

CREATE TABLE Booking_Info (
    Booking_ID VARCHAR(20) ,
    Booking_Date DATE,
    Booking_Time TIME,
    Booking_Value DECIMAL(10,2),
    Trip VARCHAR(20),
    Customer_ID VARCHAR(20),
    Vehicle_Type VARCHAR(50)
);

CREATE TABLE Booking_Status (
    Booking_ID VARCHAR(20),
    Booking_Status VARCHAR(50),
    Ride_Cancel_by_Customer VARCHAR(5),
    Incomplete_Rides VARCHAR(5),
    Reason_Cancelled_by_Customer VARCHAR(255),
    Reason_Cancelled_by_Driver VARCHAR(255),
    Incomplete_Rides_Reason VARCHAR(255)
);



CREATE TABLE Ride_Detail (
    Booking_ID VARCHAR(20),
    Pickup_Location VARCHAR(255),
    Drop_Location VARCHAR(255),
    VTAT DECIMAL(10,2),
    CTAT DECIMAL(10,2),
    Ride_Distance DECIMAL(10,2),
    Ride_Distance_Bins VARCHAR(20)

);

select * from ride_detail;
select * from customer;
select * from vehicle;
select * from booking_info;
select * from booking_status; 


# Overview: 
#Q1: What is the total sales (sum of all booking values)?
SELECT 
    ROUND(SUM(booking_value)) AS Total_Sales
FROM 
    booking_info;


#Q2: How many bookings were completed?
SELECT 
    COUNT(booking_id) AS Completed_Bookings
FROM 
    booking_status
WHERE 
    booking_status = 'Completed';


#Q3: What is the average ride distance (in kilometers)?
SELECT 
    ROUND(AVG(ride_distance), 2) AS Avg_Ride_Distance_km
FROM 
    ride_detail;


#Q4: How many unique customers booked rides?
SELECT 
    COUNT(distinct customer_id) AS Total_Customers
FROM 
    customer;


#Q5: What is the average trip duration (in minutes)?
SELECT 
    ROUND(AVG(ctat), 2) AS Avg_Trip_Duration_Min
FROM 
    ride_detail;
    

    
    
#Q6: What is the total number of completed rides for each month?
SELECT 
    MONTHNAME(b.booking_date) AS Month_Name,
    COUNT(DISTINCT bs.booking_id) AS Total_Ride
FROM
    booking_info b
        JOIN
    booking_status bs ON b.booking_id = bs.booking_id
WHERE
    bs.booking_status = 'completed'
GROUP BY Month_Name , MONTH(b.booking_date)
ORDER BY MONTH(b.booking_date);





#Q8: What are the top 15 most common pickup locations?
SELECT 
    rd.pickup_location,
    COUNT(DISTINCT bs.booking_id) AS Most_Common_location
FROM
    ride_detail rd
JOIN
    booking_status bs 
    ON rd.booking_id = bs.booking_id
GROUP BY 
    rd.pickup_location
ORDER BY 
    Most_Common_location DESC
LIMIT 15;


#Q9: Which payment methods are used most frequently for completed bookings?
SELECT 
    c.payment_method, 
    COUNT(DISTINCT bs.booking_id) AS Most_Used
FROM
    Customer c
JOIN
    booking_info b 
        ON c.customer_id = b.customer_id
JOIN
    booking_status bs 
        ON b.booking_id = bs.booking_id
WHERE
    bs.booking_status = 'completed'
GROUP BY 
    c.payment_method
ORDER BY 
    Most_Used DESC;





# Booking_Trend:

#Q11: What is the total number of bookings per month, categorized by weekday and weekend?
SELECT 
    MONTHNAME(b.booking_date) AS Month_name,
    CASE
        WHEN DAYOFWEEK(b.booking_date) IN (1,7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    COUNT(DISTINCT bs.booking_id) AS Total_Booking
FROM
    booking_info b
JOIN
    booking_status bs 
        ON b.booking_id = bs.booking_id
GROUP BY 
    MONTHNAME(b.booking_date), 
    MONTH(b.booking_date), 
    Day_Type
ORDER BY 
    MONTH(b.booking_date);


#Q12: What is the total number of ride by each booking status?
SELECT 
    booking_status, 
    COUNT(booking_id) AS Total_Booking
FROM
    booking_status
GROUP BY 
    booking_status
ORDER BY 
    Total_Booking DESC;


#Q13: How many total bookings fall within each ride distance range (in 10 km bins)?
SELECT 
    rd.ride_distance_bins AS Avg_10_Km,
    COUNT(DISTINCT bs.booking_id) AS Total_Booking
FROM
    ride_detail rd
JOIN
    booking_status bs 
        ON rd.booking_id = bs.booking_id
GROUP BY 
    Avg_10_Km
ORDER BY 
    Avg_10_Km;


#Q14: What percentage of total completed rides belongs to each vehicle type?
SELECT 
    b.vehicle_type,
    Round(COUNT(distinct bs.booking_id) * 100.0 / 
        (SELECT 
            COUNT(DISTINCT bs.booking_id)
         FROM
            booking_info b
         JOIN
            booking_status bs 
                ON b.booking_id = bs.booking_id
         WHERE
            bs.booking_status = 'completed'),2) AS Total_Ride_Percentage
FROM
    booking_info b
JOIN
    booking_status bs 
        ON b.booking_id = bs.booking_id
WHERE
    bs.booking_status = 'completed'
GROUP BY 
    b.vehicle_type
ORDER BY 
    Total_Ride_Percentage DESC;


# cancellation: 
#Q15: What is the total number of cancellations (both customer & driver)?
SELECT 
    COUNT(*) AS Total_Cancellation
FROM
    booking_status
WHERE
    booking_status IN ('cancelled by customer', 'cancelled by driver');


#Q16: How many cancellations were by customer?
SELECT 
    COUNT(*) AS Total_Cancellation_By_Customer
FROM
    booking_status
WHERE
    booking_status = 'cancelled by customer';


#Q17: How many cancellations were by driver?
SELECT 
    COUNT(*) AS Total_Cancellation_By_Driver
FROM
    booking_status
WHERE
    booking_status = 'cancelled by driver';


#Q18: How many distinct bookings are marked as 'Incomplete'?
SELECT 
    COUNT(DISTINCT booking_id) AS Total_Incomplete_Booking
FROM
    booking_status
WHERE
    booking_status = 'incomplete';


#Q19: For each weekday (Mon-Sun), how many cancellations happened by customer and by driver?
SELECT 
    DAYNAME(b.booking_date) AS Day_Name,
    COUNT(DISTINCT CASE
            WHEN LOWER(bs.booking_status) = 'cancelled by customer' THEN bs.booking_id
        END) AS Cancelled_By_Customer,
    COUNT(DISTINCT CASE
            WHEN LOWER(bs.booking_status) = 'cancelled by driver' THEN bs.booking_id
        END) AS Cancelled_By_Driver
FROM
    booking_info b
JOIN
    booking_status bs ON b.booking_id = bs.booking_id
GROUP BY 
    DAYOFWEEK(b.booking_date), DAYNAME(b.booking_date)
ORDER BY 
    DAYOFWEEK(b.booking_date);


#Q20: For each month, how many cancellations happened by customer and by driver?
SELECT 
    MONTH(b.booking_date) AS Month_No,
    MONTHNAME(b.booking_date) AS Month_Name,
    COUNT(DISTINCT CASE
            WHEN (bs.booking_status) = 'cancelled by customer' THEN bs.booking_id
        END) AS Cancelled_By_Customer,
    COUNT(DISTINCT CASE
            WHEN (bs.booking_status) = 'cancelled by driver' THEN bs.booking_id
        END) AS Cancelled_By_Driver
FROM
    booking_info b
JOIN
    booking_status bs ON b.booking_id = bs.booking_id
GROUP BY 
    MONTH(b.booking_date), MONTHNAME(b.booking_date)
ORDER BY 
    MONTH(b.booking_date);


#Q21: For cancelled-by-driver bookings, how many cancellations per vehicle type (top first)?
SELECT 
    b.vehicle_type,
    ROUND(COUNT(bs.booking_id) * 100.0 / (SELECT 
                    COUNT( bs2.booking_id)
                FROM
                    booking_info b2
                        JOIN
                    booking_status bs2 ON b2.booking_id = bs2.booking_id
                WHERE
                    bs2.booking_status = 'Cancelled by Driver'),
            2) AS Pct
FROM
    booking_info b
        JOIN
    booking_status bs ON b.booking_id = bs.booking_id
WHERE
    bs.booking_status = 'Cancelled by Driver'
GROUP BY b.vehicle_type
ORDER BY Pct DESC;


#performance: 
# Q22: What is the average driver arrival time (VTAT).
SELECT 
    AVG(Vtat) AS Avg_Drival_Arrival_Time
FROM
    ride_detail;
    

#Q23: How many accurate pickups occurred
SELECT 
    COUNT(DISTINCT bs.booking_id) AS Accurate_Pickup
FROM
    ride_detail rd
        JOIN
    booking_status bs ON bs.booking_id = rd.booking_id
WHERE
    rd.VTAT <= 5; 
    
use uber;
#Q24: What is the monthly average driver arrival time
SELECT 
    MONTHNAME(b.booking_date) AS Monthly,
    ROUND(AVG(rd.vtat), 2) AS Avg_driver_arrival_time
FROM
    booking_info b
        JOIN
    ride_detail rd ON b.booking_id = rd.booking_id
GROUP BY MONTH(b.booking_date) , MONTHNAME(b.booking_date)
ORDER BY MONTH(b.booking_date);


#Q25: What is the total number of cancellations by vehicle
SELECT 
    b.vehicle_type,
    COUNT(DISTINCT bs.booking_id) AS Total_Cancellations
FROM
    booking_info b
        JOIN
    booking_status bs ON b.booking_id = bs.booking_id
WHERE
    bs.booking_status IN ('Cancelled by Customer' , 'Cancelled by Driver')
GROUP BY b.vehicle_type
ORDER BY Total_Cancellations DESC;
    

#Q26: What is the average trip duration for each vehicle and trip type (Long/Short)
SELECT 
    b.vehicle_type,
    b.trip,
    ROUND(AVG(rd.ctat), 2) AS Avg_Trip_Duration
FROM
    booking_info b
        JOIN
    ride_detail rd ON b.booking_id = rd.booking_id
GROUP BY b.vehicle_type , b.trip
ORDER BY b.vehicle_type , CASE
    WHEN b.trip = 'Long Trip' THEN 1
    WHEN b.trip = 'Short Trip' THEN 2
END;


#Revenue and payment : 
#Q27:  Which payment method is used the most
SELECT 
    c.payment_method
FROM
    Customer c
        JOIN
    booking_info b ON c.customer_id = b.customer_id
        JOIN
    booking_status bs ON b.booking_id = bs.booking_id
GROUP BY payment_method
ORDER BY COUNT(bs.booking_id) desc
LIMIT 1;


#Q28: Which day has the highest total sales (most busy day)
SELECT 
    Dayname(B.booking_date)As Most_Busiest_day
FROM
    Customer c
        JOIN
    booking_info b ON c.customer_id = b.customer_id
        JOIN
    booking_status bs ON b.booking_id = bs.booking_id
GROUP BY dayname(b.booking_date)
ORDER BY sum(b.booking_value) desc
LIMIT 1;

#Q29:  What are the total monthly sales
SELECT 
    MONTHNAME(booking_date) AS Month_Name,
    ROUND(SUM(booking_value)) AS Total_Sales
FROM 
    booking_info
GROUP BY 
    MONTH(booking_date), MONTHNAME(booking_date)
ORDER BY 
    MONTH(booking_date);


#Q30: What are the total sales by payment method
SELECT 
    c.payment_method,
    ROUND(SUM( b.booking_value)) AS Total_Sales
FROM 
    booking_info b
join customer c on b.customer_id=c.customer_id
GROUP BY 
    c.payment_method
ORDER BY total_sales desc;

#Q31: Which booking hours generate the highest sales
SELECT 
    Hour(booking_time) AS Hourly,
    ROUND(SUM(booking_value)) AS Total_Sales
FROM 
    booking_info
GROUP BY 
    Hour(booking_time)
ORDER BY 
    total_sALES DESC Limit 10 ;


#Q32: What are the total sales by vehicle type
SELECT 
    Vehicle_type,
    ROUND(SUM(booking_value)) AS Total_Sales
FROM 
    booking_info
GROUP BY 
       Vehicle_type
ORDER BY 
    total_sALES DESC ;
    

# Customer and driver_rating: 
#Q33: What is the average customer rating?
SELECT 
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating
FROM
    customer;

#Q34: What is the average driver rating?
SELECT 
    ROUND(AVG(driver_ratings), 2) AS Avg_Driver_rating
FROM 
    vehicle;

#Q35: How many customers gave a rating of 3 or less (Unhappy Customers)?
SELECT 
    COUNT(DISTINCT customer_id) AS Unhappy_Customers
FROM 
    customer
WHERE 
    customer_rating <= 3;

#Q36: How many customers gave a 5-star rating (Happy Customers)?
SELECT 
    COUNT(DISTINCT customer_id) AS Happy_customer
FROM 
    customer
WHERE 
    customer_rating >= 5;
    
#Q37: What is the average spend per customer (booking value)?
SELECT 
    ROUND(SUM(booking_value) / COUNT(DISTINCT customer_id), 2) AS Avg_Spend_Per_Customer
FROM 
    booking_info;

#Q38: How many customers are there in each driver rating bin?
SELECT 
    v.Driver_rating_bins, 
    COUNT(DISTINCT b.customer_id) AS Customer_Count
FROM
    vehicle v
        JOIN
    booking_info b ON v.vehicle_type = b.vehicle_type
GROUP BY 
    v.driver_rating_bins;

#Q39: Which pickup locations have the lowest customer ratings (Bad Experience Areas)?
SELECT 
    rd.pickup_location,
    AVG(c.customer_rating) AS bad_experience_area
FROM
    booking_info b
        JOIN
    customer c ON b.customer_id = c.customer_id
        JOIN
    ride_detail rd ON b.booking_id = rd.booking_id
GROUP BY 
    rd.pickup_location
ORDER BY 
    bad_experience_area ASC 
LIMIT 10;

#Q40: What is the average customer rating by vehicle type?
SELECT 
    b.vehicle_type, 
    ROUND(AVG(c.customer_rating), 1) AS Avg_Vehicle_Rating 
FROM
    booking_info b
        JOIN
    customer c ON b.customer_id = c.customer_id
GROUP BY 
    b.vehicle_type;



#Q41: How many loyal customers have more than 1 ride?
SELECT 
    COUNT(*) AS Loyal_Customers
FROM (
    SELECT 
        customer_id,
        COUNT(booking_id) AS Total_Rides
    FROM 
        booking_info
    GROUP BY 
        customer_id
    HAVING 
        COUNT(booking_id) > 1
) AS t;


