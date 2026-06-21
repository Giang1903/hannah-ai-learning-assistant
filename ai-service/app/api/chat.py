"""
API endpoint xu ly hoi dap voi AI (RAG: Retrieve + Generate).
"""
from fastapi import APIRouter, Depends

from app.core.security import get_current_user
from app.rag.retriever import retrieve_relevant_chunks
from app.llm.gemini_client import generate_answer
from app.schemas.chat_schema import ChatRequest, ChatResponse, SourceDocument

router = APIRouter(prefix="/chat", tags=["Chat"])


@router.post("", response_model=ChatResponse)
def chat(request: ChatRequest , user: dict = Depends(get_current_user)):
    """
    Nhan cau hoi -> tim tai lieu lien quan (Retrieval) -> sinh cau tra loi (Generation).
    """
    relevant_chunks = retrieve_relevant_chunks(
        query=request.question,
        course_id=request.course_id,
    )

    answer = generate_answer(question=request.question, context_docs=relevant_chunks)

    source_documents = [
        SourceDocument(
            content=doc.page_content[:300],
            source_file=doc.metadata.get("source"),
            page=doc.metadata.get("page"),
        )
        for doc in relevant_chunks
    ]

    return ChatResponse(answer=answer, source_documents=source_documents)
