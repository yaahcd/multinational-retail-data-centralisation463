-- 01. Change the data types to correspond to those seen in the table below.

-- +------------------+--------------------+--------------------+
-- |   orders_table   | current data type  | required data type |
-- +------------------+--------------------+--------------------+
-- | date_uuid        | TEXT               | UUID               |
-- | user_uuid        | TEXT               | UUID               |
-- | card_number      | TEXT               | VARCHAR(?)         |
-- | store_code       | TEXT               | VARCHAR(?)         |
-- | product_code     | TEXT               | VARCHAR(?)         |
-- | product_quantity | BIGINT             | SMALLINT           |
-- +------------------+--------------------+--------------------+

-- The ? in VARCHAR should be replaced with an integer representing the maximum length of the values in that column.

SELECT MAX(LENGTH(card_number)) AS max_length
FROM orders_table;

SELECT MAX(LENGTH(store_code)) AS max_length
FROM orders_table;

SELECT MAX(LENGTH(product_code)) AS max_length
FROM orders_table;

ALTER TABLE orders_table
ALTER COLUMN card_number SET DATA TYPE VARCHAR(19),
ALTER COLUMN store_code SET DATA TYPE VARCHAR(12),
ALTER COLUMN product_code SET DATA TYPE VARCHAR(11),
ALTER COLUMN product_quantity SET DATA TYPE SMALLINT;

ALTER TABLE orders_table
ALTER COLUMN date_uuid
SET DATA TYPE UUID USING date_uuid::UUID;

ALTER TABLE orders_table
ALTER COLUMN user_uuid
SET DATA TYPE UUID USING user_uuid::UUID;

-----------------------------------------------------------

-- 02. The column required to be changed in the users table are as follows:

-- +----------------+--------------------+--------------------+
-- | dim_users      | current data type  | required data type |
-- +----------------+--------------------+--------------------+
-- | first_name     | TEXT               | VARCHAR(255)       |
-- | last_name      | TEXT               | VARCHAR(255)       |
-- | date_of_birth  | TEXT               | DATE               |
-- | country_code   | TEXT               | VARCHAR(?)         |
-- | user_uuid      | TEXT               | UUID               |
-- | join_date      | TEXT               | DATE               |
-- +----------------+--------------------+--------------------+

SELECT MAX(LENGTH(country_code)) AS max_length
FROM dim_users;

ALTER TABLE dim_users 
ALTER COLUMN first_name SET DATA TYPE VARCHAR(255),
ALTER COLUMN last_name SET DATA TYPE VARCHAR(255),
ALTER COLUMN country_code SET DATA TYPE VARCHAR(3),
ALTER COLUMN date_of_birth SET DATA TYPE DATE USING date_of_birth::DATE,
ALTER COLUMN join_date SET DATA TYPE DATE USING join_date::DATE,
ALTER COLUMN user_uuid SET DATA TYPE UUID USING user_uuid::UUID;

--------------------------------------------------------------

-- 03. Set the data types for each column as shown below:

-- +---------------------+-------------------+------------------------+
-- | store_details_table | current data type |   required data type   |
-- +---------------------+-------------------+------------------------+
-- | longitude           | TEXT              | FLOAT                  |
-- | locality            | TEXT              | VARCHAR(255)           |
-- | store_code          | TEXT              | VARCHAR(?)             |
-- | staff_numbers       | TEXT              | SMALLINT               |
-- | opening_date        | TEXT              | DATE                   |
-- | store_type          | TEXT              | VARCHAR(255) NULLABLE  |
-- | latitude            | TEXT              | FLOAT                  |
-- | country_code        | TEXT              | VARCHAR(?)             |
-- | continent           | TEXT              | VARCHAR(255)           |
-- +---------------------+-------------------+------------------------+

-- There is a row that represents the business's website change the location column values from N/A to NULL.

SELECT MAX(LENGTH(country_code)) AS max_length
FROM dim_store_details;

SELECT MAX(LENGTH(store_code)) AS max_length
FROM dim_store_details;

UPDATE dim_store_details
SET locality = NULL
WHERE locality = 'N/A';

UPDATE dim_store_details
SET longitude = NULL
WHERE longitude = 'N/A';

ALTER TABLE dim_store_details
ALTER COLUMN longitude SET DATA TYPE FLOAT USING longitude::FLOAT, 
ALTER COLUMN locality SET DATA TYPE VARCHAR(255),
ALTER COLUMN store_code SET DATA TYPE VARCHAR(12),
ALTER COLUMN staff_numbers SET DATA TYPE SMALLINT,
ALTER COLUMN opening_date SET DATA TYPE DATE,
ALTER COLUMN store_type SET DATA TYPE VARCHAR(255),
ALTER COLUMN store_type DROP NOT NULL,
ALTER COLUMN latitude SET DATA TYPE FLOAT USING latitude::FLOAT,
ALTER COLUMN country_code SET DATA TYPE VARCHAR(2),
ALTER COLUMN continent SET DATA TYPE VARCHAR(255);

-------------------------------------------------------------------

-- 04. You will need to do some work on the products table before casting the data types correctly.

-- The product_price column has a £ character which you need to remove using SQL.

-- The team that handles the deliveries would like a new human-readable column added for the weight so they can quickly make decisions on delivery weights.

-- Add a new column weight_class which will contain human-readable values based on the weight range of the product.

-- +--------------------------+-------------------+
-- | weight_class VARCHAR(?)  | weight range(kg)  |
-- +--------------------------+-------------------+
-- | Light                    | < 2               |
-- | Mid_Sized                | >= 2 - < 40       |
-- | Heavy                    | >= 40 - < 140     |
-- | Truck_Required           | => 140            |
-- +----------------------------+-----------------+

-- 05. After all the columns are created and cleaned, change the data types of the products table.

-- You will want to rename the removed column to still_available before changing its data type.

-- Make the changes to the columns to cast them to the following data types:

-- +-----------------+--------------------+--------------------+
-- |  dim_products   | current data type  | required data type |
-- +-----------------+--------------------+--------------------+
-- | product_price   | TEXT               | FLOAT              |
-- | weight          | TEXT               | FLOAT              |
-- | EAN             | TEXT               | VARCHAR(?)         |
-- | product_code    | TEXT               | VARCHAR(?)         |
-- | date_added      | TEXT               | DATE               |
-- | uuid            | TEXT               | UUID               |
-- | still_available | TEXT               | BOOL               |
-- | weight_class    | TEXT               | VARCHAR(?)         |
-- +-----------------+--------------------+--------------------+

UPDATE dim_products
SET product_price = REPLACE(product_price, '£', '')
WHERE product_price LIKE '£%';

ALTER TABLE dim_products
ADD COLUMN weight_class VARCHAR(20);

UPDATE dim_products
SET weight_class = CASE
    WHEN weight < 2 THEN 'Light'
    WHEN weight >= 2 AND weight < 40 THEN 'Mid_Sized'
    WHEN weight >= 40 AND weight < 140 THEN 'Heavy'
    WHEN weight >= 140 THEN 'Truck_Required'
END;

ALTER TABLE dim_products
RENAME COLUMN removed TO still_available;

SELECT MAX(LENGTH("EAN")) AS max_length
FROM dim_products;

SELECT MAX(LENGTH(product_code)) AS max_length
FROM dim_products;

SELECT MAX(LENGTH(weight_class)) AS max_length
FROM dim_products;

ALTER TABLE dim_products 
ALTER COLUMN product_price SET DATA TYPE FLOAT USING product_price::FLOAT,
ALTER COLUMN weight SET DATA TYPE FLOAT USING weight::FLOAT,
ALTER COLUMN "EAN" SET DATA TYPE VARCHAR(17),
ALTER COLUMN product_code SET DATA TYPE VARCHAR(11),
ALTER COLUMN date_added SET DATA TYPE DATE,
ALTER COLUMN uuid SET DATA TYPE UUID USING uuid::uuid,
ALTER COLUMN still_available SET DATA TYPE BOOLEAN
USING CASE WHEN still_available::text = 'true' THEN TRUE
           WHEN still_available::text = 'false' THEN FALSE
           END,
ALTER COLUMN weight_class SET DATA TYPE VARCHAR(14);

-----------------------------------------------------------------------

-- 06. Now update the date table with the correct types:

-- +-----------------+-------------------+--------------------+
-- | dim_date_times  | current data type | required data type |
-- +-----------------+-------------------+--------------------+
-- | month           | TEXT              | VARCHAR(?)         |
-- | year            | TEXT              | VARCHAR(?)         |
-- | day             | TEXT              | VARCHAR(?)         |
-- | time_period     | TEXT              | VARCHAR(?)         |
-- | date_uuid       | TEXT              | UUID               |
-- +-----------------+-------------------+--------------------+

SELECT MAX(LENGTH(month)) AS max_length
FROM dim_date_times;

SELECT MAX(LENGTH(year)) AS max_length
FROM dim_date_times;

SELECT MAX(LENGTH(day)) AS max_length
FROM dim_date_times;

SELECT MAX(LENGTH(time_period)) AS max_length
FROM dim_date_times;

ALTER TABLE dim_date_times 
ALTER COLUMN month SET DATA TYPE VARCHAR(2),
ALTER COLUMN year SET DATA TYPE VARCHAR(4),
ALTER COLUMN day SET DATA TYPE VARCHAR(2),
ALTER COLUMN time_period SET DATA TYPE VARCHAR(10),
ALTER COLUMN date_uuid SET DATA TYPE UUID USING date_uuid::uuid;

--------------------------------------------------------------------------

-- 07. Now we need to update the last table for the card details.

-- Make the associated changes after finding out what the lengths of each variable should be:

-- +------------------------+-------------------+--------------------+
-- |    dim_card_details    | current data type | required data type |
-- +------------------------+-------------------+--------------------+
-- | card_number            | TEXT              | VARCHAR(?)         |
-- | expiry_date            | TEXT              | VARCHAR(?)         |
-- | date_payment_confirmed | TEXT              | DATE               |
-- +------------------------+-------------------+--------------------+

SELECT MAX(LENGTH(card_number)) AS max_length
FROM dim_card_details;

SELECT MAX(LENGTH(expiry_date)) AS max_length
FROM dim_card_details;

SELECT MAX(LENGTH(card_provider)) AS max_length
FROM dim_card_details;

ALTER TABLE dim_card_details 
ALTER COLUMN card_number SET DATA TYPE VARCHAR(22),
ALTER COLUMN expiry_date SET DATA TYPE VARCHAR(5),
ALTER COLUMN card_provider SET DATA TYPE VARCHAR(27),
ALTER COLUMN date_payment_confirmed SET DATA TYPE DATE;

--------------------------------------------------------------------------

-- 08. Now that the tables have the appropriate data types we can begin adding the primary keys to each of the tables prefixed with dim.

-- Each table will serve the orders_table which will be the single source of truth for our orders.

-- Check the column header of the orders_table you will see all but one of the columns exist in one of our tables prefixed with dim.

-- We need to update the columns in the dim tables with a primary key that matches the same column in the orders_table.

-- Using SQL, update the respective columns as primary key columns.

ALTER TABLE dim_date_times
ADD PRIMARY KEY (date_uuid);

ALTER TABLE dim_users
ADD PRIMARY KEY (user_uuid);

ALTER TABLE dim_card_details
ADD PRIMARY KEY (card_number);

ALTER TABLE dim_store_details
ADD PRIMARY KEY (store_code);

ALTER TABLE dim_products
ADD PRIMARY KEY (product_code);

--------------------------------------------------------------------------

-- 09. With the primary keys created in the tables prefixed with dim we can now create the foreign keys in the orders_table to reference the primary keys in the other tables.

-- Use SQL to create those foreign key constraints that reference the primary keys of the other table.

-- This makes the star-based database schema complete.

INSERT INTO dim_card_details (card_number)
SELECT DISTINCT card_number
FROM orders_table
WHERE card_number NOT IN (SELECT card_number FROM dim_card_details);

ALTER TABLE orders_table
ADD FOREIGN KEY (date_uuid) 
REFERENCES dim_date_times(date_uuid);

ALTER TABLE orders_table
ADD FOREIGN KEY (user_uuid) 
REFERENCES dim_users(user_uuid);

ALTER TABLE orders_table
ADD FOREIGN KEY (card_number) 
REFERENCES dim_card_details(card_number);

ALTER TABLE orders_table
ADD FOREIGN KEY (store_code) 
REFERENCES dim_store_details(store_code);

ALTER TABLE orders_table
ADD FOREIGN KEY (product_code) 
REFERENCES dim_products(product_code);




