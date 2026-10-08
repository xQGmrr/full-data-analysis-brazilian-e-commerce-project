USE Brazillian_E_commerce

-- Explore database columns
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS;

-- Explore customer cities
SELECT DISTINCT city FROM dim_customer_geolocation

-- Explore customer states
SELECT DISTINCT [state] FROM dim_customer_geolocation

-- Explore order years
SELECT DISTINCT order_year FROM dim_date
 
-- Explore product categories
SELECT DISTINCT category FROM dim_products

-- Explore review scores
SELECT DISTINCT review_score FROM fact_reviews ORDER BY review_score

-- Explore payment types
SELECT DISTINCT payment_type FROM fact_payments 

-- Explore payment installments
SELECT DISTINCT payment_installments FROM fact_payments ORDER BY payment_installments

-- Explore product categories
SELECT DISTINCT category FROM dim_products


-- Find first and last order dates
SELECT 
	MIN(order_date) AS First_Order,
	MAX(order_date) AS Last_Order
FROM fact_orders;

-- Explore shipping duration
SELECT  DISTINCT
	DATEDIFF(DAY,order_date,order_delivered_carrier_date) AS Shipping_Time
FROM fact_orders
ORDER BY Shipping_Time ASC

-- Explore delivery duration
SELECT  DISTINCT
	DATEDIFF(DAY,order_date,order_delivered_customer_date) AS delivering_Time
FROM fact_orders
ORDER BY delivering_Time ASC


-- Generate overall business KPIs
SELECT 
	'Total Customers' AS Summary ,COUNT(DISTINCT customer_unique_id) AS Report
FROM dim_customers
UNION ALL
SELECT 
	'Total Orders',COUNT(DISTINCT order_id) 
FROM fact_orders
UNION ALL
SELECT 
	'Total products',COUNT(DISTINCT product_id)
FROM dim_products
UNION ALL
SELECT 
	'Total categories',COUNT(DISTINCT category)
FROM dim_products
UNION ALL
SELECT 
	'Product revenue',ROUND(SUM(price),0) 
FROM fact_order_items
UNION ALL
SELECT 
	'Freight revenue',ROUND(SUM(freight_value),0) 
FROM fact_order_items
UNION ALL
SELECT 
	'Total revenue',ROUND(SUM(price+freight_value),0) 
FROM fact_order_items
UNION ALL
SELECT 
	'Average revenue',ROUND(AVG(price+freight_value),0) 
FROM fact_order_items
UNION ALL
SELECT 
	'Average review score',ROUND(AVG(review_score),2) 
FROM fact_reviews;






