from decimal import Decimal

from pydantic import BaseModel, Field


class ProductCreate(BaseModel):
    category_id: int
    name: str = Field(min_length=2, max_length=200)
    description: str = Field(min_length=10)
    price: Decimal = Field(gt=0)
    stock: int = Field(ge=0)


class ProductRead(ProductCreate):
    id: int
    status: str
