"""
Pydantic schemas cho API /chat - dinh nghia hinh dang du lieu vao/ra.
"""
from pydantic import BaseModel, Field


class ChatRequest(BaseModel):
    question: str = Field(..., min_length=1, description="Cau hoi cua nguoi dung")
    session_id: int | None = Field(None, description="ID phien chat (de luu lich su)")
    course_id: int | None = Field(None, description="Neu co, chi tim tai lieu trong khoa hoc nay")


class SourceDocument(BaseModel):
    content: str
    source_file: str | None = None
    page: int | None = None


class ChatResponse(BaseModel):
    answer: str
    source_documents: list[SourceDocument] = []
