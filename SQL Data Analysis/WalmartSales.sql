CREATE DATABASE IF NOT EXISTS salesDataWalmart;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(12,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12,4) NOT NULL,
    rating FLOAT(2,1) 
);





-- ------------------------------------------------------
-- ---------------------------------------Feature Engineering ------------------------------

-- time_of_day
SELECT 
	time,
    (CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:00:01" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_date
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales 
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:00:01" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END
);

-- day_name
SELECT
	date,
    dayname(date) AS day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = dayname(date);

-- month_name

SELECT
	date,
    monthname(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = monthname(date);




-- -----------------------------------------
-- -----------------------------------------

-- ----------------------GENERIC------------------------------
-- How many unique cities does the data have

SELECT DISTINCT city FROM salesDataWalmart.sales;
-- In what cities is each branch

SELECT DISTINCT city, branch  FROM salesDataWalmart.sales;
-- -------------------------------------------
-- How many unique product line does the data have

SELECT DISTINCT product_line  FROM salesDataWalmart.sales;

-- What is the most common payment method

SELECT payment_method, COUNT(payment_method) AS COUNT 
FROM salesDataWalmart.sales
GROUP BY payment_method
ORDER BY COUNT DESC;

-- What is the most selling product line
SELECT product_line, COUNT(product_line) AS COUNT 
FROM salesDataWalmart.sales
GROUP BY product_line
ORDER BY COUNT DESC;

-- What is the total revenue by month
SELECT month_name as Month, SUM(total) AS Revenue 
FROM salesDataWalmart.sales
GROUP BY month_name
ORDER BY Revenue DESC;

-- What month had the largest COGS
SELECT month_name as Month, SUM(cogs) AS total_cogs
FROM salesDataWalmart.sales
GROUP BY month_name
ORDER BY total_cogs DESC;

-- What product line had the largest revenue
SELECT product_line, SUM(total) AS Revenue 
FROM salesDataWalmart.sales
GROUP BY product_line
ORDER BY Revenue DESC;

-- what city is the largest revenue

SELECT city, SUM(total) AS Revenue 
FROM salesDataWalmart.sales
GROUP BY city
ORDER BY Revenue DESC;

-- what product line had the largest VAT
SELECT product_line, AVG(vat) AS VAT
FROM salesDataWalmart.sales
GROUP BY product_line
ORDER BY VAT DESC;

-- fetch each prodfuct line and add column to product line "good" if sales is greater the average sales "bad" if lower.
SELECT product_line, (SELECT AVG(total) FROM sales) AS average_sales, sum(total),
	CASE
		WHEN SUM(total) > (SELECT AVG(total) FROM sales) THEN 'GOOD'
        ELSE 'BAD'
	END AS sale_category
FROM salesDataWalmart.sales
GROUP BY product_line;

-- which branch sold more products than average product sold

SELECT
	branch,
    SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- what is the most common product line by gender

SELECT
	gender,
    product_line,
    COUNT(gender) as total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- what is the average rating of each product

SELECT
	AVG(rating) as avg_rating,
    product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

SELECT * FROM salesDataWalmart.sales;