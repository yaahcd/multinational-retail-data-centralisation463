--How many stores does the business have and in which countries?

SELECT country_code, COUNT(store_code) as total_no_stores 
FROM dim_store_details 
GROUP BY country_code
ORDER BY total_no_stores DESC;

-- +----------+-----------------+
-- | country  | total_no_stores |
-- +----------+-----------------+
-- | GB       |             265 |
-- | DE       |             141 |
-- | US       |              34 |
-- +----------+-----------------+

------------------------------------------------------------------

--Which locations currently have the most stores?

SELECT locality, COUNT(store_code) as total_no_stores 
FROM dim_store_details 
GROUP BY locality
ORDER BY total_no_stores DESC;

-- +-------------------+-----------------+
-- |     locality      | total_no_stores |
-- +-------------------+-----------------+
-- | Chapletown        |              14 |
-- | Belper            |              13 |
-- | Bushley           |              12 |
-- | Exeter            |              11 |
-- | High Wycombe      |              10 |
-- | Arbroath          |              10 |
-- | Rutherglen        |              10 |
-- +-------------------+-----------------+^

-------------------------------------------------------------------

--Which months produced the largest amount of sales?

-- Round did not work for float and integer so I had to use cast to make sure the result of Sum would be numeric before applying Round

SELECT ROUND(CAST(SUM(o.product_quantity * p.product_price) AS numeric), 2) AS total_sales, d.month
FROM orders_table o
JOIN dim_products p
ON o.product_code = p.product_code
JOIN dim_date_times d
ON o.date_uuid = d.date_uuid
GROUP BY d.month;

-- +-------------+-------+
-- | total_sales | month |
-- +-------------+-------+
-- |   673295.68 |     8 |
-- |   668041.45 |     1 |
-- |   657335.84 |    10 |
-- |   650321.43 |     5 |
-- |   645741.70 |     7 |
-- |   645463.00 |     3 |
-- +-------------+-------+

----------------------------------------------------------------------

-- How many sales are coming from online?

SELECT COUNT(o.product_quantity) AS number_of_sales, SUM(o.product_quantity) AS product_quantity_count, 
CASE
	WHEN s.store_type = 'Web Portal' THEN 'Web'
	ELSE 'Offline'
	END AS store_location
FROM orders_table o
JOIN dim_store_details s 
ON o.store_code = s.store_code
GROUP BY store_location
ORDER BY store_location DESC;

-- +------------------+-------------------------+----------+
-- | numbers_of_sales | product_quantity_count  | location |
-- +------------------+-------------------------+----------+
-- |            26957 |                  107739 | Web      |
-- |            93166 |                  374047 | Offline  |
-- +------------------+-------------------------+----------+
------------------------------------------------------------------------

-- What percentage of sales come through each type of store?

SELECT s.store_type, 
    ROUND(CAST(SUM(o.product_quantity * p.product_price) AS numeric), 2) AS total_sales, 
    ROUND(ROUND(CAST(SUM(o.product_quantity * p.product_price) AS numeric), 2) /
    (SELECT ROUND(CAST(SUM(o2.product_quantity * p2.product_price) AS numeric), 2) AS total_sales
FROM orders_table o2
JOIN dim_products p2 ON o2.product_code = p2.product_code) * 100, 2) AS percentage_total
FROM orders_table o
JOIN dim_products p
ON o.product_code = p.product_code
JOIN dim_store_details s
ON o.store_code = s.store_code
GROUP BY s.store_type;

-- +-------------+-------------+---------------------+
-- | store_type  | total_sales | percentage_total    |
-- +-------------+-------------+---------------------+
-- | Local       |  3440896.52 |               44.87 |
-- | Web portal  |  1726547.05 |               22.44 |
-- | Super Store |  1224293.65 |               15.63 |
-- | Mall Kiosk  |   698791.61 |                8.96 |
-- | Outlet      |   631804.81 |                8.10 |
-- +-------------+-------------+---------------------+

-----------------------------------------------------------------------------

-- Which month in each year produced the highest cost of sales?

WITH total_monthly_sales AS (
SELECT ROUND(CAST(SUM(o.product_quantity * p.product_price) AS numeric), 2) AS total_sales,
d.year AS year, d.month AS month
FROM orders_table o
JOIN dim_products p ON o.product_code = p.product_code
JOIN dim_date_times d ON o.date_uuid = d.date_uuid
GROUP BY d.year, d.month 
)
SELECT m.total_sales, m.year, m.month
FROM total_monthly_sales m
JOIN (
	SELECT year, max(total_sales) AS total_sales
	FROM total_monthly_sales
	GROUP BY year
	) AS total_yearly_sales 
ON m.year = total_yearly_sales.year 
AND m.total_sales = total_yearly_sales.total_sales
ORDER BY m.year;

-- +-------------+------+-------+
-- | total_sales | year | month |
-- +-------------+------+-------+
-- |    27936.77 | 1994 |     3 |
-- |    27356.14 | 2019 |     1 |
-- |    27091.67 | 2009 |     8 |
-- |    26679.98 | 1997 |    11 |
-- |    26310.97 | 2018 |    12 |
-- |    26277.72 | 2019 |     8 |
-- |    26236.67 | 2017 |     9 |
-- |    25798.12 | 2010 |     5 |
-- |    25648.29 | 1996 |     8 |
-- |    25614.54 | 2000 |     1 |
-- +-------------+------+-------+

-----------------------------------------------------------------------------

-- What is our staff headcount?

SELECT SUM(staff_numbers) AS total_staff_numbers, country_code
FROM dim_store_details
GROUP BY country_code
ORDER BY total_staff_numbers DESC;

-- +---------------------+--------------+
-- | total_staff_numbers | country_code |
-- +---------------------+--------------+
-- |               13307 | GB           |
-- |                6123 | DE           |
-- |                1384 | US           |
-- +---------------------+--------------+

-----------------------------------------------------------------------------

-- Which German store type is selling the most?

SELECT ROUND(CAST(SUM(o.product_quantity * p.product_price) AS numeric), 2) AS total_sales, s.store_type, s.country_code
FROM orders_table o
JOIN dim_products p
ON o.product_code = p.product_code
JOIN dim_store_details s
ON o.store_code = s.store_code
WHERE s.country_code = 'DE'
GROUP BY s.store_type, s.country_code
ORDER BY total_sales;

-- +--------------+-------------+--------------+
-- | total_sales  | store_type  | country_code |
-- +--------------+-------------+--------------+
-- |   198373.57  | Outlet      | DE           |
-- |   247634.20  | Mall Kiosk  | DE           |
-- |   384625.03  | Super Store | DE           |
-- |  1109909.59  | Local       | DE           |
-- +--------------+-------------+--------------+

-----------------------------------------------------------------------------

-- How quickly is the company making sales?

WITH timestamp_events AS (
SELECT TO_TIMESTAMP(CONCAT(year, '-', month, '-', day, ' ', timestamp), 'YYYY-MM-DD HH24:MI:SS') AS timestamp_event
FROM dim_date_times),
next_timestamp_event AS (
SELECT timestamp_event, LEAD(timestamp_event) OVER (ORDER BY timestamp_event) AS next_timestamp_event
FROM timestamp_events)
SELECT EXTRACT(YEAR FROM timestamp_event) AS year,
    JSON_BUILD_OBJECT(
        'hours', ROUND(AVG(EXTRACT(HOUR FROM next_timestamp_event - timestamp_event))),
        'minutes', ROUND(AVG(EXTRACT(MINUTE FROM next_timestamp_event - timestamp_event))),
        'seconds', ROUND(AVG(EXTRACT(SECOND FROM next_timestamp_event - timestamp_event))),
		'milliseconds', ROUND(AVG(EXTRACT(MILLISECONDS FROM next_timestamp_event - timestamp_event)))) AS actual_time_taken
FROM next_timestamp_event
GROUP BY EXTRACT(YEAR FROM timestamp_event)
ORDER BY EXTRACT(YEAR FROM timestamp_event);

-- +------+-------------------------------------------------------+
--  | year |                           actual_time_taken           |
--  +------+-------------------------------------------------------+
--  | 2013 | "hours": 2, "minutes": 17, "seconds": 12, "millise... |
--  | 1993 | "hours": 2, "minutes": 15, "seconds": 35, "millise... |
--  | 2002 | "hours": 2, "minutes": 13, "seconds": 50, "millise... | 
--  | 2022 | "hours": 2, "minutes": 13, "seconds": 6,  "millise... |
--  | 2008 | "hours": 2, "minutes": 13, "seconds": 2,  "millise... |
--  +------+-------------------------------------------------------+