-- Channel Analysis 
-- Channel 1 and 2 are kept as numeric channel labels because the store/online interpretation is inferred and not officially defined
-- 1. Do more customers purchase through Channel 1 or Channel 2?
SELECT
	sales_channel_id,
	COUNT(DISTINCT customer_id) AS customer_count
FROM transactions_12mo
GROUP BY sales_channel_id;

-- 2. How many customers are Channel 1 only, Channel 2 only, or omnichannel?
SELECT 
	SUM(CASE WHEN used_c1 = 1 AND used_c2 = 0 THEN 1 ELSE 0 END) AS c1_count,
	SUM(CASE WHEN used_c1 = 0 AND used_c2 = 1 THEN 1 ELSE 0 END) AS c2_count,
	SUM(CASE WHEN used_c1 = 1 AND used_c2 = 1 THEN 1 ELSE 0 END) AS omni_count
FROM (
	SELECT
		customer_id,
		MAX(CASE WHEN sales_channel_id = 1 THEN 1 ELSE 0 END) AS used_c1,
		MAX(CASE WHEN sales_channel_id = 2 THEN 1 ELSE 0 END) AS used_c2
	FROM transactions_12mo
	GROUP BY customer_id
);

-- 3. Are omnichannel customers more engaged/valuable than single-channel customers?
SELECT 
	channel_type,
	COUNT(*) AS customer_count,
	AVG(purchase_days) AS avg_purchase_days,
	SUM(CASE WHEN purchase_days > 1 THEN 1 ELSE 0 END) / (COUNT(*) * 1.0) AS repeat_customer_rate,
	AVG(total_price) AS avg_customer_value
FROM (
	SELECT
		CASE 
			WHEN used_c1 = 1 AND used_c2 = 0 THEN 'Channel 1 Only'
			WHEN used_c1 = 0 AND used_c2 = 1 THEN 'Channel 2 Only' 
			WHEN used_c1 = 1 AND used_c2 = 1 THEN 'Omnichannel'  
		END AS channel_type,
		purchase_days,
		total_price
	FROM (
		SELECT
			customer_id,
			MAX(CASE WHEN sales_channel_id = 1 THEN 1 ELSE 0 END) AS used_c1,
			MAX(CASE WHEN sales_channel_id = 2 THEN 1 ELSE 0 END) AS used_c2,
			COUNT(DISTINCT t_dat) AS purchase_days,
			SUM(price) AS total_price
		FROM transactions_12mo
		GROUP BY customer_id
	)
)
GROUP BY channel_type;

-- 3.5. Why do Channel 2 Only customers have higher average customer value despite similar purchase frequency?
SELECT 
	channel_type,
	AVG(avg_items_per_purchase_day) AS avg_items_per_purchase_day
FROM (
	SELECT
		CASE 
			WHEN used_c1 = 1 AND used_c2 = 0 THEN 'Channel 1 Only'
			WHEN used_c1 = 0 AND used_c2 = 1 THEN 'Channel 2 Only' 
			WHEN used_c1 = 1 AND used_c2 = 1 THEN 'Omnichannel'  
		END AS channel_type,
		avg_items_per_purchase_day
	FROM (
		SELECT
			customer_id,
			(COUNT(*) * 1.0) / COUNT(DISTINCT t_dat) AS avg_items_per_purchase_day,
			MAX(CASE WHEN sales_channel_id = 1 THEN 1 ELSE 0 END) AS used_c1,
			MAX(CASE WHEN sales_channel_id = 2 THEN 1 ELSE 0 END) AS used_c2
		FROM transactions_12mo
		GROUP BY customer_id
	)
)
GROUP BY channel_type;

SELECT 
	channel_type,
	AVG(avg_price) AS avg_item_value
FROM (
	SELECT
		CASE 
			WHEN used_c1 = 1 AND used_c2 = 0 THEN 'Channel 1 Only'
			WHEN used_c1 = 0 AND used_c2 = 1 THEN 'Channel 2 Only' 
			WHEN used_c1 = 1 AND used_c2 = 1 THEN 'Omnichannel'  
		END AS channel_type,
		avg_price
	FROM (
		SELECT
			customer_id,
			AVG(price) AS avg_price,
			MAX(CASE WHEN sales_channel_id = 1 THEN 1 ELSE 0 END) AS used_c1,
			MAX(CASE WHEN sales_channel_id = 2 THEN 1 ELSE 0 END) AS used_c2
		FROM transactions_12mo
		GROUP BY customer_id
	)
)
GROUP BY channel_type;

-- 4. How does channel usage differ by age group?
WITH customer_channels AS (
	SELECT
		customer_id,
		CASE 
			WHEN age <= 25 THEN '16-25'
			WHEN age <= 35 THEN '26-35'
			WHEN age <= 45 THEN '36-45'
			WHEN age <= 55 THEN '46-55'
			WHEN age <= 65 THEN '56-65'
			WHEN age > 65 THEN '66+'
			ELSE 'Unknown'
		END AS age_groups,
		MAX(CASE WHEN sales_channel_id = 1 THEN 1 ELSE 0 END) AS used_c1,
		MAX(CASE WHEN sales_channel_id = 2 THEN 1 ELSE 0 END) AS used_c2
	FROM customer_transaction_view
	GROUP BY customer_id
),

channel_segments AS (
	SELECT
		age_groups,
		CASE 
			WHEN used_c1 = 1 AND used_c2 = 0 THEN 'Channel 1 Only'
			WHEN used_c1 = 0 AND used_c2 = 1 THEN 'Channel 2 Only'
			WHEN used_c1 = 1 AND used_c2 = 1 THEN 'Omnichannel'
		END AS channel_type
	FROM customer_channels
),

age_channel_counts AS (
	SELECT
		age_groups,
		channel_type,
		COUNT(*) AS customer_count
	FROM channel_segments
	GROUP BY age_groups, channel_type
)

SELECT
	age_groups,
	channel_type,
	customer_count,
	customer_count * 1.0
		/ SUM(customer_count) OVER (PARTITION BY age_groups) AS channel_share
FROM age_channel_counts;

-- 5. How did channel activity change over time?
SELECT 
	strftime('%Y-%m', t_dat) AS month,
	sales_channel_id,
	COUNT(DISTINCT customer_id) AS unique_customers
FROM transactions_12mo
GROUP BY month, sales_channel_id
ORDER BY month, sales_channel_id;
-- September 2019 and September 2020 are partial months and should not be compared directly with full months 
-- April 2020 has no Channel 1 activity; this is treated as an observed pattern rather than missing data because it aligns with real-world disruption during that period