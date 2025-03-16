CREATE DATABASE IF NOT EXISTS Bill_system;
USE Bill_system;
DESC LOGIN;



-- 1. Signup Table (Signup.java)
CREATE TABLE IF NOT EXISTS Signup (
    id INT AUTO_INCREMENT PRIMARY KEY,
    meter_no VARCHAR(20) UNIQUE NULL, 
    employee_id VARCHAR(20) UNIQUE NULL, 
    username VARCHAR(50) NOT NULL UNIQUE, 
    name VARCHAR(50) NOT NULL, 
    password VARCHAR(255) NOT NULL, 
    usertype ENUM('Admin', 'Customer') NOT NULL,
    CHECK (
        (usertype = 'Customer' AND meter_no IS NOT NULL AND employee_id IS NULL) OR
        (usertype = 'Admin' AND employee_id IS NOT NULL AND meter_no IS NULL)
    )
);

-- 2. Customer Details (customer_details.java)
CREATE TABLE IF NOT EXISTS new_customer (
    meter_no VARCHAR(20) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(15)
);

-- 3. Meter Information (meterInfo.java)
CREATE TABLE IF NOT EXISTS meter_info (
    meter_number VARCHAR(20) PRIMARY KEY,
    meter_location ENUM('Inside', 'Outside') NOT NULL,
    meter_type ENUM('Electric Meter', 'Solar Meter', 'Smart Meter') NOT NULL,
    phase_code VARCHAR(10) NOT NULL,
    bill_type ENUM('Normal', 'Industrial') NOT NULL,
    days INT DEFAULT 30
);

-- 4. Electricity Bill (calculate_bill.java, generate_bill.java, pay_bill.java)
CREATE TABLE IF NOT EXISTS bill (
    id INT AUTO_INCREMENT PRIMARY KEY,
    meter_no VARCHAR(20) NOT NULL,
    month VARCHAR(20) NOT NULL,
    units_consumed INT NOT NULL,
    total_bill DECIMAL(10,2) NOT NULL,
    status ENUM('Paid', 'Not Paid') DEFAULT 'Not Paid',
    FOREIGN KEY (meter_no) REFERENCES new_customer(meter_no)
);

-- 5. Deposit Details (deposit_details.java)
CREATE TABLE IF NOT EXISTS deposit_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    meter_no VARCHAR(20) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    deposit_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (meter_no) REFERENCES new_customer(meter_no)
);

-- 6. Tax Information (used in bill calculations - generate_bill.java)
CREATE TABLE IF NOT EXISTS tax (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cost_per_unit DECIMAL(10,2) NOT NULL,
    meter_rent DECIMAL(10,2) NOT NULL,
    service_charge DECIMAL(10,2) NOT NULL,
    service_tax DECIMAL(10,2) NOT NULL,
    swacch_bharat DECIMAL(10,2) NOT NULL,
    fixed_tax DECIMAL(10,2) NOT NULL
);

-- 7. Payment Records (payment_bill.java, pay_bill.java)
CREATE TABLE IF NOT EXISTS payment_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    meter_no VARCHAR(20) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_status ENUM('Paid', 'Failed') DEFAULT 'Paid',
    FOREIGN KEY (meter_no) REFERENCES new_customer(meter_no)
);

-- 8. User Login Details (Login.java)
CREATE TABLE IF NOT EXISTS login_activity (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Success', 'Failed') DEFAULT 'Success',
    FOREIGN KEY (username) REFERENCES Signup(username)
);

-- 9. Bill Details View (bill_details.java)
CREATE VIEW bill_summary AS
SELECT 
    b.id, b.meter_no, nc.name, b.month, b.units_consumed, b.total_bill, b.status
FROM bill b
JOIN new_customer nc ON b.meter_no = nc.meter_no;

-- 10. View Information (view_information.java)
CREATE VIEW customer_info AS
SELECT 
    nc.meter_no, nc.name, nc.address, nc.city, nc.state, nc.email, nc.phone, 
    mi.meter_type, mi.bill_type
FROM new_customer nc
JOIN meter_info mi ON nc.meter_no = mi.meter_number;

-- 11. Update Information (update_information.java)
-- Customers and Admins can update details, so we allow updates on these tables
ALTER TABLE new_customer ADD COLUMN last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
ALTER TABLE meter_info ADD COLUMN last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- 12. Splash Screen Activity (Splash.java)
-- No direct database interaction required for splash screen.

-- 13. Main Class (main_class.java)
-- No direct database table required, but it manages access control.

-- 14. New Customer Entry (newCustomer.java)
-- Insert query for adding a new customer:
-- INSERT INTO new_customer (meter_no, name, address, city, state, email, phone) 
-- VALUES ('123456', 'John Doe', '123 Street', 'CityX', 'StateY', 'johndoe@example.com', '1234567890');

-- 15. Database Configuration (database.java)
-- Used for handling database connections, no table required.

-- 16. Payment Handling (payment_bill.java)
-- Redirects to an external payment gateway.

-- dummy data
USE Bill_system;
INSERT INTO Signup (meter_no, employee_id, username, name, password, usertype) VALUES
('10001', NULL, 'rahul_sharma', 'Rahul Sharma', 'password123', 'Customer'),
('10002', NULL, 'priya_verma', 'Priya Verma', 'securePass456', 'Customer');

-- Dummy data for new_customer Table
INSERT INTO new_customer (meter_no, name, address, city, state, email, phone) VALUES
('10001', 'Rahul Sharma', '45, MG Road', 'Mumbai', 'Maharashtra', 'rahul.sharma@example.com', '9876543210'),
('10002', 'Priya Verma', '12, Rajpath Nagar', 'Delhi', 'Delhi', 'priya.verma@example.com', '8765432109'),
('10003', 'Vikram Singh', '78, Gandhi Chowk', 'Jaipur', 'Rajasthan', 'vikram.singh@example.com', '9988776655'),
('10004', 'Neha Joshi', '56, Indira Colony', 'Bangalore', 'Karnataka', 'neha.joshi@example.com', '8877665544');

-- Dummy data for meter_info Table
INSERT INTO meter_info (meter_number, meter_location, meter_type, phase_code, bill_type, days) VALUES
('10001', 'Inside', 'Electric Meter', '011', 'Normal', 30),
('10002', 'Outside', 'Solar Meter', '022', 'Industrial', 30),
('10003', 'Inside', 'Smart Meter', '033', 'Normal', 30),
('10004', 'Outside', 'Electric Meter', '044', 'Industrial', 30);

-- Dummy data for bill Table
INSERT INTO bill (meter_no, month, units_consumed, total_bill, status) VALUES
('10001', 'January', 250, 1250.50, 'Paid'),
('10001', 'February', 220, 1100.00, 'Not Paid'),
('10002', 'January', 300, 1500.75, 'Paid'),
('10003', 'March', 180, 900.25, 'Not Paid');

-- Dummy data for deposit_details Table
INSERT INTO deposit_details (meter_no, amount) VALUES
('10001', 5000.00),
('10002', 7500.00),
('10003', 6000.00);

-- Dummy data for tax Table
INSERT INTO tax (cost_per_unit, meter_rent, service_charge, service_tax, swacch_bharat, fixed_tax) VALUES
(10.50, 50.00, 30.00, 5.00, 2.50, 100.00);

-- Dummy data for payment_records Table
INSERT INTO payment_records (meter_no, amount, payment_status) VALUES
('10001', 1250.50, 'Paid'),
('10002', 1500.75, 'Paid'),
('10003', 900.25, 'Failed');

-- Dummy data for login_activity Table
-- INSERT INTO login_activity (username, status) VALUES
-- ('rahul_sharma', 'Success'),
-- ('priya_verma', 'Failed'),
-- ('admin_amit', 'Success'),
-- ('admin_sneha', 'Success');

-- Print all data from the tables
SELECT * FROM Signup;
SELECT * FROM new_customer;
SELECT * FROM meter_info;
SELECT * FROM bill;
SELECT * FROM deposit_details;
SELECT * FROM tax;
SELECT * FROM payment_records;
SELECT * FROM login_activity;

-- print details
USE Bill_system;

-- Print all data from the Signup table
SELECT * FROM Signup;

-- Print all data from the new_customer table
SELECT * FROM new_customer;

-- Print all data from the meter_info table
SELECT * FROM meter_info;

-- Print all data from the bill table
SELECT * FROM bill;

-- Print all data from the deposit_details table
SELECT * FROM deposit_details;

-- Print all data from the tax table
SELECT * FROM tax;

-- Print all data from the payment_records table
SELECT * FROM payment_records;

-- Print all data from the login_activity table
SELECT * FROM login_activity;

-- Print data from views
SELECT * FROM bill_summary;
SELECT * FROM customer_info;

ALTER TABLE new_customer CHANGE COLUMN phone phone_no VARCHAR(15);
ALTER TABLE bill CHANGE COLUMN units_consumed unit INT;
ALTER TABLE bill CHANGE COLUMN unit units_consumed INT;

USE Bill_system;
USE Bill_system;

INSERT INTO new_customer (meter_no, name, address, city, state, email, phone_no) VALUES 
('10005', 'Amit Kumar', '101, MG Road', 'Mumbai', 'Maharashtra', 'amit.kumar@example.com', '9876543210'),
('10006', 'Neha Singh', '202, Park Avenue', 'Delhi', 'Delhi', 'neha.singh@example.com', '8765432109'),
('10007', 'Rajesh Sharma', '303, Gandhi Street', 'Chennai', 'Tamil Nadu', 'rajesh.sharma@example.com', '7654312345'),
('10008', 'Pooja Verma', '404, Nehru Nagar', 'Bangalore', 'Karnataka', 'pooja.verma@example.com', '6543212345'),
('10009', 'Vikram Patel', '505, Patel Road', 'Jaipur', 'Rajasthan', 'vikram.patel@example.com', '9988776655'),
('10010', 'Anjali Das', '606, Indira Colony', 'Kolkata', 'West Bengal', 'anjali.das@example.com', '8877665544'),
('10011', 'Rahul Yadav', '707, Rajendra Nagar', 'Pune', 'Maharashtra', 'rahul.yadav@example.com', '7788912345'),
('10012', 'Simran Kaur', '808, Shivaji Nagar', 'Nagpur', 'Maharashtra', 'simran.kaur@example.com', '8899712345'),
('10013', 'Karan Mehta', '909, Rani Bagh', 'Chandigarh', 'Punjab', 'karan.mehta@example.com', '9988412345'),
('10014', 'Poonam Joshi', '1001, Model Town', 'Lucknow', 'Uttar Pradesh', 'poonam.joshi@example.com', '9665512345');

INSERT INTO meter_info (meter_number, meter_location, meter_type, phase_code, bill_type, days) VALUES
('10005', 'Inside', 'Electric Meter', '011', 'Normal', 30),
('10006', 'Outside', 'Solar Meter', '022', 'Industrial', 30),
('10007', 'Inside', 'Smart Meter', '033', 'Normal', 30),
('10008', 'Outside', 'Electric Meter', '044', 'Industrial', 30),
('10009', 'Inside', 'Electric Meter', '055', 'Normal', 30),
('10010', 'Outside', 'Smart Meter', '066', 'Industrial', 30),
('10011', 'Inside', 'Solar Meter', '077', 'Normal', 30),
('10012', 'Outside', 'Electric Meter', '088', 'Industrial', 30),
('10013', 'Inside', 'Electric Meter', '099', 'Normal', 30),
('10014', 'Outside', 'Solar Meter', '101', 'Industrial', 30);

INSERT INTO bill (meter_no, month, units_consumed, total_bill, status) VALUES
('10005', 'January', 250, 1250.50, 'Paid'),
('10006', 'February', 220, 1100.00, 'Not Paid'),
('10007', 'March', 180, 900.25, 'Paid'),
('10008', 'April', 300, 1500.75, 'Not Paid'),
('10009', 'May', 210, 1050.40, 'Paid'),
('10010', 'June', 270, 1350.60, 'Not Paid'),
('10011', 'July', 290, 1450.90, 'Paid'),
('10012', 'August', 200, 1000.30, 'Not Paid'),
('10013', 'September', 310, 1550.80, 'Paid'),
('10014', 'October', 230, 1150.45, 'Not Paid');

INSERT INTO deposit_details (meter_no, amount) VALUES
('10005', 5000.00),
('10006', 7500.00),
('10007', 6000.00),
('10008', 7000.00),
('10009', 6500.00),
('10010', 7200.00),
('10011', 8000.00),
('10012', 5500.00),
('10013', 7700.00),
('10014', 6800.00);

INSERT INTO tax (cost_per_unit, meter_rent, service_charge, service_tax, swacch_bharat, fixed_tax) VALUES
(10.50, 50.00, 30.00, 5.00, 2.50, 100.00);
INSERT INTO payment_records (meter_no, amount, payment_status) VALUES
('10005', 1250.50, 'Paid'),
('10006', 1100.00, 'Failed'),
('10007', 900.25, 'Paid'),
('10008', 1500.75, 'Failed'),
('10009', 1050.40, 'Paid'),
('10010', 1350.60, 'Failed'),
('10011', 1450.90, 'Paid'),
('10012', 1000.30, 'Failed'),
('10013', 1550.80, 'Paid'),
('10014', 1150.45, 'Failed');

INSERT INTO login_activity (username, status) VALUES
('rahul_sharma', 'Success'),
('priya_verma', 'Failed'),
('amit_kumar', 'Success'),
('neha_singh', 'Success'),
('rajesh_sharma', 'Failed'),
('pooja_verma', 'Success'),
('vikram_patel', 'Success'),
('anjali_das', 'Failed'),
('rahul_yadav', 'Success'),
('simran_kaur', 'Failed');

SELECT * FROM Signup;
SELECT * FROM new_customer;
SELECT * FROM meter_info;
SELECT * FROM bill;
SELECT * FROM deposit_details;
SELECT * FROM tax;
SELECT * FROM payment_records;
SELECT * FROM login_activity;



SHOW COLUMNS FROM new_customer;

SHOW TABLES;


DESC Signup;
DESC new_customer;
DESC meter_info;
DESC bill;
DESC deposit_details;
DESC tax;
DESC payment_records;
DESC login_activity;