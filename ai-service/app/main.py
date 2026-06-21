"""
SE Hannah - AI Service
Entry point cua FastAPI app. Chay bang: uvicorn app.main:app --reload
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.api import chat, document

app = FastAPI(
    title="SE Hannah - AI Service",
    description="Trợ lý AI cho Giáo dục Công nghệ Phần mềm - RAG Pipeline (LangChain + ChromaDB + Gemini)",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(chat.router)
app.include_router(document.router)


@app.get("/health", tags=["Health"])
def health_check():
    """Kiem tra service con song - dung cho Docker healthcheck va debug nhanh."""
    return {"status": "ok", "service": "se-hannah-ai-service"}
