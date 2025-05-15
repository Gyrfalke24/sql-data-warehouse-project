-- Find the total sales
SELECT
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales;

-- Find how many items where sold
SELECT
	SUM(quantity) AS totla_quantity
FROM gold.fact_sales;

-- Find the avarage sellingp price
SELECT
	AVG(price) AS avg_price
FROM gold.fact_sales;

-- Find the total number of orders
SELECT
	COUNT(order_number) AS total_orders
FROM gold.fact_sales;
SELECT
	COUNT(DISTINCT order_number) AS total_orders_distinct
FROM gold.fact_sales;

-- Find the total number of products
SELECT
	COUNT(product_key) AS total_products
FROM gold.dim_products;

-- Find the total number of  customers
SELECT
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers;

-- Find the total number of customers that have placed an order
SELECT
	COUNT(DISTINCT customer_key) AS total_customers_order
FROM gold.fact_sales;

-- report of all key metrics of the business
SELECT 'Total Sales' as measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' as measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Price' as measure_name, AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Nbr Orders' as measure_name, COUNT(DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Nbr Products' as measure_name, COUNT(product_key) AS measure_value FROM gold.dim_products
UNION ALL
SELECT 'Total Nbr Customers' as measure_name, COUNT(customer_key) AS measure_value FROM gold.dim_customers;
