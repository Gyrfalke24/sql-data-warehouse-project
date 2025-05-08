/*
========================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
========================================

Script Purpose:
  This stored procedure loads datq into the 'silver' schema from 'bronze' schema.
  It performs the following actions:
  - Ttruncates the silver tables before loading data.
  - Apply transfromations and cleanfrom bronze tables querying for insertion.

Paramters:
  None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC silver.load_silver;
*/
CREATE OR ALTER PROCEDURE SILVER.LOAD_SILVER AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '========================================';
		PRINT 'Loading Silver Layer';
		PRINT '========================================';

		PRINT '----------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '----------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating table CRM_CUST_INFO';
		TRUNCATE TABLE SILVER.CRM_CUST_INFO;
		PRINT '>> Inserting records to CRM_CUST_INFO';
		INSERT INTO SILVER.CRM_CUST_INFO (
			CST_ID,
			CST_KEY,
			CST_FIRSTNAME,
			CST_LASTNAME,
			CST_MARITAL_STATUS,
			CST_GNDR,
			CST_CREATE_DATE)
		SELECT	CST_ID,
				CST_KEY,
				TRIM(CST_FIRSTNAME) AS CST_FIRSTNAME,
				TRIM(CST_LASTNAME) AS CST_LASTNAME,
				CASE	WHEN UPPER(TRIM(CST_MARITAL_STATUS)) = 'S' THEN 'Single'
						WHEN UPPER(TRIM(CST_MARITAL_STATUS)) = 'M' THEN 'Married'
						ELSE 'n/a' END CST_MARITAL_STATUS, -- Normalize marital status values to readable format
				CASE	WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
						WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
						ELSE 'n/a' END CST_GNR,-- Normalize gender status values to readable format
				cst_create_date
		FROM (
		SELECT
		*, ROW_NUMBER() OVER (PARTITION BY CST_ID ORDER BY CST_CREATE_DATE DESC) AS FLAG_LAST
		FROM	BRONZE.CRM_CUST_INFO
		WHERE	CST_ID IS NOT NULL) T WHERE T.FLAG_LAST = 1;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds';
		PRINT '----------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating table CRM_PRD_INFO';
		TRUNCATE TABLE SILVER.CRM_PRD_INFO;
		PRINT '>> Inserting records to CRM_PRD_INFO';
		INSERT INTO SILVER.CRM_PRD_INFO (
			PRD_ID,
			CAT_ID,
			PRD_KEY,
			PRD_NM,
			PRD_COST,
			PRD_LINE,
			PRD_START_DT,
			PRD_END_DT
		)
		SELECT
			PRD_ID,
			REPLACE(SUBSTRING(PRD_KEY,1,5),'-','_') AS CAT_ID,-- Extract category ID
			SUBSTRING(PRD_KEY,7,LEN(PRD_KEY)) AS PRD_KEY,-- Extract the product KEY
			PRD_NM,
			ISNULL(PRD_COST,0) AS PRD_COST,
			CASE UPPER(TRIM(PRD_LINE))  
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a' END AS PRD_LINE, -- Map product line codes to descriptive values
			CAST(PRD_START_DT AS DATE) AS PRD_START_DT,
			CAST(LEAD(PRD_START_DT) OVER (PARTITION BY PRD_KEY ORDER BY PRD_START_DT)-1 AS DATE) AS PRD_END_DT -- Calcualte end date as one day before the next start day
		FROM BRONZE.CRM_PRD_INFO;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds';
		PRINT '----------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating table CRM_SALES_DETAILS';
		TRUNCATE TABLE SILVER.CRM_SALES_DETAILS;
		PRINT '>> Inserting records to CRM_SALES_DETAILS';
		INSERT INTO SILVER.CRM_SALES_DETAILS (
			SLS_ORD_NUM,
			SLS_PRD_KEY,
			SLS_CUST_ID,
			SLS_ORDER_DT,
			SLS_SHIP_DT,
			SLS_DUE_DT,
			SLS_SALES,
			SLS_QUANTITY,
			SLS_PRICE
		)
		SELECT	SLS_ORD_NUM,
				SLS_PRD_KEY,
				SLS_CUST_ID,
				CASE WHEN SLS_ORDER_DT = 0 OR LEN(SLS_ORDER_DT) != 8 THEN NULL
					ELSE CAST(CAST(SLS_ORDER_DT AS VARCHAR) AS DATE)
				END AS SLS_ORDER_DT,
				CASE WHEN SLS_SHIP_DT = 0 OR LEN(SLS_SHIP_DT) != 8 THEN NULL
					ELSE CAST(CAST(SLS_SHIP_DT AS VARCHAR) AS DATE)
				END AS SLS_SHIP_DT,
				CASE WHEN SLS_DUE_DT = 0 OR LEN(SLS_DUE_DT) != 8 THEN NULL
					ELSE CAST(CAST(SLS_DUE_DT AS VARCHAR) AS DATE)
				END AS SLS_DUE_DT,
				CASE WHEN SLS_SALES IS NULL OR SLS_SALES <= 0 OR SLS_SALES != SLS_QUANTITY*ABS(SLS_PRICE)
					THEN SLS_QUANTITY*ABS(SLS_PRICE)
					ELSE SLS_SALES
				END AS SLS_SALES, -- Recalculate slaes if original values is missing or incorrect
				SLS_QUANTITY,
				CASE WHEN SLS_PRICE IS NULL OR SLS_PRICE <= 0
					THEN SLS_SALES/NULLIF(SLS_QUANTITY, 0)
				ELSE SLS_PRICE 
				END	AS SLS_PRICE
		FROM	BRONZE.CRM_SALES_DETAILS;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds';
		PRINT '----------------';

		PRINT '----------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '----------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating table ERP_CUST_AZ12';
		TRUNCATE TABLE SILVER.ERP_CUST_AZ12;
		PRINT '>> Inserting records to ERP_CUST_AZ12';
		INSERT INTO SILVER.ERP_CUST_AZ12 (
			CID,
			BDATE,
			GEN
		)
		SELECT	CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4,LEN(CID))
				ELSE CID END AS CID, -- Remove NAS Prefix
				CASE WHEN BDATE > GETDATE() THEN NULL
				ELSE BDATE END AS BDATE, -- Set future date to NULL
				CASE WHEN UPPER(TRIM(GEN)) IN ('F','FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(GEN)) IN ('M','MALE') THEN 'Male'
				ELSE 'n?a' END AS GEN -- Normalize gender values and handle unknown cases
		FROM	BRONZE.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds';
		PRINT '----------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating table ERP_LOC_A101';
		TRUNCATE TABLE SILVER.ERP_LOC_A101;
		PRINT '>> Inserting records to ERP_LOC_A101';
		INSERT INTO SILVER.ERP_LOC_A101 (
			CID,
			CNTRY
		)
		SELECT	REPLACE(CID,'-','') AS CID,
				CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
				WHEN TRIM(CNTRY) IN ('US','USA') THEN 'United States'
				WHEN TRIM(CNTRY) = ' ' OR CNTRY IS NULL THEN 'n/a'
				ELSE CNTRY END AS CNTRY
		FROM	BRONZE.ERP_LOC_A101;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds';
		PRINT '----------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating table erp_px_cat_g1v2';
		TRUNCATE TABLE SILVER.erp_px_cat_g1v2;
		PRINT '>> Inserting records to erp_px_cat_g1v2';
		INSERT INTO SILVER.erp_px_cat_g1v2 (
			ID,
			CAT,
			SUBCAT,
			MAINTENANCE
		)
		SELECT	ID,
				CAT,
				SUBCAT,
				MAINTENANCE
		FROM	BRONZE.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds';
		PRINT '----------------';
		SET @batch_end_time = GETDATE();
		PRINT 'Silver Layer Load Completed: '+ CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) as NVARCHAR) + ' seconds';
	END TRY
	BEGIN CATCH
		PRINT '===========================================';
		PRINT 'ERROR OCURRED DURING LOAING SILVER LAYER';
		PRINT 'Error Message' + CAST(ERROR_MESSAGE() AS NVARCHAR);
		PRINT 'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT '===========================================';
	END CATCH
END
