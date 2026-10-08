-- Calculate average delivery time
SELECT
    AVG(DATEDIFF(DAY,order_date,order_delivered_customer_date)) AS avg_delivery_days
FROM fact_orders
WHERE order_delivered_customer_date IS NOT NULL;

-- Find orders taking more than 100 days
SELECT
    order_date,
    order_delivered_customer_date,
    DATEDIFF(DAY,order_date,order_delivered_customer_date) AS delivery_days
FROM fact_orders
WHERE DATEDIFF(DAY,order_date,order_delivered_customer_date) > 100;


-- Compare actual vs estimated delivery time
SELECT
    AVG(DATEDIFF(DAY,order_date,order_delivered_customer_date)) AS actual_delivery_days,
    AVG(DATEDIFF(DAY,order_date,order_estimated_delivery_date)) AS estimated_delivery_days
FROM fact_orders
WHERE order_delivered_customer_date IS NOT NULL;


-- Compare delivery status with review scores
SELECT
    CASE WHEN o.order_delivered_customer_date < o.order_estimated_delivery_date THEN 'Early'
         WHEN o.order_delivered_customer_date = o.order_estimated_delivery_date THEN 'On Time'
         ELSE 'Late' END AS delivery_status,
    AVG(r.review_score) AS avg_review_score,
    COUNT(*) AS reviews
FROM fact_orders o
JOIN fact_reviews r
ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY
    CASE WHEN o.order_delivered_customer_date < o.order_estimated_delivery_date THEN 'Early'
         WHEN o.order_delivered_customer_date = o.order_estimated_delivery_date THEN 'On Time'
         ELSE 'Late' END;


-- Calculate late delivery rate
SELECT
    100.0 * SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1
                     ELSE 0 END) / COUNT(*) AS late_delivery_rate
FROM fact_orders
WHERE order_delivered_customer_date IS NOT NULL;


-- Calculate monthly revenue
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(price) AS revenue
FROM fact_order_items oi LEFT JOIN dim_date d
ON d.order_id = oi.order_id
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    order_year,
    order_month;


-- Calculate month-over-month revenue growth
WITH monthly_revenue AS
(
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(price) AS revenue
    FROM fact_order_items oi LEFT JOIN dim_date d
    ON d.order_id = oi.order_id
    GROUP BY
        YEAR(order_date),
        MONTH(order_date)
),

previous_month AS
(
    SELECT *,
        LAG(revenue) OVER(ORDER BY order_year, order_month) AS previous_revenue
    FROM monthly_revenue
)

SELECT
    order_year,
    order_month,
    revenue,
    previous_revenue,

    ROUND(100.0 * (revenue - previous_revenue) / NULLIF(previous_revenue, 0),2) AS mom_growth_percentage
FROM previous_month;


-- Calculate cumulative revenue over time
WITH monthly_revenue AS
(
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(price) AS revenue
    FROM fact_order_items oi LEFT JOIN dim_date d
    ON d.order_id = oi.order_id
    GROUP BY
        YEAR(order_date),
        MONTH(order_date)
)
SELECT
    order_year,
    order_month,
    revenue,

    SUM(revenue) OVER(ORDER BY order_year, order_month
                      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue
FROM monthly_revenue;


-- Calculate yearly revenue by product category
WITH category_year AS
(
    SELECT
        YEAR(o.order_date) AS order_year,
        p.category,
        SUM(oi.price) AS revenue
    FROM fact_orders o
    JOIN fact_order_items oi
    ON o.order_id = oi.order_id
    JOIN dim_products p
    ON oi.product_id = p.product_id
    GROUP BY
        YEAR(o.order_date),
        p.category
),

-- Rank categories by revenue for each year
ranked AS
(
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY order_year ORDER BY revenue DESC) AS category_rank
    FROM category_year
)
SELECT *
FROM ranked
WHERE category_rank = 1;