SELECT country_code, COUNT(store_code) as total_no_stores 
FROM dim_store_details 
GROUP BY country_code
ORDER BY total_no_stores DESC;

------------------------------------------------------------------

SELECT locality, COUNT(store_code) as total_no_stores 
FROM dim_store_details 
GROUP BY locality
ORDER BY total_no_stores DESC;

-------------------------------------------------------------------

-- Round did not work for float and integer so I had to use cast to make sure the result of Sum would be numeric before applying Round

SELECT ROUND(CAST(SUM(o.product_quantity * p.product_price) AS numeric), 2) AS total_sales, d.month
FROM orders_table o
JOIN dim_products p
ON o.product_code = p.product_code
JOIN dim_date_times d
ON o.date_uuid = d.date_uuid
GROUP BY d.month;

----------------------------------------------------------------------

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

------------------------------------------------------------------------

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

-----------------------------------------------------------------------------
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

-----------------------------------------------------------------------------

SELECT SUM(staff_numbers) AS total_staff_numbers, country_code
FROM dim_store_details
GROUP BY country_code
ORDER BY total_staff_numbers DESC;

-----------------------------------------------------------------------------

SELECT ROUND(CAST(SUM(o.product_quantity * p.product_price) AS numeric), 2) AS total_sales, s.store_type, s.country_code
FROM orders_table o
JOIN dim_products p
ON o.product_code = p.product_code
JOIN dim_store_details s
ON o.store_code = s.store_code
WHERE s.country_code = 'DE'
GROUP BY s.store_type, s.country_code
ORDER BY total_sales;

-----------------------------------------------------------------------------

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