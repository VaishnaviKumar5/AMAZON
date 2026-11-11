create database amazons;
use amazons;

describe customers;
describe products;
describe suppliers;
describe orders;
describe order_details;
describe reviews;

##TASK 3
## Retrieve all customers from a specific city.

SELECT*FROM CUSTOMERS;
select distinct city from customers;

SELECT*FROM CUSTOMERS WHERE CITY='Bettyport';

##Fetch all products under the "Fruits" category. 

SELECT DISTINCT CATEGORY FROM PRODUCTS ;

SELECT *FROM PRODUCTS WHERE CATEGORY='FRUITS';


##TASK 4
##Data Definition Language (DDL) and Constraints
SELECT *
FROM Customers
WHERE Age IS NULL OR Age <= 18;

DESCRIBE Customers;

##orginal data dose not have above 18 age. 
ALTER TABLE Customers
MODIFY COLUMN Age INT NOT NULL,
ADD CONSTRAINT Chk_Customer_Age CHECK (Age > 17); 

#Add a unique constraint for Name. 
SELECT Name, COUNT(*) AS Total FROM Customers GROUP BY Name HAVING COUNT(*) > 1;

ALTER TABLE customers ADD CONSTRAINT UQ_Customer_Name UNIQUE (Name);


##Data Manipulation Language (DML) 
##Task 5
##Insert 3 new rows into the Products table using INSERT statements

DESCRIBE Products;
SELECT*FROM PRODUCTS;

INSERT INTO Products(ProductID,ProductName,Category,Subcategory,PriceperUnit,StockQuantity,SupplierID)
VALUES('a1b2c3d4-1111-4444-8888-123456789001','Mango','Fruits','Sub-Fruits-1',120.00,100,Null),
('b2c3d4e5-2222-4444-8888-123456789002','Orange','Fruits','Sub-Fruits-2',60.00,150,Null),
('c3d4e5f6-3333-4444-8888-123456789003','Milk','Dairy','Sub-Dairy-2',35.00,80,Null);

SELECT *FROM Products WHERE ProductID IN 
('a1b2c3d4-1111-4444-8888-123456789001','b2c3d4e5-2222-4444-8888-123456789002',
'c3d4e5f6-3333-4444-8888-123456789003');

##Task 6
##Update the stock quantity of a product where ProductID matches a specific ID.

UPDATE Products SET StockQuantity = 200
WHERE ProductID = 'a1b2c3d4-1111-4444-8888-123456789001';

SELECT ProductID, ProductName, StockQuantity FROM Products
WHERE ProductID = 'a1b2c3d4-1111-4444-8888-123456789001';


##Task 7
##Delete a supplier from the Suppliers table where their city matches a specific 

SELECT DISTINCT City FROM Suppliers;

SELECT * FROM Suppliers WHERE City = 'South Ana';

SELECT * FROM Products WHERE SupplierID = '03ec3130-f542-432e-b173-f110efd69026';

DELETE FROM SUPPLIERS WHERE SupplierID='03ec3130-f542-432e-b173-f110efd69026' 
 AND City='South Ana';
 
 
 
 ##SQL Constraints and Operators
##Task 8
##Use SQL constraints to:
##Add a CHECK constraint to ensure that ratings in the Reviews table are 
##between 1 and 5
SELECT *FROM Reviews WHERE Rating < 1 or Rating > 5 or Rating IS NULL;

SELECT CONSTRAINT_NAME,
CHECK_CLAUSE FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS 
WHERE CONSTRAINT_SCHEMA='Amazons'
AND CONSTRAINT_NAME ='CHK_REVIEW_RATING';

##Add a DEFAULT constraint for the PrimeMember column in the Customerstable (default value: "No")
ALTER TABLE Customers ALTER COLUMN PrimeMember SET DEFAULT 'No';

SHOW CREATE TABLE CUSTOMERS;



##Clauses and Aggregations
##Task 9
##Write queries using:

##WHERE clause to find orders placed after 2024-01-01.
SELECT * FROM Orders WHERE OrderDate > '2024-01-01';

##HAVING clause to list products with average ratings greater than 4.

SELECT P.ProductID,
P.ProductName,
Avg(r.Rating) AS AverageRating 
From Products p
Join Reviews r
ON p.ProductID=r.ProductID
Group By p.ProductID,p.ProductName
Having Avg(r.Rating)>4;

##GROUP BY and ORDER BY clauses to rank products by total sales. 
SELECT
p.ProductID,
p.ProductName,
SUM(od.Quantity * od.UnitPrice) AS TotalSales
FROM Products p
JOIN Order_Details od
ON p.ProductID = od.ProductID
GROUP BY
p.ProductID,
p.ProductName
ORDER BY
TotalSales DESC;




##Task 10
##Identifying High-Value Customers
##Scenario:
##Amazon Fresh wants to identify top customers based on their total spending. We will:
##Calculate each customer's total spending.
SELECT
c.CustomerID,
c.Name,
SUM(o.OrderAmount) AS TotalSpending
FROM Customers c
JOIN Orders o
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name;

##Rank customers based on their spending.
SELECT c.CustomerID,c.Name,
SUM(o.OrderAmount) AS TotalSpending,RANK() 
OVER (ORDER BY SUM(o.OrderAmount) DESC) AS CustomerRank
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name
ORDER BY TotalSpending DESC;


##Identify customers who have spent more than ₹5,000. 
SELECT c.CustomerID,c.Name,SUM(o.OrderAmount) AS TotalSpending
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.Name
HAVING SUM(o.OrderAmount) > 5000
ORDER BY TotalSpending DESC;



##Complex Aggregations and Joins
##Task 11
##Use SQL to:
##Join the Orders and OrderDetails tables to calculate total revenue per order.

SELECT o.OrderID,
SUM(od.Quantity * od.UnitPrice) AS TotalRevenue
FROM Orders o
JOIN Order_Details od
ON o.OrderID = od.OrderID
GROUP BY o.OrderID
ORDER BY TotalRevenue DESC;

##Identify customers who placed the most orders in a specific time period.
SELECT c.CustomerID,c.Name,
COUNT(o.OrderID) AS TotalOrders
FROM Customers c
JOIN Orders o
ON c.CustomerID = o.CustomerID
WHERE o.OrderDate >= '2024-01-01'
AND o.OrderDate < '2025-01-01'
GROUP BY c.CustomerID, c.Name
ORDER BY TotalOrders DESC;

##Find the supplier with the most products in stock. 
SELECT s.SupplierID, s.SupplierName,
SUM(p.StockQuantity) AS TotalStock
FROM Suppliers s
JOIN Products p
ON s.SupplierID = p.SupplierID
GROUP BY s.SupplierID,s.SupplierName
ORDER BY TotalStock DESC
LIMIT 1;

SELECT ProductID, ProductName, SupplierID, StockQuantity
FROM Products;

SELECT SupplierID, SupplierName
FROM Suppliers;



##Normalization
##Task 12
##Normalize the Products table to 3NF:

##Separate product categories and subcategories into a new table.

CREATE TABLE Categories (CategoryID INT AUTO_INCREMENT PRIMARY KEY,CategoryName VARCHAR(100) NOT NULL,
SubCategoryName VARCHAR(100) NOT NULL,
UNIQUE (CategoryName, SubCategoryName));

##Create foreign keys to maintain relationships. 
ALTER TABLE Products
ADD COLUMN CategoryID INT;

INSERT IGNORE INTO Categories (CategoryName, SubCategoryName)
SELECT DISTINCT Category, SubCategory
FROM Products WHERE Category IS NOT NULL AND SubCategory IS NOT NULL;
  
SELECT p.ProductID,p.ProductName,c.CategoryName,c.SubCategoryName
FROM Products p
LEFT JOIN Categories c
ON p.CategoryID = c.CategoryID;



##Subqueries and Nested Queries
##Task 13 
##Write a subquery to:

##Identify the top 3 products based on sales revenue.

SELECT p.ProductID,p.ProductName,(
SELECT SUM(od.Quantity * od.UnitPrice)
FROM Order_Details od
WHERE od.ProductID = p.ProductID) AS TotalRevenue
FROM Products p
WHERE p.ProductID IN (SELECT od.ProductID
FROM Order_Details od
GROUP BY od.ProductID)
ORDER BY TotalRevenue DESC
LIMIT 3;

##Find customers who haven’t placed any orders yet.    

SELECT c.CustomerID,c.Name
FROM Customers c
WHERE c.CustomerID NOT IN (SELECT o.CustomerID
FROM Orders o
WHERE o.CustomerID IS NOT NULL);



##Real-World Analysis
##Task 14
##Provide actionable insights:
##Which cities have the highest concentration of Prime members?

SELECT City,
COUNT(*) AS PrimeMembers
FROM Customers
WHERE PrimeMember = 'Yes'
GROUP BY City
ORDER BY PrimeMembers DESC;

##What are the top 3 most frequently ordered categories? 

SELECT p.Category,
SUM(od.Quantity) AS TotalQuantityOrdered
FROM Products p
JOIN Order_Details od
ON p.ProductID = od.ProductID
GROUP BY p.Category

ORDER BY TotalQuantityOrdered DESC
LIMIT 3;

	
 
 
