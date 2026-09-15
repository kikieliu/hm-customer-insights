-- Data Cleaning 
-- Combine None and NONE entries in fashion_news_frequency into a new clean customer table
CREATE TABLE customers_clean AS
SELECT
	customer_id,
	FN,
	Active,
	club_member_status,
	CASE
		WHEN fashion_news_frequency = 'None' THEN 'NONE'
		ELSE fashion_news_frequency
	END AS fashion_news_frequency,
	age,
	postal_code
FROM customers;

-- Verify frequencies and counts 
SELECT 
	fashion_news_frequency,
	COUNT(*)
FROM customers_clean
GROUP BY fashion_news_frequency;

-- Verify row counts match
SELECT
    (SELECT COUNT(*) FROM customers) AS original_count,
    (SELECT COUNT(*) FROM customers_clean) AS cleaned_count;

-- Create cleaned articles table with only necessary columns
CREATE TABLE articles_clean AS
SELECT 
    article_id,
    product_code,
    prod_name,
    product_type_name,
    product_group_name,
    colour_group_name,
    department_name,
    index_name,
    index_group_name,
    section_name,
    garment_group_name,
    detail_desc
FROM articles;

-- Verify row counts match
SELECT 
    (SELECT COUNT(*) FROM articles) AS original_count,
    (SELECT COUNT(*) FROM articles_clean) AS cleaned_count;