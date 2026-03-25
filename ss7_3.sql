-- 1. Khởi tạo cấu trúc bảng
CREATE TABLE post (
    post_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT,
    tags TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_public BOOLEAN DEFAULT TRUE
);

CREATE TABLE post_like (
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    liked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, post_id)
);

-- Thêm dữ liệu mẫu (100,000 dòng để test hiệu suất)
INSERT INTO post (user_id, content, tags, created_at, is_public)
SELECT 
    (random() * 1000)::int,
    'Bài đăng về du lịch số ' || i,
    ARRAY['travel', 'food', 'lifestyle'],
    NOW() - (random() * interval '30 days'),
    (random() > 0.2)
FROM generate_series(1, 100000) s(i);

-- YÊU CẦU 1: Tối ưu tìm kiếm theo từ khóa (Expression Index)
-- a. Tạo Expression Index với LOWER
CREATE INDEX idx_post_content_lower ON post (LOWER(content) text_pattern_ops);

-- b. So sánh hiệu suất (Huy hãy chạy và xem Execution Time)
EXPLAIN ANALYZE 
SELECT * FROM post 
WHERE is_public = TRUE AND LOWER(content) LIKE '%du lịch%';


-- YÊU CẦU 2: Lọc bài đăng theo thẻ (GIN Index)
-- a. Tạo GIN Index cho cột tags (kiểu mảng)
CREATE INDEX idx_post_tags_gin ON post USING GIN (tags);

-- b. Phân tích hiệu suất
EXPLAIN ANALYZE 
SELECT * FROM post WHERE tags @> ARRAY['travel'];

-- YÊU CẦU 3: Tìm bài đăng mới trong 7 ngày (Partial Index)
-- a. Tạo Partial Index (Chỉ index những bài công khai)
CREATE INDEX idx_post_recent_public 
ON post(created_at DESC) 
WHERE is_public = TRUE;

-- b. Kiểm tra hiệu suất
EXPLAIN ANALYZE 
SELECT * FROM post 
WHERE is_public = TRUE AND created_at >= NOW() - INTERVAL '7 days';

-- YÊU CẦU 4: Chỉ mục tổng hợp (Composite Index)
-- a. Tạo chỉ mục tổng hợp (user_id và created_at)
CREATE INDEX idx_post_user_created ON post (user_id, created_at DESC);

-- b. Kiểm tra hiệu suất khi xem "bài đăng gần đây của bạn bè"
EXPLAIN ANALYZE 
SELECT * FROM post 
WHERE user_id = 123 
ORDER BY created_at DESC;