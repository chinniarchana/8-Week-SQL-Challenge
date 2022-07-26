/* 
8 WEEK SQL CHALLENGE BY @DATAWITHDANNY

SQL CASE STUDY 1: DANNY'S DINER 

TOOL USED: MICROSOFT SQL SERVER

CASE STUDY: https://8weeksqlchallenge.com/case-study-1/

*/

-----------------------------------------------------------------------------
-- CREATE SCHEMA or DATABASE

CREATE DATABASE DannysDiner;
USE DannysDiner

-----------------------------------------------------------------------------
-- CREATE TABLE AND INSERT DATA

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
  );
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
  );
INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
  );
INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

-----------------------------------------------------------------------------
-- REVIEW TABLES

SELECT *
FROM dbo.sales

SELECT *
FROM dbo.menu

SELECT * 
FROM dbo.members

-----------------------------------------------------------------------------
-- CASE STUDY QUESTIONS

-- 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, 
	   SUM(m.price) AS total_amount_spent
FROM dbo.sales AS s
JOIN dbo.menu AS m
	  ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, 
	   COUNT(DISTINCT(order_date)) AS days_visited
FROM dbo.sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

WITH menu_purchased_cte AS 
(
	SELECT s.customer_id,
		   s.order_date,
		   m.product_name,
		   DENSE_RANK() OVER 
		   (PARTITION BY customer_id ORDER BY order_date) AS rank
	FROM dbo.sales AS s
	JOIN dbo.menu AS m
		   ON s.product_id = m.product_id)

SELECT customer_id, 
	   product_name
FROM menu_purchased_cte
WHERE rank = 1
GROUP BY customer_id, 
	     product_name;

-- 4. What is the most purchased item on the menu 
--    and how many times was it purchased by all customers?

SELECT TOP 1 product_name, 
	   COUNT(m.product_id) AS most_purchased
FROM dbo.menu AS m
JOIN dbo.sales AS s
		ON m.product_id = s.product_id
GROUP BY product_name
ORDER BY most_purchased DESC

-- 5. Which item was the most popular for each customer?

WITH popular_item_cte AS
(
    SELECT s.customer_id, 
		m.product_name, 
		COUNT(s.product_id) AS total_orders,
		DENSE_RANK() OVER 
		(PARTITION BY s.customer_id ORDER BY COUNT(s.order_date) DESC) AS rank
	FROM dbo.sales AS s
	JOIN dbo.menu AS m
		ON s.product_id = m.product_id
	GROUP BY s.customer_id, 
	         m.product_name)

SELECT customer_id, 
	   product_name, 
	   total_orders
FROM popular_item_cte
WHERE rank = 1
ORDER BY total_orders DESC

-- 6. Which item was purchased first by the customer after they became a member?

WITH member_purchase_cte AS 
(
SELECT s.customer_id, 
	   s.product_id,
	   mem.join_date,
	   order_date,
	   DENSE_RANK() OVER 
	   (PARTITION BY join_date ORDER BY order_date) AS rank
FROM dbo.sales AS s
JOIN dbo.members AS mem
	ON s.customer_id = mem.customer_id
WHERE order_date >= mem.join_date)

SELECT customer_id, order_date, product_name
FROM member_purchase_cte mp
JOIN menu m
	  ON mp.product_id = m.product_id
Where rank = 1;

-- 7. Which item was purchased just before the customer became a member?


WITH member_purchase_cte AS 
(
SELECT s.customer_id, 
	   s.product_id,
	   mem.join_date,
	   order_date,
	   DENSE_RANK() OVER 
	   (PARTITION BY join_date ORDER BY order_date DESC) AS rank
FROM dbo.sales AS s
JOIN dbo.members AS mem
	ON s.customer_id = mem.customer_id
WHERE order_date < mem.join_date)

SELECT customer_id, order_date, product_name
FROM member_purchase_cte mp
JOIN menu m
	  ON mp.product_id = m.product_id
Where rank = 1;

-- 8. What is the total items and amount spent for each member 
-- before they became a member?

SELECT s.customer_id, 
	   COUNT(DISTINCT s.product_id) AS total_items, 
	   SUM(m.price) AS total_amount_spent
FROM dbo.sales AS s
JOIN dbo.menu AS m 
	ON s.product_id = m.product_id
JOIN dbo.members mem
	ON s.customer_id = mem.customer_id
WHERE order_date < join_date
GROUP BY s.customer_id;
 
-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
-- how many points would each customer have?

SELECT s.customer_id,
	SUM(CASE 
		WHEN m.product_id = 1 THEN m.price*20 
		ELSE m.price*10 
	END) AS points
FROM dbo.menu AS m
JOIN dbo.sales AS s
	  ON m.product_id = s.product_id
GROUP BY customer_id

-- 10. In the first week after a customer joins the program 
-- (including their join date) they earn 2x points on all items, not just sushi
-- how many points do customer A and B have at the end of January?

SELECT s.customer_id, 
   SUM(CASE
          WHEN m.product_name = 'sushi' THEN 20*m.price
          WHEN s.order_date BETWEEN mem.join_date 
		  AND DATEADD(DAY, 6, mem.join_date)THEN 20*m.price
          ELSE 10*m.price
      END) AS total_points
FROM dbo.members as mem
LEFT JOIN dbo.sales AS s
   ON mem.customer_id = s.customer_id
LEFT JOIN dbo.menu AS m
   ON s.product_id = m.product_id
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id;

----------------------------------------------------------------------------------------
-- BONUS QUESTIONS

-- Join all the data. 
/* The following questions are related creating basic data tables that Danny and his team can 
use to quickly derive insights without needing to join the underlying tables using SQL.
Recreate the table which contains customer_id, order_date, product_name, price, member(Y/N).*/

SELECT s.customer_id, 
       s.order_date, 
	   m.product_name, 
	   m.price,
   CASE
      WHEN mem.join_date > s.order_date THEN 'N'
      WHEN mem.join_date <= s.order_date THEN 'Y'
      ELSE 'N'
   END AS member
FROM sales AS s
LEFT JOIN menu AS m
   ON s.product_id = m.product_id
LEFT JOIN members AS mem
   ON s.customer_id = mem.customer_id;

-- Rank All The Things
/* Danny also requires further information about the ranking of customer products, but 
he purposely does not need the ranking for non-member purchases so he expects null 
ranking values for the records when customers are not yet part of the loyalty program.*/

WITH table_cte AS
(
SELECT s.customer_id, s.order_date, m.product_name, m.price,
   CASE
      WHEN mem.join_date > s.order_date THEN 'N'
      WHEN mem.join_date <= s.order_date THEN 'Y'
      ELSE 'N'
   END AS member
FROM sales AS s
LEFT JOIN menu AS m
   ON s.product_id = m.product_id
LEFT JOIN members AS mem
   ON s.customer_id = mem.customer_id)

SELECT *,
  CASE 
	  WHEN member = 'N' THEN NULL
	  ELSE RANK() OVER 
	  (PARTITION BY customer_id, member ORDER BY order_date) 
  END AS ranking
FROM table_cte

-----------------------------------------------------------------------------------------