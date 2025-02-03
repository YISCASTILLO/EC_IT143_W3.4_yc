/*****************************************************************************************************************
NAME:    W3.4 AdventureWorks 
PURPOSE: Solve complexity questions with SQL

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     02/02/2025   YCASTILLO      1. Built this script for EC IT143


RUNTIME: 
Xm Xs

NOTES: 
Built for W3.3 - Adventure Works: Create answers
I'm building this script in order to show how to solve some business questions using this tools:
-https://dataedo.com/samples/html/AdventureWorks/doc/AdventureWorks_2/home.html
-SQL
-SMS
******************************************************************************************************************/

-- Q1: 
--Original question: What is the total number of employees working in the Sales department? (Ekundayo Fayehun)
--Reworked question: What is the total current number of employees working in the Sales department?
-- A1: 18 are those that hasn't finished their contract. I use three tables to get 
USE AdventureWorks2022;


SELECT COUNT(DISTINCT ed.BusinessEntityID) AS TotalEmployeesInSales
	FROM HumanResources.EmployeeDepartmentHistory ed
	JOIN HumanResources.Department d
	  ON ed.DepartmentID = d.DepartmentID
   WHERE d.Name = 'Sales'
	 AND ed.EndDate IS NULL; 

-- Q2: What is the most expensive product listed in the AdventureWorks catalog? (Jacob Grant)
--A: Is the Road-150 Red,62 with 3578.27 and rounded as 3578

SELECT TOP 1 ProductID, 
			 Name,
		     ProductNumber,
	         ROUND(ListPrice,0) AS RoundPrice
        FROM Production.Product
    ORDER BY ListPrice DESC;

--Q3: How many units of each product were scrapped in the last quarter? Tab REF.(Production.ScrapReason, Production.WorkOrder) (Lance Dale Naylor)
--A: 
  SELECT p.Name AS ProductName,
	     SUM(wo.ScrappedQty) AS TotalScrappedUnits
	FROM Production.WorkOrder wo
	JOIN Production.Product p ON wo.ProductID = p.ProductID
	JOIN Production.ScrapReason sr ON wo.ScrapReasonID = sr.ScrapReasonID
   WHERE wo.StartDate >= DATEADD(QUARTER, -1, CAST(EOMONTH('2014-06-30', -1) AS DATETIME)) + 1
	 AND wo.ScrapReasonID IS NOT NULL  
GROUP BY p.Name
ORDER BY TotalScrappedUnits DESC;


--Q4:(Moderate Complexity): How many employees are assigned to each department in the "Research and Development" group? (Daniel Adeolu)
---Reworked question: How many employees are assigned to the department "Research and Development" group?
--A:4

  SELECT d.GroupName, 
         COUNT(d.DepartmentID) AS EmployeeCount
    FROM HumanResources.Department d
    JOIN HumanResources.EmployeeDepartmentHistory ed
	  ON d.DepartmentID= ed.DepartmentID
   WHERE d.GroupName='Research and Development'
     AND ed.EndDate IS NULL
GROUP BY d.GroupName;
	

--Q5:The marketing team wants to target customers who made large purchases. List customers with orders exceeding $10,000 from Sales.SalesOrderHeader, including their contact information from Person.Person (Me)
--A:

  SELECT c.CustomerID,
         p.FirstName,
         p.LastName,
         soh.SalesOrderID,
         soh.OrderDate,
         ROUND(soh.TotalDue,2) Purchase,
         st.Name AS TerritoryName
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
    JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
    JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
   WHERE soh.TotalDue > 10000
ORDER BY soh.TotalDue DESC;

--Q6. Can I break down the sales for all bike products during Q3 2022? I need to know sales by month, product name, total units sold, and total revenue.
--Reworked question: Can you provide a monthly breakdown of sales for all bike products during the last Quarter? The report should include the product name, total units sold, total revenue (calculated as Order Quantity × Unit Price), and the month of sale.
--There is no data for 2022 so I use the last quarter in the dataset. NTILE argument shows all the quartiles but I wanted to show only the last quarter.

  SELECT p.Name AS ProductName,
         SUM(sod.OrderQty) AS TotalUnitsSold,
         SUM(COALESCE(sod.LineTotal, 0)) AS TotalRevenue,
         MONTH(soh.OrderDate) AS MonthOfSale
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
   WHERE soh.OrderDate BETWEEN '2014-04-01' AND '2014-06-30'
GROUP BY p.Name, MONTH(soh.OrderDate)
ORDER BY MONTH(soh.OrderDate), p.Name;



--Q7. Which tables in the database have a foreign key defined, as seen in INFORMATION_SCHEMA.TABLE_CONSTRAINTS? (Me)
/*A: Foreign keys are important because they help keep the database organized and ensure data accuracy. 
They create relationships between tables, making sure that data entered in one table matches existing data in another*/

  SELECT TABLE_NAME, 
         CONSTRAINT_NAME
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
   WHERE CONSTRAINT_TYPE = 'FOREIGN KEY'
GROUP BY TABLE_NAME,CONSTRAINT_NAME
ORDER BY TABLE_NAME;

--Q8. Which columns in the SalesOrderHeader table are indexed? Please provide the index names. (Jacob Grant)
/* A:In the SalesOrderHeader table, indexes help speed up queries related to sales, like finding orders by date or customer. 
Without indexes, searching large amounts of data would take much longer, slowing down reports and applications that rely on the database.*/

SELECT i.name AS IndexName,
       c.name AS ColumnName,
       i.type_desc AS IndexType
  FROM sys.indexes i
  JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
  JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
 WHERE i.object_id = OBJECT_ID('Sales.SalesOrderHeader');




SELECT GETDATE() AS my_date;