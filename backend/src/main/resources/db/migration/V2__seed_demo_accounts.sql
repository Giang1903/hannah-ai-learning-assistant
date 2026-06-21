-- ============================================================
-- V2: Tai khoan demo (CHI dung cho moi truong DEV/TEST)
-- Mat khau that can duoc hash bang BCrypt tu Spring Security
-- KHONG chay migration nay tren production
-- ============================================================

-- ============================================================
-- DATA MẪU – Tài khoản mặc định
-- ============================================================
-- Mật khẩu mẫu: Admin@123 (cần hash bằng BCrypt trước khi dùng thật)
INSERT INTO users (full_name, email, password_hash, role, is_active, is_verified) VALUES
('Admin Hệ Thống',   'admin@sehannah.edu.vn',    '$2a$10$PLACEHOLDER_ADMIN_HASH',    'ADMIN',    1, 1),
('Giảng Viên Mẫu',  'lecturer@sehannah.edu.vn', '$2a$10$PLACEHOLDER_LECTURER_HASH', 'LECTURER', 1, 1),
('Sinh Viên Mẫu',   'student@sehannah.edu.vn',  '$2a$10$PLACEHOLDER_STUDENT_HASH',  'STUDENT',  1, 1);

