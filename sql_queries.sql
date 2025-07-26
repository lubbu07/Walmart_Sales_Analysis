use walmart_db;
SHOW TABLES;
SELECT * FROM walmart;


select count(*) from walmart;

#Business Problems
#Q1 Find number of transaction by different payment methods and number of total quantity sold 

SELECT  payment_method AS Methods,COUNT(invoice_id) AS Number_of_Payments, SUM(quantity) AS Total_Quantity
FROM walmart
GROUP BY payment_method
ORDER BY Total_Quantity DESC;


#Q2 Identify the higest avergae rating category in each branch and diplay the branch, category, Average rating

SELECT * 
FROM
(
	SELECT  Branch,category, AVG(rating) AS AVG_Highest_Rating,
		RANK() OVER(PARTITION BY Branch ORDER BY AVG_Highest_Rating DESC) AS rank
	FROM walmart
	GROUP BY 1, 2
)
WHERE rank = 1;



# Q3 Identify the busiest day for each branch on the number of transactions

DESCRIBE walmart;

SELECT 
	date,
	STR_TO_DATE(date, 'MM-DD-YY') AS formated_date
 FROM walmart;

#this one worked below 
	
SELECT 
  date,
  DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%W') AS day_name
FROM walmart;



SELECT * FROM
(
	SELECT Branch, 
		 DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%W') AS day_name,
		COUNT(invoice_id) AS Number_of_tansaction,
		RANK() OVER(PARTITION BY Branch ORDER BY COUNT(invoice_id) DESC) AS rank
	FROM walmart
	GROUP BY 1,2
)
WHERE rank = 1;

#Q4 Calculate the total quantity of items sold per payment method. List payment method and total quantity
SELECT  
	payment_method AS Methods,
	#COUNT(invoice_id) AS Number_of_Payments, 
    SUM(quantity) AS Total_Quantity
FROM walmart
GROUP BY payment_method
ORDER BY Total_Quantity DESC;

#Q5 Determine the average, minimum and maximun rating of the category for each city.
# list the city, average_rating,min_rating and max_rating

SELECT 
	city, 
    category, 
    MIN(rating) AS Minimum_Rating, 
    MAx(rating) AS Maximum_Rating,
    AVG(rating) AS Average_Rating
FROM walmart
GROUP BY city,category
ORDER BY city;

#Q6 Calculate total profit for each category by considering total_profit as (unit_price* quantity * profit_margin)
#List all the category and total_profit, ordered from the higest to lowerst profit

 SELECT * FROM walmart;
SELECT 
	category,
    ROUND(SUM(total),2) AS Revenue,
    ROUND(SUM(total * profit_margin),2) AS Profit
FROM walmart
GROUP BY category
ORDER BY Profit DESC;

#Q7 Determine the most common payment method for each Branch. Display branch and the preffered payment method.

SELECT *
FROM
(
	SELECT
		branch,
		payment_method,
		COUNT(invoice_id) AS Total_transaction,
		RANK OVER(PARTION BY branch OREDER BY COUNT(invoice_id) DESC) AS rank
	FROM walmart
	GROUP BY 1,2
)
WHERE rank = 1 ;

WITH transaction_ranked AS (
	SELECT
		branch,
		payment_method,
		COUNT(invoice_id) AS Total_transaction,
		RANK() OVER (PARTITION BY branch ORDER BY COUNT(invoice_id) DESC) AS rank
	FROM walmart
	GROUP BY branch, payment_method
)
SELECT *
FROM transaction_ranked
WHERE rank = 1;

#Q8 Categorize sales into 3 groups Mornings, Afternoon, Evenings. FInd out which of the number of shifts and number of invoices


SELECT *,CAST(time AS TIME) AS clean_time
FROM walmart;



SELECT Branch,
  CASE 
    WHEN EXTRACT(HOUR FROM CAST(time AS TIME)) < 12 THEN 'MORNING'
    WHEN EXTRACT(HOUR FROM CAST(time AS TIME)) BETWEEN 12 AND 17 THEN 'AFTERNOON'
    ELSE 'EVENING'
  END AS Shifts,
  COUNT(*) AS No_of_Invoices,
  ####RANK() OVER (PARTITION BY branch ORDER BY COUNT(invoice_id) DESC) AS rank
FROM walmart
GROUP BY Branch,Shifts
ORDER BY 1, 3 DESC;


#Q9 Identify 5 branches with the higest decrease ratio in the revenue compared to the last year ratio 
#( current year 2023 and previous year 2022)

# rev_dec == last_rev - cur_rev / last_rev * 100

SELECT EXTRACT(YEAR FROM STR_TO_DATE(date, '%d/%m/%y')) AS formated_date
FROM walmart;

SELECT Branch, SUM(total) AS revenue
FROM walmart
WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%d/%m/%y')) = 2022
GROUP BY Branch
ORDER BY revenue;


WITH revenue_2022 AS
(
	SELECT Branch, SUM(total) AS revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%d/%m/%y')) = 2022
	GROUP BY Branch
	#ORDER BY revenue
),
revenue_2023 AS
(
	SELECT Branch, SUM(total) AS revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM STR_TO_DATE(date, '%d/%m/%y')) = 2023
	GROUP BY Branch
	#ORDER BY revenue
)

SELECT 
	ls.Branch,
    ls.revenue AS last_year_revenue,
    cs.revenue AS current_year_revenue,
    CAST(((ls.revenue - cs.revenue) /ls.revenue *100) AS DECIMAL(10,2))  AS  Decrease_Ratio
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs
ON ls.Branch = cs.Branch
WHERE ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5;




SELECT Branch, SUM(total) AS revenue , YEAR(STR_TO_DATE(date, '%d/%m/%y'))  AS year
FROM walmart
#WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
GROUP BY Branch, year
HAVING year = 2023;





