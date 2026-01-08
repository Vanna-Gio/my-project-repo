

--Sample Data (Optional but Recommended)
INSERT INTO categories (name, description)
VALUES 
(N'ភេសជ្ជៈ', N'ប្រភេទភេសជ្ជៈ'),
(N'អាហារ', N'ប្រភេទអាហារ'),
(N'Electronics', N'Electronic products');

--Products
INSERT INTO products (name, description, price, image_url, category_id)
VALUES
(N'ទូរស័ព្ទ Samsung Galaxy S24', N'ទូរស័ព្ទដៃទំនើបបំផុត', 899.99, 'upload/images/samsung-s24.jpg', 3);
(N'Laptop', N'Gaming laptop', 1300.00, 'uploads/images/laptop.jpg', 3);


UPDATE products
SET image_url = 'upload/images/samsung-s24.jpg'
WHERE id = 3;





