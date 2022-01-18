1 .How many customers has Foodie-Fi ever had?

select count(distinct customer_id)
from foodie_fi.subscriptions

2 .What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

select
  DATE_TRUNC('MONTH', start_date) as month_start_date,
  count(plan_id)
from foodie_fi.subscriptions
where plan_id = 0
group by month_start_date
order by month_start_date


3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name


select  
  p.plan_id,
  plan_name,
  count(*) as events
from foodie_fi.subscriptions s
join foodie_fi.plans p
  on s.plan_id = p.plan_id
where start_date >= '2021-01-01'
group by p.plan_id, plan_name
order by p.plan_id 


4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT
  SUM(CASE WHEN plan_id = 4 THEN 1 ELSE 0 END) AS churn_count,
  ROUND(100 * SUM(CASE WHEN plan_id = 4 THEN 1 ELSE 0 END) /COUNT(DISTINCT customer_id)
  ) AS percentage
FROM foodie_fi.subscriptions

5.What is the number and percentage of customer plans after their initial free trial?

WITH cte AS (
  SELECT
    customer_id,
    plan_id,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY start_date
    ) AS plan_rank
  FROM foodie_fi.subscriptions
)
SELECT
  SUM(CASE WHEN plan_id = 4 THEN 1 ELSE 0 END) AS churn,
  ROUND( 100 * SUM(CASE WHEN plan_id = 4 THEN 1 ELSE 0 END) /
    COUNT(*)
  ) AS percentage
FROM cte
WHERE plan_rank = 2

6.How many customers have upgraded to an annual plan in 2020?

with cte_plans as
(select customer_id,plan_id,
ROW_NUMBER() OVER(PARTITION BY customer_id order by start_date) as rn
from foodie_fi.subscriptions
where start_date <= '2020-12-31' and start_date >= '2020-01-01' and plan_id = 3 )

select count(*) as annual_count from cte_plans where rn = 1


7. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

with cte as
(select customer_id,plan_id,start_date,
lead(plan_id) over(PARTITION BY customer_id order by start_date) lead_plan
from foodie_fi.subscriptions
where extract(year from start_date) = 2020)

select count(*)
from cte
where lead_plan=2 and plan_id=1 and lead_plan is not null

