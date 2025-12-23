# routers/sellers.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from database import SessionLocal
from models import Seller
from schemas import SellerOut

router = APIRouter(prefix="/sellers", tags=["sellers"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/{seller_id}", response_model=SellerOut)
def get_seller(seller_id: str, db: Session = Depends(get_db)):
    seller = db.query(Seller).filter(Seller.seller_id == seller_id).first()
    if not seller:
        raise HTTPException(status_code=404, detail="Seller not found")
    return seller

@router.get("/", response_model=List[SellerOut])
def get_sellers(limit: int = 500, offset: int = 0, db: Session = Depends(get_db)):
    sellers = (db.query(Seller)
               .limit(limit)
               .offset(offset)
               .all())
    return sellers
