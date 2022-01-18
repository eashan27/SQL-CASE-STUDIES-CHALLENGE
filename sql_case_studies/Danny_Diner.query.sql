1. What is the total amount each customer spent at the restaurant?

select s.customer_id,sum(m.price)
from dannys_diner.sales s
join dannys_diner.menu m on s.product_id=m.product_id
group by 1
order by s.customer_id


2. How many days has each customer visited the restaurant?

select customer_id,count(distinct(order_date))
from dannys_diner.sales
group by customer_id

3.What was the first item from the menu purchased by each customer?

WITH ordered_sales AS (
  SELECT
    sales.customer_id,
    RANK() OVER (
      PARTITION BY sales.customer_id
      ORDER BY sales.order_date
    ) AS order_rank,
    menu.product_name
  FROM dannys_diner.sales
  INNER JOIN dannys_diner.menu
    on sales.product_id = menu.product_id
)

SELECT DISTINCT
  customer_id,
  product_name
FROM ordered_sales
WHERE order_rank = 1;

4.What is the most purchased item on the menu and how many times was it purchased by all customers?

select count(sales.product_id),menu.product_name,sales.customer_id
from dannys_diner.sales
join dannys_diner.menu on sales.product_id=menu.product_id
group by sales.product_id,menu.product_name,sales.customer_id

    
5. Which item was purchased first by the customer after they became a member?    

WITH sales_cte AS (
  SELECT
    sales.customer_id,
    sales.order_date,
    menu.product_name,
    RANK() OVER (
      PARTITION BY sales.customer_id
      ORDER BY sales.order_date
    ) AS order__rank
  FROM dannys_diner.sales
  INNER JOIN dannys_diner.menu
    ON sales.product_id = menu.product_id
  INNER JOIN dannys_diner.members
    ON sales.customer_id = members.customer_id
  WHERE
    sales.order_date >= members.join_date::DATE
)
SELECT DISTINCT
  customer_id,
  order_date,
  product_name
FROM sales_cte
WHERE order_rank = 1

