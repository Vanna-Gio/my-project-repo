CREATE DATABASE TonaireDigitalDB;
GO
USE TonaireDigitalDB;
GO


--Users Table (Authentication)
CREATE TABLE users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    email NVARCHAR(255) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT GETDATE()
);

--
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'users';

ALTER TABLE users 
ADD otp NVARCHAR(10),
    otp_expiration DATETIME;   

--
--Categories Table
CREATE TABLE categories (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(500),
    created_at DATETIME DEFAULT GETDATE()
);

--Products Table
CREATE TABLE products (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(1000),
    price DECIMAL(10,2) NOT NULL,
    image_url NVARCHAR(500),
    category_id INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),

    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id)
        REFERENCES categories(id)
        ON DELETE CASCADE
);

--Indexes (Performance + Search)
CREATE INDEX idx_categories_name ON categories(name);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_category ON products(category_id);


--Test
SELECT * FROM users;
SELECT * FROM categories;
SELECT * FROM products;

use TonaireDigitalDB 
go

SELECT * FROM categories
WHERE name COLLATE Khmer_100_CI_AI LIKE N'%ភ%';
--How Khmer Search Will Work (IMPORTANT)
SELECT * FROM products
WHERE name COLLATE Khmer_100_CI_AI LIKE N'%ភេ%';
--Sorting:
ORDER BY name COLLATE Khmer_100_CI_AI

--

--
UPDATE products
SET image_url = 'upload/images/samsung-s24.jpg'
WHERE id = 3;
