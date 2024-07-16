use project;

SELECT * 
FROM df_orders;


CREATE TABLE df_orders (
	order_id int primary key,
    order_date date,
    ship_mode varchar(20),
    segment varchar(20),
    country varchar(25),
    city varchar(20),
    state varchar (20),
    postal_code varchar (20),
	region varchar (20),
    category varchar (20),
    sub_category varchar(20),
    product_id varchar(50),
    quantity int,
    discount decimal(7,2),
    sale_price decimal(7,2),
    profit decimal(7,2) );
    
SELECT 
    *
FROM
    df_orders;

SELECT product_id, sub_category, sum(sale_price) AS sales
FROM df_orders
GROUP BY product_id, sub_category
ORDER BY SALES desc
LIMIT 10;


WITH CTE as (
SELECT region , product_id , sum(sale_price) as sales
FROM df_orders
GROUP BY region , product_id
ORDER BY region, sales DESC
)
SELECT * FROM (
SELECT * ,
ROW_NUMBER() OVER(PARTITION BY REGION ORDER BY sales DESC) AS ranking
FROM CTE) A
WHERE 
ranking <= 5;

WITH CTE as (
SELECT region , product_id , sum(sale_price) as sales
FROM df_orders
GROUP BY region , product_id
ORDER BY region, sales DESC
)
SELECT * FROM(
SELECT *, 
RANK() OVER(PARTITION BY REGION ORDER BY SALES DESC) as ranking
FROM CTE) A
WHERE
ranking <=5;

SELECT * FROM df_orders;

with cte as (
select year(order_date) as order_year,month(order_date) as order_month,
sum(sale_price) as sales
from df_orders
group by year(order_date),month(order_date)
	)
select order_month
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by order_month
order by order_month

WITH CTE AS(
SELECT 
DATE_FORMAT(order_date, '%Y-%m') as year_and_month, sum(sale_price) as sales
FROM df_orders
GROUP BY year_and_month)
SELECT year_and_month,
CASE WHEN YEAR(year_and_month)= 2022 then sales else 0 END as sales_2022,
CASE WHEN YEAR(year_and_month)= 2023 then sales else 0 END as sales_2023
FROM CTE;

select * from df_orders;

WITH CTE AS (
SELECT category, DATE_FORMAT(order_date, '%Y-%m') as order_year_and_month, sum(sale_price) as sales
FROM df_orders
GROUP BY category, order_year_and_month
)
SELECT * FROM(
SELECT *, 
RANK() OVER(PARTITION BY category ORDER BY SALES DESC) as ranking
FROM CTE) A
WHERE
ranking = 1;

with cte as (
select category, date_format(order_date,'%Y%m') as order_year_month
, sum(sale_price) as sales 
from df_orders
group by category,order_year_month

)
select * from (
select *,
row_number() over(partition by category order by sales desc) as rn
from cte
) a
where rn=1;

SELECT DISTINCT(category) from df_orders;

with cte as (
select sub_category, year(order_date) as order_year,
sum(sale_price) as sales
from df_orders
group by sub_category, order_year
	)
, cte2 as (    
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
SELECT *,
(sales_2023 - sales_2022) sales_differences
FROM cte2
ORDER BY sales_differences DESC
LIMIT 1;

with cte as 
(select category, sum(sale_price) as sales, date_format(order_date, '%m%Y') as order_month from df_orders group by category,order_month order by sales desc)
select category, order_month, sales from cte c1 where sales = (select max(sales) from cte c2 where c1.category = c2.category);