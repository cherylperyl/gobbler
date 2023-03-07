from sqlalchemy import Column, Integer, TIMESTAMP, String, DECIMAL, DATETIME, BOOLEAN
from app.database import Base


class Post(Base):
    __tablename__ = "posts"
    post_id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    title = Column(String(50), nullable=False)
    user_id = Column(Integer, nullable=False)
    image_url = Column(String(120))
    location_latitude = Column(DECIMAL(11, 6), nullable=False)
    location_longitude = Column(DECIMAL(11, 6), nullable=False)
    available_reservations = Column(Integer, nullable=False)
    total_reservations = Column(Integer, nullable=False)
    time_end = Column(DATETIME, nullable=False)
    created_at = Column(TIMESTAMP, nullable=False)
    updated_at = Column(TIMESTAMP, nullable=True)
    is_available = Column(BOOLEAN, nullable=False)
