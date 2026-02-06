from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.modules.auth.schemas import LoginRequest, TokenPair, UserCreate
from app.repositories.user_repository import UserRepository
from app.services.auth_service import AuthService

router = APIRouter(prefix='/auth', tags=['auth'])


@router.post('/register', status_code=201)
def register(payload: UserCreate, db: Annotated[Session, Depends(get_db)]):
    service = AuthService(UserRepository(db))
    user = service.register_customer(payload)
    return {'id': user.id, 'email': user.email, 'role': user.role}


@router.post('/login', response_model=TokenPair)
def login(payload: LoginRequest, db: Annotated[Session, Depends(get_db)]):
    service = AuthService(UserRepository(db))
    return service.login(payload)
