# routers/reviews.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from database import SessionLocal
from models import OrderReviewRating
from schemas import ReviewOut

router = APIRouter(prefix="/reviews", tags=["reviews"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/{review_id}", response_model=ReviewOut)
def get_review(review_id: str, db: Session = Depends(get_db)):
    review = db.query(OrderReviewRating).filter(OrderReviewRating.review_id == review_id).first()
    if not review:
        raise HTTPException(status_code=404, detail="Review not found")
    return review

@router.get("/", response_model=List[ReviewOut])
def get_reviews(limit: int = 500, offset: int = 0, db: Session = Depends(get_db)):
    reviews = (db.query(OrderReviewRating)
               .limit(limit)
               .offset(offset)
               .all())
    return reviews
