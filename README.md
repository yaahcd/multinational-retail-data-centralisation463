# Multinational Retail Data Centralisation

### Table of Contents
---
<ul>
<li>Description</li>
<li>Installation</li>
<li>Usage</li>
<li>File structure</li>
</ul>

### Description
---
This project simulates the implementation of a process to centralize a multinational company's database. It encompasses all aspects of data engineering, from extracting data from different databases and cleaning that data to creating a single database that acts as a single source of truth for sales data.

### Installation
---
To run this project:
<ul>
<li>Clone this repository:</li>
</ul>

```
git clone https://github.com/yaahcd/multinational-retail-data-centralisation463.git
```
<ul>
<li>Install packages:</li>
</ul>

```
pip install pandas PyYAML requests s3fs tabula numpy SQLAlchemy
```

<ul>
<li>Make sure to have PostgresSQL installed as well.</li>
</ul>

### Usage
---
#### *&emsp;Database_utils: DatabaseConnector*
This class establishes connections to both a remote database and a local database.
#### *&emsp;Database_extraction: DataExtractor*
Once the connection is established, data is extracted from various sources including AWS RDS, S3 buckets, APIs, CSV files, and PDFs for cleaning.
#### *&emsp;Database_cleaning: DataCleaning*
After extraction, the data is cleaned using Pandas.
#### *&emsp;Queries*
Finally, after the data is extracted and cleaned, it is uploaded to a local database and can be queried to find metrics for the sales data, such as:

1. *How many stores does the business have and in which countries?*
2. *Which locations currently have the most stores?*
3. *Which months produced the largest amount of sales?*
4. *How many sales are coming from online?*
5. *What percentage of sales come through each type of store?*
6. *Which month in each year produced the highest cost of sales?*
7. *What is our staff headcount?*
8. *Which German store type is selling the most?*
9. *How quickly is the company making sales?*

### File structure
---
├── README.md\
├── data_cleaning.py\
├── data_extraction.py\
├── database_utils.py\
└── queries\
&emsp;&emsp;├── milestone_03.sql\
&emsp;&emsp;└── milestone_04.sql


