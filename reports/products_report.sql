/*
===============================================
    Products Report
==============================================

Purpose:
    - This report consolidates key product metrics and behaviors

HIghlights:
    1. Gathers essential fields such as product name, cateogry,subcategory, and cost.
    2. Segments products by revenue to idnetify High-Performers, Mid-Range, or Low-Performers
    3. Aggregate product-levle metrics:
        * Total orders
        * Total Sales
        * Total quantity sold
        * Total Customers (Unique)
        * lifespan (in months)
    4. Calculate vluable KPIs:
        * recency (months since last order)
        * avarage order revenue (AOR)
        * averga monthly revenue
*/ 
IF OBJECT_ID('gold.report_products','V') IS NOT NULL
  DROP VIEW gold.report_products
GO

CREATE VIEW gold.report_products AS
WITH base_query AS (
/*--------------------------------------------------------------------
1)  Base Query: Retrieves core columns from tables
----------------------------------------------------------------------*/
SELECT  a.order_number,
        a.customer_key,
        a.order_date,
        a.sales_amount,
        a.quantity,
        b.product_key,
        b.product_name,
        b.category,
        b.subcategory,
        b.cost
FROM    gold.fact_sales a
LEFT JOIN gold.dim_products b
ON a.product_key = b.product_key
WHERE   order_date IS NOT NULL),
product_aggregation AS (
/*--------------------------------------------------------------------
2)  Prodcut Aggregations: Summarizes key metrics at the product level
----------------------------------------------------------------------*/  
SELECT  product_key,
        product_name,
        category,
        subcategory,
        cost,
        COUNT(DISTINCT order_number) As total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT customer_key) AS total_unique_customers,
        MAX(order_date) As last_order,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) As avg_selling_price
FROM   base_query
GROUP BY product_key,
        product_name,
        category,
        subcategory,
        cost)
SELECT  product_key,
        product_name,
        category,
        subcategory,
        cost,
        CASE WHEN total_sales > 50000 THEN 'High-Performer'
            WHEN total_sales >= 10000 THEN 'Mid-Performer'
        ELSE 'Low_Performer' END As product_segment,
        DATEDIFF(month, last_order, GETDATE()) As recency_months,
        total_orders,
        total_sales,
        total_quantity,
        total_unique_customers,
        last_order,
        lifespan,
        avg_selling_price,
        -- Compute Average Order Value (AVO)
        CASE WHEN total_orders = 0 THEn 0
        ELSE total_sales/total_orders END As avg_order_revenue,
        -- Compute average monthly spend
        CASE WHEN lifespan = 0 THEn total_sales
        ELSE total_sales/lifespan END As avg_monthly_revenue
FROM    product_aggregation;