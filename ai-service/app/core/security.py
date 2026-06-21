"""
Xac thuc JWT token phat hanh boi Backend Spring Boot.
AI Service KHONG tu phat hanh token - chi xac minh token da co.
"""
import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.config import settings

bearer_scheme = HTTPBearer()


def decode_jwt_token(token: str) -> dict:
    """
    Giai ma va xac minh JWT token.
    Neu token khong hop le hoac het han se nem HTTPException 401.
    """
    try:
        payload = jwt.decode(
            token,
            settings.jwt_secret,
            algorithms=[settings.jwt_algorithm],
        )
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token da het han",
        )
    except jwt.InvalidTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token khong hop le",
        )


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
) -> dict:
    """
    Dependency dung trong cac endpoint can xac thuc.
    Vi du: def chat(user: dict = Depends(get_current_user)):
    """
    token = credentials.credentials
    payload = decode_jwt_token(token)
    return payload
