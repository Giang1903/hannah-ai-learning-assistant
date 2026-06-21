"""
Goi Gemini de sinh cau tra loi dua tren ngu canh da truy xuat (Generation trong RAG).
Buoc cuoi cung: Load -> Split -> Embed -> Store -> Retrieve -> Generate
"""
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.documents import Document

from app.core.config import settings

RAG_PROMPT_TEMPLATE = """Ban la SE Hannah, tro ly AI ho tro sinh vien hoc Cong nghe phan mem.
Hay tra loi cau hoi CHI dua tren ngu canh duoc cung cap duoi day.
Neu ngu canh khong du thong tin de tra loi, hay noi ro la khong tim thay thong tin lien quan,
KHONG duoc bia dat thong tin.

Ngu canh:
{context}

Cau hoi: {question}

Tra loi (bang tieng Viet, ro rang, ngan gon):"""


def get_llm_model() -> ChatGoogleGenerativeAI:
    return ChatGoogleGenerativeAI(
        model=settings.llm_model,
        temperature=settings.llm_temperature,
        google_api_key=settings.google_api_key,
    )


def generate_answer(question: str, context_docs: list[Document]) -> str:
    """
    Ghep cac chunk ngu canh vao prompt va goi LLM sinh cau tra loi.
    """
    context_text = "\n\n---\n\n".join(doc.page_content for doc in context_docs)
    prompt = RAG_PROMPT_TEMPLATE.format(context=context_text, question=question)

    llm = get_llm_model()
    response = llm.invoke(prompt)
    return response.content
