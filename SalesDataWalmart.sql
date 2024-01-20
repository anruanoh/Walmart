CREATE SCHEMA IF NOT EXISTS WalmartSalesData;

CREATE TABLE IF NOT EXISTS Sales(
	invoiceid VARCHAR(45) NOT NULL PRIMARY KEY,
    branch VARCHAR(45) NOT NULL,
    city VARCHAR(45) NOT NULL,
    customertype VARCHAR(45) NOT NULL,
    gender VARCHAR(45) NOT NULL,
    productline VARCHAR(45) NOT NULL,
    unitprice DECIMAL(4,2) NOT NULL,
    quantity INT NOT NULL,
    tax5pct FLOAT(6,4) NOT NULL,
    total DECIMAL(10,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(45) NOT NULL,
    cogs DECIMAL(6,2) NOT NULL,
    gross_margin_pct FLOAT(11,9)NOT NULL,
    gross_income DECIMAL(10,4)NOT NULL,
    ratiNg FLOAT(2,1)NOT NULL
);
 
ALTER TABLE sales
RENAME COLUMN ratiNg TO rating;

-- -------------------------------------------------------------------

-- ADDING NEW COLUMNS

-- 1) time_of_day(Morning, afternoon, evening)
ALTER TABLE sales 
ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day =
	CASE 
    WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
    WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
    ELSE 'Evening'
    END; 
    
-- 2) day_name (Monday, Tuesday, Wednesday, Thursday, Friday)
ALTER TABLE sales
ADD COLUMN day_name VARCHAR(20);

UPDATE sales
SET day_name = dayname(date);

-- 3) month_name
ALTER TABLE sales
ADD COLUMN month_name VARCHAR(20);

UPDATE sales
SET month_name = monthname(date);

-- ---------------------------------------------------------------------

-- BUSINESS QUESTIONS TO ANSWER.


-- GENETIC QUESTIONS;

-- 1) How many unique cities does the data have?
SELECT count(DISTINCT city) AS unique_cities 
FROM sales; 

-- 2) In which city is each branch?
SELECT DISTINCT city, branch 
FROM sales;



-- PRODUCT QUESTIONS;

-- 1) How many unique product lines does the data have?
SELECT COUNT(DISTINCT productline) AS Unique_productlines
FROM sales;

-- 2) What is the most common payment method? 
SELECT payment, count(payment) as payment_amount
FROM sales
GROUP BY payment
ORDER BY payment_amount desc;


-- 3) What is the most selling product line?
SELECT productline, count(productline) as top_selling_line FROM sales
GROUP BY productline
ORDER BY top_selling_line desc;

-- 4) What is the total revenue by month? 
SELECT month_name, ROUND(SUM(total), 0) as total_revenue FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- 5) What month had the largest COGS(Cost of goods sold)?
SELECT month_name, ROUND(SUM(cogs),0) as total_cogs FROM sales
GROUP BY month_name
ORDER BY total_cogs DESC;

-- 6) What product line had the largest revenue? 
SELECT productline, ROUND(SUM(total),0) as total_revenue FROM sales
GROUP BY productline
ORDER BY total_revenue DESC;

-- 7) What is the city with the largest revenue?
SELECT city, branch, ROUND(SUM(total),0) as total_revenue FROM sales
GROUP BY city, branch
ORDER BY total_revenue DESC;

-- 8) What product line had largest VAT(Value added tax)?
SELECT productline, ROUND(AVG(tax5pct),2) as avg_tax FROM sales
GROUP BY productline
ORDER BY avg_tax DESC;

-- 9) Fetch each product line and add a column to those product line showing "Good","Bad". Good if its greater than average sales. 
SELECT productline, 
	CASE
		WHEN AVG(total) > (SELECT AVG(total) from sales) THEN 'Good'   
		ELSE 'Bad'
	END as remark 
FROM sales
GROUP BY productline;  

-- Different way to answer the same question --
SELECT  AVG(total) AS avg_qnty FROM sales;

SELECT productline,
	CASE
		WHEN AVG(total) > 322.49888894 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY productline;

-- 10) Wich branch sold more products than average product sold? 
SELECT branch, SUM(quantity) AS sum_quantity FROM sales
GROUP BY Branch
HAVING sum_quantity > (SELECT AVG(quantity) FROM sales);

-- 11)What is the most common product line by gender?
SELECT productline, gender, COUNT(gender) as count FROM sales
GROUP BY productline, gender
ORDER BY productline, count DESC; 

-- 12) What is the average rating of each product line?
SELECT productline, ROUND(AVG(rating),2) as avg_rating FROM sales
GROUP BY productline
ORDER BY avg_rating DESC;



-- SALES QUESTIONS;

-- 1) Number of sales made in each time of the day per weekday. 
SELECT day_name, time_of_day, COUNT(*) as sales FROM sales
GROUP BY day_name, time_of_day
ORDER BY 
    CASE 
        WHEN day_name = 'Sunday' THEN 1
        WHEN day_name = 'Monday' THEN 2
        WHEN day_name = 'Tuesday' THEN 3
        WHEN day_name = 'Wednesday' THEN 4
        WHEN day_name = 'Thursday' THEN 5
        WHEN day_name = 'Friday' THEN 6
        WHEN day_name = 'Saturday' THEN 7
        ELSE 8
    END, 
  time_of_day;
  
  -- 2) Which of the customer types bring the most revenue? 
  SELECT customertype, ROUND(SUM(total),0) AS total_revenue FROM sales
  GROUP BY customertype
  ORDER BY total_revenue DESC;
  
  -- 3) Which city has the largest tax percent VAT (Value added Tax)?
  SELECT city, ROUND(AVG(tax5pct),2) AS avg_VAT FROM sales
  GROUP BY city
  ORDER BY avg_VAT DESC;
  
  -- 4) Which customer type pays the most in VAT?
  
SELECT customertype, ROUND(AVG(tax5pct),2) AS avg_VAT FROM sales
GROUP BY customertype
ORDER BY avg_VAT DESC;



-- CUSTOMER QUESTIONS;

-- 1) How many unique customer types does the data have?
SELECT customertype, count(*) AS total_customers FROM sales
GROUP BY customertype;

-- 2) How many unique payment methods does the data have? 
  SELECT payment, count(*) as total_payments FROM sales
  GROUP BY payment;
  
-- 3) What is the most common customer type?
SELECT customertype, count(*) AS total_customers FROM sales
GROUP BY customertype
ORDER BY total_customers DESC;


-- 4) What is the gender of most of the customers?
SELECT gender, count(*) as total_customers FROM sales
GROUP BY gender
ORDER BY total_customers DESC; 

-- 5) What it the gender distribution per branch?
SELECT branch, gender, count(*) as total_customers FROM sales
GROUP BY branch, gender
ORDER BY branch;

-- 6) Which time of the day do customers give most ratings? 
SELECT time_of_day, ROUND(AVG(rating),2) as avg_rating FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- 7) Which time of the day do customers give most rating per branch?
SELECT branch, ROUND(AVG(rating),2) as avg_rating, time_of_day FROM sales
GROUP BY branch, time_of_day
ORDER BY branch, avg_rating DESC;

-- 8) Which day of the week has the best average ratings? 
SELECT day_name, ROUND(AVG(rating),2) as avg_rating FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC
LIMIT 3;

-- 9) Which day of the week has the best average ratings per branch? 
SELECT branch, ROUND(AVG(rating),2) as avg_rating, day_name FROM sales
GROUP BY branch, day_name
ORDER BY branch, avg_rating DESC;