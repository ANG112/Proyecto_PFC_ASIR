# routers/payments.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from database import SessionLocal
from models import OrderPayment
from schemas import PaymentOut

router = APIRouter(prefix="/payments", tags=["payments"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Consulta individual (por ID de Pedido, devuelve todos los pagos asociados)
@router.get("/{order_id}", response_model=List[PaymentOut])
def get_payments_by_order(order_id: str, db: Session = Depends(get_db)):
    payments = db.query(OrderPayment).filter(OrderPayment.order_id == order_id).all()
    if not payments:
        raise HTTPException(status_code=404, detail="Payments for this order not found")
    return payments

# Extracción Masiva (ETL) con Paginación
@router.get("/", response_model=List[PaymentOut])
def get_all_payments(limit: int = 500, offset: int = 0, db: Session = Depends(get_db)):
    payments = (db.query(OrderPayment)
                .limit(limit)
                .offset(offset)
                .all())
    return payments
