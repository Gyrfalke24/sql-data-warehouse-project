/*
=======================================================
    Test Queries for Silver Layer
=======================================================
Script Purpose:
  This script is utilized to test the data on the silver layer and created tables
  More tests may be added as needed to ensure data quality and that all tables
  were created correctly.
  
*/


-- Check there are no duplicate entries of customer IDs
SELECT
cst_id
FROM silver.crm_cust_info
GROUP BY cst_id HAVING COUNT(cst_id) > 1;

-- Check for spaces in fields such as first name, last anme
SELECT
cst_firstname
FROM silver.crm_cust_info
WHERE LEN(cst_firstname) != LEN(TRIM(cst_firstname));

-- Verify Only Male, Female, N/A corrrect values an no NULLs or other Values
SELECT DISTINCT cst_gndr FROM silver.crm_cust_info;

-- Check there are no duplicate entries of product IDs
SELECT
prd_id
FROM silver.crm_prd_info
GROUP BY prd_id HAVING COUNT(prd_id) > 1;

-- Check for spaces in fields such as product name, category and so on
SELECT
prd_nm
FROM silver.crm_prd_info
WHERE LEN(prd_nm) != LEN(TRIM(prd_nm));

/*
=============================================================
    Add more test queries to ensure quality of Silver tables
=============================================================
*/

