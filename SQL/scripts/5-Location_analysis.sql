SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS orders,
    SUM(oi.price + oi.freight_value) AS revenue
FROM fact_orders o
JOIN dim_customers c
ON o.customer_id = c.customer_id
JOIN fact_order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS customers
FROM dim_customers
GROUP BY customer_state
ORDER BY customers DESC;



SELECT
    c.customer_state,
    AVG(DATEDIFF(DAY,o.order_date,o.order_delivered_customer_date)) AS avg_delivery_days
FROM fact_orders o
JOIN dim_customers c
ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;

