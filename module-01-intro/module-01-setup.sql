-- Module 1: Intro to Databases - Common Setup Script (MySQL)
-- This script creates small reusable schemas for activities in Module 1.
-- Run parts as needed. Each activity also includes its own minimal data inline.

-- Clean up if re-running
DROP DATABASE IF EXISTS m1_intro_ecom;
DROP DATABASE IF EXISTS m1_intro_edu;
DROP DATABASE IF EXISTS m1_intro_health;

-- E-COMMERCE SCHEMA
CREATE DATABASE m1_intro_ecom;
USE m1_intro_ecom;

CREATE TABLE `products` (
  `product_id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `category` VARCHAR(50),
  `price` DECIMAL(10,2) NOT NULL,
  `stock` INT NOT NULL,
  `discontinued` TINYINT(1) DEFAULT 0
);

CREATE TABLE `customers` (
  `customer_id` INT PRIMARY KEY AUTO_INCREMENT,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `email` VARCHAR(120) UNIQUE,
  `created_at` DATE NOT NULL
);

CREATE TABLE `orders` (
  `order_id` INT PRIMARY KEY AUTO_INCREMENT,
  `customer_id` INT NOT NULL,
  `order_date` DATE NOT NULL,
  `status` VARCHAR(20) NOT NULL,
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`)
);

CREATE TABLE `order_items` (
  `order_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `quantity` INT NOT NULL,
  `unit_price` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`order_id`, `product_id`),
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`order_id`),
  FOREIGN KEY (`product_id`) REFERENCES `products`(`product_id`)
);

INSERT INTO `products` (`name`,`category`,`price`,`stock`,`discontinued`) VALUES
('Wireless Mouse','Accessories',19.99,100,0),
('Mechanical Keyboard','Accessories',79.99,50,0),
('USB-C Cable','Cables',9.99,0,0), -- out of stock edge case
('4K Monitor','Displays',299.00,10,0),
('Old Webcam','Cameras',24.99,5,1); -- discontinued edge case

INSERT INTO `customers` (`first_name`,`last_name`,`email`,`created_at`) VALUES
('Ava','Lee','ava.lee@example.com','2025-01-10'),
('Ben','Kim','ben.kim@example.com','2025-02-02'),
('Cara','Singh',NULL,'2025-02-20'), -- email NULL edge case
('Dan','Ng','dan.ng@example.com','2025-03-01');

INSERT INTO `orders` (`customer_id`,`order_date`,`status`) VALUES
(1,'2025-03-05','PAID'),
(1,'2025-03-20','CANCELLED'),
(2,'2025-03-21','PAID');

INSERT INTO `order_items` (`order_id`,`product_id`,`quantity`,`unit_price`) VALUES
(1,1,2,19.99),
(1,3,1,9.99),
(2,5,1,24.99),
(3,2,1,79.99),
(3,4,2,299.00);

-- EDUCATION SCHEMA
CREATE DATABASE m1_intro_edu;
USE m1_intro_edu;

CREATE TABLE `courses` (
  `course_id` INT PRIMARY KEY AUTO_INCREMENT,
  `title` VARCHAR(100) NOT NULL,
  `category` VARCHAR(50),
  `active` TINYINT(1) DEFAULT 1
);

CREATE TABLE `students` (
  `student_id` INT PRIMARY KEY AUTO_INCREMENT,
  `full_name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(120),
  `enrolled_on` DATE NOT NULL
);

CREATE TABLE `enrollments` (
  `student_id` INT NOT NULL,
  `course_id` INT NOT NULL,
  `grade` DECIMAL(4,2),
  PRIMARY KEY (`student_id`,`course_id`),
  FOREIGN KEY (`student_id`) REFERENCES `students`(`student_id`),
  FOREIGN KEY (`course_id`) REFERENCES `courses`(`course_id`)
);

INSERT INTO `courses` (`title`,`category`,`active`) VALUES
('SQL Basics','Data',1),
('Python 101','Programming',1),
('Project Management','Business',0); -- inactive edge case

INSERT INTO `students` (`full_name`,`email`,`enrolled_on`) VALUES
('Maya Patel','maya@example.com','2025-01-15'),
('Omar Ali',NULL,'2025-02-01'), -- NULL email
('Jin Park','jin.park@example.com','2025-02-20');

INSERT INTO `enrollments` (`student_id`,`course_id`,`grade`) VALUES
(1,1,92.50),
(1,2,NULL), -- missing grade
(2,1,84.00),
(3,2,88.00);

-- HEALTHCARE SCHEMA
CREATE DATABASE m1_intro_health;
USE m1_intro_health;

CREATE TABLE `patients` (
  `patient_id` INT PRIMARY KEY AUTO_INCREMENT,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `dob` DATE NOT NULL
);

CREATE TABLE `appointments` (
  `appt_id` INT PRIMARY KEY AUTO_INCREMENT,
  `patient_id` INT NOT NULL,
  `appt_date` DATETIME NOT NULL,
  `status` VARCHAR(20) NOT NULL,
  FOREIGN KEY (`patient_id`) REFERENCES `patients`(`patient_id`)
);

INSERT INTO `patients` (`first_name`,`last_name`,`dob`) VALUES
('Ivy','Chen','1995-04-12'),
('Leo','Garcia','1998-09-30');

INSERT INTO `appointments` (`patient_id`,`appt_date`,`status`) VALUES
(1,'2025-03-10 09:00:00','COMPLETED'),
(1,'2025-04-02 14:00:00','SCHEDULED'),
(2,'2025-03-15 11:30:00','CANCELLED');

-- End of Setup
