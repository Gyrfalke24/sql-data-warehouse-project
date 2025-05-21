-- Analyze the yearly performance of products by comparing
-- each product's sales to both its average performance and the previous year's sales
WITH yearly_product_sales AS (
SELECT  YEAR(a.order_date) AS order_year,
        b.product_name,
        SUM(a.sales_amount) AS current_sales
FROM    gold.fact_sales a
LEFT JOIN gold.dim_products b
ON  a.product_key = b.product_key
WHERE   a.order_date IS NOT NULL
GROUP BY YEAR(a.order_date),b.product_name)
SELECT  order_year,
        product_name,
        current_sales,
        AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
        current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
        CASE WHEN (current_sales - AVG(current_sales) OVER (PARTITION BY product_name)) > 0 THEN 'Above Avg'
        WHEN (current_sales - AVG(current_sales) OVER (PARTITION BY product_name)) < 0 THEn 'Below Avg'
        ELSE 'Avg' END As avg_change,
        -- Year-over-year analysis
        LAG(current_Sales) OVER (PARTITiON BY product_name ORDER BY order_year) As py_sales,
        current_sales - LAG(current_Sales) OVER (PARTITiON BY product_name ORDER BY order_year) As diff_py,
        CASE WHEN (current_sales - LAG(current_Sales) OVER (PARTITiON BY product_name ORDER BY order_year)) > 0 THEN 'Increase'
        WHEN (current_sales - LAG(current_Sales) OVER (PARTITiON BY product_name ORDER BY order_year)) < 0 THEN 'Decrease'
        ELSE 'No Change' END As py_change
FROM    yearly_product_sales;