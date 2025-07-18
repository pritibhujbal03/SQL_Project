drop table if exists Zepto;
Create table Zepto(
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC (8,2),
discountpercent NUMERIC(8,2),
availablequantity INTEGER,
discountedsellingprice NUMERIC(8,2),
weightingms INTEGER,
outofstock BOOLEAN,
quantity INTEGER
)

--data exploration

--count of rows

SELECT COUNT(*)
FROM Zepto;

--sample data
SELECT *
FROM Zepto
LIMIT 10;

--check null values
SELECT *
FROM Zepto
Where name is null
OR
category is null
OR
 mrp is null
OR
discountpercent is null
OR
discountedsellingprice is null
OR
weightingms is null
OR
availablequantity is null
OR
outofstock is null
OR
quantity is null;

--different product categories
SELECT DISTINCT category
FROM Zepto
ORDER BY category;

--products in stock/out of stock

SELECT outofstock, COUNT(sku_id)
FROM Zepto
GROUP BY outofstock;

--product names present multiple times
SELECT name,COUNT(sku_id) AS "Number of SKU's"
FROM Zepto
GROUP BY name
HAVING COUNT(sku_id)>1
ORDER BY COUNT(sku_id)DESC;

--DATA CLEANING

--products with price = 0
SELECT *
FROM Zepto
WHERE mrp=0 OR discountedsellingprice=0;

--delete 0 priced product
DELETE FROM Zepto
WHERE mrp=0;

--convert paisa into rupees
UPDATE Zepto
SET mrp=mrp/100.0,
discountedsellingprice=discountedsellingprice/100.0;

--To Check
SELECT mrp,discountedsellingprice FROM Zepto;

--Business KPI/ Business Insights

--Q1 find the top 10 best-value products based on the discount percentage
SELECT DISTINCT name,mrp,discountpercent
FROM Zepto
ORDER BY discountpercent DESC
LIMIT 10;

--what are the products with high MRP but out of stock
SELECT DISTINCT name,mrp
FROM Zepto
WHERE outofstock = true and mrp>300
ORDER BY mrp DESC;

--calculate estimated revenue for each category

SELECT category,
SUM(discountedsellingprice * availablequantity) AS total_revenue
FROM Zepto
GROUP BY category
ORDER BY total_revenue;

--find all products where MRP is grater than RS 500 and discount is less then 10%

SELECT DISTINCT name,mrp,discountpercent
FROM Zepto
WHERE mrp>500 AND discountpercent<10
ORDER BY mrp DESC, discountpercent DESC;

--identify the top 5 categories offering the highest average discount percentage

SELECT category,
ROUND(AVG(discountpercent),2) AS avg_discount
FROM Zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

--group the products into categories like Low,Medium,Bulk

SELECT DISTINCT name,weightingms,
CASE WHEN weightingms<1000 THEN 'LOW'
     WHEN weightingms<5000 THEN'Medium'
	 ELSE 'BULK'
END AS weight_category
FROM Zepto;

--what is the total inventory weight per category
SELECT category,
SUM(weightingms*availablequantity) AS total_weight
FROM Zepto
GROUP BY category
ORDER BY total_weight;

