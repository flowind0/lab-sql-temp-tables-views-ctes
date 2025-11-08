-- 1 Create a View — Rental Summary per Customer

CREATE OR REPLACE VIEW customer_rental_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer AS c
JOIN rental AS r
    ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

-- 2 Create a Temporary Table — Payment Summary per Customer

CREATE TEMPORARY TABLE temp_customer_payment_summary AS
SELECT 
    crs.customer_id,
    SUM(p.amount) AS total_paid
FROM customer_rental_summary AS crs
JOIN payment AS p
    ON crs.customer_id = p.customer_id
GROUP BY crs.customer_id;


-- 3 Create a CTE

WITH customer_summary_cte AS (
    SELECT 
        crs.customer_name,
        crs.email,
        crs.rental_count,
        tps.total_paid
    FROM customer_rental_summary AS crs
    JOIN temp_customer_payment_summary AS tps
        ON crs.customer_id = tps.customer_id
)
SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    ROUND(total_paid / rental_count, 2) AS average_payment_per_rental
FROM customer_summary_cte
ORDER BY total_paid DESC;

