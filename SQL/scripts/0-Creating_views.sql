-- Dimension: Customer information
CREATE OR ALTER VIEW dim_customers AS
SELECT *	
FROM olist_customers_dataset$


-- Dimension: Date information linked to orders
CREATE OR ALTER VIEW dim_date AS
SELECT 
	order_id,
	order_purchase_timestamp AS order_date,
	[Year] AS order_year,
	[Month Name] AS order_month_name,
	[Month] AS order_month,
	[Quarter] AS order_quarter,
	[Week of Year] AS order_week,
	[Day Name] AS order_day_name,
	[Day of Week] AS order_day_of_week
FROM olist_date_dataset$


-- Dimension: Customer geographical information
CREATE OR ALTER VIEW dim_customer_geolocation AS
SELECT * 
FROM olist_dim_geolocation_customer_$


-- Dimension: Seller geographical information
CREATE OR ALTER VIEW dim_seller_geolocation AS
SELECT * 
FROM olist_dim_geolocation_dataset$


-- Dimension: Seller information
CREATE OR ALTER VIEW dim_seller AS
SELECT * 
FROM olist_sellers_dataset$


-- Dimension: Product information with translated and standardized categories
CREATE OR ALTER VIEW dim_products AS
SELECT 
	product_id,
	CASE 
    WHEN p.product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos' 
        THEN 'portable_kitchen'
    WHEN p.product_category_name = 'pc_gamer' 
        THEN 'pc_gamer'
    WHEN p.product_category_name IS NULL 
         OR TRIM(p.product_category_name) = '' 
        THEN 'not provided'
    ELSE product_category_name_english
END AS category,
	product_name_lenght,
	product_description_lenght,
	product_photos_qty,
	product_weight_g,
	product_length_cm,
	product_height_cm,
	product_width_cm
FROM olist_products_dataset$ p 
LEFT JOIN product_category_name_translati$ pt
ON p.product_category_name = pt.product_category_name


-- Fact: Individual products included in each order
CREATE OR ALTER VIEW fact_order_items AS
SELECT * 
FROM olist_order_items_dataset$


-- Fact: Order-level information and important order dates
CREATE OR ALTER VIEW fact_orders AS
SELECT 
	order_id,
	customer_id,
	order_status,
	order_purchase_timestamp AS order_date,
	order_approved_at AS approved_date,
	order_delivered_carrier_date,
	order_delivered_customer_date,
	order_estimated_delivery_date
FROM olist_orders_dataset$


-- Fact: Payment information for each order
CREATE OR ALTER VIEW fact_payments AS
SELECT * 
FROM olist_order_payments_dataset$


-- Fact: Customer reviews with cleaned comments and message availability indicator
CREATE OR ALTER VIEW fact_reviews AS
SELECT *,
	CASE WHEN review_comment_message IS NULL THEN 'review message not provided'
		 ELSE 'review message provided' END AS review_message_provided
FROM
(
SELECT 
	order_id,
	review_id,
	review_score,
	NULLIF(TRIM(review_comment_title),'') AS review_comment_title,
	NULLIF(TRIM(review_comment_message),'') AS review_comment_message,
	review_creation_date,
	review_answer_timestamp
FROM olist_order_reviews_dataset$)t