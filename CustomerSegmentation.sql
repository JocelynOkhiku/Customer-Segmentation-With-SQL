--DATA CLEANING
-- Inspected the data to check for null values and number of records

SELECT COUNT(DISTINCT(CustomerID))
from products_online_sales_updated$;

SELECT COUNT(*)
FROM products_online_sales_updated$ -- check if there are null values
WHERE CustomerID is null;

--Select Data that we are going to be starting with
SELECT *
from products_online_sales_updated$;

--Total Quantity Purchased by Each Customer
--The result is a list of unique customer IDs along with the corresponding total quantity of products they have bought. 

SELECT CustomerID, SUM(Quantity) AS TotalQuantityPurchased
FROM products_online_sales_updated$
GROUP BY CustomerID
ORDER BY TotalQuantityPurchased DESC;

--Total Amount Spent by Each Customer
--Total Monetary Amount spent by each customer by summing the product of the quantity and unit price for all transactions associated with that customer.
SELECT CustomerID, SUM(Quantity * UnitPrice) AS TotalAmountSpent
FROM products_online_sales_updated$
GROUP BY CustomerID
ORDER BY TotalAmountSpent DESC;


--The Customer with the highest quantity and amount spent, and provided additional information such as average unit price, first purchase date, and last purchase date
SELECT
P.CustomerID,P.Country,
MAX(TotalQuantityPurchased) AS HighestQuantityPurchased, MAX(TotalAmountSpent) AS HighestAmountSpent,AVG(P.UnitPrice) AS AverageUnitPrice,
MIN(P.InvoiceDate) AS FirstPurchaseDate, MAX(P.InvoiceDate) AS LastPurchaseDate
FROM (SELECT
CustomerID, SUM(Quantity) AS TotalQuantityPurchased, SUM(Quantity * UnitPrice) AS TotalAmountSpent
FROM products_online_sales_updated$
GROUP BY CustomerID
) AS CustomerSummary 
JOIN products_online_sales_updated$ P ON CustomerSummary.CustomerID = P.CustomerID
WHERE TotalQuantityPurchased = (
SELECT MAX(TotalQuantityPurchased)
FROM (
SELECT CustomerID,SUM(Quantity) AS TotalQuantityPurchased
FROM products_online_sales_updated$
GROUP BY CustomerID
) AS QuantitySummary
)
AND TotalAmountSpent = (
SELECT MAX(TotalAmountSpent)
FROM (
SELECT CustomerID,SUM(Quantity * UnitPrice) AS TotalAmountSpent
FROM products_online_sales_updated$
GROUP BY CustomerID
) AS AmountSummary
)
GROUP BY P.CustomerID, P.Country;


--Countries with the Highest Number of Customers
SELECT Country, COUNT(DISTINCT CustomerID) AS NumberOfCustomers
FROM products_online_sales_updated$
GROUP BY Country
ORDER BY NumberOfCustomers DESC;

--Country with the Highest number of customers is United Kingdom

--Top Selling Products by Quantity
-- Shows which products are the most popular and have the highest demand among customers
SELECT StockCode, Description, SUM(Quantity) AS TotalQuantitySold
FROM products_online_sales_updated$
GROUP BY StockCode, Description
ORDER BY TotalQuantitySold DESC;

--To retrieve information about the unique products purchased by each customer in the
SELECT CustomerID, COUNT(DISTINCT StockCode) AS UniqueProductsPurchased
FROM products_online_sales_updated$
GROUP BY CustomerID;

--Customer Purchase Frequency:
SELECT CustomerID, COUNT(InvoiceNo) AS PurchaseFrequency
FROM products_online_sales_updated$
GROUP BY CustomerID;

--Customer Categories based on their Purchase Frequency:
--Segment customers into categories like "Frequent," "Regular," and "Infrequent" based on their purchase frequency.
SELECT
    CustomerID,
    CASE
        WHEN COUNT(DISTINCT InvoiceNo) > 5 THEN 'Frequent'
        WHEN COUNT(DISTINCT InvoiceNo) BETWEEN 2 AND 5 THEN 'Regular'
        ELSE 'Infrequent'
    END AS PurchaseCategory
FROM
    products_online_sales_updated$
GROUP BY
    CustomerID;


--Segment Customers Based on Total Amount Spent
	SELECT
    CustomerID,
    CASE
        WHEN SUM(Quantity * UnitPrice) < 1000 THEN 'Low Spender'
        WHEN SUM(Quantity * UnitPrice) BETWEEN 1000 AND 5000 THEN 'Medium Spender'
        ELSE 'High Spender'
    END AS SpendingSegment
FROM products_online_sales_updated$
GROUP BY CustomerID
ORDER BY SpendingSegment DESC;


--Identify Customers with Large Transaction
-- to pinpoint high vaalue customers who have made purchases involving large transactions.
SELECT CustomerID,Description
FROM products_online_sales_updated$
WHERE Quantity * UnitPrice > 1000;

--Segment Customers Based on Product Category Preferences
--Grouping customers according to the types of products they predominantly purchase
SELECT P.CustomerID, P.Country, COUNT(DISTINCT P.InvoiceNo) AS PurchaseFrequency, PC.Product_Category
FROM products_online_sales_updated$ P
JOIN product_category$ PC ON P.StockCode = P.StockCode
GROUP BY P.CustomerID, P.Country, PC.Product_Category
ORDER BY PurchaseFrequency;

--Total Amount Spent by Each Customer in Each Product Category
-- To provide a breakdown of the total amount spent by individual customers within different product categories
SELECT P.CustomerID, PC.Product_Category, SUM(P.Quantity * P.UnitPrice) AS TotalAmountSpent
FROM products_online_sales_updated$	P
JOIN product_category$ PC ON P.StockCode = PC.StockCode
GROUP BY P.CustomerID, PC.Product_Category;

--Counting the number of unique customers for each combination of country and product category
SELECT P.Country,PC.Product_Category,COUNT(DISTINCT P.CustomerID) AS CustomerCount
FROM products_online_sales_updated$ P
JOIN product_category$ PC ON P.StockCode = PC.StockCode
GROUP BY P.Country, PC.Product_Category;

 