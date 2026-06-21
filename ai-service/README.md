# SE Hannah – AI Service

Service xử lý AI (FastAPI) của hệ thống **SE Hannah – Trợ lý AI cho Giáo dục Công nghệ Phần mềm**.

Phụ trách: RAG Pipeline (Load → Split → Embed → Store → Retrieve → Generate), endpoint `/chat` và `/document/index`.
Phần nghiệp vụ (User, Course, Document metadata...) thuộc về **Backend** (Spring Boot) — repo riêng.

---

## 1. Cấu trúc thư mục

```
app/
├── main.py              # Entry point FastAPI
├── api/
│   ├── chat.py           # POST /chat
│   └── document.py       # POST /document/index
├── core/
│   ├── config.py         # Đọc biến môi trường (.env)
│   └── security.py       # Xác thực JWT (đồng bộ secret với Backend)
├── rag/
│   ├── loader.py          # Đọc file PDF/DOCX/TXT
│   ├── splitter.py        # Chia chunk văn bản
│   ├── embedder.py        # Tạo vector embedding (Gemini)
│   └── retriever.py       # Lưu & truy vấn ChromaDB
├── llm/
│   └── gemini_client.py   # Sinh câu trả lời (Generation)
└── schemas/               # Pydantic request/response models
```

**Luồng RAG:** `loader` → `splitter` → `embedder` (qua `retriever.add_documents_to_store`) → `retriever.retrieve_relevant_chunks` → `gemini_client.generate_answer`.

---

## 2. Setup lần đầu

### Bước 1 – Tạo virtual environment (nếu chưa có)

```bash
cd ai-service
python -m venv venv
```

### Bước 2 – Kích hoạt venv

```bash
# Windows (PowerShell)
.\venv\Scripts\Activate.ps1

# Windows (Git Bash)
source venv/Scripts/activate

# macOS / Linux
source venv/bin/activate
```

> Sau khi kích hoạt, đầu dòng lệnh sẽ hiện `(venv)`.

### Bước 3 – Cài thư viện

```bash
pip install -r requirements.txt
```

### Bước 4 – Cấu hình môi trường

```bash
cp .env.example .env
```

Mở `.env` và điền:
- `GOOGLE_API_KEY` — lấy tại [Google AI Studio](https://aistudio.google.com/apikey)
- `JWT_SECRET` — **phải giống hệt** `JWT_SECRET` bên Backend Spring Boot, nếu không AI Service sẽ không xác minh được token

### Bước 5 – Chạy thử

```bash
uvicorn app.main:app --reload
```

- Service chạy tại: `http://localhost:8000`
- Swagger UI (test API trực tiếp): `http://localhost:8000/docs`
- Kiểm tra nhanh: `http://localhost:8000/health`

---

## 3. Lưu ý quan trọng

**`venv/` KHÔNG được commit lên Git** — đã có trong `.gitignore`. Mỗi thành viên tự tạo venv riêng trên máy mình bằng Bước 1–3.

**JWT_SECRET phải đồng bộ với Backend** — AI Service không tự phát hành token, chỉ xác minh token do Backend (Spring Boot) cấp khi người dùng đăng nhập.

**`document_id` và `course_id`** được Backend gửi sang khi gọi `/document/index`, dùng để gắn metadata cho từng chunk trong ChromaDB — phục vụ việc lọc tài liệu theo khóa học khi truy vấn.

---

## 4. Việc cần làm tiếp theo

- [ ] Test thử `/chat` qua Swagger UI với 1 tài liệu mẫu đã index
- [ ] Viết thêm logic lưu `chat_messages` (gọi ngược về Backend hoặc lưu trực tiếp nếu được giao)
- [ ] Xử lý lỗi khi `GOOGLE_API_KEY` hết quota / sai key
- [ ] Thêm endpoint xóa tài liệu khỏi ChromaDB khi giảng viên xóa document

---

## 5. Liên kết liên quan

- Backend (Spring Boot): `<link repo Backend>`
- Frontend (ReactJS): `<link repo Frontend>`
