"""
Doc noi dung tu cac dinh dang tai lieu khac nhau (PDF, DOCX, TXT).
Day la buoc dau tien trong RAG Pipeline: Load -> Split -> Embed -> Store
"""
from langchain_community.document_loaders import (
    PyPDFLoader,
    Docx2txtLoader,
    TextLoader,
)
from langchain_core.documents import Document
from langchain_community.document_loaders import UnstructuredPowerPointLoader


def load_document(file_path: str, file_type: str) -> list[Document]:
    """
    Doc file va tra ve danh sach Document (LangChain object).
    file_type: 'pdf', 'docx', 'txt'
    """
    file_type = file_type.lower()

    if file_type == "pdf":
        loader = PyPDFLoader(file_path)
    elif file_type in ("docx", "doc"):
        loader = Docx2txtLoader(file_path)
    elif file_type == "txt":
        loader = TextLoader(
            file_path=file_path,
            encoding="utf-8",
            autodetect_encoding=True
        )
    elif file_type == "md":
        loader = TextLoader(
        file_path=file_path,
        encoding="utf-8"
    )
    elif file_type == "pptx":
        loader = UnstructuredPowerPointLoader(file_path)   
    else:
        raise ValueError(f"Dinh dang file khong duoc ho tro: {file_type}")

    documents = loader.load()
    return documents
