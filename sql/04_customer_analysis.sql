-- Customer Analysis 
-- Create view for analysis 
CREATE VIEW customer_transaction_view AS
SELECT * 
FROM customers_clean
INNER JOIN transactions_12mo
USING(customer_id);

-- 1. How often do customers purchase?
SELECT
	MIN(purchases),
	MAX(purchases),
	AVG(purchases)
FROM (
	SELECT 
		customer_id,
		COUNT(DISTINCT t_dat) AS purchases
	FROM customer_transaction_view
	GROUP BY customer_id
);

-- 2. How many customers are repeat customers?
SELECT
	SUM(CASE WHEN purchases = 1 THEN 1 ELSE 0 END) AS one,
	SUM(CASE WHEN purchases >1 AND purchases <=3 THEN 1 ELSE 0 END) AS two_to_three,
	SUM(CASE WHEN purchases >3 AND purchases <=6 THEN 1 ELSE 0 END) AS four_to_six,	
	SUM(CASE WHEN purchases >=7 THEN 1 ELSE 0 END) AS seven_or_more
FROM (
	SELECT
		customer_id,
		COUNT(DISTINCT t_dat) AS purchases 
	FROM customer_transaction_view
	GROUP BY customer_id
);

SELECT
	COUNT(*) AS total_customers,
	SUM(CASE WHEN purchases > 1 THEN 1 ELSE 0 END) AS repeat_customers,
	SUM(CASE WHEN purchases > 1 THEN 1 ELSE 0 END) / (COUNT(*) * 1.0) AS repeat_customer_rate
FROM (
	SELECT 
		customer_id, 
		COUNT(DISTINCT t_dat) AS purchases 
	FROM customer_transaction_view
	GROUP BY customer_id
);


-- 3. How recently did customers last purchase?
SELECT 
	recency_band,
	COUNT(*) AS customer_count
FROM(
	SELECT 
		customer_id, 
		days,
		CASE 
			WHEN days <= 30 THEN '0-30 days'
			WHEN days <=60 THEN '31-60 days'
			WHEN days <= 90 THEN '61-90 days'
			WHEN days <= 180 THEN '91-180 days'
			ELSE '181+ days'
		END AS recency_band
	FROM (
		SELECT 
			customer_id,
			julianday('2020-09-22') - julianday(MAX(t_dat)) AS days
	FROM customer_transaction_view
	GROUP BY customer_id
	)
)
GROUP BY recency_band
ORDER BY CASE recency_band
	WHEN '0-30 days' THEN 1
	WHEN '31-60 days' THEN 2
	WHEN '61-90 days' THEN 3
	WHEN '91-180 days' THEN 4
	ELSE 5
END;

-- 4. How does purchasing behavior differ by age_group?
SELECT
	age_groups,
	COUNT(*) AS total_customers,
	AVG(purchase_days) AS avg_purchase_days,
	SUM(CASE WHEN purchase_days > 1 THEN 1 ELSE 0 END) AS repeat_customers,
	SUM(CASE WHEN purchase_days > 1 THEN 1 ELSE 0 END) / (COUNT(*) * 1.0) AS repeat_customer_rate,
	AVG(total_price) AS avg_customer_value
FROM (
	SELECT
		CASE 
			WHEN age <= 25 THEN '16-25'
			WHEN age <= 35 THEN '26-35'
			WHEN age <= 45 THEN '36-45'
			WHEN age <= 55 THEN '46-55'
			WHEN age <= 65 THEN '56-65'
			WHEN age >65 THEN '66+'
			ELSE 'Unknown'
		END as age_groups,
		COUNT(DISTINCT t_dat) AS purchase_days,
		SUM(price) AS total_price
	FROM customer_transaction_view
	GROUP BY customer_id
)
GROUP BY age_groups;

-- 5. Do customer membership/ marketing attributes relate to purchasing behavior?
-- Membership
SELECT 
	club_member_status,
	COUNT(*) AS customer_count,
	AVG(purchase_days) AS avg_purchase_days,
	SUM(CASE WHEN purchase_days > 1 THEN 1 ELSE 0 END) / (COUNT(*) * 1.0) AS repeat_customer_rate,
	AVG(total_price) AS avg_customer_value
FROM (
	SELECT 
		customer_id,
		club_member_status,
		COUNT(DISTINCT t_dat) AS purchase_days,
		SUM(price) AS total_price
	FROM customer_transaction_view
	GROUP BY customer_id
)
GROUP BY club_member_status;

-- Fashion News Frequency 
SELECT 
	fashion_news_frequency,
	COUNT(*) AS customer_count,
	AVG(purchase_days) AS avg_purchase_days,
	SUM(CASE WHEN purchase_days > 1 THEN 1 ELSE 0 END) / (COUNT(*) * 1.0) AS repeat_customer_rate,
	AVG(total_price) AS avg_customer_value
FROM (
	SELECT 
		customer_id,
		fashion_news_frequency,
		COUNT(DISTINCT t_dat) AS purchase_days,
		SUM(price) AS total_price
	FROM customer_transaction_view
	GROUP BY customer_id
)
GROUP BY fashion_news_frequency;