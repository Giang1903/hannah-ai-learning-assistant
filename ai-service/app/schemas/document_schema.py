"""
Pydantic schemas cho API /document - upload va xu ly tai lieu RAG.
"""
from pydantic import BaseModel


class DocumentIndexRequest(BaseModel):
    document_id: int
    course_id: int
    file_path: str
    file_type: str


class DocumentIndexResponse(BaseModel):
    document_id: int
    chroma_doc_ids: list[str]
    chunks_count: int
    status: str
