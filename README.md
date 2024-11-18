# RealTime-Trader-KPI-Analytics

# Trade Data Pipeline for Ecomm (Bronze-Silver-Gold Architecture)

This project demonstrates the creation and management of a **data pipeline** that processes **trade data** using a **Bronze-Silver-Gold** architecture in **Snowflake**. It simulates the flow of raw trading data from ingestion through processing to reporting, ensuring that data is transformed, aggregated, and made ready for business analysis.

The pipeline structure is based on **Futures First's** requirements for trade data analysis, involving the following stages:

- **Bronze Layer**: Raw data ingestion
- **Silver Layer**: Data cleaning and transformation
- **Gold Layer**: Aggregation and business reporting

## Table of Contents

- [Introduction](#introduction)
- [Technologies Used](#technologies-used)
- [Project Workflow](#project-workflow)
- [Setup Instructions](#setup-instructions)
  - [Prerequisites](#prerequisites)
  - [Snowflake Setup](#snowflake-setup)
  - [Data Generation (Mock Data)](#data-generation-mock-data)
- [Detailed Steps of the Pipeline](#detailed-steps-of-the-pipeline)
- [Challenges Faced](#challenges-faced)
- [Outcome](#outcome)
- [Real-World Usefulness](#real-world-usefulness)
- [Future Improvements](#future-improvements)
- [Error Handling and Logging](#error-handling-and-logging)
- [Running the Pipeline](#running-the-pipeline)
- [License](#license)

## Introduction

This project involves the creation of a Snowflake-based data pipeline designed to process and aggregate trade data. The pipeline simulates **Change Data Capture (CDC)** by generating mock data, inserting it into raw tables, and processing it across multiple layers. The architecture follows a **Bronze-Silver-Gold** approach where:

- **Bronze Layer** stores raw, unprocessed data.
- **Silver Layer** performs transformations and data cleaning.
- **Gold Layer** aggregates data for reporting and business insights.

## Technologies Used

- **Snowflake**: Data warehousing platform for storing and processing the trade data.
- **Python**: Used for generating mock data and automating the data insertion process.
- **Pandas**: For manipulating and handling data in Python.
- **Snowflake Connector for Python**: Used to interact with Snowflake's database from Python.
- **SQL**: For querying, transforming, and aggregating data in Snowflake.

## Project Workflow

1. **Data Ingestion**: Mock trade data is generated and inserted into the **Bronze Layer** (raw trades).
2. **Data Transformation**: Data is cleaned and transformed in the **Silver Layer** by removing invalid records and applying business rules.
3. **Aggregation**: Data is aggregated for reporting in the **Gold Layer**, where it is summarized for trader performance and trade summaries.
4. **Business Insights**: The final aggregated data is ready for business analysis and reporting.

---

## Setup Instructions

### Prerequisites

Before you begin, make sure you have the following:

1. **Snowflake Account**: need to have access to a Snowflake account to create databases and tables.
2. **Python 3**: This project uses Python for generating mock data and interacting with Snowflake.
3. **Required Python Libraries**:
   - `snowflake-connector-python`: Snowflake's Python connector to interact with the database.
   - `pandas`: For handling data manipulation (especially for mock data).
   - `random` and `time`: Used for generating random mock data and controlling execution timing.
4. Refer mock_data_generator.py code for mock data generation.
   **To simulate Change Data Capture (CDC), we can generate mock data for both the Bronze Layer and Silver Layer **
6. Refer snowflake_sql.sql code for the dynamic table pipeline(bronze, silver and gold) & lineage.
   


