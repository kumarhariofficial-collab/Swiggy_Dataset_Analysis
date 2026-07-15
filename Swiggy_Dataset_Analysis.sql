CREATE DATABASE swiggy_db;
USE swiggy_db;

-- Check the data type once it is loaded from python--
DESCRIBE swiggy;
SHOW COLUMNS FROM swiggy;

-- Change the order_date dtype to date instead of datetime dtype--
ALTER TABLE swiggy
MODIFY COLUMN Order_Date DATE;

-- Check the number of rows imported from python--
SELECT COUNT(*)
FROM swiggy;

-- Check the Table--
SELECT *
FROM swiggy LIMIT 10;

-- Data Validation and Cleaning--

# Checking Null Values
SELECT 
    SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS null_restaurant,
    SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_location,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS null_dish,
    SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
    SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) AS null_rating_count
FROM swiggy;

-- Blank or Empty Strings--
SELECT *
FROM swiggy
WHERE state = '' OR city='' OR restaurant_name='' OR location='' OR category='' OR dish_name='' ;

-- Duplicate Detection--
SELECT state,city, Order_Date, restaurant_name, location, category, dish_name, price_inr, rating ,rating_count, count(*) as total
FROM swiggy
GROUP BY state,city, Order_Date, restaurant_name, location, category, dish_name, price_inr, rating ,rating_count
HAVING count(*) > 1;

-- Removing Duplicates--
with CTE as (
select *,
ROW_NUMBER() OVER (PARTITION BY state,city, Order_Date, restaurant_name, location, category, dish_name, price_inr, rating ,rating_count ORDER BY (SELECT NULL)) as rn
FROM swiggy
)
DELETE 
FROM CTE
WHERE rn > 1 ;

-- Creating Schemas--Dimension Tables--
# Date Tables
create table dim_date(
date_id INT AUTO_INCREMENT PRIMARY KEY,
full_date DATE,
Year INT,
Month INT,
Month_name varchar(20),
Quarter INT,
Day INT,
Week INT
);

# dim_location table
CREATE TABLE dim_location(
location_id INT AUTO_INCREMENT PRIMARY KEY,
State varchar(100),
city varchar(100),
Location varchar(100)
);

# dim_restaurant
CREATE TABLE dim_restaurant(
restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
Restaurant_Name varchar(200)
);

# dim_category
CREATE TABLE dim_category(
category_id INT AUTO_INCREMENT PRIMARY KEY,
category varchar(200)
);

# dim_dish
CREATE TABLE dim_dish(
dish_id INT AUTO_INCREMENT PRIMARY KEY,
Dish_name varchar(200)
);

-- Fact Table--
CREATE TABLE fact_swiggy_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    date_id INT,
    Price_INR DECIMAL(10,2),
    Rating DECIMAL(4,2),
    Rating_Count INT,
    location_id INT,
    restaurant_id INT,
    category_id INT,
    dish_id INT,

    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
    FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
    FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
    FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);

-- Insert the Data in all Tables--
-- dim date --
INSERT INTO dim_date (full_date, Year,Month, Month_name,Quarter,Day,Week)
SELECT distinct 
Order_date, Year(Order_date), Month(Order_date), MONTHNAME(Order_date), Quarter(Order_date), Day(Order_date), Week(Order_date)
FROM swiggy
WHERE Order_date IS NOT NULL;

-- dim_location --
INSERT INTO dim_location (State, city, Location)
SELECT distinct state, city, Location
FROM swiggy;

-- dim_restaurant --
INSERT INTO dim_restaurant (Restaurant_Name)
Select distinct Restaurant_Name
from swiggy;

-- dim_category --
INSERT INTO dim_category (category)
SELECT distinct Category
from swiggy;

-- dim_dish --
INSERT INTO dim_dish (Dish_name)
SELECT distinct Dish_name
from swiggy;

SELECT * FROM swiggy;
SELECT * FROM dim_date;
SELECT * FROM dim_location;
SELECT * FROM dim_restaurant;
SELECT * FROM dim_category;
SELECT * FROM dim_dish;

-- Fact table --
INSERT INTO fact_swiggy_orders
(
    dish_id
)
SELECT dsh.dish_id
FROM swiggy s
JOIN dim_dish dsh ON dsh.Dish_Name = s.Dish_Name;
 
INSERT INTO fact_swiggy_orders (date_id, Price_INR, Rating, Rating_Count )
SELECT dd.date_id, s.Price_INR, s.Rating, s.Rating_Count
FROM swiggy s
JOIN dim_date dd ON dd.Full_Date = s.Order_Date;
    
INSERT INTO fact_swiggy_orders (location_id )
SELECT dl.location_id
FROM swiggy s
JOIN dim_location dl ON dl.State = s.State AND dl.City = s.City AND dl.Location = s.Location;
    
INSERT INTO fact_swiggy_orders (restaurant_id)
SELECT dr.restaurant_id
FROM swiggy s
JOIN dim_restaurant dr ON dr.Restaurant_Name = s.Restaurant_Name;

INSERT INTO fact_swiggy_orders (category_id)
SELECT dc.category_id
FROM swiggy s
JOIN dim_category dc ON dc.Category = s.Category;

-- Check the data as has loaded to the respective tables--
SELECT * FROM swiggy;
SELECT * FROM dim_date;
SELECT * FROM dim_location;
SELECT * FROM dim_restaurant;
SELECT * FROM dim_category;
SELECT * FROM dim_dish;
SELECT * FROM fact_swiggy_orders;

SELECT *
FROM fact_swiggy_orders f
JOIN dim_date d 
    ON f.date_id = d.date_id
JOIN dim_location l
    ON f.location_id = l.location_id
JOIN dim_restaurant r
    ON f.restaurant_id = r.restaurant_id
JOIN dim_category c
    ON f.category_id = c.category_id
JOIN dim_dish di
    ON f.dish_id = di.dish_id;

-- KPI's --
# Total Orders
Select count(*) as total_orders 
FROM fact_swiggy_orders;

# Total Revenue (INR Million)
SELECT CONCAT(
    FORMAT(SUM(CAST(Price_INR AS DECIMAL(10,2))) / 1000000, 2),
    ' INR MILLION'
) AS total_amount
FROM fact_swiggy_orders;

-- Average DISH Price --
SELECT CONCAT(
    FORMAT(AVG(CAST(Price_INR AS DECIMAL(10,2))), 2),
    ' INR'
) AS total_Avg
FROM fact_swiggy_orders;

-- Average Rating --
Select round(avg(Rating),2) as avg_rating
FROM fact_swiggy_orders;

-- Deep Dive Business Analysis --
-- Monthly Order Trends --
Select d.year, d.month, d.month_name, count(*) as Total_Orders
from fact_swiggy_orders f
Join dim_date d
on f.date_id = d.date_id
Group by d.year, d.month, d.month_name;

-- Month on Month revenue
Select d.year, d.month, d.month_name, sum(Price_INR) as Total_revenue
from fact_swiggy_orders f
Join dim_date d
on f.date_id = d.date_id
Group by d.year, d.month, d.month_name
order by Total_revenue desc;

-- Quarterly Trend --
Select d.year, d.quarter, count(*) as Total_Orders
from fact_swiggy_orders f
Join dim_date d
on f.date_id = d.date_id
Group by d.year, d.quarter;

-- Yearly Trend --
Select d.year, count(*) as Total_Orders
from fact_swiggy_orders f
Join dim_date d
on f.date_id = d.date_id
Group by d.year;

-- orders by Day of Week (Mon - Sun) --
Select dayname(d.full_date) as day_name, count(*) as total_orders
from fact_swiggy_orders f
Join dim_date d on f.date_id = d.date_id
Group by dayname(d.full_date);

-- Location based Analysis --
# Top 10 cities order volume
Select l.city, count(*) as Total_orders
From fact_swiggy_orders f
Join dim_location l 
On l.location_id = f.location_id
Group by l.city
order by Total_orders desc
limit 10;

-- Revenue Contribution by States --
Select l.state, sum(f.Price_INR) as Total_Revenue
From fact_swiggy_orders f
Join dim_location l 
On l.location_id = f.location_id
Group by l.state
order by Total_Revenue desc;

-- Food Performance --
# Top 10 Restaurants by orders
Select r.restaurant_name, count(*) as Total_orders
From fact_swiggy_orders f
Join dim_restaurant r On r.restaurant_id = f.restaurant_id
Group by r.restaurant_name
order by Total_orders desc
limit 10;

-- Top Categories --
Select c.category, count(*) as Total_orders
From fact_swiggy_orders f
Join dim_category c On c.category_id = f.category_id
Group by c.category
order by Total_orders desc
limit 10;

-- Most ordered dishes --
Select d.dish_name, count(*) as Total_orders
From fact_swiggy_orders f
Join dim_dish d On d.dish_id = f.dish_id
Group by d.dish_name
order by Total_orders desc
limit 10;

-- Cusine Performance -- orders + Avg rating
select c.category, count(*) as total_orders, round(avg(f.rating),2) as avg_rating
from fact_swiggy_orders f
Join dim_category c On f.category_id = c.category_id
Group by c.category
order by total_orders desc;

-- Total orders by price range --
SELECT
    CASE
        WHEN CAST(Price_INR AS DECIMAL(10,2)) < 100 THEN 'Under 100'
        WHEN CAST(Price_INR AS DECIMAL(10,2)) BETWEEN 100 AND 199 THEN '100 - 199'
        WHEN CAST(Price_INR AS DECIMAL(10,2)) BETWEEN 200 AND 299 THEN '200 - 299'
        WHEN CAST(Price_INR AS DECIMAL(10,2)) BETWEEN 300 AND 499 THEN '300 - 499'
        ELSE '500+'
    END AS price_range,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders
GROUP BY
    CASE
        WHEN CAST(Price_INR AS DECIMAL(10,2)) < 100 THEN 'Under 100'
        WHEN CAST(Price_INR AS DECIMAL(10,2)) BETWEEN 100 AND 199 THEN '100 - 199'
        WHEN CAST(Price_INR AS DECIMAL(10,2)) BETWEEN 200 AND 299 THEN '200 - 299'
        WHEN CAST(Price_INR AS DECIMAL(10,2)) BETWEEN 300 AND 499 THEN '300 - 499'
        ELSE '500+'
    END
ORDER BY total_orders DESC;

-- Rating Count Distribution --
Select rating, count(*) as rating_count
FROM fact_swiggy_orders
Group by rating
order by rating_count desc;