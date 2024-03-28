--Measures

--Num of orders
select COUNT (o.orderID) as [Num of orders]
from [dbo].[Order] o


--Total sales 
select SUM (o.[Total sales])  as [Total sales]
from [dbo].[Order] o

--Num of Organizations 
select COUNT (org.Organization_ID) as [Num Of Organizations]
from Organization org

--Num of products
select COUNT (p.ProductID) as [Num of Products]
from Product p

--Units sold
select SUM (o.[Total sales]) as[Units sold]
from [dbo].[Order] o


--  Best 10 Costumors
select top 10 org.Organization_ID,org.Organization_Name ,COUNT(o.OrderID) as [Num Of Orders]
from [dbo].[Order] o join  Organization org
on org.Organization_ID = o.organizationID
group by org.Organization_Name ,org.Organization_ID
order by[Num Of Orders] desc

--Germany VS Poland in sales

Select c.Country ,SUM(o.[Total sales]) as [Total sales]
from [dbo].[Order] o join Organization org
on o.organizationID= org.Organization_ID
join Address ad
on ad.AddressID=org.Organization_ID
join country c
on c.CountryID = ad.countryID
group by c.Country


Go

--sales Over Years
select o.Year,SUM(o.[Total sales]) as [Total sales]
from [dbo].[Order] o
group by o.Year

	-- Year Filter PROC
	create or alter proc year_filter
	@Year int
	as 
	select o.Year ,
	SUM(o.[Total sales]) as [Total sales],
	COUNT (o.orderID) as [Num of orders],
	SUM (o.[Total sales]) as[Units sold]
	from [dbo].[Order] o
	group by o.Year
	having @year =o.Year

	year_filter @year=2018


Go

-- Trendy products (n)
CREATE OR ALTER FUNCTION [Top N Sales Products] (@n INT)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM (
        SELECT p.ProductID,
               p.ProductName,
               SUM(od.[Total sales]) AS [Total Sales],
               RANK() OVER (ORDER BY SUM(od.[Total sales]) DESC) AS Salesrank
        FROM product p
        JOIN [dbo].[order] od ON od.productID = p.productID
        GROUP BY p.ProductID, p.ProductName
    ) AS rank_view
    WHERE rank_view.Salesrank <= @n
);
select * from [Top N Sales Products] (10)


Go

-- Trendy Product Class
CREATE OR ALTER FUNCTION TrendyProductClass (@n INT)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM (
        SELECT p.ProductID,
               p.ProductName,
               SUM(od.[Total sales]) AS [Total Sales],
               RANK() OVER (ORDER BY SUM(od.[Total sales]) DESC) AS Salesrank
        FROM [dbo].[order] od JOIN product p 
		ON od.productID = p.productID
		join ProductClass pc
		on pc.ProductClassID =p.ProductID
        GROUP BY p.ProductID, p.ProductName
    ) AS rank_view
    WHERE rank_view.Salesrank <= @n)
select * from TrendyProductClass (10)

go

--
-- Best 2 product in each class
with RankProdect as(
select p.ProductName,pc.ProductClass
,SUM(od.[Total sales]) as [Total sales]
,ROW_NUMBER() OVER (PARTITION BY pc.ProductClass ORDER BY SUM(od.[Total sales]) DESC) AS rank

from [dbo].[Order] od join Product p 
on p.ProductID=od.productID
join ProductClass pc
on pc.ProductClassID=p.ProductClassID
group by p.ProductName,pc.ProductClass
)
select 
   ProductName, 
    ProductClass, 
    [Total sales]
from RankProdect 
where RANK <= 2


Go



