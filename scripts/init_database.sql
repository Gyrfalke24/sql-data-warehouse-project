/*
=====================================
Create Database and Schemas
=====================================
Script Purpose:
  This script creates a new database anmed 'DatWarehouse' after checking if it already exists.
  If the database exists, it is dropped and recreated. Additonally, the script sets up three schemas
  within the database: 'bronze', 'silver', 'gold'

WARNING:

  Running this script will drop the entire 'DataWarehouse' database if it exists.
  All data int eh database will be permanenetly deleted. Proceed with caution
  and ensure you have the proper backups  before running this script.

*/

USE master;
GO

-- Drop and create the 'DataWarehouse' datbase
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
  ALTER DATABASE DatWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE DataWarehouse;
END;
GO

-- Create Database 'DataWarehouse'
CREATE DATABASE DataWarehouse;
GO
  
USE DataWarehouse;
GO

-- Create a Schema
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
