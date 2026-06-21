-- ============================================================
-- SE HANNAH – DATABASE SCHEMA (MySQL)
-- Phiên bản: 1.0
-- Mô tả: Cơ sở dữ liệu cho hệ thống Trợ lý AI Giáo dục CNPM
-- ============================================================
-- Luu y: Database 'se_hannah' va charset utf8mb4 can duoc tao truoc
-- khi chay migration nay (xem README.md - phan Setup Database)
-- ============================================================

-- ============================================================
-- 1. USERS – Người dùng hệ thống
-- ============================================================
CREATE TABLE users (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(100)  NOT NULL,
    email         VARCHAR(150)  NOT NULL UNIQUE,
    password_hash VARCHAR(255)  NOT NULL,
    role          ENUM('STUDENT','LECTURER','ADMIN') NOT NULL DEFAULT 'STUDENT',
    avatar_url    VARCHAR(500)  NULL,
    student_code  VARCHAR(20)   NULL COMMENT 'Mã sinh viên (chỉ dùng cho role STUDENT)',
    phone         VARCHAR(15)   NULL,
    bio           TEXT          NULL,
    is_active     TINYINT(1)    NOT NULL DEFAULT 1,
    is_verified   TINYINT(1)    NOT NULL DEFAULT 0,
    last_login_at DATETIME      NULL,
    created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email      (email),
    INDEX idx_role       (role),
    INDEX idx_is_active  (is_active)
) ENGINE=InnoDB COMMENT='Bảng người dùng hệ thống';

-- ============================================================
-- 2. REFRESH_TOKENS – JWT Refresh Token
-- ============================================================
CREATE TABLE refresh_tokens (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT UNSIGNED NOT NULL,
    token       VARCHAR(500)    NOT NULL UNIQUE,
    expires_at  DATETIME        NOT NULL,
    is_revoked  TINYINT(1)      NOT NULL DEFAULT 0,
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token      (token(255)),
    INDEX idx_user_id    (user_id)
) ENGINE=InnoDB COMMENT='Lưu Refresh Token JWT';

-- ============================================================
-- 3. COURSES – Khóa học
-- ============================================================
CREATE TABLE courses (
    id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    lecturer_id   BIGINT UNSIGNED NOT NULL COMMENT 'Giảng viên tạo khóa học',
    title         VARCHAR(200)    NOT NULL,
    course_code   VARCHAR(20)     NOT NULL UNIQUE COMMENT 'Mã môn học VD: SE101',
    description   TEXT            NULL,
    thumbnail_url VARCHAR(500)    NULL,
    semester      VARCHAR(20)     NULL COMMENT 'VD: HK1-2024',
    status        ENUM('DRAFT','PUBLISHED','ARCHIVED') NOT NULL DEFAULT 'DRAFT',
    created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (lecturer_id) REFERENCES users(id) ON DELETE RESTRICT,
    INDEX idx_lecturer_id (lecturer_id),
    INDEX idx_status      (status),
    INDEX idx_course_code (course_code)
) ENGINE=InnoDB COMMENT='Bảng khóa học';

-- ============================================================
-- 4. ENROLLMENTS – Sinh viên đăng ký khóa học
-- ============================================================
CREATE TABLE enrollments (
    id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id   BIGINT UNSIGNED NOT NULL,
    course_id    BIGINT UNSIGNED NOT NULL,
    enrolled_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status       ENUM('ACTIVE','DROPPED','COMPLETED') NOT NULL DEFAULT 'ACTIVE',
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id)  REFERENCES courses(id) ON DELETE CASCADE,
    UNIQUE KEY uq_enrollment (student_id, course_id),
    INDEX idx_student_id (student_id),
    INDEX idx_course_id  (course_id)
) ENGINE=InnoDB COMMENT='Sinh viên đăng ký khóa học';

-- ============================================================
-- 5. DOCUMENTS – Tài liệu học tập
-- ============================================================
CREATE TABLE documents (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    course_id       BIGINT UNSIGNED NOT NULL,
    uploaded_by     BIGINT UNSIGNED NOT NULL COMMENT 'Giảng viên upload',
    title           VARCHAR(200)    NOT NULL,
    description     TEXT            NULL,
    file_name       VARCHAR(255)    NOT NULL,
    file_url        VARCHAR(500)    NOT NULL COMMENT 'Đường dẫn file lưu trữ',
    file_type       VARCHAR(50)     NOT NULL COMMENT 'pdf, docx, mp4, jpg...',
    file_size       BIGINT UNSIGNED NOT NULL COMMENT 'Kích thước file (bytes)',
    is_indexed      TINYINT(1)      NOT NULL DEFAULT 0 COMMENT 'Đã xử lý RAG chưa',
    index_status    ENUM('PENDING','PROCESSING','DONE','FAILED') NOT NULL DEFAULT 'PENDING',
    chroma_doc_id   VARCHAR(100)    NULL COMMENT 'ID tài liệu trong ChromaDB',
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id)   REFERENCES courses(id)  ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES users(id)    ON DELETE RESTRICT,
    INDEX idx_course_id    (course_id),
    INDEX idx_is_indexed   (is_indexed),
    INDEX idx_index_status (index_status)
) ENGINE=InnoDB COMMENT='Tài liệu học tập của từng khóa học';

-- ============================================================
-- 6. CHAT_SESSIONS – Phiên hội thoại với AI
-- ============================================================
CREATE TABLE chat_sessions (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT UNSIGNED NOT NULL,
    course_id   BIGINT UNSIGNED NULL COMMENT 'NULL = chat chung, có giá trị = chat theo môn',
    title       VARCHAR(200)    NULL COMMENT 'Tiêu đề phiên chat (tự sinh hoặc người dùng đặt)',
    is_active   TINYINT(1)      NOT NULL DEFAULT 1,
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)   REFERENCES users(id)   ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE SET NULL,
    INDEX idx_user_id   (user_id),
    INDEX idx_course_id (course_id)
) ENGINE=InnoDB COMMENT='Phiên hội thoại của người dùng với AI';

-- ============================================================
-- 7. CHAT_MESSAGES – Tin nhắn trong phiên hội thoại
-- ============================================================
CREATE TABLE chat_messages (
    id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    session_id   BIGINT UNSIGNED NOT NULL,
    role         ENUM('USER','ASSISTANT') NOT NULL COMMENT 'USER = người dùng, ASSISTANT = AI',
    content      LONGTEXT        NOT NULL,
    tokens_used  INT UNSIGNED    NULL COMMENT 'Số token đã dùng (ghi lại để theo dõi chi phí)',
    source_docs  JSON            NULL COMMENT 'Danh sách tài liệu RAG đã dùng để trả lời',
    created_at   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES chat_sessions(id) ON DELETE CASCADE,
    INDEX idx_session_id (session_id),
    INDEX idx_role       (role)
) ENGINE=InnoDB COMMENT='Tin nhắn trong phiên hội thoại với AI';

-- ============================================================
-- 8. LEARNING_PROGRESS – Tiến độ học tập
-- ============================================================
CREATE TABLE learning_progress (
    id              BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id      BIGINT UNSIGNED NOT NULL,
    course_id       BIGINT UNSIGNED NOT NULL,
    document_id     BIGINT UNSIGNED NULL COMMENT 'Tài liệu đã xem',
    progress_type   ENUM('DOCUMENT_VIEWED','CHAT_ASKED','COURSE_COMPLETED') NOT NULL,
    metadata        JSON            NULL COMMENT 'Dữ liệu bổ sung tuỳ loại tiến độ',
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id)  REFERENCES users(id)     ON DELETE CASCADE,
    FOREIGN KEY (course_id)   REFERENCES courses(id)   ON DELETE CASCADE,
    FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE SET NULL,
    INDEX idx_student_id (student_id),
    INDEX idx_course_id  (course_id)
) ENGINE=InnoDB COMMENT='Theo dõi tiến độ học tập của sinh viên';

-- ============================================================
-- 9. POSTS – Bài viết cộng đồng học tập
-- ============================================================
CREATE TABLE posts (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    author_id   BIGINT UNSIGNED NOT NULL,
    course_id   BIGINT UNSIGNED NULL COMMENT 'NULL = post toàn hệ thống, có giá trị = post trong khóa học',
    title       VARCHAR(300)    NOT NULL,
    content     LONGTEXT        NOT NULL,
    post_type   ENUM('DISCUSSION','QUESTION','ANNOUNCEMENT') NOT NULL DEFAULT 'DISCUSSION',
    is_pinned   TINYINT(1)      NOT NULL DEFAULT 0,
    is_resolved TINYINT(1)      NOT NULL DEFAULT 0 COMMENT 'Dành cho post dạng QUESTION',
    view_count  INT UNSIGNED    NOT NULL DEFAULT 0,
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id)   ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE SET NULL,
    INDEX idx_author_id (author_id),
    INDEX idx_course_id (course_id),
    INDEX idx_post_type (post_type)
) ENGINE=InnoDB COMMENT='Bài viết trong cộng đồng học tập';

-- ============================================================
-- 10. COMMENTS – Bình luận bài viết
-- ============================================================
CREATE TABLE comments (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    post_id     BIGINT UNSIGNED NOT NULL,
    author_id   BIGINT UNSIGNED NOT NULL,
    parent_id   BIGINT UNSIGNED NULL COMMENT 'NULL = comment gốc, có giá trị = reply',
    content     TEXT            NOT NULL,
    is_accepted TINYINT(1)      NOT NULL DEFAULT 0 COMMENT 'Câu trả lời được chấp nhận cho QUESTION',
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id)   REFERENCES posts(id)    ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(id)    ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES comments(id) ON DELETE CASCADE,
    INDEX idx_post_id   (post_id),
    INDEX idx_author_id (author_id),
    INDEX idx_parent_id (parent_id)
) ENGINE=InnoDB COMMENT='Bình luận và trả lời trong cộng đồng';

-- ============================================================
-- 11. NOTIFICATIONS – Thông báo người dùng
-- ============================================================
CREATE TABLE notifications (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT UNSIGNED NOT NULL COMMENT 'Người nhận thông báo',
    type        ENUM('COURSE_UPDATE','NEW_DOCUMENT','NEW_COMMENT','NEW_POST','SYSTEM') NOT NULL,
    title       VARCHAR(200)    NOT NULL,
    message     TEXT            NOT NULL,
    ref_id      BIGINT UNSIGNED NULL COMMENT 'ID đối tượng liên quan (post, course...)',
    ref_type    VARCHAR(50)     NULL COMMENT 'Loại đối tượng: post, course, document...',
    is_read     TINYINT(1)      NOT NULL DEFAULT 0,
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id  (user_id),
    INDEX idx_is_read  (is_read)
) ENGINE=InnoDB COMMENT='Thông báo cho người dùng';

-- ============================================================
-- 12. AI_QUESTION_STATS – Thống kê câu hỏi cho giảng viên
-- ============================================================
CREATE TABLE ai_question_stats (
    id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    course_id    BIGINT UNSIGNED NOT NULL,
    keyword      VARCHAR(200)    NOT NULL COMMENT 'Từ khóa / chủ đề câu hỏi',
    ask_count    INT UNSIGNED    NOT NULL DEFAULT 1,
    last_asked   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    UNIQUE KEY uq_course_keyword (course_id, keyword(100)),
    INDEX idx_course_id (course_id),
    INDEX idx_ask_count (ask_count)
) ENGINE=InnoDB COMMENT='Thống kê chủ đề câu hỏi sinh viên hỏi AI theo khóa học';

-- ============================================================
-- 13. SYSTEM_LOGS – Nhật ký hoạt động hệ thống (cho Admin)
-- ============================================================
CREATE TABLE system_logs (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT UNSIGNED NULL COMMENT 'NULL nếu là hành động hệ thống',
    action      VARCHAR(100)    NOT NULL COMMENT 'VD: LOGIN, UPLOAD_DOC, DELETE_USER',
    target_type VARCHAR(50)     NULL COMMENT 'Loại đối tượng bị tác động',
    target_id   BIGINT UNSIGNED NULL COMMENT 'ID đối tượng bị tác động',
    ip_address  VARCHAR(45)     NULL,
    user_agent  VARCHAR(300)    NULL,
    metadata    JSON            NULL COMMENT 'Thông tin bổ sung',
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_id    (user_id),
    INDEX idx_action     (action),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB COMMENT='Nhật ký hoạt động hệ thống';
