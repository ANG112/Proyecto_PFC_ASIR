# routers/geolocation.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from database import SessionLocal
from models import GeoLocation
from schemas import GeoLocationOut

router = APIRouter(prefix="/geolocation", tags=["geolocation"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 1. Endpoint para Extracción Masiva (ETL) con Paginación
@router.get("/", response_model=List[GeoLocationOut])
def get_locations(limit: int = 500, offset: int = 0, db: Session = Depends(get_db)):
    locations = (db.query(GeoLocation)
                 .limit(limit)
                 .offset(offset)
                 .all())
    return locations

# 2. Endpoint para Consulta por Prefijo de CP (Lookup)
@router.get("/{zip_prefix}", response_model=List[GeoLocationOut])
def get_location_by_zip(zip_prefix: int, db: Session = Depends(get_db)):
    # Nota: Un prefijo puede tener múltiples entradas
    locations = db.query(GeoLocation).filter(
        GeoLocation.geolocation_zip_code_prefix == zip_prefix
    ).all()
    
    if not locations:
        raise HTTPException(status_code=404, detail=f"GeoLocation for zip prefix {zip_prefix} not found")
        
    return locations
