# SE Hannah – Backend Service

Backend nghiệp vụ (Spring Boot) của hệ thống **SE Hannah – Trợ lý AI cho Giáo dục Công nghệ Phần mềm**.

Service này phụ trách: Authentication, quản lý User, Course, Document, Community (Post/Comment), Notification.
Phần xử lý AI (RAG, Chat) thuộc về **AI Service** (FastAPI) — repo riêng.

---

## 1. Yêu cầu môi trường

| Công cụ | Phiên bản |
|---|---|
| JDK | 17+ |
| Maven | 3.9+ |
| MySQL | 8.0+ |
| Docker (tùy chọn) | mới nhất |

---

## 2. Cấu trúc thư mục

```
src/main/java/com/sehannah/backend/
├── config/          # Cấu hình Spring (Security, CORS, Swagger...)
├── controller/      # REST Controller - nhận request, trả response
├── dto/
│   ├── request/     # Object nhận dữ liệu từ client
│   └── response/    # Object trả dữ liệu cho client
├── entity/          # JPA Entity - map trực tiếp với bảng MySQL
├── enums/           # Enum dùng chung (UserRole, CourseStatus...)
├── exception/       # Exception tùy chỉnh + Global Exception Handler
├── mapper/          # MapStruct - chuyển đổi Entity <-> DTO
├── repository/      # Spring Data JPA Repository
├── security/        # JWT filter, UserDetailsService
├── service/         # Interface nghiệp vụ
│   └── impl/        # Class triển khai nghiệp vụ
└── util/            # Hàm tiện ích dùng chung

src/main/resources/
├── application.yml          # Cấu hình chính
├── application-dev.yml      # Cấu hình môi trường dev
├── application-prod.yml     # Cấu hình môi trường production
└── db/migration/            # Flyway - quản lý version database
    ├── V1__init_schema.sql
    └── V2__seed_demo_accounts.sql
```

**Quy ước:** mỗi entity nghiệp vụ đi theo bộ 4 file: `Entity` → `Repository` → `Service`/`ServiceImpl` → `Controller`. Khi thêm tính năng mới, làm theo đúng thứ tự này.

---

## 3. Setup lần đầu (cho từng thành viên)

### Bước 1 – Clone & cấu hình môi trường

```bash
git clone <repo-url>
cd se-hannah-backend
cp .env.example .env
# Mở .env và điền mật khẩu MySQL, JWT secret của máy bạn
```

### Bước 2 – Khởi động MySQL bằng Docker (khuyến nghị)

```bash
docker compose up -d
```

> Không dùng Docker? Cài MySQL 8.0 local và tạo database thủ công:
> ```sql
> CREATE DATABASE se_hannah CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
> ```

### Bước 3 – Chạy ứng dụng

```bash
mvn spring-boot:run
```

Flyway sẽ **tự động** chạy `V1__init_schema.sql` và `V2__seed_demo_accounts.sql` để tạo toàn bộ 13 bảng + tài khoản demo khi ứng dụng khởi động lần đầu. Không cần chạy file `.sql` thủ công.

### Bước 4 – Kiểm tra

- API chạy tại: `http://localhost:8080/api`
- Swagger UI: `http://localhost:8080/api/swagger-ui.html`

---

## 4. Quy tắc làm việc nhóm (Git)

- **Nhánh chính:** `main` — chỉ merge code đã review
- **Nhánh phát triển:** `develop` — tích hợp tính năng trước khi lên `main`
- **Nhánh tính năng:** `feature/ten-tinh-nang` (VD: `feature/auth-jwt`, `feature/course-crud`)

```bash
git checkout develop
git checkout -b feature/ten-tinh-nang
# ... code ...
git push origin feature/ten-tinh-nang
# Tạo Pull Request vào develop
```

**Khi thêm/sửa bảng database:** KHÔNG sửa trực tiếp `V1__init_schema.sql`. Tạo file migration mới (`V3__them_bang_xyz.sql`) để giữ lịch sử thay đổi rõ ràng — đây cũng là điểm cộng khi báo cáo đồ án.

---

## 5. Phân công gợi ý (nhóm 3 người)

| Thành viên | Module phụ trách |
|---|---|
| Người 1 | Auth + User + Notification |
| Người 2 | Course + Document + tích hợp gọi sang AI Service |
| Người 3 | Community (Post/Comment) + Learning Progress |

---

## 6. Liên kết liên quan

- AI Service (FastAPI + RAG): `<link repo AI Service>`
- Frontend (ReactJS): `<link repo Frontend>`
- Database schema gốc: `se_hannah_database.sql`
