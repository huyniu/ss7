-- 1. Tạo các bảng cơ sở
CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    region VARCHAR(50)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customer(customer_id),
    total_amount DECIMAL(10,2),
    order_date DATE,
    status VARCHAR(20)
);

-- Thêm dữ liệu mẫu để test kết quả
INSERT INTO customer (full_name, region) VALUES 
('Huy Đinh', 'North'), ('An Nguyễn', 'North'), 
('Bình Lê', 'South'), ('Chi Phan', 'Central');

INSERT INTO orders (customer_id, total_amount, order_date, status) VALUES 
(1, 500000, '2026-01-10', 'Shipped'),
(2, 700000, '2026-01-15', 'Pending'),
(3, 1500000, '2026-02-01', 'Shipped'),
(4, 300000, '2026-02-10', 'Shipped');

-- YÊU CẦU 1: View tổng hợp doanh thu theo khu vực
CREATE VIEW v_revenue_by_region AS
SELECT c.region, SUM(o.total_amount) AS total_revenue
FROM customer c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.region;

-- a. Truy vấn xem top 3 khu vực có doanh thu cao nhất
SELECT * FROM v_revenue_by_region
ORDER BY total_revenue DESC
LIMIT 3;

-- YÊU CẦU 2: View chi tiết đơn hàng có thể cập nhật
CREATE VIEW v_order_shipped AS
SELECT order_id, customer_id, total_amount, status
FROM orders
WHERE status = 'Shipped'
WITH CHECK OPTION;

-- a. Cập nhật status thông qua View
UPDATE v_order_shipped SET status = 'Shipped' WHERE order_id = 2; 

-- b. Kiểm tra hành vi vi phạm WITH CHECK OPTION

-- YÊU CẦU 3: View phức hợp (Nested View)
-- a. Tạo View v_revenue_above_avg hiển thị khu vực có doanh thu > trung bình toàn quốc
CREATE VIEW v_revenue_above_avg AS
SELECT * FROM v_revenue_by_region
WHERE total_revenue > (SELECT AVG(total_revenue) FROM v_revenue_by_region);

-- Xem kết quả
SELECT * FROM v_revenue_above_avg;