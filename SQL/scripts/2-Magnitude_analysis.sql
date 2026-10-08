SELECT
    order_status,
    COUNT(*) AS order_count
FROM fact_orders
GROUP BY order_status
ORDER BY order_count DESC;

SELECT
    category,
    COUNT(*) AS product_count
FROM dim_products
GROUP BY category
ORDER BY product_count DESC;


SELECT
    p.category,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price),0) AS revenue,
    ROUND(AVG(oi.price),0) AS avg_product_price,
    ROUND(AVG(oi.freight_value),0) AS AverageFreightValue
FROM fact_order_items oi
JOIN dim_products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

SELECT TOP 10
    p.category,
    ROUND(SUM(oi.price),0) AS revenue
FROM fact_order_items oi
JOIN dim_products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT order_id) AS order_count
FROM fact_orders o LEFT JOIN dim_customers c on o.customer_id = c.customer_id 
GROUP BY c.customer_unique_id
ORDER BY order_count DESC;

WITH customer_orders AS
(
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM fact_orders o
    JOIN dim_customers c
    ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    CASE WHEN order_count = 1 THEN 'One-Time Customer'
         ELSE 'Repeat Customer' END AS customer_type,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY
    CASE WHEN order_count = 1 THEN 'One-Time Customer'
    ELSE 'Repeat Customer' END;


SELECT
    c.customer_unique_id,
    SUM(oi.price) AS product_spending,
    SUM(oi.freight_value) AS freight_spending,
    SUM(oi.price + oi.freight_value) AS total_spending
FROM fact_orders o
JOIN dim_customers c
ON o.customer_id = c.customer_id
JOIN fact_order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spending DESC;


SELECT 
    COUNT(*) AS orders_count
FROM fact_reviews

SELECT 
	review_message_provided,
	COUNT(DISTINCT order_id) AS rev_msg_count 
From
(
SELECT 
	o.order_id,
	review_id,
	review_score,
	CASE WHEN r.review_id IS NULL THEN 'review is not provided' 
    WHEN r.review_comment_message IS NULL THEN 'review message not provided' ELSE 'review message provided' END AS review_message_provided
FROM fact_reviews r FULL OUTER JOIN fact_orders o
ON r.order_id = o.order_id)t
GROUP BY review_message_provided
ORDER BY rev_msg_count DESC


SELECT
    review_score,
    COUNT(*) AS reviews
FROM fact_reviews
GROUP BY review_score
ORDER BY reviews DESC;

