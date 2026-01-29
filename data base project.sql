CREATE DATABASE FactoryDB;
USE FactoryDB;

-- Departments
CREATE TABLE Department(
  DeptID INT AUTO_INCREMENT PRIMARY KEY,
  DeptName VARCHAR(50) UNIQUE NOT NULL
);

-- Employees
CREATE TABLE Employee(
  EmpID INT AUTO_INCREMENT PRIMARY KEY,
  EmpName VARCHAR(50) NOT NULL,
  Gender CHAR(1),
  Email VARCHAR(100) UNIQUE,
  Salary DECIMAL(10,2),
  DeptID INT,
  FOREIGN KEY(DeptID) REFERENCES Department(DeptID)
);

-- Machines
CREATE TABLE Machine(
  MachineID INT AUTO_INCREMENT PRIMARY KEY,
  SerialNo VARCHAR(50) UNIQUE NOT NULL,
  Status VARCHAR(20) DEFAULT 'Active',
  DeptID INT,
  FOREIGN KEY(DeptID) REFERENCES Department(DeptID)
);

-- Products
CREATE TABLE Product(
  ProductID INT AUTO_INCREMENT PRIMARY KEY,
  ProductName VARCHAR(50) NOT NULL,
  Price DECIMAL(10,2)
);

-- Orders
CREATE TABLE Orders(
  OrderID INT AUTO_INCREMENT PRIMARY KEY,
  OrderDate DATE NOT NULL,
  Status VARCHAR(20) DEFAULT 'Pending'
);

-- Order Details
CREATE TABLE OrderDetail(
  DetailID INT AUTO_INCREMENT PRIMARY KEY,
  OrderID INT,
  ProductID INT,
  Quantity INT,
  FOREIGN KEY(OrderID) REFERENCES Orders(OrderID),
  FOREIGN KEY(ProductID) REFERENCES Product(ProductID)
);

-- Inventory
CREATE TABLE Inventory(
  InvID INT AUTO_INCREMENT PRIMARY KEY,
  ProductID INT,
  Quantity INT,
  FOREIGN KEY(ProductID) REFERENCES Product(ProductID)
);

-- Suppliers
CREATE TABLE Supplier(
  SupplierID INT AUTO_INCREMENT PRIMARY KEY,
  SupplierName VARCHAR(50) NOT NULL,
  Email VARCHAR(100) UNIQUE
);

-- Raw Materials
CREATE TABLE RawMaterial(
  MaterialID INT AUTO_INCREMENT PRIMARY KEY,
  MaterialName VARCHAR(50),
  Quantity INT,
  SupplierID INT,
  FOREIGN KEY(SupplierID) REFERENCES Supplier(SupplierID)
);

-- Maintenance Records
CREATE TABLE Maintenance(
  RecordID INT AUTO_INCREMENT PRIMARY KEY,
  MachineID INT,
  MaintDate DATE,
  Notes TEXT,
  FOREIGN KEY(MachineID) REFERENCES Machine(MachineID)
);

-- Audit Log (for triggers)
CREATE TABLE AuditLog(
  LogID INT AUTO_INCREMENT PRIMARY KEY,
  Action VARCHAR(100),
  LogTime DATETIME
);

-- Views (5 total)
-- Views
CREATE VIEW PendingOrders AS 
SELECT * FROM Orders WHERE Status='Pending';

CREATE VIEW InventoryStatus AS 
SELECT p.ProductName, i.Quantity 
FROM Inventory i JOIN Product p ON i.ProductID=p.ProductID;

CREATE VIEW EmployeeList AS 
SELECT e.EmpName, e.Email, d.DeptName 
FROM Employee e JOIN Department d ON e.DeptID=d.DeptID;

CREATE VIEW MachineStatus AS 
SELECT SerialNo, Status FROM Machine;

CREATE VIEW SupplierMaterials AS 
SELECT s.SupplierName, r.MaterialName, r.Quantity 
FROM RawMaterial r JOIN Supplier s ON r.SupplierID=s.SupplierID;


-- Stored Procedures (3 total)
DELIMITER //
CREATE PROCEDURE AddEmployee(IN name VARCHAR(50), IN gender CHAR(1), IN email VARCHAR(100), IN salary DECIMAL(10,2), IN dept INT)
BEGIN
  INSERT INTO Employee(EmpName,Gender,Email,Salary,DeptID) VALUES(name,gender,email,salary,dept);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE UpdateStock(IN prod INT, IN qty INT)
BEGIN
  UPDATE Inventory SET Quantity=Quantity+qty WHERE ProductID=prod;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE AddMaintenance(IN machine INT, IN date DATE, IN notes TEXT)
BEGIN
  INSERT INTO Maintenance(MachineID,MaintDate,Notes) VALUES(machine,date,notes);
END //
DELIMITER ;

-- Triggers (2 total)
DELIMITER //
CREATE TRIGGER trg_UpdateInventory AFTER INSERT ON OrderDetail
FOR EACH ROW
BEGIN
  UPDATE Inventory SET Quantity=Quantity-NEW.Quantity WHERE ProductID=NEW.ProductID;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_LogEmployee AFTER INSERT ON Employee
FOR EACH ROW
BEGIN
  INSERT INTO AuditLog(Action,LogTime) VALUES(CONCAT('New Employee Added: ',NEW.EmpName),NOW());
END //
DELIMITER ;

INSERT INTO Department (DeptName) VALUES
('Production'),
('HR'),
('Maintenance'),
('Sales'),
('Quality Control');

INSERT INTO Employee (EmpName, Gender, Email, Salary, DeptID) VALUES
('Ali Khan', 'M', 'ali.khan@gmail.com', 45000, 1),
('Sara Ahmed', 'F', 'sara.ahmed@gmail.com', 50000, 2),
('Usman Raza', 'M', 'usman.raza@gmail.com', 48000, 3),
('Ayesha Noor', 'F', 'ayesha.noor@gmail.com', 52000, 4),
('Bilal Hussain', 'M', 'bilal.h@gmail.com', 47000, 5);

INSERT INTO Machine (SerialNo, Status, DeptID) VALUES
('MC-1001', 'Active', 1),
('MC-1002', 'Active', 1),
('MC-2001', 'Inactive', 3),
('MC-3001', 'Active', 5);

INSERT INTO Product (ProductName, Price) VALUES
('Steel Rod', 1500),
('Iron Sheet', 2500),
('Copper Wire', 1800),
('Aluminium Bar', 2200);

INSERT INTO Inventory (ProductID, Quantity) VALUES
(1, 500),
(2, 300),
(3, 400),
(4, 250);

INSERT INTO Orders (OrderDate, Status) VALUES
('2026-01-20', 'Pending'),
('2026-01-22', 'Completed'),
('2026-01-25', 'Pending');

INSERT INTO OrderDetail (OrderID, ProductID, Quantity) VALUES
(1, 1, 20),
(1, 3, 15),
(2, 2, 10),
(3, 4, 5);

INSERT INTO Supplier (SupplierName, Email) VALUES
('Pak Steel Ltd', 'contact@paksteel.com'),
('Metal Works', 'info@metalworks.com'),
('Raw Materials Co', 'sales@rawco.com');

INSERT INTO RawMaterial (MaterialName, Quantity, SupplierID) VALUES
('Iron Ore', 1000, 1),
('Copper Scrap', 600, 2),
('Aluminium Ore', 800, 3);

INSERT INTO Maintenance (MachineID, MaintDate, Notes) VALUES
(1, '2026-01-10', 'Routine maintenance completed'),
(3, '2026-01-15', 'Motor replaced'),
(2, '2026-01-18', 'Oil change and inspection');

SELECT * FROM department;
SELECT * FROM Inventory;




