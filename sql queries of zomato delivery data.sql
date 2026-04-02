CREATE TABLE zomato_delivery_data (
    ID VARCHAR(50) PRIMARY KEY,
    Delivery_person_ID VARCHAR(50),
    Delivery_person_Age INT,
    Delivery_person_Ratings NUMERIC(3,1),
    Restaurant_latitude DECIMAL(12,9),
    Restaurant_longitude DECIMAL(12,9),
    Delivery_location_latitude DECIMAL(12,9),
    Delivery_location_longitude DECIMAL(12,9),
    Order_Date DATE,
    Time_Order_Ordered TIME,
    Time_Order_Picked TIME,
    Weather_Condition VARCHAR(100),
    Road_traffic_density VARCHAR(50),
    Vehicle_condition INT,
    Type_of_order VARCHAR(100),
    Type_of_vehicle VARCHAR(100),
    multiple_deliveries INT, 
    Festival VARCHAR(20),
    City VARCHAR(50),
    Time_taken_min INT
);

select * from zomato_delivery_data;

--1. Average delivery time by weather condition
SELECT 
    Weather_Condition, 
    ROUND(AVG(Time_taken_min), 2) AS Avg_Time
FROM zomato_delivery_data
GROUP BY Weather_Condition
ORDER BY Avg_Time DESC;

--2. Top 10 delivery persons by rating
SELECT 
    Delivery_person_ID, 
    ROUND(AVG(Delivery_person_Ratings), 2) AS Avg_Rating
FROM zomato_delivery_data
GROUP BY Delivery_person_ID
ORDER BY Avg_Rating DESC
LIMIT 10;

--3. Classify delivery speed (Fast/Average/Slow)
SELECT 
    ID, 
    Time_taken_min,
    CASE 
        WHEN Time_taken_min < 20 THEN 'Fast'
        WHEN Time_taken_min BETWEEN 20 AND 35 THEN 'Average'
        ELSE 'Slow'
    END AS Speed_Category
FROM zomato_delivery_data;

--4. Deliveries greater than average time (Subquery)
SELECT ID, Time_taken_min
FROM zomato_delivery_data
WHERE Time_taken_min > (SELECT AVG(Time_taken_min) FROM zomato_delivery_data);

--5. Rank delivery persons using WINDOW functions
SELECT 
    Delivery_person_ID, 
    City, 
    Delivery_person_Ratings,
    DENSE_RANK() OVER(PARTITION BY City ORDER BY Delivery_person_Ratings DESC) as Rank
FROM zomato_delivery_data
WHERE Delivery_person_Ratings IS NOT NULL; 

--6. Month-wise delivery count
SELECT 
    TO_CHAR(Order_Date, 'Month') AS Month_Name, 
    COUNT(*) AS Total_Orders
FROM zomato_delivery_data
GROUP BY Month_Name, EXTRACT(MONTH FROM Order_Date)
ORDER BY EXTRACT(MONTH FROM Order_Date);

--7. Busiest hour of the day
SELECT 
    EXTRACT(HOUR FROM Time_Order_Ordered) AS Order_Hour,
    COUNT(*) AS Order_Count
FROM zomato_delivery_data
GROUP BY Order_Hour
ORDER BY Order_Count DESC;

--8. Average Delivery Time by City and Weather
SELECT 
    City, 
    Weather_Condition,
    ROUND(AVG(Time_taken_min), 2) AS Avg_Delivery_Time
FROM zomato_delivery_data
GROUP BY City, Weather_Condition
ORDER BY City, Avg_Delivery_Time DESC;

--9. Calculate Distance (Haversine/Simplified Formula)
SELECT 
    ID,
    ROUND(SQRT(POWER(69.1 * (Restaurant_latitude - Delivery_location_latitude), 2) + 
    POWER(69.1 * (Delivery_location_longitude - Restaurant_longitude) * COS(Restaurant_latitude / 57.3), 2))::NUMERIC, 2) AS Distance_Miles,
    Time_taken_min
FROM zomato_delivery_data
ORDER BY Distance_Miles DESC;

--10. Festival vs Non-festival Delivery Time
SELECT 
    Festival,
    ROUND(AVG(Time_taken_min), 2) AS Avg_Time,
    COUNT(*) AS Total_Orders
FROM zomato_delivery_data
GROUP BY Festival;
