# schemas.py
from pydantic import BaseModel
from typing import List
from datetime import datetime

class OrderItemOut(BaseModel):
    order_id: str
    order_item_id: int
    product_id: str
    seller_id: str
    shipping_limit_date: datetime
    price: float
    freight_value: float

    class Config:
       from_attributes = True

class OrderOut(BaseModel):
    order_id: str
    customer_id: str
    order_status: str
    order_purchase_timestamp: datetime
    order_approved_at: datetime | None = None
    order_delivered_carrier_date: datetime | None = None
    order_delivered_customer_date: datetime | None = None
    order_estimated_delivery_date: datetime | None = None
    items: List[OrderItemOut] = []

    class Config:
        from_attributes = True

class CustomerOut(BaseModel):
    customer_id: str
    customer_unique_id: str
    customer_zip_code_prefix: int
    customer_city: str
    customer_state: str
    class Config:
        from_attributes = True

class ProductOut(BaseModel):
    product_id: str
    product_category_name: str
    product_weight_g: int
    product_length_cm: int
    product_height_cm: int
    product_width_cm: int
    class Config:
        from_attributes = True

class SellerOut(BaseModel):
    seller_id: str
    seller_zip_code_prefix: int
    seller_city: str
    seller_state: str
    class Config:
        from_attributes = True
 
class PaymentOut(BaseModel):
    order_id: str
    payment_sequential: int
    payment_type: str
    payment_installments: int
    payment_value: float
    class Config:
        from_attributes = True

class ReviewOut(BaseModel):
    review_id: str
    order_id: str
    review_score: int
    review_creation_date: datetime
    review_answer_timestamp: datetime | None = None # Puede ser nulo
    class Config:
        from_attributes = True

class GeoLocationOut(BaseModel):
    geolocation_zip_code_prefix: int
    # Mapeamos los campos Numeric a float en Pydantic
    geolocation_lat: float
    geolocation_lng: float
    geolocation_city: str
    geolocation_state: str

    class Config:
        from_attributes = True
