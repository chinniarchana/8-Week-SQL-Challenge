
# :ramen: CASE STUDY #1: DANNY'S DINER

# Introduction

Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

## Danny has shared with you 3 key datasets for this case study:

* sales
* menu
* members

# Entity Relationship Diagram

![EntityFig1](https://user-images.githubusercontent.com/70010985/181160058-5a505575-9432-49d6-9c52-e2da617135be.JPG)

# Task

Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite.

-----------------------------------------------------------------------------------------------------------------------------------
# CASE STUDY SOLUTIONS 

## 1. What is the total amount each customer spent at the restaurant?

```sql

SELECT s.customer_id, 
	   SUM(m.price) AS total_amount_spent
FROM dbo.sales AS s
JOIN dbo.menu AS m
	  ON s.product_id = m.product_id
GROUP BY s.customer_id;

```

Solution

![Sol1](https://user-images.githubusercontent.com/70010985/181084022-da8aaf6b-cac2-48f3-a9b6-add8e839dc38.JPG)

-----------------------------------------------------------------------------------------------------------------------------------

## 2. How many days has each customer visited the restaurant?

```sql

SELECT customer_id, 
	   COUNT(DISTINCT(order_date)) AS days_visited
FROM dbo.sales
GROUP BY customer_id;

```
Solution

![Sol2](https://user-images.githubusercontent.com/70010985/181084146-6948a062-6725-4d83-af17-9ec943538049.JPG)

-----------------------------------------------------------------------------------------------------------------------------------

## 3. What was the first item from the menu purchased by each customer?

```sql

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
	 
```
Solution

![Sol3](https://user-images.githubusercontent.com/70010985/181084252-4d313b28-ce4a-457d-a5ae-e1dac8b979dd.JPG)

-----------------------------------------------------------------------------------------------------------------------------------

## 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql

SELECT TOP 1 product_name, 
	   COUNT(m.product_id) AS most_purchased
FROM dbo.menu AS m
JOIN dbo.sales AS s
		ON m.product_id = s.product_id
GROUP BY product_name
ORDER BY most_purchased DESC

```
Solution

![Sol4](https://user-images.githubusercontent.com/70010985/181084569-fc417be6-bfb0-4750-ad25-97154e753f42.JPG)

-----------------------------------------------------------------------------------------------------------------------------------

## 5. Which item was the most popular for each customer?

```sql

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

```
Solution

![Sol5](https://user-images.githubusercontent.com/70010985/181084610-3cdc3453-fb71-45d2-8cb6-5f393c86bff5.JPG)

-----------------------------------------------------------------------------------------------------------------------------------

## 6. Which item was purchased first by the customer after they became a member?

```sql

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

```
Solution

![Sol6](https://user-images.githubusercontent.com/70010985/181084652-46d61a2b-950d-4caf-845f-687cdb491dc3.JPG)

-----------------------------------------------------------------------------------------------------------------------------------

## 7. Which item was purchased just before the customer became a member?

```sql

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

```
Solution

![Sol7](https://user-images.githubusercontent.com/70010985/181084686-d62ddaab-ae11-4e96-b177-515aa841f841.JPG)

-----------------------------------------------------------------------------------------------------------------------------------

## 8. What is the total items and amount spent for each member before they became a member?

``` sql

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
 
```
Solution

![Sol8](https://user-images.githubusercontent.com/70010985/181084725-e60c9a92-bacb-4c68-becd-d5f6e7823a58.JPG)

-----------------------------------------------------------------------------------------------------------------------------------

## 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier how many points would each customer have?

```sql

SELECT s.customer_id,
	SUM(CASE 
		WHEN m.product_id = 1 THEN m.price*20 
		ELSE m.price*10 
	END) AS points
FROM dbo.menu AS m
JOIN dbo.sales AS s
	  ON m.product_id = s.product_id
GROUP BY customer_id

```
Solution

![Sol9](https://user-images.githubusercontent.com/70010985/181084763-101f3e02-aa47-4201-979e-5eeb19dac64a.JPG)

-----------------------------------------------------------------------------------------------------------------------------------

## 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,

not just sushi how many points do customer A and B have at the end of January?

```sql

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

```
Solution

![Sol10](https://user-images.githubusercontent.com/70010985/181084821-c9578b09-5d4f-452d-ae66-4f6876a1b852.JPG)

-----------------------------------------------------------------------------------------------------------------------------------

# BONUS QUESTIONS

## Join all the data. 
/* The following questions are related creating basic data tables that Danny and his team can 
use to quickly derive insights without needing to join the underlying tables using SQL.
Recreate the table which contains customer_id, order_date, product_name, price, member(Y/N).*/

```sql

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

``` 
Solution

![B1](https://user-images.githubusercontent.com/70010985/181084869-d5b20cef-3162-4d86-87ba-22f590f31f89.JPG)

-----------------------------------------------------------------------------------------------------------------------------------

## Rank All The Things
/* Danny also requires further information about the ranking of customer products, but 
he purposely does not need the ranking for non-member purchases so he expects null 
ranking values for the records when customers are not yet part of the loyalty program.*/

```sql

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

```
Solution 

![B2](https://user-images.githubusercontent.com/70010985/181083444-cfb4a532-5f72-4967-a4fb-715104b0d3ce.JPG)

-----------------------------------------------------------------------------------------------------------------------------------
