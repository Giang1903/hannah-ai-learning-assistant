"""
Cau hinh trung tam cua AI Service.
Doc bien moi truong tu file .env bang pydantic-settings.
"""
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    # --- LLM Provider ---
    google_api_key: str = ""
    openai_api_key: str = ""
    llm_model: str = "gemini-2.5-flash"
    llm_temperature: float = 0.3

    # --- ChromaDB ---
    chroma_persist_dir: str = "./chroma_data"
    chroma_collection_name: str = "se_hannah_documents"

    # --- JWT (phai trung voi Backend Spring Boot) ---
    jwt_secret: str = "change_this_to_a_real_secret_key_min_32_chars"
    jwt_algorithm: str = "HS256"

    # --- Server ---
    app_host: str = "0.0.0.0"
    app_port: int = 8000

    # --- CORS ---
    cors_origins: str = "http://localhost:5173,http://localhost:3000"

    # --- Backend URL ---
    backend_service_url: str = "http://localhost:8080/api"

    # --- RAG Config ---
    chunk_size: int = 1000
    chunk_overlap: int = 200
    retrieval_top_k: int = 4

    @property
    def cors_origins_list(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",")]


# Singleton - import settings tu day o moi noi can dung
settings = Settings()
