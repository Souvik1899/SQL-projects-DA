--SELECT * FROM df_orders;
--find top 10 highest reveue generating products 
SELECT product_id, SUM(sale_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;

--find top 5 highest selling products in each region
with cte as (
select region,product_id,sum(sale_price) as sales
from df_orders
group by region,product_id)
select * from (
select *
, row_number() over(partition by region order by sales desc) as rn
from cte) A
where rn<=5


--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with cte AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS order_year,
        EXTRACT(MONTH FROM order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
)
SELECT 
    order_month,
    COALESCE(SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END), 0) AS sales_2022,
    COALESCE(SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END), 0) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;



--for each category which month had highest sales 
with cte as (
select category,format(order_date,'yyyyMM') as order_year_month
, sum(sale_price) as sales 
from df_orders
group by category,format(order_date,'yyyyMM')
--order by category,format(order_date,'yyyyMM')
)
select * from (
select *,
row_number() over(partition by category order by sales desc) as rn
from cte
) a
where rn=1






--which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category,year(order_date) as order_year,
sum(sale_price) as sales
from df_orders
group by sub_category,year(order_date)
--order by year(order_date),month(order_date)
	)
, cte2 as (
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
select top 1 *
,(sales_2023-sales_2022)
from  cte2
order by (sales_2023-sales_2022) desc