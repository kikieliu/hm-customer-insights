-- Product Analysis
-- Create indexes to improve product analysis query performance
CREATE INDEX IF NOT EXISTS idx_transactions_article
ON transactions_12mo(article_id);

CREATE INDEX IF NOT EXISTS idx_articles_article
ON articles_clean(article_id);

CREATE INDEX IF NOT EXISTS idx_transactions_customer
ON transactions_12mo(customer_id);

-- Create view for analysis
CREATE VIEW article_transaction_view AS
SELECT * 
FROM articles_clean
INNER JOIN transactions_12mo
USING(article_id);

-- 1. Which product groups/categories are purchased most often?
SELECT
	product_group_name,
	COUNT(*) AS purchase_count
FROM article_transaction_view
GROUP BY product_group_name
ORDER BY purchase_count DESC;

-- 2. Which product groups reach the most unique customers?
SELECT
	product_group_name,
	COUNT(DISTINCT customer_id) AS customer_reach
FROM article_transaction_view
GROUP BY product_group_name
ORDER BY customer_reach DESC;

-- 3. Do product preferences differ by channel type?
WITH customer_channels AS (
	SELECT 
		customer_id,
		MAX(CASE WHEN sales_channel_id = 1 THEN 1 ELSE 0 END) AS used_c1,
		MAX(CASE WHEN sales_channel_id = 2 THEN 1 ELSE 0 END) AS used_c2
	FROM transactions_12mo
	GROUP BY customer_id
),

customer_segments AS (
	SELECT 
		customer_id,
		CASE 
			WHEN used_c1 = 1 AND used_c2 = 0 THEN 'Channel 1 Only'
			WHEN used_c1 = 0 AND used_c2 = 1 THEN 'Channel 2 Only'
			WHEN used_c1 = 1 AND used_c2 = 1 THEN 'Omnichannel'
		END AS channel_type
	FROM customer_channels
)

SELECT
	channel_type,
	product_group_name,
	COUNT(*) as purchase_count,
	COUNT(*) * 1.0
    / SUM(COUNT(*)) OVER (PARTITION BY channel_type) AS purchase_share
FROM customer_segments 
INNER JOIN article_transaction_view
USING(customer_id)
GROUP BY channel_type, product_group_name
ORDER BY channel_type, purchase_share DESC;

-- 4. Do product preferences differ by age group?
WITH age_segmentation AS (
	SELECT
		customer_id,
		CASE 
			WHEN age <= 25 THEN '16-25'
			WHEN age <= 35 THEN '26-35'
			WHEN age <= 45 THEN '36-45'
			WHEN age <= 55 THEN '46-55'
			WHEN age <= 65 THEN '56-65'
			WHEN age >65 THEN '66+'
			ELSE 'Unknown'
		END as age_groups
	FROM customers_clean
)

SELECT
	age_groups, 
	product_group_name,
	COUNT(*) AS purchase_count,
	COUNT(*) * 1.0
	/ SUM(COUNT(*)) OVER (PARTITION BY age_groups) AS purchase_shares
FROM age_segmentation 
INNER JOIN article_transaction_view
USING(customer_id)
GROUP BY age_groups, product_group_name
ORDER BY age_groups, purchase_shares DESC;

-- 5. Are some product groups more associated with repeat or higher-value customers?
-- Repeat
WITH customer_classification AS (
	SELECT 
		customer_id, 
		COUNT(DISTINCT t_dat) AS purchase_days,
		CASE
			WHEN COUNT(DISTINCT t_dat) > 1 THEN 'Repeat'
			ELSE 'One-Time'
		END AS customer_type
	FROM transactions_12mo
	GROUP BY customer_id
)

SELECT
	customer_type, 
	product_group_name,
	COUNT(*) AS purchase_count,
	COUNT(*) * 1.0
	/ SUM(COUNT(*)) OVER (PARTITION BY customer_type) AS purchase_shares
FROM customer_classification
INNER JOIN article_transaction_view
USING(customer_id)
GROUP BY customer_type, product_group_name
ORDER BY customer_type, purchase_shares DESC;

-- Higher-value
WITH customer_value AS (
	SELECT 
		customer_id, 
		SUM(price) AS total_customer_value
	FROM transactions_12mo
	GROUP BY customer_id
),

value_quartiles AS (
	SELECT
		customer_id, 
		total_customer_value, 
		NTILE(4) OVER (ORDER BY total_customer_value) AS value_quartile
	FROM customer_value
)

SELECT
	value_quartile,
	product_group_name,
	COUNT(*) AS purchase_count,
	COUNT(*) * 1.0
	/ SUM(COUNT(*)) OVER (PARTITION BY value_quartile) AS purchase_shares
FROM value_quartiles
INNER JOIN article_transaction_view
USING(customer_id)
GROUP BY value_quartile, product_group_name
ORDER BY value_quartile, purchase_shares DESC;