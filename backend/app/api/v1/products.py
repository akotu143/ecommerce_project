from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.dependencies import require_roles
from app.db.session import get_db
from app.modules.auth.models import User
from app.modules.catalog.models import Product
from app.modules.catalog.schemas import ProductCreate

router = APIRouter(prefix='/products', tags=['products'])


@router.post('', status_code=201)
def create_product(
    payload: ProductCreate,
    db: Annotated[Session, Depends(get_db)],
    seller: Annotated[User, Depends(require_roles('seller', 'admin'))],
):
    product = Product(**payload.model_dump(), seller_id=seller.id, status='active')
    db.add(product)
    db.commit()
    db.refresh(product)
    return {'id': product.id, 'name': product.name, 'price': product.price, 'status': product.status}


@router.get('')
def list_products(db: Annotated[Session, Depends(get_db)]):
    products = db.query(Product).filter(Product.status == 'active').limit(50).all()
    return [
        {'id': p.id, 'name': p.name, 'price': p.price, 'stock': p.stock}
        for p in products
    ]
