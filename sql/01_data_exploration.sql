-- Data Exploration 
-- 1. Customers Exploration
SELECT 
	COUNT(customer_id),
	COUNT(DISTINCT customer_id) AS unique_customers
FROM customers;

SELECT Active, COUNT(*)
FROM customers
GROUP BY Active;

SELECT COUNT(*)
FROM customers 
WHERE age IS NULL;

SELECT
	MIN(age),
	MAX(age),
	AVG(age)
FROM customers;

SELECT COUNT(age)
FROM customers
WHERE age > 70;

SELECT 
	fashion_news_frequency, 
	COUNT(*)
FROM customers
GROUP BY fashion_news_frequency;
-- Need to combine NONE and None into one category 

SELECT 
	club_member_status, 
	COUNT(*)
FROM customers 
GROUP BY club_member_status;

SELECT 
	COUNT(DISTINCT postal_code)
FROM customers;

-- 2. Articles Exploration
SELECT COUNT(*)
FROM articles
WHERE article_id IS NULL;

SELECT 
	COUNT(article_id),
	COUNT(DISTINCT article_id)
FROM articles;

SELECT 
	COUNT(DISTINCT article_id),
	COUNT(DISTINCT product_code)
FROM articles;

SELECT
	product_group_name,
	COUNT(article_id)
FROM articles
GROUP BY product_group_name
ORDER BY COUNT(article_id) DESC;

SELECT
	garment_group_name,
	COUNT(article_id)
FROM articles
GROUP BY garment_group_name
ORDER BY COUNT(article_id) DESC;

SELECT COUNT(DISTINCT product_type_name)
FROM articles;

SELECT
	product_type_name,
	COUNT(article_id)
FROM articles
GROUP BY product_type_name
ORDER BY COUNT(article_id) DESC
LIMIT 10;

SELECT COUNT(DISTINCT section_name)
FROM articles;

SELECT
	section_name,
	COUNT(article_id)
FROM articles
GROUP BY section_name
ORDER BY COUNT(article_id) DESC
LIMIT 10;

SELECT
	SUM(CASE WHEN prod_name IS NULL THEN 1 ELSE 0 END) AS prod_name_null,
	SUM(CASE WHEN product_type_name IS NULL THEN 1 ELSE 0 END) AS prod_type_name_null,
	SUM(CASE WHEN colour_group_name IS NULL THEN 1 ELSE 0 END) AS colour_group_null,
	SUM(CASE WHEN section_name IS NULL THEN 1 ELSE 0 END) AS section_name_null
FROM articles;

-- 3. Transactions Exploration
SELECT
	SUM(CASE WHEN t_dat IS NULL THEN 1 ELSE 0 END) AS date_null,
	SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_null,
	SUM(CASE WHEN article_id IS NULL THEN 1 ELSE 0 END) AS article_null,
	SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS price_null,
	SUM(CASE WHEN sales_channel_id IS NULL THEN 1 ELSE 0 END) AS sales_channel_null
FROM transactions_12mo;

SELECT COUNT(DISTINCT customer_id)
FROM transactions_12mo;

SELECT COUNT(DISTINCT article_id)
FROM transactions_12mo;

SELECT 
	sales_channel_id,
	COUNT(*)
FROM transactions_12mo
GROUP BY sales_channel_id;

SELECT
	strftime('%Y-%m', t_dat),
	sales_channel_id,
	COUNT(*)
FROM transactions_12mo
GROUP BY strftime('%Y-%m', t_dat), sales_channel_id;
-- April 2020 has no Channel 1 transactions
-- Combined with H&M's reported COVID store closures, this suggests Channel 1 = store and Channel 2 = online

SELECT 
	MIN(price),
	MAX(price),
	AVG(price)
FROM transactions_12mo;