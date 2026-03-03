from sqlalchemy import Column, String, Integer, Numeric, TIMESTAMP, ForeignKey
from sqlalchemy.orm import relationship
from database import Base

class Order(Base):
    __tablename__ = "orders"

    order_id = Column(String, primary_key=True)
    customer_id = Column(String, nullable=False)
    order_status = Column(String, nullable=False)
    order_purchase_timestamp = Column(TIMESTAMP, nullable=False)
    order_approved_at = Column(TIMESTAMP, nullable=True)
    order_delivered_carrier_date = Column(TIMESTAMP, nullable=True)
    order_delivered_customer_date = Column(TIMESTAMP, nullable=True)
    order_estimated_delivery_date = Column(TIMESTAMP, nullable=True)

    items = relationship("OrderItem", back_populates="order")


class OrderItem(Base):
    __tablename__ = "order_items"

    order_id = Column(String, ForeignKey("orders.order_id"), primary_key=True)
    order_item_id = Column(Integer, primary_key=True)
    product_id = Column(String, nullable=False)
    seller_id = Column(String, nullable=False)
    shipping_limit_date = Column(TIMESTAMP, nullable=False)
    price = Column(Numeric(10,2), nullable=False)
    freight_value = Column(Numeric(10,2), nullable=False)

    order = relationship("Order", back_populates="items")

class Customer(Base):
    __tablename__ = "customers"
    customer_id = Column(String, primary_key=True)
    customer_unique_id = Column(String, nullable=False)
    customer_zip_code_prefix = Column(Integer, nullable=False)
    customer_city = Column(String, nullable=False)
    customer_state = Column(String, nullable=False)

class Product(Base):
    __tablename__ = "products"
    product_id = Column(String, primary_key=True)
    product_category_name = Column(String)
    product_weight_g = Column(Integer)
    product_length_cm = Column(Integer)
    product_height_cm = Column(Integer)
    product_width_cm = Column(Integer)

class Seller(Base):
    __tablename__ = "sellers"
    seller_id = Column(String, primary_key=True)
    seller_zip_code_prefix = Column(Integer, nullable=False)
    seller_city = Column(String, nullable=False)
    seller_state = Column(String, nullable=False)

class OrderPayment(Base):
    __tablename__ = "order_payments"
    order_id = Column(String, ForeignKey("orders.order_id"), primary_key=True)
    payment_sequential = Column(Integer, primary_key=True)
    payment_type = Column(String, nullable=False)
    payment_installments = Column(Integer, nullable=False)
    payment_value = Column(Numeric(10,2), nullable=False)
    
class OrderReviewRating(Base):
    __tablename__ = "order_review_ratings"
    review_id = Column(String, primary_key=True)
    order_id = Column(String, ForeignKey("orders.order_id"))
    review_score = Column(Integer)
    review_creation_date = Column(TIMESTAMP)
    review_answer_timestamp = Column(TIMESTAMP)

class GeoLocation(Base):
    __tablename__ = "geo_location"

    # La PK es el prefijo, por lo que puede haber varias filas para el mismo prefijo
    # Por defecto, SQLAlchemy usa todas las columnas PK para una clave compuesta
    geolocation_zip_code_prefix = Column(Integer, primary_key=True)
    geolocation_lat = Column(Numeric(10, 6), primary_key=True) # Usamos Numeric para precisión
    geolocation_lng = Column(Numeric(10, 6), primary_key=True)
    geolocation_city = Column(String(100), nullable=False)
    geolocation_state = Column(String(100), nullable=False)
