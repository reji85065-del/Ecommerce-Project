USE ecommerce;

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT NOT NULL,
    Order_Date DATE NOT NULL,
    Total_Amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    Order_Status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    CHECK (Total_Amount >= 0),
    CHECK (Order_Status IN ('Pending', 'Shipped', 'Delivered', 'Cancelled'))
);

CREATE TABLE Order_Details (
    Order_Detail_ID INT PRIMARY KEY,
    Order_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID)
        ON DELETE CASCADE,
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID),
    CHECK (Quantity > 0),
    CHECK (Price >= 0)
);

INSERT INTO Orders
(Order_ID, Customer_ID, Order_Date, Total_Amount, Order_Status)
VALUES
(5001, 1, '2026-10-09', 0, 'Pending');

INSERT INTO Order_Details
(Order_Detail_ID, Order_ID, Product_ID, Quantity, Price)
VALUES
(1, 5001, 101, 1, 50000),
(2, 5001, 102, 2, 500);

UPDATE Orders
SET Total_Amount = (
    SELECT SUM(Quantity * Price)
    FROM Order_Details
    WHERE Order_ID = 5001
)
WHERE Order_ID = 5001;

UPDATE Orders
SET Order_Status = 'Delivered'
WHERE Order_ID = 5001;

UPDATE Order_Details
SET Quantity = 3
WHERE Order_Detail_ID = 2;

UPDATE Orders
SET Total_Amount = (
    SELECT SUM(Quantity * Price)
    FROM Order_Details
    WHERE Order_ID = 5001
)
WHERE Order_ID = 5001;

DELETE FROM Orders WHERE Order_Status = 'Cancelled';

SELECT
    p.Product_ID,
    p.Product_Name,
    COUNT(DISTINCT od.Order_ID) AS Times_Ordered,
    SUM(od.Quantity) AS Total_Quantity_Sold
FROM Product p
LEFT JOIN Order_Details od
ON p.Product_ID = od.Product_ID
GROUP BY p.Product_ID, p.Product_Name;

SELECT SUM(Total_Amount) AS Total_Sales
FROM Orders
WHERE Order_Status <> 'Cancelled';
