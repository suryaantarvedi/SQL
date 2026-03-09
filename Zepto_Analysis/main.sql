create table zepto (
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,	
quantity INTEGER
);
select count(*) from zepto;
select * from zepto;

select * from zepto
limit 10;

select * from zepto
where name IS NULL
OR 
category IS NULL
OR 
mrp IS NULL
OR 
discountPercent IS NULL
OR 
availableQuantity IS NULL
OR 
discountedSellingPrice IS NULL
OR 
weightInGms IS NULL
OR 
outOfStock IS NULL
OR 
quantity IS NULL;

-- different peoduct categories
select distinct category
from zepto
order by category;

-- products stock or out of stock
select outOfStock , count(sku_id)
from zepto
group by OutOfStock;

--products names present multiple times
select name, count(sku_id) as "number of SKUs"
from zepto
group by name 
having count(sku_id)>1
order by count(sku_id) DESC;

-- data cleaning

--products with price =0
select * from zepto
where mrp =0 OR discountedSellingPrice = 0;

delete from zepto
where mrp = 0;

-- covert paise to rupees
update zepto
set mrp = mrp/100.0,
discountedSellingPrice = discountedSellingPrice/100.0;

select mrp , discountedSellingPrice FROM zepto;

-- Find top 10 best-value products based on discount percentage.
select distinct name , mrp , discountPercent
from zepto
order by discountPercent DESC
LIMIT 10;

-- Identified high-MRP products that are currently out of stock

-- select distinct name , mrp 
-- from zepto
-- where name and mrp in (select distinct OutOfStock from zepto) 
-- order by mrp desc;

select distinct name , mrp 
from zepto
where outOfStock = True and mrp>300
order by mrp desc;

-- Estimated potential revenue for each product category

select category , 
sum(discountedSellingPrice * availableQuantity) AS revenue
from zepto
group by category
order by revenue desc;

-- Filtered expensive products (MRP > ₹500) and discount is less than 10%
select distinct name , mrp, discountPercent
from zepto
where mrp> 500 and discountPercent<10
order by mrp desc , discountPercent desc;

-- Ranked top 5 categories offering highest average discounts

select category , ROUND(avg(discountPercent),2) as avg_discount
from zepto
group by category 
-- having (discountPercent) > avg(discountPercent
order by avg_discount desc
limit 5;

-- find the price per gram for products above 100g and sort by best value

select distinct name , weightingms , discountedSellingPrice,
round(discountedSellingPrice/weightingms,2) as price_per_gram
from zepto
where weightingms >=100
order by price_per_gram;


-- Grouped products based on weight into Low, Medium, and Bulk categories
select distinct name , weightingms,
case when weightingms <1000 then 'low'
     when weightingms < 5000 then 'medium'
	 else 'bulk'
	 end as weight_category
from zepto;

-- Measured total inventory weight per product category
select category,
sum(weightingms * availablequantity) as total_weight
from zepto
group by category
order by total_weight;