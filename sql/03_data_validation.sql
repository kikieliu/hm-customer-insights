-- Data Validation 
-- Check that customer keys are unique and not NULL
SELECT customer_id
FROM customers_clean
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT COUNT(*)
FROM customers_clean
WHERE customer_id IS NULL;

-- Check that article keys are unique and not NULL
SELECT article_id
FROM articles_clean
GROUP BY article_id
HAVING COUNT(*) > 1;

SELECT COUNT(*)
FROM articles_clean
WHERE article_id IS NULL;

-- Check for unmatched customer IDS in transactions
SELECT customer_id
FROM transactions_12mo
WHERE customer_id NOT IN(SELECT customer_id FROM customers_clean); 

-- Check for unmatched article IDS in transactions
SELECT article_id
FROM transactions_12mo
WHERE article_id NOT IN(SELECT article_id FROM articles_clean); 

-- Check sales channels values 
SELECT 
	sales_channel_id,
	COUNT(*)
FROM transactions_12mo
GROUP BY sales_channel_id;

-- Check that the dates are from the last 12 months of dataset
SELECT 
	MIN(t_dat),
	MAX(t_dat)
FROM transactions_12mo;

-- Check that prices are not NULL and positive 
SELECT
	SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS price_null_count,
	SUM(CASE WHEN price <= 0 THEN 1 ELSE 0 END) AS price_negative_count
FROM transactions_12mo;

-- Check that transaction has the same row count before and after joins
SELECT
	(SELECT COUNT(*) FROM transactions_12mo) AS before_join,
	(SELECT COUNT(*)
	 FROM transactions_12mo t
	 INNER JOIN customers_clean c ON t.customer_id = c.customer_id
	 INNER JOIN articles_clean a ON t.article_id = a.article_id) AS after_join;
	 