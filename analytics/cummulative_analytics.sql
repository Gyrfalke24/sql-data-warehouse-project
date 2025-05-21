-- Calcualte  the total sales for each month and the running total

SELECT  order_date,
        total_sales,
        SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
    FROM (
SELECT  DATETRUNC(month, order_date) AS order_date,
        SUM(sales_amount) AS total_sales
FROM    gold.fact_sales
WHERE   order_date IS NOT NULL
GROUP BY  DATETRUNC(month, order_date))t;

-- Running total cummulative analysis and moving average partitioned by year
SELECT  order_date,
        total_sales,
        SUM(total_sales) OVER (PARTITION BY YEAR(order_date) ORDER BY order_date) AS running_total_sales,
        AVG(avg_price) OVER (PARTITION BY YEAR(order_date) ORDER BY order_date) AS Moving_average_price
    FROM (
SELECT  DATETRUNC(month, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) as avg_price
FROM    gold.fact_sales
WHERE   order_date IS NOT NULL
GROUP BY  DATETRUNC(month, order_date))t;
