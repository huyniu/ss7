CREATE TABLE book (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    author VARCHAR(100),
    genre VARCHAR(50),
    price DECIMAL(10,2),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Chèn 500,000 bản ghi ngẫu nhiên
INSERT INTO book (title, author, genre, price, description)
SELECT 
    'Book Title ' || i,
    CASE 
        WHEN i % 1000 = 0 THEN 'J.K. Rowling' 
        ELSE 'Author ' || i 
    END,
    CASE 
        WHEN i % 4 = 0 THEN 'Fantasy' 
        WHEN i % 4 = 1 THEN 'Sci-Fi' 
        WHEN i % 4 = 2 THEN 'Horror' 
        ELSE 'Romance' 
    END,
    (random() * 100)::decimal(10,2),
    'This is a detailed description for book number ' || i
FROM generate_series(1, 500000) s(i);
EXPLAIN ANALYZE 
SELECT * FROM book WHERE genre = 'Fantasy';

EXPLAIN ANALYZE 
SELECT * FROM book WHERE author ILIKE '%Rowling%';

-- a. B-tree Index cho genre (Khớp chính xác)
CREATE INDEX idx_book_genre ON book(genre);

-- b. GIN Index cho author (Tìm kiếm chuỗi có ký tự % ở đầu/giữa)
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_book_author_gin ON book USING gin (author gin_trgm_ops);

-- c. GIN Index cho description (Tìm kiếm toàn văn - Full Text Search)
CREATE INDEX idx_book_desc_gin ON book USING gin(to_tsvector('english', description));
-- Sắp xếp vật lý dữ liệu trên ổ đĩa theo thể loại (genre)
CLUSTER book USING idx_book_genre;