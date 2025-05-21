-- Which categories contribute the most to the overall sales
WITh category_Sales AS (
SELECT  b.category,
        SUM(a.sales_amount) As total_sales
FROM    gold.fact_sales a
LEFT JOIN gold.dim_products b
ON  a.product_key = b.product_key
GROUP BY b.category)
SELECT  category,
        total_sales,
        SUM(total_sales) OVER () overall_sales,
        ROUND((CAST (total_sales As FLOAT)/(SUM(total_sales) OVER ()))*100, 2) As precentage_total
FROM    category_Sales
ORDER BY total_Sales DESC;
-- Which subcategories contribute the most to the overall sales
WITh category_Sales AS (
SELECT  b.subcategory,
        SUM(a.sales_amount) As total_sales
FROM    gold.fact_sales a
LEFT JOIN gold.dim_products b
ON  a.product_key = b.product_key
GROUP BY b.subcategory)
SELECT  subcategory,
        total_sales,
        SUM(total_sales) OVER () overall_sales,
        ROUND((CAST (total_sales As FLOAT)/(SUM(total_sales) OVER ()))*100, 2) As precentage_total
FROM    category_Sales
ORDER BY total_Sales DESC;