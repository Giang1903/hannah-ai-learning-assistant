"""
API endpoint xu ly tai lieu: doc file -> chia chunk -> embed -> luu ChromaDB.
Duoc Backend (Spring Boot) goi sang sau khi giang vien upload tai lieu thanh cong.
"""
from fastapi import APIRouter, Depends, HTTPException

from app.core.security import get_current_user
from app.rag.loader import load_document
from app.rag.splitter import split_documents
from app.rag.retriever import add_documents_to_store
from app.schemas.document_schema import DocumentIndexRequest, DocumentIndexResponse

router = APIRouter(prefix="/document", tags=["Document"])


@router.post("/index", response_model=DocumentIndexResponse)
def index_document(request: DocumentIndexRequest, user: dict = Depends(get_current_user)):
    """
    Quy trinh: Load -> Split -> Embed -> Store (4 buoc dau cua RAG Pipeline).
    Goi khi co tai lieu moi can dua vao he thong hoi dap.
    """
    try:
        documents = load_document(request.file_path, request.file_type)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="Khong tim thay file tai duong dan da cho")

    # Gan metadata de loc theo course_id luc retrieval
    for doc in documents:
        doc.metadata["course_id"] = request.course_id
        doc.metadata["document_id"] = request.document_id

    chunks = split_documents(documents)
    chroma_ids = add_documents_to_store(chunks)

    return DocumentIndexResponse(
        document_id=request.document_id,
        chroma_doc_ids=chroma_ids,
        chunks_count=len(chunks),
        status="DONE",
    )
