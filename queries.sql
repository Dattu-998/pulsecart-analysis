/*
============================================================
PulseCart - Station A SQL Extraction
============================================================
IMPORTANT:
1. First load and execute pulsecart_dump.sql in MySQL Workbench.
2. The dump creates the pulsecart database and loads the following items
   * customers
   * products
   * orders
   * support_tickets
   These are the four tables that are present in the existing database
3. If you encounter execution errors, first check `pulsecart_dump.sql`.
	The file contains duplicated INSERT INTO <table_name> VALUES
	header lines. Remove the duplicate header lines, reload the
	corrected dump, and then execute this queries.sql file.
    
4. After the database is loaded and corrected, execute this
   queries.sql file to get the required Station A results.
============================================================
*/
USE pulsecart;
/*
============================================================
QUESTION 1
Row counts per table
============================================================
*/
SELECT 'products' AS table_name,
COUNT(*) AS row_count
FROM products

UNION ALL

SELECT 'customers',
COUNT(*)
FROM customers

UNION ALL

SELECT 'orders',
COUNT(*)
FROM orders

UNION ALL

SELECT 'support_tickets',
COUNT(*)
FROM support_tickets;
/*
============================================================
QUESTION 2
Customers who churned and placed at least one returned order
============================================================
*/
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE c.churned = 1
  AND o.returned = 1;
/*
============================================================
QUESTION 3
Return rate by category
(JOIN orders to products)
============================================================
*/
SELECT
    p.category,
    COUNT(*) AS total_orders,
    AVG(o.returned) * 100 AS return_rate
FROM products AS p
JOIN orders AS o
    ON p.product_id = o.product_id
GROUP BY p.category;

/*
============================================================
QUESTION 4
Customers with more than one row for the same email
============================================================
*/

SELECT
    email,
    COUNT(*) AS customer_count
FROM customers
GROUP BY email
HAVING COUNT(*) > 1
ORDER BY customer_count DESC, email;


/*
============================================================
QUESTION 5
Orders whose customer_id does not exist in customers
============================================================
*/

SELECT
    o.*
FROM orders AS o
LEFT JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL
ORDER BY o.order_id;


/*
============================================================
QUESTION 6
Top 20 customers by net revenue

Rules:
- Exclude cancelled orders
- Subtract returned lines
============================================================
*/
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    SUM(
        o.quantity * o.unit_price * (1 - o.discount_pct / 100)
    )
    -
    SUM(
        IF(o.returned = 1,
           o.quantity * o.unit_price * (1 - o.discount_pct / 100),
           0)
    ) AS net_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.status <> 'cancelled'
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
ORDER BY net_revenue DESC
LIMIT 20;