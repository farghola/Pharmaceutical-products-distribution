CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,
    DateValue DATE,
    Year INT,
    Quarter INT,
    Month INT
);

DECLARE @StartDate DATE = '2015-01-01'; -- Adjust start date as needed
DECLARE @EndDate DATE = '2030-12-31'; -- Adjust end date as needed

DECLARE @CurrentDate DATE = @StartDate;

-- Loop through dates and insert into DimDate table
WHILE @CurrentDate <= @EndDate
BEGIN
    INSERT INTO DimDate (DateKey, DateValue, Year, Quarter, Month)
    VALUES (
        YEAR(@CurrentDate) * 10000 + MONTH(@CurrentDate) * 100,
        @CurrentDate,
        YEAR(@CurrentDate),
        DATEPART(QUARTER, @CurrentDate),
        MONTH(@CurrentDate)
    );

    SET @CurrentDate = DATEADD(MONTH, 1, @CurrentDate);
END;




  create table Dim_Organization	(	
PK_organizationID int IDENTITY(1,1) primary key ,
organization_ID_BK int ,
organization_name nvarchar(255),
Distribution_ID_BK int ,
Distribution nvarchar(255),
Organization_Type nvarchar(255),
Organization_sub_type nvarchar(255),
addressID int ,
city nvarchar(255),
Latitude float,
Longitude float,
Country nvarchar(255),
StartDAte datetime,
EndDate datetime,
IsCurrent bit
)

create table Dim_Product(
PK_ProductID int IDENTITY(1,1) primary key ,
ProductID_BK int ,
ProductName nvarchar(255),
ProductClass nvarchar(255),
StartDate datetime,
EndDate datetime,
IsCurrent bit
)



create table Dim_Salesmen (
PK_SalesmenID int IDENTITY(1,1) primary key ,
SalesmenID_BK int ,
Name nvarchar(255),
SalesTeam nvarchar(255),
Manager nvarchar(255),
StartDate datetime,
EndDate datetime,
IsCurrent bit
)


create table Fact_Order	(
PK_orderID int IDENTITY(1,1) primary key ,
OrderID_BK int ,
Quantity float,
Price float,
Total_sales float,
Organization_FK int,
Product_FK int,
Salesmen_FK int,
Date_FK int
)

--ETL process
select o.Organization_ID,o.Organization_Name,d.DistributionID,d.Distribution,t.[Organization type]
,t.[Organization sub-type],a.AddressID,a.City,a.Latitude,a.Longitude,c.Country
from Organization o,Distribution d,Address a,country c,Organization_Distribution od,Type t
where od.organizationID=o.Organization_ID and
od.DistributionID=d.DistributionID and
o.typeID=t.typeid and
a.AddressID=o.addressID and
a.countryID =c.CountryID



select p.ProductID,p.ProductName,pc.ProductClass
from Product p,ProductClass pc
where pc.ProductClassID=p.ProductClassID


select s.IDsales,s.SalesRepName,t.SalesTeam,t.Manager
from Sales_Preson s, Team t
where s.teamID=t.teamID



--fact
create table control_flow (
id int , last_order_id int)

INSERT into control_flow VALUES(1,1)

select last_order_id from control_flow where id=1

select max(OrderID_BK) from Fact_Order

update control_flow 
set last_order_id = ? 
where id=1


SELECT 
    o.OrderID,
    o.Quantity,
    o.Price,
    o.[Total sales],
    o.organizationID,
    o.productID,
    o.Sales_RepID,
    o.[year], 
    o.NumericMonth
FROM 
    [Order] o
where   o.OrderID > ?

UPDATE control_flow set last_order_id=(select max(OrderID_BK) from Fact_Order) where id=1
