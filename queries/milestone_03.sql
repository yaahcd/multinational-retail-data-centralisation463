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




