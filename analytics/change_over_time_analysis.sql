-- Aggregation by Year of sales
SELECT  YEAR(order_date) as order_year,
        SUM(sales_amount) AS total_sales,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(quantity) As total_quantity
FROM    gold.fact_sales
WHERE   order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date) ASC;

-- Aggregation by Year and Month (int) of sales
SELECT  YEAR(order_date) as order_year,
        MONTH(order_date) as order_month,
        SUM(sales_amount) AS total_sales,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(quantity) As total_quantity
FROM    gold.fact_sales
WHERE   order_date IS NOT NULL
GROUP BY YEAR(order_date),MONTH(order_date)
ORDER BY YEAR(order_date) ASC, MONTH(order_date) ASC;

-- Aggregation by using date trunc function on sales=
SELECT  DATETRUNC(month, order_date) as order_date,
        SUM(sales_amount) AS total_sales,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(quantity) As total_quantity
FROM    gold.fact_sales
WHERE   order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);

-- Aggregation by using the FORMAT function on sales
SELECT  FORMAT(order_date, 'yyyy-MMM') as order_date,
        SUM(sales_amount) AS total_sales,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(quantity) As total_quantity
FROM    gold.fact_sales
WHERE   order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM') 
ORDER BY FORMAT(order_date, 'yyyy-MMM');