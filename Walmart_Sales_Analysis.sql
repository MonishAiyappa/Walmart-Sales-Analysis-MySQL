-- CREATING AND USING A DATABASE 

CREATE DATABASE IF NOT EXISTS Walmart_sales_db;
USE Walmart_sales_db;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- CREATING TABLES FOR WALMART ANALYSIS

CREATE TABLE IF NOT EXISTS Sales (
	Invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,  
    Branch VARCHAR(10) NOT NULL,
    City VARCHAR(30) NOT NULL,
    Customer_type VARCHAR(30) NOT NULL,
    Gender VARCHAR(10) NOT NULL,
    Product_line VARCHAR(100) NOT NULL,
    Unit_price DECIMAL(10,2) NOT NULL,
    Quantity INT NOT NULL,
    VAT_amount DECIMAL(10,2) NOT NULL,
    Total DECIMAL(12,4) NOT NULL,
    Transaction_date DATETIME NOT NULL,
    Transaction_time TIME NOT NULL,
    Payment_method VARCHAR(15) NOT NULL,
    Cost_of_goods_sold DECIMAL(10,2) NOT NULL,
    Gross_margin_percentage DECIMAL(5,2) NOT NULL,
    Gross_income DECIMAL(10,2) NOT NULL,
    Rating DECIMAL(2,1),
    CONSTRAINT chk_rating CHECK(Rating BETWEEN 1 AND 10)
);

SELECT * FROM Sales;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- =================================================================================================================================================================================================================
-- INDEXING FOR QUERY PERFORMANCE OPTIMIZATION
-- =================================================================================================================================================================================================================

--  Date-based analysis (monthly revenue, weekday analysis)
CREATE INDEX idx_sales_transaction_date
ON Sales (Transaction_date);

-- Time-based analysis (time of day, ratings by time)
CREATE INDEX idx_sales_transaction_time
ON Sales (Transaction_time);

-- City & Branch analysis (revenue, VAT, customer distribution)
CREATE INDEX idx_sales_city_branch
ON Sales (City, Branch);

-- Product-level analysis (revenue, VAT, ratings)
CREATE INDEX idx_sales_product_line
ON Sales (Product_line);

-- Customer segmentation (revenue & VAT by customer type)
CREATE INDEX idx_sales_customer_type
ON Sales (Customer_type);

-- Rating-based analysis (average ratings, best day/time)
CREATE INDEX idx_sales_rating
ON Sales (Rating);


-- =================================================================================================================================================================================================================
                                                 -- FEATURE ENGINEERING (FE)
-- =================================================================================================================================================================================================================

-- Created an analytical view to derive time-based features
-- without modifying the raw Sales table.
-- This improves reusability, consistency, and analytical clarity.

CREATE VIEW Sales_enriched AS
SELECT *,
	(
		CASE 
			WHEN Transaction_time BETWEEN "00:00:00" AND "11:59:59" THEN "Morning"
            WHEN Transaction_time BETWEEN "12:00:00" AND "16:59:59" THEN "Afternoon"
            ELSE "Evening"
		END
    ) AS Time_of_day ,
    DAYNAME(Transaction_date) AS Day_name ,
    MONTHNAME(Transaction_date) AS Month_name 
    FROM Sales;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- =================================================================================================================================================================================================================
                                                 -- EXPLORATORY DATA ANALYSIS (EDA)
-- =================================================================================================================================================================================================================


-- *****************************************************************************************************************************************************************************************************************
			-- GENERIC Questions
-- *****************************************************************************************************************************************************************************************************************

-- 1) How many unique cities does the data have?

SELECT COUNT(DISTINCT City) AS NO_of_unique_cities
FROM Sales;

-- 2) In which city is each branch?

SELECT DISTINCT City , Branch
FROM Sales;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- *****************************************************************************************************************************************************************************************************************
			-- PRODUCT
-- *****************************************************************************************************************************************************************************************************************

-- 1) How many unique product lines does the data have?

SELECT COUNT(DISTINCT Product_line) FROM Sales;

-- 2) What is the most common payment method?

SELECT Payment_method , COUNT(Invoice_id) AS cnt 
FROM Sales
GROUP BY Payment_method
ORDER BY cnt DESC
LIMIT 1;

-- 3) What is the highest revenue-generating product line?

SELECT Product_line, SUM(Total) AS total_revenue
FROM Sales
GROUP BY Product_line
ORDER BY total_revenue DESC
LIMIT 1;
 
 -- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 4) What is the total revenue by month?

SELECT YEAR(Transaction_date) AS Year,
       MONTH(Transaction_date) AS Month_num,
       Month_name ,
       SUM(Total) AS total_revenue
FROM Sales_enriched
GROUP BY Year, Month_num, Month_name
ORDER BY Year, Month_num;


-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 5) What month had the largest COGS?

SELECT Month_name AS Month ,SUM(Cost_of_goods_sold) AS Cogs
FROM Sales_enriched
GROUP BY Month_name
ORDER BY Cogs DESC
LIMIT 1;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 6) What is the city with the largest revenue?

SELECT City ,Branch, SUM(Total) AS total_revenue
FROM Sales
GROUP BY City , Branch
ORDER BY total_revenue DESC
LIMIT 1;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 7) What product line had the largest VAT?

SELECT Product_line , SUM(VAT_amount) AS VAT_Amount
FROM Sales
GROUP BY Product_line
ORDER BY VAT_Amount DESC
LIMIT 1;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 8) Which branch sold more products than average product sold?

SELECT Branch , SUM(Quantity) AS Product_Sold
FROM Sales
GROUP BY Branch
HAVING Product_Sold > (
	 SELECT AVG(Branch_Total)
     FROM(
			SELECT SUM(Quantity) AS Branch_Total
            FROM Sales
            GROUP BY Branch
		 ) AS avg_table
);

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 9) What is the most common product line by gender?

SELECT 
    sales.Gender,
    sales.Product_line,
    COUNT(*) AS total_cnt
FROM Sales AS sales
GROUP BY sales.Gender, sales.Product_line
HAVING COUNT(*) = (
    SELECT MAX(cnt)
    FROM (
        SELECT COUNT(*) AS cnt
        FROM Sales AS sales_inner
        WHERE sales_inner.Gender = sales.Gender
        GROUP BY sales_inner.Product_line
    ) AS t
);

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 10) What is the average rating of each product line?

SELECT Product_line , AVG(Rating) AS Avg_Rating
FROM Sales
GROUP BY Product_line;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 11) Fetch each product line and add a column to those product line showing "Good" , "Bad" . Good if its greater than the average sales.

SELECT s.Product_line , SUM(s.Quantity) AS total_sales ,
(
	CASE
		WHEN SUM(s.Quantity) > (
			SELECT AVG(Product_total)
            FROM (
				SELECT SUM(Quantity) AS Product_total
                FROM Sales 
                GROUP BY Product_line
			) AS avg_table
		)
        THEN "Good"
        ELSE "Bad"
    	END 
) AS Review
FROM Sales AS s
GROUP BY s.Product_line;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- *****************************************************************************************************************************************************************************************************************
			-- SALES
-- *****************************************************************************************************************************************************************************************************************

-- 1) Number of sales made in each time of the day per weekday

SELECT Day_name, Time_of_day, COUNT(*) AS total_sales
FROM Sales_enriched
GROUP BY Day_name, Time_of_day
ORDER BY 
    FIELD(Day_name,
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
    ),
    Time_of_day;


-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 2) Which customer type(s) generate the highest total revenue?

SELECT Customer_type , SUM(Total) AS total_revenue
FROM Sales
GROUP BY Customer_type
HAVING SUM(Total) = (
	SELECT MAX(revenue) 
    FROM (
		SELECT SUM(Total) AS revenue
        FROM Sales
        GROUP BY Customer_type
        ) AS t
);


-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 3) Which city contributes the highest total VAT?

SELECT City , SUM(VAT_amount) AS total_VAT
FROM Sales
GROUP BY City
HAVING SUM(VAT_amount) = (
	SELECT MAX(VAT)
    FROM(
		SELECT SUM(VAT_amount) AS VAT
        FROM Sales
        GROUP BY City
    )AS t
);

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 4) Which city has the highest VAT as a percentage of total revenue?

SELECT City,
       (SUM(VAT_amount) / SUM(Total)) * 100 AS vat_percentage
FROM Sales
GROUP BY City
ORDER BY vat_percentage DESC
LIMIT 1;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 5) Which customer type pays the most in VAT?

SELECT Customer_type, SUM(VAT_amount) AS total_vat
FROM Sales
GROUP BY Customer_type
ORDER BY total_vat DESC
LIMIT 1;
 
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- *****************************************************************************************************************************************************************************************************************
			-- CUSTOMERS
-- *****************************************************************************************************************************************************************************************************************

-- 1) How many unique customer types does the data have?

SELECT  COUNT(DISTINCT Customer_type) AS No_of_customer_types
FROM Sales;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 2) How many unique payment methods does the data have?

SELECT COUNT(DISTINCT Payment_method) AS No_of_payment_methods
FROM Sales;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 3) What is the most common customer type?

SELECT Customer_type , COUNT(*) AS total_customers
FROM Sales
GROUP BY Customer_type
ORDER BY COUNT(*) DESC
LIMIT 1;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 4) What is the gender of most of the customers?

SELECT Gender, COUNT(*) AS total_customers
FROM Sales
GROUP BY Gender
ORDER BY total_customers DESC
LIMIT 1;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 5) What is the gender distribution per branch?

SELECT City ,Branch , Gender , COUNT(*) AS total_customers
FROM Sales
GROUP BY City , Branch , Gender
ORDER BY City;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 6) Which time of the day do customers give most ratings?

SELECT Time_of_day, COUNT(Rating) AS rating_count
FROM Sales_enriched
GROUP BY Time_of_day
ORDER BY rating_count DESC
LIMIT 1;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 7) Which time of the day do customers give most ratings per branch?

SELECT outer_sales.Branch,
       outer_sales.Time_of_day,
       COUNT(outer_sales.Rating) AS rating_count
FROM Sales_enriched AS outer_sales
GROUP BY outer_sales.Branch, outer_sales.Time_of_day
HAVING COUNT(outer_sales.Rating) = (
    SELECT MAX(cnt)
    FROM (
        SELECT COUNT(inner_sales.Rating) AS cnt
        FROM Sales_enriched AS inner_sales
        WHERE inner_sales.Branch = outer_sales.Branch
        GROUP BY inner_sales.Time_of_day
    ) AS t
);

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 8) Which day of the week has the best average ratings per branch?

SELECT outer_sales.Branch,
       outer_sales.Day_name,
       AVG(outer_sales.Rating) AS avg_rating
FROM Sales_enriched AS outer_sales
GROUP BY outer_sales.Branch, outer_sales.Day_name
HAVING AVG(outer_sales.Rating) = (
    SELECT MAX(avg_day_rating)
    FROM (
        SELECT AVG(inner_sales.Rating) AS avg_day_rating
        FROM Sales_enriched AS inner_sales
        WHERE inner_sales.Branch = outer_sales.Branch
        GROUP BY inner_sales.Day_name
    ) AS t
); 

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
