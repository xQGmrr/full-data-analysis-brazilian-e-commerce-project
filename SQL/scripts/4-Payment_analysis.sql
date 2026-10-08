SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS orders,
    SUM(payment_value) AS payment_value
FROM fact_payments
GROUP BY payment_type
ORDER BY payment_value DESC;

SELECT
    payment_installments,
    COUNT(DISTINCT order_id) AS orders,
    AVG(payment_value) AS avg_payment
FROM fact_payments
GROUP BY payment_installments
ORDER BY payment_installments;

SELECT
    p.category,
    pay.payment_type,
    COUNT(DISTINCT o.order_id) AS orders,
    SUM(pay.payment_value) AS revenue
FROM fact_orders o
JOIN fact_order_items oi
ON o.order_id = oi.order_id
JOIN dim_products p
ON oi.product_id = p.product_id
JOIN fact_payments pay
ON o.order_id = pay.order_id
GROUP BY
    p.category,
    pay.payment_type
ORDER BY
    p.category,
    revenue DESC;



