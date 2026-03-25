-- 1. Tạo bảng khách hàng

CREATE TABLE customer (

    customer_id SERIAL PRIMARY KEY,

    full_name VARCHAR(100),

    email VARCHAR(100),

    phone VARCHAR(15)

);



-- 2. Tạo bảng đơn hàng

CREATE TABLE orders (

    order_id SERIAL PRIMARY KEY,

    customer_id INT REFERENCES customer(customer_id),

    total_amount DECIMAL(10,2),

    order_date DATE

);



-- 3. Thêm dữ liệu mẫu (Mock data)

INSERT INTO customer (full_name, email, phone) VALUES 

('Nguyễn Văn A', 'vana@gmail.com', '0901234567'),

('Lê Thị B', 'thib@gmail.com', '0907654321'),

('Đinh Quốc Huy', 'huy@student.com', '0988888888');



INSERT INTO orders (customer_id, total_amount, order_date) VALUES 

(1, 1500000, '2026-03-01'),

(1, 500000, '2026-03-15'),

(2, 2000000, '2026-02-20'),

(3, 3000000, '2026-03-20'),

(3, 800000, '2026-01-10');



-- 4. Tạo View v_order_summary (Yêu cầu 1)

CREATE VIEW v_order_summary AS

SELECT c.full_name, o.total_amount, o.order_date

FROM customer c

JOIN orders o ON c.customer_id = o.customer_id;



-- Xem View (Yêu cầu 2)

SELECT * FROM v_order_summary;



-- 5. Tạo View v_high_value_orders (Yêu cầu 3)

CREATE VIEW v_high_value_orders AS

SELECT * FROM orders WHERE total_amount >= 1000000;



-- Cập nhật thử 1 bản ghi qua View

UPDATE v_high_value_orders SET total_amount = 1300000 WHERE order_id = 1;



-- 6. Tạo View v_monthly_sales (Yêu cầu 4)

CREATE VIEW v_monthly_sales AS

SELECT 

    TO_CHAR(order_date, 'YYYY-MM') AS month, 

    SUM(total_amount) AS total_revenue

FROM orders

GROUP BY month

ORDER BY month;



-- Xem báo cáo doanh thu tháng

SELECT * FROM v_monthly_sales;