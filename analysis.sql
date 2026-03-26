USE walmart_db;
SELECT * FROM walmart_clean_data;
SELECT COUNT(*) FROM walmart_clean_data;
SELECT payment_method, COUNT(*) FROM walmart_clean_data
GROUP BY payment_method;
SELECT COUNT(DISTINCT Branch) FROM walmart_clean_data;
SELECT MAX(quantity) FROM walmart_clean_data;

### Business Problem ###
### Q-1 Find diffrent payment method and number of transaction, number of qty sold?

SELECT 
	payment_method, 
    COUNT(*) AS no_of_payment, 
    SUM(quantity) AS no_qty_sold 
FROM walmart_clean_data
GROUP BY payment_method;

### Project Qustion
### Q-2 Identify the highest-rated category in each branch, displaying the branch, category, AVG Rating.alter

SELECT *
FROM	
(
    SELECT  
		branch,
		category,
		AVG(rating) AS avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS Rrank
	FROM walmart_clean_data
	GROUP BY 1, 2
)AS sub
WHERE Rrank = 1;

### Q-3 Identify the busiest day for each branch based on the number of transactions

SELECT * 
FROM		
(        
	SELECT
		branch,
		DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
		COUNT(*) as no_tarnsactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as Rrank
	FROM walmart_clean_data
	GROUP BY branch, day_name
)AS sub
WHERE Rrank = 1;

### Q-4 Calculate the total quantity item sold per payment_methord. List the payment methord and quantity?

SELECT 
	payment_method, 
	SUM(quantity) AS no_qty_sold
FROM walmart_clean_data
GROUP BY payment_method;

### Q-5 Determine the average, minimum, and maximum of products for each city. List the city, avg_rating, min_rating, and max_rating.

SELECT
	city,
    category,
    MIN(rating) as min_rating,
    MAX(rating) as max_rating,
    AVG(rating) as avg_rating
FROM walmart_clean_data
GROUP BY city, category;

### Q- 6 Calculate the total profit for each category by cosidering total_profit as (unit_price * quantity * profit_margin). List category and total_profit, ordered from highest to lowest profit.

SELECT 
	category,
    SUM(total) as total_revenue,
    SUM(total * profit_margin) as profit
FROM walmart_clean_data
GROUP BY category;

### Q-7 Determine the most common payment methord for each Branch. Dispaly branch and the prefered payment_method.

WITH cte
AS
(
	SELECT 
		branch,
		payment_method,
		COUNT(*) as total_trans,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as Rrank
		FROM walmart_clean_data
		GROUP BY branch, payment_method
)
SELECT *
FROM cte
WHERE Rrank = 1;

### Q-8 Categorize sales into three group MORNING, AFTERNOON, EVENING. Find out which of the shift and number of invoices.
	
SELECT
	branch,
CASE
		WHEN HOUR(time) < 12 THEN 'Morning'
		WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS total_orders
FROM walmart_clean_data
GROUP BY branch, day_time
ORDER BY branch, total_orders DESC;

### Q-9 Identify 5 branch with highest decrease ratio in reverse compare to last year(current year-2023 and last year-2022).
### rdr == last_rev - cr_rev / ls_rev * 100

WITH revenue_2022 AS
(
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart_clean_data
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
    GROUP BY branch
),

revenue_2023 AS
(
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart_clean_data
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
    GROUP BY branch
)

SELECT 
    ls.branch,
    ls.revenue AS last_yr_revenue,
    cs.revenue AS current_yr_revenue,
    ((ls.revenue - cs.revenue) / ls.revenue) * 100 AS rev_dec_ratio
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs
    ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY rev_dec_ratio DESC
LIMIT 5;
