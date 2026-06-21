"""
Chia van ban thanh cac chunk nho de embedding.
Buoc thu 2 trong RAG Pipeline: Load -> Split -> Embed -> Store
"""
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_core.documents import Document

from app.core.config import settings


def split_documents(documents: list[Document]) -> list[Document]:
    """
    Chia danh sach Document thanh cac chunk nho hon,
    co overlap de khong mat ngu canh giua cac chunk.
    """
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=settings.chunk_size,
        chunk_overlap=settings.chunk_overlap,
        separators=["\n\n", "\n", ". ", " ", ""],
    )
    chunks = splitter.split_documents(documents)
    return chunks
