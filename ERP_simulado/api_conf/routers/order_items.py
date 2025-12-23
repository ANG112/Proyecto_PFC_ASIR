# routers/order_items.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from database import SessionLocal
from models import OrderItem
from schemas import OrderItemOut

router = APIRouter(prefix="/order-items", tags=["order-items"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 1. Endpoint de Consulta Individual (Lookup por Order ID y Item ID)
@router.get("/{order_id}/{item_id}", response_model=OrderItemOut)
def get_order_item(order_id: str, item_id: int, db: Session = Depends(get_db)):
    order_item = db.query(OrderItem).filter(
        OrderItem.order_id == order_id,
        OrderItem.order_item_id == item_id
    ).first()
    if not order_item:
        raise HTTPException(status_code=404, detail="Order item not found")
    return order_item

# 2. Endpoint para Extracción Masiva (ETL) con Paginación
@router.get("/", response_model=List[OrderItemOut])
def get_all_order_items(limit: int = 500, offset: int = 0, db: Session = Depends(get_db)):
    order_items = (db.query(OrderItem)
                   .limit(limit)
                   .offset(offset)
                   .all())
    return order_items
