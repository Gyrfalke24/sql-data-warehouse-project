# Modern Data Warehouse Project
---

## Summary
The project consist on the apploication of modern concepts for building a data warehouse. It is intended for learning and skill building applications. The project will utilize MS SQL Server as the DBM for the data warehouse. DRAW.io for documntaion of diagrams. Git for version control and documentation of the work performed.

## Architecture
The project will follow the following architecture:

### Source
For the source, there are a total of 6 CSV files that will be utilized as the source files. Three contain transation, product, and customer records denominated by the prefix CRm and the other three ERP files will contain reference infromation.

### Data Warehouse

This wil follow a Medallion Model Architecture. Which consistes in three layers for the data warehouse where teh ETL operations will take place:

* **Bronze** - The ingestion phase where the data will be taken raw fromt he CSV files
* **Silver** - The transfromation and cleaning phase of the data ingested in the bronze layer.
* **Gold** - The Preparation of the business views for data analytics and reporting.

![Data Architecture Diagram](./docs/Data_Architecture_Diag.drawio.png)

![Data Pipeline Diagram](./docs/Data_Pipeline.drawio.png)