from sqlalchemy import Column, Integer, String
from .database import Base


class User(Base):
    __tablename__ = "user"

    user_id = Column(Integer, primary_key=True, index=True)
    stripe_user_id = Column(String(64))
    subscription = Column(String(255))
