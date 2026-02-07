# Walmart-Sales-Analysis-MySQL
Walmart sales data analysis project using MySQL to extract actionable business insights, trends, and customer behavior patterns.


## About

This project analyzes Walmart sales transaction data to understand sales performance,
customer behavior, and product trends across different branches and cities.

The analysis focuses on identifying top-performing product lines, popular payment methods,
peak sales periods, and revenue contribution by branch. The insights derived from this project
can help improve sales strategies and operational decision-making.

## Project Objectives
- Analyze overall sales performance across branches and cities
- Identify high-revenue product lines
- Understand customer purchasing behavior
- Determine peak sales time and preferred payment methods
- Gain hands-on experience with MySQL for data analysis

## Skills Demonstrated
- MySQL database creation and management
- Writing complex SQL queries
- Data aggregation using GROUP BY
- Business analysis using SUM, COUNT, AVG
- Conditional logic using CASE statements

## Dataset Overview

The dataset was obtained from the [Kaggle Walmart Sales Forecasting Competition](https://www.kaggle.com/c/walmart-recruiting-store-sales-forecasting). This dataset contains sales transactions from a three different branches of Walmart, respectively located in Mandalay, Yangon and Naypyitaw. The data contains 17 columns and 1000 rows:

| Column                  | Description                             | Data Type      |
| :---------------------- | :-------------------------------------- | :------------- |
| Invoice_id              | Invoice of the sales made               | VARCHAR(30)    |
| Branch                  | Branch at which sales were made         | VARCHAR(10)    |
| City                    | The location of the branch              | VARCHAR(30)    |
| Customer_type           | The type of the customer                | VARCHAR(30)    |
| Gender                  | Gender of the customer making purchase  | VARCHAR(10)    |
| Product_line            | Product line of the product sold        | VARCHAR(100)   |
| Unit_price              | The price of each product               | DECIMAL(10, 2) |
| quantity                | The amount of the product sold          | INT            |
| VAT_amount              | The amount of tax on the purchase       | DECIMAL(10, 2) |
| Total                   | The total cost of the purchase          | DECIMAL(12, 4) |
| Transaction_date        | The date on which the purchase was made | DATETIME       |
| Transaction_time        | The time at which the purchase was made | TIME           |
| Payment_method          | Customer payment method                 | VARCHAR(15)    |
| Cost_of_goods_sold      | Cost Of Goods sold                      | DECIMAL(10, 2) |
| Gross_margin_percentage | Gross margin percentage                 | DECIMAL(5, 2)  |
| Gross_income            | Gross Income                            | DECIMAL(10, 2) |
| Rating                  | Customer rating score                   | DECIMAL(2, 1)  |

## Feature Engineering

To enhance the analysis without altering the raw data, an analytical view
(`Sales_enriched`) was created. This view derives additional time-based features
from existing date and time columns to support deeper trend analysis.

The following features were engineered:

- **Time_of_day**: Categorized transactions into Morning, Afternoon, and Evening
  based on transaction time.
- **Day_name**: Extracted the day of the week from the transaction date to analyze
  weekday-wise sales and customer behavior.
- **Month_name**: Extracted the month name from the transaction date to enable
  monthly revenue and cost analysis.

Creating a view ensures data integrity, improves query reusability, and provides
a clean separation between raw data and analytical features.

## Exploratory Data Analysis (EDA)

Exploratory Data Analysis was performed using MySQL to answer key business
questions related to sales performance, customer behavior, and product trends.
The analysis was grouped into logical categories for clarity.

### General Analysis

- Identified the number of unique cities and branches present in the dataset
- Analyzed branch distribution across cities

### Product Analysis

- Determined the total number of unique product lines
- Identified the most common payment method used by customers
- Found the highest revenue-generating product line
- Analyzed monthly revenue trends
- Identified the month with the highest cost of goods sold (COGS)
- Determined the city and branch generating the highest revenue
- Analyzed VAT contribution by product line
- Identified branches selling more products than the average
- Analyzed product line preferences based on customer gender
- Calculated average customer ratings for each product line
- Classified product lines as "Good" or "Bad" based on sales performance

### Sales Analysis

- Analyzed the number of sales by time of day across weekdays
- Identified customer types generating the highest revenue
- Determined the city contributing the highest VAT
- Calculated VAT as a percentage of total revenue by city
- Identified the customer type contributing the most VAT

### Customer Analysis

- Analyzed the number of unique customer types and payment methods
- Identified the most common customer type and gender
- Analyzed gender distribution across branches
- Determined the time of day when customers provide the most ratings
- Analyzed peak rating times per branch
- Identified the day of the week with the highest average ratings per branch


## Key Insights

- Branch A generated the highest overall revenue
- E-wallet and cash are the most commonly used payment methods
- Sales peak during evening hours
- Certain product lines contribute disproportionately to total revenue
- Customer type "Member" contributes higher average revenue

## SQL Analysis Approach

- Used GROUP BY and aggregate functions for summarization
- Applied CASE statements for categorical analysis
- Created analytical views for feature engineering
- Used subqueries and HAVING clauses for comparative analysis
- Implemented indexing to optimize query performance

## Conclusion

This project demonstrates the application of MySQL for real-world sales analysis,
covering data preparation, feature engineering, and exploratory analysis to derive
meaningful business insights.

## Code Overview

For the rest of the code, check the [SQL_queries.sql](https://github.com/Princekrampah/WalmartSalesAnalysis/blob/master/SQL_queries.sql) file

```sql
-- CREATING AND USING A DATABASE 

CREATE DATABASE IF NOT EXISTS Walmart_sales_db;
USE Walmart_sales_db;

-- --------------------------------------------------------------------------------------------------------------------------------------------

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
```
