from datetime import timedelta
from fastapi import HTTPException, status

from app.core.security import create_token, hash_password, verify_password
from app.core.settings import get_settings
from app.modules.auth.schemas import LoginRequest, TokenPair, UserCreate
from app.repositories.user_repository import UserRepository


class AuthService:
    def __init__(self, users: UserRepository):
        self.users = users
        self.settings = get_settings()

    def register_customer(self, payload: UserCreate):
        if self.users.get_by_email(payload.email):
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail='Email already registered')
        return self.users.create(
            email=payload.email,
            password_hash=hash_password(payload.password),
            full_name=payload.full_name,
            role='customer',
        )

    def login(self, payload: LoginRequest) -> TokenPair:
        user = self.users.get_by_email(payload.email)
        if not user or not verify_password(payload.password, user.password_hash):
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail='Invalid credentials')

        access_token = create_token(
            subject=str(user.id),
            expires_delta=timedelta(minutes=self.settings.access_token_expire_minutes),
            token_type='access',
            extra={'role': user.role},
        )
        refresh_token = create_token(
            subject=str(user.id),
            expires_delta=timedelta(days=self.settings.refresh_token_expire_days),
            token_type='refresh',
        )
        return TokenPair(access_token=access_token, refresh_token=refresh_token)
