-- Segment products into cost ranges and count how many products fall into each segment

WITH products_segments AS (
SELECT  product_key,
        product_name,
        cost,
        CASE WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END As cost_range
FROM    gold.dim_products)
SELECT  cost_range,
        COUNT(product_key) AS total_products
FROM    products_segments
GROUP BY cost_range
ORDER BY total_products DESC;

/*
Gorup customers into three segments based ont heir spending behavior:
    - VIP: Customers with at least 12 months of history and spending more than 5,000 $
    - Regular: Customers with at least 12 months of history but sepending 5,000 $ or less
    - New: Customers with a lifespan less than 12 months
And infd the total numbers of customers by each group
*/
WITH customer_class AS (
SELECT  customer_key,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS span,
        SUM(sales_amount) As total_spent,
        CASE WHEN DATEDIFF(month, MIN(order_date), MAX(order_date)) >= 12 AND SUM(sales_amount) > 5000 THEN 'VIP'
            WHEN DATEDIFF(month, MIN(order_date), MAX(order_date)) >= 12 AND SUM(sales_amount) <= 5000 THEN 'Regular'
            WHEN DATEDIFF(month, MIN(order_date), MAX(order_date)) < 12 THEN 'New'
            ELSE 'N/A' END As customer_type
FROM    gold.fact_sales
GROUP BY customer_key)
SELECT  customer_type,
        COUNT(customer_key) As total_customers
FROM    customer_class
GROUP BY customer_type
ORDER BY total_customers DESC; -- N/A results mean no order date span