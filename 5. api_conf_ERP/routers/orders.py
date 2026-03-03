# routers/orders.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from database import SessionLocal
from models import Order
from schemas import OrderOut

router = APIRouter(prefix="/orders", tags=["orders"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 1. Endpoint de Consulta Individual (Lookup por ID)
@router.get("/{order_id}", response_model=OrderOut)
def get_order(order_id: str, db: Session = Depends(get_db)):
    order = db.query(Order).filter(Order.order_id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order

# 2. Endpoint para Extracción Masiva (ETL) con Paginación
@router.get("/", response_model=List[OrderOut])
def get_all_orders(limit: int = 500, offset: int = 0, db: Session = Depends(get_db)):
    orders = (db.query(Order)
              .limit(limit)
              .offset(offset)
              .all())
    return orders
