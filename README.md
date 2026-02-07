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


## Revenue And Profit Calculations

$ COGS = unitsPrice * quantity $

$ VAT = 5\% * COGS $

$VAT$ is added to the $COGS$ and this is what is billed to the customer.

$ total(gross_sales) = VAT + COGS $

$ grossProfit(grossIncome) = total(gross_sales) - COGS $

**Gross Margin** is gross profit expressed in percentage of the total(gross profit/revenue)

$ \text{Gross Margin} = \frac{\text{gross income}}{\text{total revenue}} $

<u>**Example with the first row in our DB:**</u>

**Data given:**

- $ \text{Unite Price} = 45.79 $
- $ \text{Quantity} = 7 $

$ COGS = 45.79 * 7 = 320.53 $

$ \text{VAT} = 5\% * COGS\\= 5\%  320.53 = 16.0265 $

$ total = VAT + COGS\\= 16.0265 + 320.53 = $336.5565$

$ \text{Gross Margin Percentage} = \frac{\text{gross income}}{\text{total revenue}}\\=\frac{16.0265}{336.5565} = 0.047619\\\approx 4.7619\% $

## Code

For the rest of the code, check the [SQL_queries.sql](https://github.com/Princekrampah/WalmartSalesAnalysis/blob/master/SQL_queries.sql) file

```sql
-- Create database
CREATE DATABASE IF NOT EXISTS walmartSales;

-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);
```
