"""
Luu va truy van vector tu ChromaDB.
Buoc thu 4 trong RAG Pipeline: Load -> Split -> Embed -> Store -> Retrieve
"""
from langchain_chroma import Chroma
from langchain_core.documents import Document

from app.core.config import settings
from app.rag.embedder import get_embedding_model


def get_vector_store() -> Chroma:
    """
    Tra ve ket noi den ChromaDB collection dung chung cho he thong.
    """
    return Chroma(
        collection_name=settings.chroma_collection_name,
        embedding_function=get_embedding_model(),
        persist_directory=settings.chroma_persist_dir,
    )


def add_documents_to_store(chunks: list[Document]) -> list[str]:
    """
    Them cac chunk da embed vao ChromaDB.
    Tra ve danh sach ID cua cac chunk vua them (de luu lai chroma_doc_id trong MySQL).
    """
    vector_store = get_vector_store()
    ids = vector_store.add_documents(chunks)
    return ids


def retrieve_relevant_chunks(query: str, course_id: int | None = None) -> list[Document]:
    """
    Tim cac chunk lien quan nhat den cau hoi cua nguoi dung (Retrieval trong RAG).
    Neu co course_id, chi tim trong pham vi tai lieu cua khoa hoc do.
    """
    vector_store = get_vector_store()

    search_kwargs = {"k": settings.retrieval_top_k}
    if course_id is not None:
        search_kwargs["filter"] = {"course_id": course_id}

    results = vector_store.similarity_search(query, **search_kwargs)
    return results
