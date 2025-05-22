/*
===============================================
    Customer Report
==============================================

Purpose:
    - This report consolidates key customer metrics and behaviors

HIghlights:
    1. Gathers essential fields such as names, ages, and transactions details.
    2. Segments customers into categories (VIP, Regular, New) and age groups
    3. Aggregate customers-levle metrics:
        * Total orders
        * Total Sales
        * Total quantity purchased
        * Total Products
        * lifespan
    4. Calculate vluable KPIs:
        * recency (months since last order)
        * avarage order value
        * averga monthly stipnend
*/ 
IF OBJECT_ID('gold.report_customers','V') IS NOT NULL
  DROP VIEW gold.report_customers
GO

CREATE VIEW gold.report_customers AS
WITH base_query AS (
/*--------------------------------------------------------------------
1)  Base Query: Retrieves core columns from tables
----------------------------------------------------------------------*/
SELECT  a.order_number,
        a.product_key,
        a.order_date,
        a.sales_amount,
        a.quantity,
        b.customer_key,
        b.customer_number,
        CONCAT(b.first_name, ' ', b.last_name) As customer_name,
        DATEDIFF(year, b.birth_date, GETDATE()) AS age
FROM    gold.fact_sales a
LEFT JOIN gold.dim_customers b
ON a.customer_key = b.customer_key
WHERE   order_date IS NOT NULL),
customer_aggregation AS (
/*--------------------------------------------------------------------
2)  Customer Aggregations: Summarizes key metrics at the customer level
----------------------------------------------------------------------*/  
SELECT  customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) As total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) As last_order,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM   base_query
GROUP BY customer_key,
        customer_number,
        customer_name,
        age)
SELECT  customer_key,
        customer_number,
        customer_name,
        age,
        CASE WHEN age < 20 THEN 'Under 20'
            WHEN age BETWEEN 20 AND 29 THEN '20-29'
            WHEN age BETWEEN 30 AND 39 THEN '30-39'
            WHEN age BETWEEN 40 AND 49 THEN '40-49'
            ELSE 'Above 50' END As age_group,
        CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New' END As customer_type,
        DATEDIFF(month, last_order, GETDATE()) As recency_months,
        total_orders,
        total_sales,
        total_quantity,
        total_products,
        last_order,
        lifespan,
        -- Compute Average Order Value (AVO)
        CASE WHEN total_orders = 0 THEn 0
        ELSE total_sales/total_orders END As avg_order_value,
        -- Compute average monthly spend
        CASE WHEN lifespan = 0 THEn total_sales
        ELSE total_sales/lifespan END As avg_monthly_spend
FROM    customer_aggregation;