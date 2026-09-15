-- Data Preparation
-- Check latest transaction date
SELECT MAX(t_dat)
FROM transactions_train;

-- Create 12-month transaction table
CREATE TABLE transactions_12mo AS
SELECT *
FROM transactions_train
WHERE t_dat > '2019-09-22';

-- Verify date range and check row count
SELECT 
    MIN(t_dat),
    MAX(t_dat),
    COUNT(*)
FROM transactions_12mo;

-- Select 10000 rows for customers sample
SELECT *
FROM customers
LIMIT 10000;

-- Select 10000 rows for transactions sample
SELECT *
FROM transactions_12mo
LIMIT 10000;