create database IMS;

use IMS;

-- Create the Products Table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(255) NOT NULL,
    Category VARCHAR(100),
    Price DECIMAL(10, 2) NOT NULL,
    SupplierID INT,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

-- Create the Suppliers Table
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY AUTO_INCREMENT,
    SupplierName VARCHAR(255) NOT NULL,
    ContactDetails VARCHAR(255),
    Rating DECIMAL(3, 2) CHECK (Rating BETWEEN 0 AND 5)
);

-- Create the StockLevels Table
CREATE TABLE StockLevels (
    StockID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT,
    Quantity INT NOT NULL,
    WarehouseLocation VARCHAR(100),
    ReorderThreshold INT DEFAULT 10,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Create the PurchaseOrders Table
CREATE TABLE PurchaseOrders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT,
    SupplierID INT,
    OrderDate DATE NOT NULL,
    QuantityOrdered INT NOT NULL,
    ExpectedDeliveryDate DATE,
    Status VARCHAR(50) CHECK (Status IN ('Pending', 'Delivered', 'Canceled')),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

-- Insert data into Suppliers
INSERT INTO Suppliers (SupplierName, ContactDetails, Rating)
VALUES ('Dinesh', 'dinesh@gmail.com', 4.5),
       ('vamshi', 'vamshi@gamil.com', 3.9),
       ('uday', 'uday@gamil.com', 3.5),
       ('mahesh' , 'mahesh@gamil.com' , 3.2),
       ('harish' , 'harish@gmail.com' , 4.0),
       ('poornachandu', 'poorna@gmail.com' , 3.2),
       ('divya' , 'divya@gamil.com', 4.6),
       ('mounika', 'mounika@gmail.com', 4.5),
       ('akhil' , 'akhil@gmail.com' , 4.7),
       ('akash' , 'akash@gmail.com', 4.7);

-- Insert data into Products
INSERT INTO Products (ProductName, Category, Price, SupplierID)
VALUES ('waterpurifier', 'electronics', 1000.00, 1),
       ('laptop', 'electronics', 200000.00, 2),
       ('oneplus' ,'electronics', 300000.00, 3),
       ('footwear' , 'fashion' , 500.00, 4 ),
       ('kurta', 'fashion' , 10000.00 , 5),
       ('earpods', 'accessories', 900.00 , 6),
       ('powerbank' , 'accessories' , 10000.00 , 7),
       ('dryfruits', 'grocery', 300.00 , 8),
       ('beds and sofas' , 'furnitures' , 10000.00 , 9),
       ('tables' , 'furnitures' , 20000.00 , 10);

-- Insert data into StockLevels
INSERT INTO StockLevels (ProductID, Quantity, WarehouseLocation)
VALUES (1, 50, 'lbnagar'),
       (2, 5, 'moosapet'),
       (3, 30 , 'kukatpally'),
       (4, 80, 'securandrabad'),
       (5 , 10 , 'hitechscity'),
       (6, 20 , 'kphb'),
       (7, 10, 'miyapur'),
       (8, 40 , 'srnagar'),
       (9, 30 , 'erragada'),
       (10 , 60 , 'banjarahills');
       
-- Insert data into PurchaseOrders
INSERT INTO PurchaseOrders (ProductID, SupplierID, OrderDate, QuantityOrdered, ExpectedDeliveryDate, Status)
VALUES (1, 1, '2024-08-01', 100, '2024-08-15', 'Pending'),
       (2, 2, '2024-08-01', 50, '2024-08-10', 'Delivered'),
       (3, 3, '2021-01-11', 10 , '2021-01-17', 'Delivered'),
       (4 , 4, '2022-05-12', 30 , '2022-05-14' , 'canceled'),
       (5, 5 , '2022-06-21' , 15 , '2022-05-25' , 'pending'),
       (6, 6 , '2023-02-15', 20 , '2023-02-17', 'delivered'),
       (7, 7 , '2023-07-30', 03 , '2024-08-06', 'canceled'),
       (8, 8 , '2024-05-17' , 40 , '2024-05-20' , 'delivered'),
       (9 , 9 , '2024-08-21' , 60 , '2024-08-25' , 'pending'),
       (10 , 10 , '2024-06-20' , 25 , '2024-06-25' , 'canceled');

-- SQL Queries
-- Monitor Stock Levels (Find products with low stock)

SELECT p.ProductName, s.Quantity, s.WarehouseLocation 
FROM StockLevels s
JOIN Products p ON s.ProductID = p.ProductID
WHERE s.Quantity < s.ReorderThreshold;

-- Track Reorders (Find pending purchase orders)

SELECT o.OrderID, p.ProductName, s.SupplierName, o.QuantityOrdered, o.ExpectedDeliveryDate 
FROM PurchaseOrders o
JOIN Products p ON o.ProductID = p.ProductID
JOIN Suppliers s ON o.SupplierID = s.SupplierID
WHERE o.Status = 'Pending';

-- Analyze Supplier Performance (Find the number of orders and average rating of suppliers)

SELECT s.SupplierName, COUNT(o.OrderID) AS TotalOrders, AVG(s.Rating) AS AvgRating 
FROM Suppliers s
LEFT JOIN PurchaseOrders o ON s.SupplierID = o.SupplierID
GROUP BY s.SupplierName;

-- Views
-- Create a View for Low Stock Products

CREATE VIEW LowStockProducts AS
SELECT p.ProductName, s.Quantity, s.WarehouseLocation
FROM StockLevels s
JOIN Products p ON s.ProductID = p.ProductID
WHERE s.Quantity < s.ReorderThreshold;

-- Create a View for Pending Orders

CREATE VIEW PendingOrders AS
SELECT o.OrderID, p.ProductName, s.SupplierName, o.QuantityOrdered, o.ExpectedDeliveryDate
FROM PurchaseOrders o
JOIN Products p ON o.ProductID = p.ProductID
JOIN Suppliers s ON o.SupplierID = s.SupplierID
WHERE o.Status = 'Pending';

-- Indexes
-- Create Index on ProductID in StockLevels

CREATE INDEX idx_productID ON StockLevels(ProductID);

-- Create Index on SupplierID in PurchaseOrders

CREATE INDEX idx_supplierID ON PurchaseOrders(SupplierID);

-- Transaction
-- how to use a transaction when updating stock levels and recording a purchase order

START TRANSACTION;

-- Decrease stock levels when a product is ordered
UPDATE StockLevels
SET Quantity = Quantity - 10
WHERE ProductID = 1;

-- Insert a new purchase order
INSERT INTO PurchaseOrders (ProductID, SupplierID, OrderDate, QuantityOrdered, ExpectedDeliveryDate, Status)
VALUES (1, 1, CURDATE(), 10, DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'Pending');

COMMIT;


